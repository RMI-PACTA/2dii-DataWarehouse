"""Utility functions for file import."""


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
    """Cleans the header and all rows above from a dataframe."""
    header_row, header_names = find_header_row(
        df,
        columns_name_list,
        **kwargs
    )

    df.columns = header_names
    # include the header row in the rows to drop
    df = df.drop(range(header_row + 1))


def find_df_footer(
    df,
    rows_to_search=20
):
    """Find the row in which a dataframe footer starts.

    rows_to_search: the number of rows in which a valid footer. None will
    search all rows"""
    if rows_to_search is None:
        rows_to_search = df.shape[0]
    for k, v in df.tail(rows_to_search).iterrows():
        # TODO: iterate over row contents, and ensure that all are
        # pd.isnan(thing)
