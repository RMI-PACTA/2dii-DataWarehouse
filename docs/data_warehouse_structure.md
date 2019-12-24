# Data Warehouse Structure

This document outlines the overall structure of the data warehouse.

## Database Schemata

The database will be grouped logically into three schemata:

* `rawdata:` contains the data that has been imported, but not transformed in any way, and details about the import process.
* `etl`: contains intermediate processing tables, as well as functions, and procedures for transforming, cleaning, and preparing data, as well as running data quality checks.
* `dw`: the primary schema that analysts will access. Contains data that has been integrated and processed into a useful format.

Additionally, there is a single table on the `public` schema: `public.dw_version`, which contains metadata about the current state of the database structure.

Because `dw` is the primary point of interest, access SHOULD be restricted for most users to that schema only.

More information about each table in these schemata is availible in `docs/sql/*`, or in the `*.sql` files which create the database objects.
