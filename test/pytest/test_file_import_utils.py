"""Testing utilities for file import."""
import pandas as pd
import twodii_datawarehouse.file_import.utils as utils

# Test frame with header on first row, no footers
df_test_1 = pd.DataFrame([
    ["intA", "strB", "floatC", "intD", "strE", "floatF"],
    [4, "foo", 1.23, 1, "", 4.8],
    [3, "bar", 1.33, 2, "stringX", 4.8],
    [10, "baz", 1.43, 0, "stringY", 2.8],
    [8, "bax", "", -1, "", ""],
    ["", "foo", 1.53, "", "stringZ", 0.8],
    [4, "", 1.63, 1, "", ""]
])

df_test_1_names = ["intA", "strB", "floatC", "intD", "strE", "floatF"]


def test_find_simple_header():
    """Test header finding on a simple dataframe."""
    header_row, header_names = utils.find_header_row(
        df=df_test_1,
        columns_name_list=df_test_1_names
    )
    assert header_row == 0
    assert header_names == ["inta", "strb", "floatc", "intd", "stre", "floatf"]


# def test_fail():
#     """Test a failing condition for CI/CD servers."""
#     assert 1 == 0
