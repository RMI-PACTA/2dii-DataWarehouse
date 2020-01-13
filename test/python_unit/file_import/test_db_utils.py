"""Tests for database utilities for file importing."""
import os
import pytest
import sqlalchemy as sqla
import twodii_datawarehouse.file_import.db_utils as dbu


@pytest.fixture
def connection_string():
    """Provide connection information for the test postgres connection."""
    return sqla.engine.url.URL(
        drivername='postgresql',
        database=os.getenv('POSTGRES_DB'),
        username=os.getenv('POSTGRES_USER'),
        password=os.getenv('POSTGRES_PASSWORD'),
        host=os.getenv('POSTGRES_HOST'),
        port='5432'
    )


@pytest.fixture
def db_engine(connection_string):
    """Create connection object for the test database."""
    return sqla.create_engine(connection_string)


# @pytest.fixture
# def db_transact(db_engine):
#     """Create a transaction which cleans up after itself by rolling back"""
#     with db_engine.connect().begin() as db_con:
#         yield db_con
#         db_con.rollback()


# def teardown_function():
#     print('tearing down')


def test_check_table_exists_schema_does_not_exist(db_engine):
    with pytest.raises(Exception) as excinfo:
        dbu.check_table_exists_in_db(
            db_connection=db_engine,
            tablename="tablebar",
            schemaname='schemafoo',
            raise_exception=True
        )
    assert str(excinfo.value) == "Table schemafoo.tablebar not in database."


def test_check_table_exists_table_does_not_exist(db_engine):
    with pytest.raises(Exception) as excinfo:
        dbu.check_table_exists_in_db(
            db_connection=db_engine,
            tablename="tablebar",
            schemaname="public",
            raise_exception=True
        )
    assert str(excinfo.value) == "Table public.tablebar not in database."
