"""Utility functions for inteeractingv with database for file import."""
from datetime import datetime
from hashlib import md5
import logging


def check_table_exists_in_db(
    db_connection,
    tablename,
    schemaname='rawdata',
    raise_exception=True
):
    """Check that the table exists in the database.

    raise_exception: if True, will raise and exception if the table is not
    found in the database.
    """
    query = """
    SELECT
        table_name
    FROM information_schema.tables
    WHERE table_name = %(tablename)s
    AND table_schema = %(schemaname)s
    """
    table_info = pd.read_sql(
        sql=query,
        con=db_connection,
        params={'tablename': tablename, 'schemaname': schemaname}
    )
    if raise_exception & (len(table_info) == 0):
        raise Exception(f"Table {schemaname}.{tablename} not in database.")
    return len(table_info) == 1


def get_db_column_info(
    db_connection,
    tablename,
    schemaname='rawdata'
):
    """Find the column names and types for a table."""
    # Before starting, check that the table exists
    check_table_exists_in_db(
        db_connection=db_connection,
        tablename=tablename,
        schemaname=schemaname,
        raise_exception=True
    )
    query = """
        SELECT
            col.column_name,
            col.ordinal_position,
            col.is_nullable,
            col.data_type,
            tc.constraint_type
        FROM information_schema.columns AS col
            LEFT JOIN information_schema.key_column_usage AS ccu ON (
                col.column_name = ccu.column_name
                AND col.table_name = ccu.table_name
                AND col.table_schema = ccu.table_schema
                AND col.table_catalog = ccu.table_catalog
            )
            LEFT JOIN information_schema.table_constraints AS tc ON (
                ccu.constraint_name = tc.constraint_name
                AND ccu.constraint_catalog = tc.constraint_catalog
            )
        WHERE col.table_name = %(tablename)s
        AND col.table_schema = %(schemaname)s
        ORDER BY ordinal_position
    """
    col_info = pd.read_sql(
        sql=query,
        con=db_connection,
        params={'tablename': tablename, 'schemaname': schemaname}
    )
    if len(col_info) == 0:
        raise Exception(f"No column info found for {schemaname}.{tablename}")
    return col_info


def add_to_import_history(
    filepath,
    db_connection,
    filetype
):
    """Write to the import history table."""
    with filepath.open('rb') as file:
        filehash = md5(file.read())
    import_history_data = {
            "filehash": filehash.hexdigest(),
            "filename": filepath.name,
            "filetype": filetype,
            "import_time": datetime.now()
        }
    pd.DataFrame(data=import_history_data, index=[0]).to_sql(
        con=db_connection,
        name=IMPORT_HISTORY_TABLE,
        schema=IMPORT_HISTORY_SCHEMA,
        if_exists='append',
        index=False
    )
    # Using an fstring for table name here, because it's a parameter.
    new_import_query = f"""
        SELECT
        id
        FROM {IMPORT_HISTORY_SCHEMA}.{IMPORT_HISTORY_TABLE}
        WHERE filehash = %(filehash)s
        AND filename = %(filename)s
        AND filetype = %(filetype)s
        AND import_time = %(import_time)s
    """
    new_import_id = pd.read_sql(
        con=db_connection,
        sql=new_import_query,
        params=import_history_data
    )
    if len(new_import_id) > 1:
        raise Exception(f"Multiple matches for new import id: {new_import_id}")
    new_import_id_int = int(new_import_id['id'][0])
    return new_import_id_int


def check_if_file_imported(filepath, db_connection):
    """Determine if a file has already been imported."""
    logging.debug(f"Checking import status for {filepath}")
    with filepath.open('rb') as file:
        filehash = md5(file.read())
    import_history_data = {
            "filehash": filehash.hexdigest(),
            "filename": filepath.name
        }
    find_import_query = f"""
        SELECT
        id
        FROM {IMPORT_HISTORY_SCHEMA}.{IMPORT_HISTORY_TABLE}
        WHERE filehash = %(filehash)s
        AND filename = %(filename)s
        ORDER BY import_time DESC, id DESC
        LIMIT 1
    """
    import_id = pd.read_sql(
        con=db_connection,
        sql=find_import_query,
        params=import_history_data
    )
    logging.debug(import_id)
    if len(import_id):
        return int(import_id['id'][0])
    else:
        return None


def write_df_to_db(
    df,
    db_connection,
    tablename,
    schemaname='rawdata'
):
    """Write the contents of a dataframe to the database."""
    target_column_info = get_db_column_info(
        db_connection=db_connection,
        tablename=tablename,
        schemaname=schemaname
    )
    target_columns = list(target_column_info['column_name'])

    # Check that all of the columns in df have a column to go to in the target
    # table
    bad_columns = [x for x in df.columns if x not in target_columns]
    if len(bad_columns):
        err_msg = ["Unexpected column names could not map to DB columns:"]
        err_msg.extend(bad_columns)
        raise Exception("\n\t".join(err_msg))

    # Actually write the table to the database
    df.to_sql(
        con=db_connection,
        name=tablename,
        schema=schemaname,
        if_exists='append',
        index=False,
        # method='multi'
    )
