#!/usr/bin/python
"""Update database and import data.

This is the main application file. running this file will bootstrap or update
the data warehouse database, and import any data files which need imported
"""


# External imports
import sqlalchemy as sqla
import argparse
import logging

# Project imports
import twodii_datawarehouse.migrations as migrations
import twodii_datawarehouse.file_import as fi


def main():
    """Run database migrations and import data."""
    # This will generate the db connection (from envvars), find current
    # version, run new migrations, and load any data

    logging.info("Establishing db connection")
    connection_string = sqla.engine.url.URL(
        drivername='postgres',
        database='twodii',
        username='postgres',
        password='postgres',
        host='db',
        port='5432'
    )
    logging.debug(connection_string)
    db_engine = sqla.create_engine(connection_string)

    print("Section 1: Migrations")
    migrations.run_migrations(db_engine)

    print("Section 2: Importing Files")
    fi.import_all_files(db_engine)


if __name__ == '__main__':
    # Enable logging levels, using -v or -vv flags
    parser = argparse.ArgumentParser()
    parser.add_argument('-v', '--verbose', action='count', default=0)
    args = parser.parse_args()
    levels = [logging.WARNING, logging.INFO, logging.DEBUG]
    level = levels[min(len(levels)-1, args.verbose)]  # capped number of levels
    logging.basicConfig(
        level=level,
        format="%(asctime)sZ %(levelname)s %(message)s",
        datefmt="%Y-%m-%dT%H:%M:%S"
    )
    main()
