"""Tests for database utilities for file importing."""
import logging
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


@pytest.fixture
def db_transact(request, db_engine):
    """Create a transaction which cleans up after itself by rolling back"""
    connection = db_engine.connect()
    transaction = connection.begin()
    logging.debug("Creating transaction")

    def rollback_transaction():
        logging.debug("Rolling back transaction")
        transaction.rollback()

    request.addfinalizer(rollback_transaction)
    # Returning the transaction with connection intact
    return connection


def test_check_table_exists_schema_does_not_exist_raise(db_engine):
    with pytest.raises(Exception) as excinfo:
        dbu.check_table_exists_in_db(
            db_connection=db_engine,
            tablename="tablebar",
            schemaname='schemafoo'
        )
    assert str(excinfo.value) == "Table schemafoo.tablebar not in database."


def test_check_table_exists_table_does_not_exist_raise(db_engine):
    with pytest.raises(Exception) as excinfo:
        dbu.check_table_exists_in_db(
            db_connection=db_engine,
            tablename="tablebar",
            schemaname="public"
        )
    assert str(excinfo.value) == "Table public.tablebar not in database."


def test_check_table_exists_schema_does_not_exist_value(db_engine):
    table_found = dbu.check_table_exists_in_db(
        db_connection=db_engine,
        tablename="tablebar",
        schemaname='schemafoo',
        raise_exception=False
    )
    assert table_found is False


def test_check_table_exists_table_does_not_exist_value(db_engine):
    table_found = dbu.check_table_exists_in_db(
        db_connection=db_engine,
        tablename="tablebar",
        schemaname="public",
        raise_exception=False
    )
    assert table_found is False


# The information_schema.columns table always exists on postgres
def test_check_table_exists_table_exist_engine_raise(db_engine):
    table_found = dbu.check_table_exists_in_db(
        db_connection=db_engine,
        tablename="columns",
        schemaname="information_schema"
    )
    assert table_found is True


def test_check_table_exists_table_exist_engine_value(db_engine):
    table_found = dbu.check_table_exists_in_db(
        db_connection=db_engine,
        tablename="columns",
        schemaname="information_schema",
        raise_exception=False
    )
    assert table_found is True


def test_check_table_exists_table_exist_engine_default(db_engine):
    table_found = dbu.check_table_exists_in_db(
        db_connection=db_engine,
        tablename="columns",
        schemaname="information_schema",
    )
    assert table_found is True
