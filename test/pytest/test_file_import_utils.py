"""Testing utilities for file import."""
import numpy.testing as npt
import pandas as pd
import pytest
import twodii_datawarehouse.file_import.utils as utils

# Test frame with header on first row, no footers
df_test_1a = pd.DataFrame([
    ["intA", "strB", "floatC", "intD", "strE", "floatF"],
    [4, "foo", 1.23, 1, "", 4.8],
    [3, "bar", 1.33, 2, "stringX", 4.8],
    [10, "baz", 1.43, 0, "stringY", 2.8],
    [8, "bax", "", -1, "", ""],
    ["", "foo", 1.53, "", "stringZ", 0.8],
    [4, "", 1.63, 1, "", ""]
])

# Test frame with header on first row, no footers
df_test_1b = pd.DataFrame([
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
df_test_1c = pd.DataFrame([
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
df_test_1d = pd.DataFrame([
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

df_test_1_names = ["intA", "strB", "floatC", "intD", "strE", "floatF"]


# ---------------------------- find_header_row ----------------------------
def test_find_simple_header_top_row():
    header_row, header_names = utils.find_header_row(
        df=df_test_1a,
        columns_name_list=df_test_1_names
    )
    assert header_row == 0
    assert header_names == ["inta", "strb", "floatc", "intd", "stre", "floatf"]


def test_find_simple_header_fourth_row():
    header_row, header_names = utils.find_header_row(
        df=df_test_1b,
        columns_name_list=df_test_1_names
    )
    assert header_row == 3
    assert header_names == ["inta", "strb", "floatc", "intd", "stre", "floatf"]


def test_find_simple_header_throw_exception_default_rows():
    with pytest.raises(Exception) as excinfo:
        utils.find_header_row(
            df=df_test_1c,
            columns_name_list=df_test_1_names
        )
    assert str(excinfo.value) == "Header not found in 10 rows"


def test_find_simple_header_throw_exception_limited_rows():
    with pytest.raises(Exception) as excinfo:
        utils.find_header_row(
            df=df_test_1c,
            columns_name_list=df_test_1_names,
            rows_to_search=5
        )
    assert str(excinfo.value) == "Header not found in 5 rows"


def test_find_simple_header_throw_exception_partial_match():
    with pytest.raises(Exception) as excinfo:
        utils.find_header_row(
            df=df_test_1d,
            columns_name_list=df_test_1_names,
            rows_to_search=3
        )
    assert str(excinfo.value) == "Header not found in 3 rows"


def test_find_simple_header_search_exact_rows():
    with pytest.raises(Exception) as excinfo:
        utils.find_header_row(
            df=df_test_1c,
            columns_name_list=df_test_1_names,
            rows_to_search=12
        )
    assert str(excinfo.value) == "Header not found in 12 rows"


def test_find_simple_header_rows_to_test_15():
    header_row, header_names = utils.find_header_row(
        df=df_test_1c,
        columns_name_list=df_test_1_names,
        rows_to_search=15
    )
    assert header_row == 12
    assert header_names == ["inta", "strb", "floatc", "intd", "stre", "floatf"]


def test_find_simple_header_rows_to_test_none():
    header_row, header_names = utils.find_header_row(
        df=df_test_1c,
        columns_name_list=df_test_1_names,
        rows_to_search=None
    )
    assert header_row == 12
    assert header_names == ["inta", "strb", "floatc", "intd", "stre", "floatf"]


def test_stop_at_first_header_row_above_threshold_default():
    header_row, header_names = utils.find_header_row(
        df=df_test_1d,
        columns_name_list=df_test_1_names
    )
    assert header_row == 4
    assert header_names == ["inta", "strb", "floatc", "intd", "", ""]


def test_stop_at_first_header_row_above_threshold_value():
    header_row, header_names = utils.find_header_row(
        df=df_test_1d,
        columns_name_list=df_test_1_names,
        stop_threshold=(1/6)
    )
    assert header_row == 0
    assert header_names == ["inta", "strb", "", "", "", ""]


def test_find_best_header_in_range():
    header_row, header_names = utils.find_header_row(
        df=df_test_1d,
        columns_name_list=df_test_1_names,
        stop_threshold=1
    )
    assert header_row == 7
    assert header_names == ["inta", "strb", "floatc", "intd", "stre", "floatf"]


def test_find_header_row_stop_threshold_must_be_numeric():
    with pytest.raises(TypeError) as excinfo:
        utils.find_header_row(
            df=df_test_1d,
            columns_name_list=df_test_1_names,
            stop_threshold=None
        )
    assert "'>' not supported" in str(excinfo.value)


# ---------------------------- clean_header ----------------------------
def test_clean_simple_header():
    clean_df = utils.clean_df_header(
        df=df_test_1d,
        columns_name_list=df_test_1_names
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
        df=df_test_1c,
        columns_name_list=df_test_1_names,
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
        df=df_test_1d,
        columns_name_list=df_test_1_names,
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
