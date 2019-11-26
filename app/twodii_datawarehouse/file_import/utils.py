"""Utility functions for file import."""
import pandas as pd
import pandas.io.sql as sqlio


def find_header_row(
    df,
    columns_name_list,
    rows_to_search=10,
    stop_threshold=0.5
):
    """Find the header, by matching row contents to list of expected names.

    rows_to_search: an upper limit of rows to search for the best header match.
    If None, function will searrch the entire df.
    stop_threshold: a threshold value (between 0 and 1) for the number of
    matched columns.
    """
    if rows_to_search is None:
        rows_to_search = df.shape[0]
    best_header_match = 0
    header_row = 0
    # loop across the rows to find the one which has the best match to the
    # listed comlumn names in the sql table.
    for k, v in df.iterrows():
        # Check if we've passed our number of rows limit
        if k == rows_to_search:
            break
        # Check if our best match is good enough
        if best_header_match / df.shape[1] > stop_threshold:
            break
        # casefold is a more aggressive version of lower, and replace the
        # spaces with underscores
        row_clean = [str(x).casefold().replace(" ", "_") for x in v.values]
        header_match = 0
        for x in columns_name_list:
            if x.casefold() in row_clean:
                header_match += 1
            if header_match > best_header_match:
                best_header_match = header_match
                header_row = k
                header_names = row_clean
    return header_row, header_names


def clean_df_header(
    df,
    columns_name_list,
    **kwargs
):
    """Clean the header and all rows above from a dataframe."""
    header_row, header_names = find_header_row(
        df,
        columns_name_list,
        **kwargs
    )

    df.columns = header_names
    # include the header row in the rows to drop
    df = df.drop(range(header_row + 1))
    return df


def find_df_footer(
    df,
    rows_to_search=20
):
    """Find the row in which a dataframe footer starts.

    rows_to_search: the number of rows in which a valid footer. None will
    search all rows.
    """
    if rows_to_search is None:
        rows_to_search = df.shape[0]
    footer_start = None
    for k, v in df.tail(rows_to_search).iterrows():
        if all(pd.isna(v.values)):
            footer_start = k
            break
    return footer_start


def clean_df_footer(df, **kwargs):
    """Clean the footer from a dataframe (anything after an empty line)."""
    footer_start = find_df_footer(df, **kwargs)
    if footer_start:
        remove_index = range(footer_start, df.index[-1] + 1)
        df = df.drop(remove_index)
    return df


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
    table_info = sqlio.read_sql(
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
    col_info = sqlio.read_sql(
        sql=query,
        con=db_connection,
        params={'tablename': tablename, 'schemaname': schemaname}
    )
    if len(col_info) == 0:
        raise Exception(f"No column info found for {schemaname}.{tablename}")
    return col_info


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
    bad_columns = [x for x in df.columns if x not in target_columns]
    if len(bad_columns):
        err_msg = ["Unexpected column names could not map to DB columns:"]
        err_msg.extend(bad_columns)
        raise Exception("\n\t".join(err_msg))


"""

importlib.reload(utils)
utils.write_df_to_db(df, db_connection, 'globaldata_power_plants')

"""
