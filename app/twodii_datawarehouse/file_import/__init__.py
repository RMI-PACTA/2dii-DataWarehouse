"""Functions to import datafiles."""
import logging
import pathlib
import re

import twodii_datawarehouse.file_import.db_utils as dbu
import twodii_datawarehouse.file_import.globaldata as gd


def import_all_files(
    db_engine,
    data_files_path=pathlib.Path('/tmp', 'data_files')
):
    """Recursively scan a directory and import all data files."""
    # list all files
    data_files = list(data_files_path.glob('**/*'))
    # list comprehension to filter only files (not directories)
    data_files = list(f for f in data_files if f.is_file())
    for file in data_files:
        import_single_file(
            filepath=file,
            db_engine=db_engine,
            data_files_path=data_files_path
        )
    logging.info(f"Imported all files in {data_files_path}")


def import_single_file(
    filepath,
    db_engine,
    data_files_path=pathlib.PurePosixPath('/')
        ):
    """Orchestrate reading and import a file."""
    if dbu.check_if_file_imported(filepath, db_engine):
        logging.info(
            f"Already imported: {filepath.relative_to(data_files_path)}"
        )
        return None
    logging.info(f"Importing: {filepath.relative_to(data_files_path)}")
    logging.debug(f"Absolute path: {filepath}")
    file_info = _determine_file_type(filepath=filepath)
    schemaname = 'rawdata'

    with db_engine.begin() as db_con:
        columns_info = dbu.get_db_column_info(
            db_connection=db_con,
            tablename=file_info['tablename'],
            schemaname=schemaname
        )
    columns_name_list = list(columns_info['column_name'])
    df = file_info['parser'](filepath, columns_name_list)

    # Using the context manager allows the adding to import history and writing
    # to DB to be in the same transaction, and it will rollback if it fails.
    with db_engine.begin() as db_con:
        import_id = dbu.add_to_import_history(
            filepath=filepath,
            db_connection=db_con,
            filetype=file_info['filetype']
        )
        df['import_history_id'] = import_id
        dbu.write_df_to_db(
            df=df,
            db_connection=db_con,
            tablename=file_info['tablename'],
            schemaname=schemaname
        )
    return import_id


def _determine_file_type(filepath):
    """Logic to determine which function to use to import a file."""
    # Using if/elif to determine the type of file, since python doesn't have a
    # case/switch construction.
    filetype = None
    # Match GlobalData power plant files,
    # ex. GlobalData-2Degrees-Biopower_Power_Plants-20190903.xlsx
    if re.search(
        pattern=r"""
        globaldata # File name contains globaldata (one word)
        .* # Followed by anything
        power
        [\-_\s]* # there can be multiple _- or space characters
        plants
        .* # ending with anything.
        """,
        string=filepath.name,
        flags=re.IGNORECASE | re.VERBOSE
    ):
        filetype = "GlobalData power plant"
        parser = gd.parse_globaldata_power_plants
        tablename = 'globaldata_power_plants'
    # Find GlobalData power extract files
    # ex. GlobalData-2Degrees_ Power_ Extract_20190828
    elif re.search(
        pattern=r"""
        globaldata # File name contains globaldata (one word)
        .* # Followed by anything
        power
        [\-_\s]* # there can be multiple _- or space characters
        extract
        .* # ending with anything.
        """,
        string=filepath.name,
        flags=re.IGNORECASE | re.VERBOSE
    ):
        filetype = "GlobalData power extract"
        parser = gd.parse_globaldata_power_extract
        tablename = 'globaldata_power_extract'
    # Find GlobalData power purchase agreement files
    # ex. GlobalData-2Degrees-List_of_Power_Purchase_Agreements-20190830.xlsx
    elif re.search(
        pattern=r"""
        globaldata # File name contains globaldata (one word)
        .* # Followed by anything
        power
        [\-_\s]* # there can be multiple _- or space characters
        purchase
        [\-_\s]* # there can be multiple _- or space characters
        agreements
        .* # ending with anything.
        """,
        string=filepath.name,
        flags=re.IGNORECASE | re.VERBOSE
    ):
        filetype = "GlobalData power purchase agreements"
        parser = gd.parse_globaldata_power_purchase_agreements
        tablename = 'globaldata_power_purchase_agreements'
    else:
        raise Exception(f"File type could not be determined for {filepath}")
    return {
        "filetype": filetype,
        "tablename": tablename,
        "parser": parser
    }
