"""Tests for database utilities for file importing."""

from datetime import datetime
from tempfile import NamedTemporaryFile
import logging
import numpy.testing as npt
import os
import pandas as pd
import pathlib
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
    # See https://stackoverflow.com/a/1108850 for limits on transactions.
    connection = db_engine.connect()
    transaction = connection.begin()
    logging.debug("Creating transaction")

    def rollback_transaction():
        logging.debug("Rolling back transaction")
        transaction.rollback()

    request.addfinalizer(rollback_transaction)
    # Returning the transaction with connection intact
    return connection


def helper_create_import_history_table(db_connection):
    db_connection.execute(f"""
    CREATE SCHEMA IF NOT EXISTS {dbu.IMPORT_HISTORY_SCHEMA}
    """)
    db_connection.execute(f"""
    CREATE TABLE {dbu.IMPORT_HISTORY_SCHEMA}.{dbu.IMPORT_HISTORY_TABLE} (
        id int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
        import_time TIMESTAMP NOT NULL,
        filetype varchar(128) NOT NULL,
        filename VARCHAR(255) NOT NULL,
        filehash VARCHAR(32) NOT NULL
    );
    """)


import_history_cols = ['id', 'import_time', 'filetype', 'filename', 'filehash']


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


column_info_columns = ["column_name", "ordinal_position", "is_nullable",
                       "data_type", "constraint_type"]


def test_get_db_column_info_simple(db_transact):
    table_create_query = """
        CREATE TABLE public.test_table (
        id INT UNIQUE,
        text_col TEXT,
        float_col NUMERIC NOT NULL
        )
    """
    db_transact.execute(table_create_query)
    db_ci = dbu.get_db_column_info(
        db_connection=db_transact,
        tablename='test_table',
        schemaname='public'
    )
    npt.assert_array_equal(
        db_ci,
        pd.DataFrame([
            ["id", 1, "YES", "integer", "UNIQUE"],
            ["text_col", 2, "YES", "text", None],
            ["float_col", 3, "NO", "numeric", None],
        ])
    )
    npt.assert_array_equal(
        db_ci.columns,
        column_info_columns
    )


def test_get_db_column_info_altered(db_transact):
    table_create_query = """
        CREATE TABLE public.test_table (
        id INT UNIQUE,
        text_col TEXT,
        float_col NUMERIC NOT NULL
        )
    """
    db_transact.execute(table_create_query)
    drop_column_query = """
        ALTER TABLE public.test_table
        DROP COLUMN text_col;
        ALTER TABLE public.test_table
        ADD COLUMN bool_col BOOLEAN
    """
    db_transact.execute(drop_column_query)
    db_ci = dbu.get_db_column_info(
        db_connection=db_transact,
        tablename='test_table',
        schemaname='public'
    )
    npt.assert_array_equal(
        db_ci,
        pd.DataFrame([
            ["id", 1, "YES", "integer", "UNIQUE"],
            # Note postgres does not renumber ordinal_position
            ["float_col", 3, "NO", "numeric", None],
            ["bool_col", 4, "YES", "boolean", None],
        ])
    )
    npt.assert_array_equal(
        db_ci.columns,
        column_info_columns
    )


def test_get_db_column_info_raises_dne(db_transact):
    with pytest.raises(Exception) as excinfo:
        dbu.check_table_exists_in_db(
            db_connection=db_transact,
            tablename="tablebar",
            schemaname='schemafoo'
        )
    assert str(excinfo.value) == "Table schemafoo.tablebar not in database."


def test_add_to_import_history_simple(db_transact):
    helper_create_import_history_table(db_transact)
    f = NamedTemporaryFile()
    new_id = dbu.add_to_import_history(
        filepath=pathlib.Path(f.name),
        db_connection=db_transact,
        filetype="test1"
    )
    import_history = pd.read_sql(
        sql=f"""
            SELECT *
            from {dbu.IMPORT_HISTORY_SCHEMA}.{dbu.IMPORT_HISTORY_TABLE}
        """,
        con=db_transact
    )
    assert new_id == 1
    npt.assert_array_equal(
        import_history.columns,
        import_history_cols
    )
    # convert the timestamp to epoch, since npt can't natively compare datetime
    # objects. Rounding the epoch timestamp to the nearest second, which should
    # be okay, since most of the time these are differing by a few (9 or 10)
    # thousandths of a second.
    import_history["import_time"] = import_history["import_time"]. \
        apply(lambda x: round(x.timestamp(), 0))
    npt.assert_array_equal(
        import_history,
        pd.DataFrame([
            [
                1,  # id
                round(datetime.now().timestamp(), 0),  # "import_time" - epoch
                'test1',  # filetype
                pathlib.Path(f.name).name,  # filepath
                # d41d8cd98f00b204e9800998ecf8427e = the md5 of an empty file
                'd41d8cd98f00b204e9800998ecf8427e'  # file_hash
            ],
        ])
    )
