# Python Application

This directory contains the python code for the application, as well as tests for the same.
This is a Python 3 application.

## Running the application

The project is structured so that calling `twodii_datawarehouse.py` will run all the important processes (e.g. preparing the database structure and importing data files).

```bash
python3 twodii_datawarehouse.py
```

There are some flags to the script that offer more information and options.
Running with the `-m` flag runs only the migrations (database structure), without importing data, which is useful for running SQL tests (see pgTAP).
Running with `-v` or `-vv` increases the verbosity of the logger, from error and warning messages with no flags, to information messages, up through debugging information with `-vv`

## Important files and directories:

* `requirements.txt`: contains the list of packages needed to beinstalled with `pip` to run the application.
* `test`: Contains tests written for `pytest`.
* `twodii_datawarehouse`: contains the bulk of the application code
* `twodii_datawarehouse.py`: Main script to call from the command line (`python3 twodii_datawarehouse.py`).
  Contains high-level imports, and code to initiate the data warhouse migrations process and data import.
