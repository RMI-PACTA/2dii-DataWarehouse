"""Import functions for globaldata files."""

import pandas as pd
import twodii_datawarehouse.file_import.utils as utils


def parse_globaldata_power_plants(
    filepath,
    columns_name_list
):
    """Read a table from read the global data powerplants file."""
    raw_data = pd.read_excel(
        io=filepath,
        sheet_name=None,
        header=None
    )
    if len(raw_data.keys()) != 1:
        raise Exception(f"""Multiple sheets found in excel file,
                        but only one expected: {raw_data.keys()}""")
    raw_data = raw_data[list(raw_data.keys())[0]]

    df = utils.clean_df(
        df=raw_data,
        columns_name_list=columns_name_list
    )

    # Table specific rename
    if "total_capacity_(mw)" in df.columns:
        df['total_capacity_unit'] = 'MW'
        df = df.rename(
            mapper={"total_capacity_(mw)": "total_capacity"},
            axis='columns',
            errors='raise'
        )
    if "active_capacity_(mw)" in df.columns:
        df['active_capacity_unit'] = 'MW'
        df = df.rename(
            mapper={"active_capacity_(mw)": "active_capacity"},
            axis='columns',
            errors='raise'
        )
    if "pipeline_capacity_(mw)" in df.columns:
        df['pipeline_capacity_unit'] = 'MW'
        df = df.rename(
            mapper={"pipeline_capacity_(mw)": "pipeline_capacity"},
            axis='columns',
            errors='raise'
        )
    if "discontinued_capacity_(mw)" in df.columns:
        df['discontinued_capacity_unit'] = 'MW'
        df = df.rename(
            mapper={"discontinued_capacity_(mw)": "discontinued_capacity"},
            axis='columns',
            errors='raise'
        )
    if "owner_stake_(%)" in df.columns:
        df = df.rename(
            mapper={"owner_stake_(%)": "owner_stake_percentage"},
            axis='columns',
            errors='raise'
        )
    if "capex_usd_(million)" in df.columns:
        df['capex_usd'] = df['capex_usd_(million)'] * 1e6
        df = df.drop("capex_usd_(million)", axis='columns')
    if "efficiency_(%)" in df.columns:
        df = df.rename(
            mapper={"efficiency_(%)": "efficiency_percentage"},
            axis='columns',
            errors='raise'
        )
    if "decommissioning_year_(actual/estimated)" in df.columns:
        df = df.rename(
            mapper={
                "decommissioning_year_(actual/estimated)":
                    "decommissioning_year_status"
            },
            axis='columns',
            errors='raise'
        )

    return df


def parse_globaldata_power_extract(
    filepath,
    columns_name_list
):
    """Read a table from read the global data powerplants file."""
    # Find the header row
    raw_data = pd.read_excel(
        io=filepath,
        sheet_name=None,
        header=None
    )
    if len(raw_data.keys()) != 1:
        raise Exception(f"""Multiple sheets found in excel file,
                        but only one expected: {raw_data.keys()}""")
    raw_data = raw_data[list(raw_data.keys())[0]]

    df = utils.clean_df(
        df=raw_data,
        columns_name_list=columns_name_list
    )

    # Table specificecific renames
    if "company_type_(private/_public..)" in df.columns:
        df = df.rename(
            mapper={"company_type_(private/_public..)": "company_type"},
            axis='columns',
            errors='raise'
        )
    if "parent/subsidiary" in df.columns:
        df = df.rename(
            mapper={"parent/subsidiary": "parent_subsidiary"},
            axis='columns',
            errors='raise'
        )
    return df
