"""Update structure of data warehouse database.

This module houses python code for running SQL migrations in the data
warehouse, including bootstrapping an empty database.
"""

import hashlib
import logging
import pandas as pd
import pathlib
import re

METADATA_SCHEMA = 'public'
MIGRATION_HISTORY_TABLE = 'dw_version'


def run_migrations(
    db_engine,
    migrations_path=pathlib.Path('/tmp', 'sql')
):
    """Bootstrap and Update database structure.

    Returns a tuple of the latest version run

    When run, it will determine the current data warehouse version, and run any
    additional migrations, if needed. If the data warehouse has not been
    initialized, it will bootstrap the data warehouse with initialization
    scripts.
    """
    hasher = hashlib.md5

    dw_current_version = _get_dw_version(db_engine)
    if dw_current_version is None:
        logging.warning("No Data warehouse found. Bootstrapping.")
        dw_current_version = (0, 0, 0)
    else:
        logging.info(f"Data Warehouse at version {dw_current_version}.")

    migration_files = list(migrations_path.glob("**/*.sql"))
    migrations_to_run = []
    for x in migration_files:
        x_version = _parse_filename_version_number(x)
        if x_version is not None and x_version > dw_current_version:
            migrations_to_run.append(x)
    migrations_to_run.sort(key=_parse_filename_version_number)

    # check that migration version numbers are unique
    versions_check = []
    for x in migrations_to_run:
        if _parse_filename_version_number(x) in versions_check:
            raise Exception(f'Duplicate migration version: {x}')
        else:
            versions_check.append(_parse_filename_version_number(x))

    update_migration_history_query = f"""INSERT INTO
    {METADATA_SCHEMA}.{MIGRATION_HISTORY_TABLE}
    (major, minor, patch, filename, filehash, migration_time) VALUES
    (%(major)s, %(minor)s, %(patch)s, %(filename)s, %(filehash)s, now())
    """

    for x in migrations_to_run:
        latest_migration = _parse_filename_version_number(x)
        logging.info(f"Running migration for version: {latest_migration}")
        with x.open('rb') as file:
            file_query = file.read()
        with db_engine.begin() as db_con:
            logging.debug(f"Running Query:\n{file_query}")
            db_con.execute(file_query.decode('utf-8'))
            history_dict = {
                'major': latest_migration[0],
                'minor': latest_migration[1],
                'patch': latest_migration[2],
                'filename': x.name,
                'filehash': hasher(file_query).hexdigest()
            }
            logging.debug(f"Updating migration history:{history_dict}")
            db_con.execute(
                update_migration_history_query,
                history_dict
            )
        dw_current_version = _get_dw_version(db_engine)
    return dw_current_version


def _get_dw_version(db_engine):
    """Determine which migrations have already been run against DB.

    returns a dict-like object (from a psycopg2 dict-like cursor)
    This will first run a check that the data warehouse has been initialized
    (and contains the migration history table). If it has, then it will
    determine the current version recorded int the migration history table, and
    report that.
    """
    logging.info("Finding current dw_version")

    existence_check_query = f"""
    SELECT
        table_name
    FROM information_schema.tables
    WHERE table_schema = %(schema)s
    AND table_name = %(table)s
    LIMIT 1;
    """

    logging.debug(f"searching for {METADATA_SCHEMA}.{MIGRATION_HISTORY_TABLE}")
    table_exists = pd.read_sql(
        con=db_engine,
        sql=existence_check_query,
        params={'schema': METADATA_SCHEMA, 'table': MIGRATION_HISTORY_TABLE}
    )

    if len(table_exists) == 0:
        logging.warning(f"Migration history table not found.")
        return None

    # Passing the name of a table is the only time we want to use string
    # interpolation to pass paramaters. It's okay here because its interpolated
    # to a static parameter.
    max_version_query = f"""
    SELECT
        major,
        minor,
        patch
    FROM {METADATA_SCHEMA}.{MIGRATION_HISTORY_TABLE}
    ORDER BY
        major DESC,
        minor DESC,
        patch DESC
    LIMIT 1;
    """

    max_version_df = pd.read_sql(
        con=db_engine,
        sql=max_version_query,
        params={'schema': METADATA_SCHEMA, 'table': MIGRATION_HISTORY_TABLE}
    )

    max_version = (
        max_version_df['major'][0],
        max_version_df['minor'][0],
        max_version_df['patch'][0]
    )

    logging.debug(max_version)
    return max_version


def _parse_filename_version_number(filepath):
    filename = filepath.stem
    version_string = re.search(r"\d+_\d+_\d+", filename)
    if version_string is None:
        return None
    versions = version_string.group(0).split('_')
    return tuple(map(int, versions))
