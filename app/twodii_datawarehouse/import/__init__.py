"""Functions to import datafiles."""
import pathlib


def import_all_files(
    data_files_path=pathlib.Path('/tmp', 'data_files')
):
    """Recursively scan a directory and import all data files."""
    # list all files
    data_files = list(data_files_path.glob('**/*'))
    for file in data_files:
        import_single_file(filepath=file)


def import_single_file(filepath):
    """Orchestrate reading and import a file."""
    pass


def _determine_file_type(filepath):
    """Logic to determine which function to use to import a file."""
    pass
