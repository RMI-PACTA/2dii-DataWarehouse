#!/usr/bin/python
"""Update database and import data.

This is the main application file. running this file will bootstrap or update
the data warehouse database, and import any data files which need imported
"""


# External imports
import sqlalchemy as sqla

# Project imports
import twodii_datawarehouse.migrations as migrations


def main():
    """Run database migrations and import data."""
    # This will generate the db connection (from envvars), find current
    # version, run new migrations, and load any data

    print("Establishing db connection")
    connection_string = sqla.engine.url.URL(
        drivername='postgres',
        database='twodii',
        username='postgres',
        password='postgres',
        host='db',
        port='5432'
    )
    db_engine = sqla.create_engine(connection_string)

    print("Section 1: Migrations")
    migrations.run_migrations(db_engine)


if __name__ == '__main__':
    main()
