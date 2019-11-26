"""Functions to import datafiles."""
import pathlib
import re


def import_all_files(
    data_files_path=pathlib.Path('/tmp', 'data_files')
):
    """Recursively scan a directory and import all data files."""
    # list all files
    data_files = list(data_files_path.glob('**/*'))
    # list comprehension to filter only files (not directories)
    data_files = list(f for f in data_files if f.is_file())
    for file in data_files:
        import_single_file(filepath=file, data_files_path=data_files_path)


def import_single_file(
    filepath,
    data_files_path=pathlib.PurePosixPath('/')
        ):
    """Orchestrate reading and import a file."""
    print(f"Importing: {filepath.relative_to(data_files_path)}")
    filetype = _determine_file_type(filepath=filepath)
    print(filetype)


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
        filetype = "GlobalData power extract"
    else:
        raise Exception(f"File type could not be determined for {filepath}")
    return filetype