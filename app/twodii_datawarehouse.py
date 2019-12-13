#!/usr/bin/python
"""Update database and import data.

This is the main application file. running this file will bootstrap or update
the data warehouse database, and import any data files which need imported
"""


# External imports
import sqlalchemy as sqla
import argparse
import logging
import os

# Project imports
import twodii_datawarehouse.migrations as migrations
import twodii_datawarehouse.file_import as fi


def main(migrations_only=False):
    """Run database migrations and import data."""
    # This will generate the db connection (from envvars), find current
    # version, run new migrations, and load any data

    logging.info("Establishing db connection")
    connection_string = sqla.engine.url.URL(
        drivername='postgres',
        database=os.getenv('POSTGRES_DB'),
        username=os.getenv('POSTGRES_USER'),
        password=os.getenv('POSTGRES_PASSWORD'),
        host=os.getenv('POSTGRES_HOST'),
        port='5432'
    )
    logging.debug(connection_string)
    db_engine = sqla.create_engine(connection_string)

    print("Section 1: Migrations")
    migrations.run_migrations(db_engine)
    if migrations_only:
        logging.warning("only running migrations.")
        return 0

    print("Section 2: Importing Files")
    fi.import_all_files(db_engine)


if __name__ == '__main__':
    # Enable logging levels, using -v or -vv flags
    parser = argparse.ArgumentParser()
    parser.add_argument('-v', '--verbose', action='count', default=0)
    parser.add_argument(
        '-m', '--migrations-only',
        dest='migrations_only', action='store_true'
    )
    args = parser.parse_args()
    levels = [logging.WARNING, logging.INFO, logging.DEBUG]
    level = levels[min(len(levels)-1, args.verbose)]  # capped number of levels
    logging.basicConfig(
        level=level,
        format="%(asctime)sZ %(levelname)s %(message)s",
        datefmt="%Y-%m-%dT%H:%M:%S"
    )
    main(args.migrations_only)
