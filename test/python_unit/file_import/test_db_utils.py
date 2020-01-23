"""Tests for database utilities for file importing."""

from datetime import datetime
from freezegun import freeze_time
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


sql_dir = pathlib.Path("/", "usr", "src", "sql")


def helper_create_import_history_table(db_connection):
    filepath = pathlib.Path(
        sql_dir,
        "000_001_001-rawdata_import_history.sql"
    )
    with filepath.open() as file:
        db_connection.execute(file.read())


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


@freeze_time("1970-01-02 03:04:05", auto_tick_seconds=15)
def test_add_to_import_history_simple(db_transact):
    helper_create_import_history_table(db_transact)
    f = NamedTemporaryFile(suffix=".csv")
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
    npt.assert_array_equal(
        import_history,
        pd.DataFrame([
            [
                1,  # id
                datetime(1970, 1, 2, 3, 4, 5),
                'test1',  # filetype
                pathlib.Path(f.name).name,  # filename
                # d41d8cd98f00b204e9800998ecf8427e = the md5 of an empty file
                'd41d8cd98f00b204e9800998ecf8427e'  # filehash
            ],
        ])
    )


@freeze_time("1970-01-02 03:04:05", auto_tick_seconds=15)
def test_add_to_import_history_second_file(db_transact):
    helper_create_import_history_table(db_transact)
    f = NamedTemporaryFile(suffix=".csv")
    new_id = dbu.add_to_import_history(
        filepath=pathlib.Path(f.name),
        db_connection=db_transact,
        filetype="test1"
    )
    assert new_id == 1
    f2 = NamedTemporaryFile(suffix=".csv")
    f2.write(b"Hello, World")
    # Rewind the file head pointer to the beginning, to simulate reading the
    # file fresh.
    f2.seek(0)
    new_id = dbu.add_to_import_history(
        filepath=pathlib.Path(f2.name),
        db_connection=db_transact,
        filetype="test2"
    )
    assert new_id == 2
    import_history = pd.read_sql(
        sql=f"""
            SELECT *
            from {dbu.IMPORT_HISTORY_SCHEMA}.{dbu.IMPORT_HISTORY_TABLE}
        """,
        con=db_transact
    )
    npt.assert_array_equal(
        import_history.columns,
        import_history_cols
    )
    npt.assert_array_equal(
        import_history,
        pd.DataFrame([
            [
                1,  # id
                datetime(1970, 1, 2, 3, 4, 5),
                'test1',  # filetype
                pathlib.Path(f.name).name,  # filename
                # d41d8cd98f00b204e9800998ecf8427e = the md5 of an empty file
                'd41d8cd98f00b204e9800998ecf8427e'  # filehash
            ],
            [
                2,  # id
                datetime(1970, 1, 2, 3, 4, 20),  # add 15 sec for tick()
                'test2',  # filetype
                pathlib.Path(f2.name).name,  # filename
                '82bb413746aee42f89dea2b59614f9ef'  # filehash= b"Hello, World"
            ],
        ])
    )


def test_add_to_import_history_reimport_same_file(db_transact):
    helper_create_import_history_table(db_transact)
    f = NamedTemporaryFile(suffix=".csv")
    new_id = dbu.add_to_import_history(
        filepath=pathlib.Path(f.name),
        db_connection=db_transact,
        filetype="test1"
    )
    assert new_id == 1
    with pytest.raises(Exception) as excinfo:
        new_id = dbu.add_to_import_history(
            filepath=pathlib.Path(f.name),
            db_connection=db_transact,
            filetype="test1"
        )
    assert "Key (filehash)=(d41d8cd98f00b204e9800998ecf8427e) already exists" \
        in str(excinfo.value)


@freeze_time("1970-01-02 03:04:05", auto_tick_seconds=15)
def test_add_to_import_history_reimport_altered_file(db_transact):
    helper_create_import_history_table(db_transact)
    f = NamedTemporaryFile(suffix=".csv")
    new_id = dbu.add_to_import_history(
        filepath=pathlib.Path(f.name),
        db_connection=db_transact,
        filetype="test1"
    )
    assert new_id == 1
    f.write(b"Hello, World")
    f.seek(0)
    new_id = dbu.add_to_import_history(
        filepath=pathlib.Path(f.name),
        db_connection=db_transact,
        filetype="test1"
    )
    assert new_id == 2
    import_history = pd.read_sql(
        sql=f"""
            SELECT *
            from {dbu.IMPORT_HISTORY_SCHEMA}.{dbu.IMPORT_HISTORY_TABLE}
        """,
        con=db_transact
    )
    npt.assert_array_equal(
        import_history.columns,
        import_history_cols
    )
    npt.assert_array_equal(
        import_history,
        pd.DataFrame([
            [
                1,  # id
                datetime(1970, 1, 2, 3, 4, 5),
                'test1',  # filetype
                pathlib.Path(f.name).name,  # filename
                # d41d8cd98f00b204e9800998ecf8427e = the md5 of an empty file
                'd41d8cd98f00b204e9800998ecf8427e'  # filehash
            ],
            [
                2,  # id
                datetime(1970, 1, 2, 3, 4, 20),
                'test1',  # filetype
                pathlib.Path(f.name).name,  # filename
                '82bb413746aee42f89dea2b59614f9ef'  # filehash= b"Hello, World"
            ],
        ])
    )


def test_add_to_import_history_reimport_same_content(db_transact):
    helper_create_import_history_table(db_transact)
    f = NamedTemporaryFile(suffix=".csv")
    new_id = dbu.add_to_import_history(
        filepath=pathlib.Path(f.name),
        db_connection=db_transact,
        filetype="test1"
    )
    assert new_id == 1
    f2 = NamedTemporaryFile(suffix=".csv")
    with pytest.raises(Exception) as excinfo:
        new_id = dbu.add_to_import_history(
            filepath=pathlib.Path(f2.name),
            db_connection=db_transact,
            filetype="test1"
        )
    assert "Key (filehash)=(d41d8cd98f00b204e9800998ecf8427e) already exists" \
        in str(excinfo.value)


def test_add_to_import_history_reimport_same_content_diff_type(db_transact):
    helper_create_import_history_table(db_transact)
    f = NamedTemporaryFile(suffix=".csv")
    new_id = dbu.add_to_import_history(
        filepath=pathlib.Path(f.name),
        db_connection=db_transact,
        filetype="test1"
    )
    assert new_id == 1
    f2 = NamedTemporaryFile(suffix=".csv")
    with pytest.raises(Exception) as excinfo:
        new_id = dbu.add_to_import_history(
            filepath=pathlib.Path(f2.name),
            db_connection=db_transact,
            filetype="test2"
        )
    assert "Key (filehash)=(d41d8cd98f00b204e9800998ecf8427e) already exists" \
        in str(excinfo.value)


def test_check_if_file_imported_simple(db_transact):
    helper_create_import_history_table(db_transact)
    f = NamedTemporaryFile(suffix=".csv")
    filepath = pathlib.Path(f.name)
    new_id = dbu.add_to_import_history(
        filepath=filepath,
        db_connection=db_transact,
        filetype="test1"
    )
    assert new_id == 1
    is_imported = dbu.check_if_file_imported(filepath, db_transact)
    assert is_imported == 1


def test_check_if_file_imported_simple_not(db_transact):
    helper_create_import_history_table(db_transact)
    f = NamedTemporaryFile(suffix=".csv")
    filepath = pathlib.Path(f.name)
    is_imported = dbu.check_if_file_imported(filepath, db_transact)
    assert is_imported is None


def test_check_if_file_imported_simple_second_file(db_transact):
    helper_create_import_history_table(db_transact)
    f = NamedTemporaryFile(suffix=".csv")
    new_id = dbu.add_to_import_history(
        filepath=pathlib.Path(f.name),
        db_connection=db_transact,
        filetype="test1"
    )
    assert new_id == 1
    f2 = NamedTemporaryFile(suffix=".csv")
    filepath2 = pathlib.Path(f2.name)
    f2.write(b"Hello, World")
    f2.seek(0)
    new_id = dbu.add_to_import_history(
        filepath=pathlib.Path(f2.name),
        db_connection=db_transact,
        filetype="test2"
    )
    assert new_id == 2
    is_imported = dbu.check_if_file_imported(filepath2, db_transact)
    assert is_imported == 2


def test_check_if_file_imported_second_file_not(db_transact):
    helper_create_import_history_table(db_transact)
    f = NamedTemporaryFile(suffix=".csv")
    new_id = dbu.add_to_import_history(
        filepath=pathlib.Path(f.name),
        db_connection=db_transact,
        filetype="test1"
    )
    assert new_id == 1
    f2 = NamedTemporaryFile(suffix=".csv")
    filepath2 = pathlib.Path(f2.name)
    f2.write(b"Hello, World")
    f2.seek(0)
    is_imported = dbu.check_if_file_imported(filepath2, db_transact)
    assert is_imported is None


def test_check_if_file_imported_second_file_same_hash_not(db_transact):
    helper_create_import_history_table(db_transact)
    f = NamedTemporaryFile(suffix=".csv")
    new_id = dbu.add_to_import_history(
        filepath=pathlib.Path(f.name),
        db_connection=db_transact,
        filetype="test1"
    )
    assert new_id == 1
    f2 = NamedTemporaryFile(suffix=".csv")
    filepath2 = pathlib.Path(f2.name)
    is_imported = dbu.check_if_file_imported(filepath2, db_transact)
    assert is_imported is None


def test_check_if_file_imported_altered_file(db_transact):
    helper_create_import_history_table(db_transact)
    f = NamedTemporaryFile(suffix=".csv")
    new_id = dbu.add_to_import_history(
        filepath=pathlib.Path(f.name),
        db_connection=db_transact,
        filetype="test1"
    )
    assert new_id == 1
    f2 = NamedTemporaryFile(suffix=".csv")
    filepath2 = pathlib.Path(f2.name)
    is_imported = dbu.check_if_file_imported(filepath2, db_transact)
    assert is_imported is None


def test_check_if_file_imported_reimport_altered_file(db_transact):
    helper_create_import_history_table(db_transact)
    f = NamedTemporaryFile(suffix=".csv")
    filepath = pathlib.Path(f.name)
    new_id = dbu.add_to_import_history(
        filepath=filepath,
        db_connection=db_transact,
        filetype="test1"
    )
    assert new_id == 1
    f.write(b"Hello, World")
    f.seek(0)
    new_id = dbu.add_to_import_history(
        filepath=filepath,
        db_connection=db_transact,
        filetype="test1"
    )
    assert new_id == 2
    is_imported = dbu.check_if_file_imported(filepath, db_transact)
    assert is_imported == 2


def test_write_df_to_db_simple(db_transact):
    table_create_query = """
        CREATE TABLE public.test_table (
        id INT UNIQUE,
        text_col TEXT,
        float_col NUMERIC NOT NULL
        )
    """
    db_transact.execute(table_create_query)
    test_df = pd.DataFrame(
        data=[
            [1, "foo", 1.01],
            [2, "bar", 2.02],
            [3, "baz", 3.03],
        ],
        columns=["id", "text_col", "float_col"]
    )
    dbu.write_df_to_db(
        df=test_df,
        db_connection=db_transact,
        tablename='test_table',
        schemaname='public'
    )
    db_results = pd.read_sql(
        sql="SELECT * from public.test_table",
        con=db_transact
    )
    npt.assert_array_equal(
        db_results,
        test_df
    )
    npt.assert_array_equal(
        db_results.columns,
        ["id", "text_col", "float_col"]
    )


def test_write_df_to_db_multiple(db_transact):
    table_create_query = """
        CREATE TABLE public.test_table (
        id INT UNIQUE,
        text_col TEXT,
        float_col NUMERIC NOT NULL
        )
    """
    db_transact.execute(table_create_query)
    test_df = pd.DataFrame(
        data=[
            [1, "foo", 1.01],
            [2, "bar", 2.02],
            [3, "baz", 3.03],
        ],
        columns=["id", "text_col", "float_col"]
    )
    dbu.write_df_to_db(
        df=test_df,
        db_connection=db_transact,
        tablename='test_table',
        schemaname='public'
    )
    test_df2 = pd.DataFrame(
        data=[
            [4, "foo", 4.03],
            [5, "bar", 5.05],
            [6, "baz", 6.06],
        ],
        columns=["id", "text_col", "float_col"]
    )
    dbu.write_df_to_db(
        df=test_df2,
        db_connection=db_transact,
        tablename='test_table',
        schemaname='public'
    )
    db_results = pd.read_sql(
        sql="SELECT * from public.test_table",
        con=db_transact
    )
    npt.assert_array_equal(
        db_results,
        test_df.append(test_df2)
    )
    npt.assert_array_equal(
        db_results.columns,
        ["id", "text_col", "float_col"]
    )
