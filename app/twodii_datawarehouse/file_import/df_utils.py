"""Utility functions for operating on dataframes for file import."""
import pandas as pd


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
    # listed column names in the sql table.
    for k, v in df.iterrows():
        # Check if we've passed our number of rows limit
        if k >= rows_to_search:
            raise Exception(f"Header not found in {rows_to_search} rows")
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
        # Check if our best match is good enough
        if best_header_match / df.shape[1] > stop_threshold:
            break
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
        if all(pd.isna(v.values) | (v.values.astype(str) == '')):
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


def clean_empty_cols(df):
    """Remove any columns which are entirely empty."""
    # externalize the column list, so we arent' iterating over a changing list
    col_list = df.columns
    for col in col_list:
        # need to cast to str, otherwise a column of all nan will throw a
        # FutureWarning because it's comparing numpy and standard types
        if all(pd.isna(df[col]) | (df[col].astype(str) == '')):
            df = df.drop(col, axis='columns')
    return df


def clean_df(df, columns_name_list, **kwargs):
    """Multipurpose dataframe cleaning.

    removes headers, footers and empty columns.
    """
    df = clean_df_header(df, columns_name_list, **kwargs)
    df = clean_df_footer(df, **kwargs)
    df = clean_empty_cols(df)
    return df
