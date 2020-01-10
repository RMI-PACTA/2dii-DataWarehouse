"""Testing utilities for file import."""
import numpy as np
import numpy.testing as npt
import pandas as pd
import pytest
import twodii_datawarehouse.file_import.utils as utils

# Test frame with header on first row, no footers
df_test_simple = pd.DataFrame([
    ["intA", "strB", "floatC", "intD", "strE", "floatF"],
    [4, "foo", 1.23, 1, "", 4.8],
    [3, "bar", 1.33, 2, "stringX", 4.8],
    [10, "baz", 1.43, 0, "stringY", 2.8],
    [8, "bax", "", -1, "", ""],
    ["", "foo", 1.53, "", "stringZ", 0.8],
    [4, "", 1.63, 1, "", ""]
])

# Test frame with header on first row, no footers
df_test_small_header = pd.DataFrame([
    ["Sample", "", "", "", "", ""],
    ["", "Header", "", "", "", ""],
    ["", "", "Info", "", "", ""],
    ["intA", "strB", "floatC", "intD", "strE", "floatF"],
    [4, "foo", 1.23, 1, "", 4.8],
    [3, "bar", 1.33, 2, "stringX", 4.8],
    [10, "baz", 1.43, 0, "stringY", 2.8],
    [8, "bax", "", -1, "", ""],
    ["", "foo", 1.53, "", "stringZ", 0.8],
    [4, "", 1.63, 1, "", ""]
])

# Test frame with header on first row, no footers
df_test_long_header = pd.DataFrame([
    ["0", "Sample", "", "", "", ""],
    ["1", "Header", "", "", "", ""],
    ["2", "Info", "", "", "", ""],
    ["3", "", "", "", "", ""],
    ["4", "", "", "", "", ""],
    ["5", "", "", "", "", ""],
    ["6", "", "", "", "", ""],
    ["7", "", "", "", "", ""],
    ["8", "", "", "", "", ""],
    ["9", "", "", "", "", ""],
    ["10", "", "", "", "", ""],
    ["11", "", "", "", "", ""],
    ["intA", "strB", "floatC", "intD", "strE", "floatF"],
    [4, "foo", 1.23, 1, "", 4.8],
    [3, "bar", 1.33, 2, "stringX", 4.8],
    [10, "baz", 1.43, 0, "stringY", 2.8],
    [8, "bax", "", -1, "", ""],
    ["", "foo", 1.53, "", "stringZ", 0.8],
    [4, "", 1.63, 1, "", ""]
])

# Test frame with header on first row, no footers
df_test_multiple_headers = pd.DataFrame([
    ["intA", "strB", "", "", "", ""],
    [4, "foo", 1.23, 1, "", 4.8],
    [3, "bar", 1.33, 2, "stringX", 4.8],
    [10, "baz", 1.43, 0, "stringY", 2.8],
    ["intA", "strB", "floatC", "intD", "", ""],
    [8, "bax", "", -1, "", ""],
    ["", "foo", 1.53, "", "stringZ", 0.8],
    ["intA", "strB", "floatC", "intD", "strE", "floatF"],
    [4, "", 1.63, 1, "", ""]
])

df_test_names = ["intA", "strB", "floatC", "intD", "strE", "floatF"]


# ---------------------------- find_header_row ----------------------------
def test_find_simple_header_top_row():
    header_row, header_names = utils.find_header_row(
        df=df_test_simple,
        columns_name_list=df_test_names
    )
    assert header_row == 0
    assert header_names == ["inta", "strb", "floatc", "intd", "stre", "floatf"]


def test_find_simple_header_fourth_row():
    header_row, header_names = utils.find_header_row(
        df=df_test_small_header,
        columns_name_list=df_test_names
    )
    assert header_row == 3
    assert header_names == ["inta", "strb", "floatc", "intd", "stre", "floatf"]


def test_find_simple_header_throw_exception_default_rows():
    with pytest.raises(Exception) as excinfo:
        utils.find_header_row(
            df=df_test_long_header,
            columns_name_list=df_test_names
        )
    assert str(excinfo.value) == "Header not found in 10 rows"


def test_find_simple_header_throw_exception_limited_rows():
    with pytest.raises(Exception) as excinfo:
        utils.find_header_row(
            df=df_test_long_header,
            columns_name_list=df_test_names,
            rows_to_search=5
        )
    assert str(excinfo.value) == "Header not found in 5 rows"


def test_find_simple_header_throw_exception_partial_match():
    with pytest.raises(Exception) as excinfo:
        utils.find_header_row(
            df=df_test_multiple_headers,
            columns_name_list=df_test_names,
            rows_to_search=3
        )
    assert str(excinfo.value) == "Header not found in 3 rows"


def test_find_simple_header_search_exact_rows():
    with pytest.raises(Exception) as excinfo:
        utils.find_header_row(
            df=df_test_long_header,
            columns_name_list=df_test_names,
            rows_to_search=12
        )
    assert str(excinfo.value) == "Header not found in 12 rows"


def test_find_simple_header_rows_to_test_15():
    header_row, header_names = utils.find_header_row(
        df=df_test_long_header,
        columns_name_list=df_test_names,
        rows_to_search=15
    )
    assert header_row == 12
    assert header_names == ["inta", "strb", "floatc", "intd", "stre", "floatf"]


def test_find_simple_header_rows_to_test_none():
    header_row, header_names = utils.find_header_row(
        df=df_test_long_header,
        columns_name_list=df_test_names,
        rows_to_search=None
    )
    assert header_row == 12
    assert header_names == ["inta", "strb", "floatc", "intd", "stre", "floatf"]


def test_stop_at_first_header_row_above_threshold_default():
    header_row, header_names = utils.find_header_row(
        df=df_test_multiple_headers,
        columns_name_list=df_test_names
    )
    assert header_row == 4
    assert header_names == ["inta", "strb", "floatc", "intd", "", ""]


def test_stop_at_first_header_row_above_threshold_value():
    header_row, header_names = utils.find_header_row(
        df=df_test_multiple_headers,
        columns_name_list=df_test_names,
        stop_threshold=(1/6)
    )
    assert header_row == 0
    assert header_names == ["inta", "strb", "", "", "", ""]


def test_find_best_header_in_range():
    header_row, header_names = utils.find_header_row(
        df=df_test_multiple_headers,
        columns_name_list=df_test_names,
        stop_threshold=1
    )
    assert header_row == 7
    assert header_names == ["inta", "strb", "floatc", "intd", "stre", "floatf"]


def test_find_header_row_stop_threshold_must_be_numeric():
    with pytest.raises(TypeError) as excinfo:
        utils.find_header_row(
            df=df_test_multiple_headers,
            columns_name_list=df_test_names,
            stop_threshold=None
        )
    assert "'>' not supported" in str(excinfo.value)


# ---------------------------- clean_header ----------------------------
def test_clean_simple_header():
    clean_df = utils.clean_df_header(
        df=df_test_multiple_headers,
        columns_name_list=df_test_names
    )
    npt.assert_array_equal(
        clean_df,
        pd.DataFrame([
            [8, "bax", "", -1, "", ""],
            ["", "foo", 1.53, "", "stringZ", 0.8],
            ["intA", "strB", "floatC", "intD", "strE", "floatF"],
            [4, "", 1.63, 1, "", ""]
        ])
    )
    npt.assert_array_equal(
        clean_df.columns,
        ["inta", "strb", "floatc", "intd", "", ""]
    )


def test_clean_header_pass_kwargs_rows():
    clean_df = utils.clean_df_header(
        df=df_test_long_header,
        columns_name_list=df_test_names,
        rows_to_search=15
    )
    npt.assert_array_equal(
        clean_df,
        pd.DataFrame([
            [4, "foo", 1.23, 1, "", 4.8],
            [3, "bar", 1.33, 2, "stringX", 4.8],
            [10, "baz", 1.43, 0, "stringY", 2.8],
            [8, "bax", "", -1, "", ""],
            ["", "foo", 1.53, "", "stringZ", 0.8],
            [4, "", 1.63, 1, "", ""]
        ])
    )
    npt.assert_array_equal(
        clean_df.columns,
        ["inta", "strb", "floatc", "intd", "stre", "floatf"],
    )


def test_clean_header_pass_kwargs_threshold():
    clean_df = utils.clean_df_header(
        df=df_test_multiple_headers,
        columns_name_list=df_test_names,
        stop_threshold=1
    )
    npt.assert_array_equal(
        clean_df,
        pd.DataFrame([
            [4, "", 1.63, 1, "", ""]
        ])
    )
    npt.assert_array_equal(
        clean_df.columns,
        ["inta", "strb", "floatc", "intd", "stre", "floatf"],
    )


# Test frame with header on first row, and footer
df_test_footer_quote = pd.DataFrame([
    ["intA", "strB", "floatC", "intD", "strE", "floatF"],
    [4, "foo", 1.23, 1, "", 4.8],
    [3, "bar", 1.33, 2, "stringX", 4.8],
    [10, "baz", 1.43, 0, "stringY", 2.8],
    [8, "bax", "", -1, "", ""],
    ["", "foo", 1.53, "", "stringZ", 0.8],
    [4, "", 1.63, 1, "", ""],
    ["", "", "", "", "", ""],
    ["Footer", "text", "", "", "", ""],
])


df_test_footer_nan = pd.DataFrame([
    ["intA", "strB", "floatC", "intD", "strE", "floatF"],
    [4, "foo", 1.23, 1, "", 4.8],
    [3, "bar", 1.33, 2, "stringX", 4.8],
    [10, "baz", 1.43, 0, "stringY", 2.8],
    [8, "bax", "", -1, "", ""],
    ["", "foo", 1.53, "", "stringZ", 0.8],
    [4, "", 1.63, 1, "", ""],
    [np.nan, np.nan, np.nan, np.nan, np.nan, np.nan],
    ["Footer", "text", "", "", "", ""],
])


df_test_footer_mixed = pd.DataFrame([
    ["intA", "strB", "floatC", "intD", "strE", "floatF"],
    [4, "foo", 1.23, 1, "", 4.8],
    [3, "bar", 1.33, 2, "stringX", 4.8],
    [10, "baz", 1.43, 0, "stringY", 2.8],
    [8, "bax", "", -1, "", ""],
    ["", "foo", 1.53, "", "stringZ", 0.8],
    [4, "", 1.63, 1, "", ""],
    ["", np.nan, "", np.nan, "", np.nan],
    ["Footer", "text", "", "", "", ""],
])


df_test_long_footer = pd.DataFrame([
    ["intA", "strB", "floatC", "intD", "strE", "floatF"],
    [4, "foo", 1.23, 1, "", 4.8],
    [3, "bar", 1.33, 2, "stringX", 4.8],
    [10, "baz", 1.43, 0, "stringY", 2.8],
    [8, "bax", "", -1, "", ""],
    ["", "foo", 1.53, "", "stringZ", 0.8],
    [4, "", 1.63, 1, "", ""],
    ["", "", "", "", "", ""],
    ["", "", "", "", "", ""],
    ["Long", "1", "", "", "", ""],
    ["Footer", "2", "", "", "", ""],
    ["Text", "3", "", "", "", ""],
    ["Long", "4", "", "", "", ""],
    ["Footer", "5", "", "", "", ""],
    ["Text", "6", "", "", "", ""],
    ["Long", "7", "", "", "", ""],
    ["Footer", "8", "", "", "", ""],
    ["Text", "9", "", "", "", ""],
    ["Long", "10", "", "", "", ""],
    ["Footer", "11", "", "", "", ""],
    ["Text", "12", "", "", "", ""],
    ["Long", "13", "", "", "", ""],
    ["Footer", "14", "", "", "", ""],
    ["Text", "15", "", "", "", ""],
    ["Text", "16", "", "", "", ""],
    ["Long", "17", "", "", "", ""],
    ["Footer", "18", "", "", "", ""],
    ["Text", "19", "", "", "", ""],
    ["Long", "20", "", "", "", ""],
    ["Footer", "21", "", "", "", ""],
    ["Text", "22", "", "", "", ""],
])


# ---------------------------- find_footer_row ----------------------------
def test_find_simple_footer():
    footer_row = utils.find_df_footer(
        df=df_test_footer_quote
    )
    assert footer_row == 7


def test_find_simple_footer_nan():
    footer_row = utils.find_df_footer(
        df=df_test_footer_nan
    )
    assert footer_row == 7


def test_find_simple_footer_mixed_nan():
    footer_row = utils.find_df_footer(
        df=df_test_footer_mixed
    )
    assert footer_row == 7


def test_find_no_footer():
    footer_row = utils.find_df_footer(
        df=df_test_simple
    )
    assert footer_row is None


def test_find_long_footer_default():
    footer_row = utils.find_df_footer(
        df=df_test_long_footer
    )
    assert footer_row is None


def test_find_long_footer_none():
    footer_row = utils.find_df_footer(
        df=df_test_long_footer,
        rows_to_search=None
    )
    assert footer_row == 7


def test_find_long_footer_value():
    footer_row = utils.find_df_footer(
        df=df_test_long_footer,
        rows_to_search=25
    )
    assert footer_row == 7


# ---------------------------- clean_df_footer ----------------------------
def test_clean_simple_footer():
    clean_df = utils.clean_df_footer(
        df=df_test_footer_quote
    )
    npt.assert_array_equal(clean_df, df_test_simple)


def test_clean_simple_footer_nan():
    clean_df = utils.clean_df_footer(
        df=df_test_footer_nan
    )
    npt.assert_array_equal(clean_df, df_test_simple)


def test_clean_simple_footer_mixed_nan():
    clean_df = utils.clean_df_footer(
        df=df_test_footer_mixed
    )
    npt.assert_array_equal(clean_df, df_test_simple)


def test_clean_no_footer():
    clean_df = utils.clean_df_footer(
        df=df_test_simple
    )
    npt.assert_array_equal(clean_df, df_test_simple)


def test_clean_long_footer_default():
    clean_df = utils.clean_df_footer(
        df=df_test_long_footer
    )
    # since the footer doesn't find_df_footert in the default parameters,
    # nothing gets cleaned.
    npt.assert_array_equal(clean_df, df_test_long_footer)


def test_clean_long_footer_none():
    clean_df = utils.clean_df_footer(
        df=df_test_long_footer,
        rows_to_search=None
    )
    npt.assert_array_equal(clean_df, df_test_simple)


def test_clean_long_footer_value():
    clean_df = utils.clean_df_footer(
        df=df_test_long_footer,
        rows_to_search=25
    )
    npt.assert_array_equal(clean_df, df_test_simple)
