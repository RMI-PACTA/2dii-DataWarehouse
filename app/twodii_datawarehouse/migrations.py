"""Update structure of data warehouse database.

This module houses python code for running SQL migrations in the data
warehouse, including bootstrapping an empty database.
"""

import psycopg2.extras

METADATA_SCHEMA = 'public'
# MIGRATION_HISTORY_TABLE = 'foo'
MIGRATION_HISTORY_TABLE = 'migration_history'


def run_migrations(
    db_connection,
    migrations_path='./sql'
):
    """Bootstrap and Update database structure.

    When run, it will determine the current data warehouse version, and run any
    additional migrations, if needed. If the data warehouse has not been
    initialized, it will bootstrap the data warehouse with initialization
    scripts.
    """
    dw_version = get_dw_version(db_connection)
    dw_current_version = 0
    if dw_version is None:
        print("No Data warehouse found. Bootstrapping.")
        with db_connection.cursor() as cursor:
            cursor.execute(open("./sql/000_001_000.sql", "r").read())
    else:
        print(f"""Data Warehouse at version {dw_version}.
        Updating to {dw_current_version}""")


def get_dw_version(db_connection):
    """Determine which migrations have already been run against DB.

    returns a dict-like object (from a psycopg2 dict-like cursor)
    This will first run a check that the data warehouse has been initialized
    (and contains the migration history table). If it has, then it will
    determine the current version recorded int the migration history table, and
    report that.
    """
    print("Finding current dw_version")

    existence_check_query = f"""
    SELECT
        table_name
    FROM information_schema.tables
    WHERE table_schema = %(schema)s
    AND table_name = %(table)s
    LIMIT 1;
    """

    cur = db_connection.cursor(cursor_factory=psycopg2.extras.DictCursor)
    cur.execute(
        existence_check_query,
        {'schema': METADATA_SCHEMA, 'table': MIGRATION_HISTORY_TABLE}
    )
    table_exists = cur.fetchone()
    db_connection.rollback()

    if table_exists is None:
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

    cur.execute(max_version_query)
    max_version = cur.fetchone()
    db_connection.rollback()

    cur.close()
    return max_version


# def run_migrations(
#     db_connection,
#     migrations_path="./sql"
# ):
#     "Run all migrations that haven't already been run against the database"
#     pass
