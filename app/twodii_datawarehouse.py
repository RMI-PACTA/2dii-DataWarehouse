#!/usr/bin/python
"""Update database and import data.

This is the main application file. running this file will bootstrap or update
the data warehouse database, and import any data files which need imported
"""


# External imports
import psycopg2


# Project imports
import twodii_datawarehouse.migrations as migrations


def main():
    """Run database migrations and import data."""
    # This will generate the db connection (from envvars), find current
    # version, run new migrations, and load any data
    print("Establishing db connection")
    db_connection = psycopg2.connect(
        dbname='twodii',
        user='postgres',
        password='postgres',
        host='db'
    )

    print("Section 1: Migrations")
    migrations.run_migrations(db_connection)

    db_connection.close()


if __name__ == '__main__':
    main()
