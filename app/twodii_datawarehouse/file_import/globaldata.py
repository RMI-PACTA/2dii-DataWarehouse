"""Import functions for globaldata files."""

import pandas as pd
import twodii_datawarehouse.file_import.utils as utils


power_plant_table_columns = [
    "id",
    "import_history_id",
    "technology",
    "global_reference_id",
    "power_plant_id",
    "power_plant_name",
    "subsidiary_asset_name",
    "fuel_category",
    "primary_fuel",
    "secondary_fuel",
    "region",
    "country",
    "state_or_province",
    "county",
    "city_or_town",
    "total_capacity",
    "total_capacity_unit",
    "active_capacity",
    "active_capacity_unit",
    "pipeline_capacity",
    "pipeline_capacity_unit",
    "discontinued_capacity",
    "discontinued_capacity_unit",
    "status",
    "type_of_plant",
    "owner_id",
    "owner_name",
    "owner_stake_percentage",
    "operator_id",
    "operator_name",
    "epc_id",
    "epc",
    "year_online",
    "latitude",
    "longitude",
    "capex_usd",
    "efficiency_percentage",
    "capacity_factor",
    "decommissioning_year",
    "decommissioning_year_status"
]


def parse_globaldata_power_plants(filepath):
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
    header_row, header_names = utils.find_header_row(
        dataframe=raw_data,
        columns_name_list=power_plant_table_columns
    )

