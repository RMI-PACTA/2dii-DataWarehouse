# Data Warehouse for 2 Degrees Investing

Note: **This is a draft specification**

This repository is the home for code related to the 2 Degrees Investing Data Warehouse (DW).

We are treating this project as a greenfield project for initial design, and will translate and migrate data from previous systems once initial design work and MVP is complete.

## Overview

Because the data warehouse (database) is the product of interest for the Data Warehousing Team, most of this document is focused on the management and design decisions for the DW.
However, because the DW structure is necessarily shaped by the data it needs to store, code for importing data will also live in this repository.
Thus, this repository shall hold all code needed to establish a database from scratch, manage migrations and changes to an already-deployed (persistent) database, and import new data into the database.
Additionally it will contain all testing code related to these functions.

### Key Words

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED",  "MAY", and "OPTIONAL" in this document are to be interpreted as described in [RFC 2119](https://tools.ietf.org/html/rfc2119).

The key word "schema" (pl. "schemata") is used in the `Postgres` sense, to indicate a grouping of objects within a database.
The word "structure" will refer to the blueprint for the construction and organization of the database (logical schema).

## Planned infrastructure

* Persistent `Postgres` database
* On-Demand `docker` container, running import process as needed.
* External File Storage (Azure Blob or Dropbox)

We SHOULD implement as much of our infrastructure as possible as "infrastructure as code" (also called "immutable infrastructure"), as this will reduce concerns about machine state when activating or deactivating machines.
Additionally, defining our infrastructure as code, will allow us to dockerize the database and mock external file storage for local development and automated testing.

## Database

In this section, we lay out some of our design principles for our Data Warehouse.
Some of the fundamental assumptions that we are basing our decisions on are:

* We want to use `PostgreSQL`
  * it is open-source, and therefore freely available
  * our team (including analysts) is comfortable with the language
  * it is widely supported by cloud hosts
* Our data import process does not need to support streaming data
  * Our organization does not generate data, but gathers it from vendors
  * We import data from vendors at regular, but infrequent intervals (most quarterly or monthly; some vendors will be imported weekly).
* Our data is not "large"
  * Even the largest of single files that we regularly import is in the many tens of thousands of records (rows).

### Core Structure

The database will be grouped logically into three schemata:

* `rawdata:` contains the data that has been imported, but not transformed in any way, and details about the import process.
* `etl`: contains intermediate processing tables, as well as functions, and procedures for transforming, cleaning, and preparing data, as well as running data quality checks.
* `dw`: the primary schema that analysts will access. Contains data that has been integrated and processed into a useful format.

Because `dw` is the primary point of interest, access SHOULD be restricted for most users to that schema only.

### Business Logic in Database Code

Because the end-product for the intermediate future is the database, rather than an application which consumes the database, it is acceptable, and perhaps preferable, to keep logic inside the database.
This decision is contrary to advice for traditional applications, but it reduces our dependency on external languages (`python` or `R`).
It forces our team to write tests for `SQL` code (functions, procedures, etc.), but this is possible because there are testing frameworks for Postgres (See [pgTAP](https://pgtap.org/))

`Postgres` doesn't have functionality to natively import Microsoft Excel files (which is a data format we MUST be able to import).
Additionally, we SHOULD be able to import a wider variety of formats beyond Excel and flat text files (such as `.csv`) in the future, if necessary.
Therefore, we will have some scripting code, but we SHOULD restrict this to import functionality only.

### Data Quality Checks

Because accurate data is key to our organization's goals, we SHOULD ensure that data correct as part of the import process.
This includes both validating the source data from our vendors, as well as ensuring that it has been correctly integrated (matched) with the rest of our dataset.

We will develop a generic data quality "test harness" that will allow us to specify a type of test, along with parameters for success.
This test harness should accept parameters such as:

* Unit of analysis, e.g. company, country, power plant (All scales of analysis)
* Metric of interest, e.g. output capacity, 5-year rolling average earnings (Any calculable metric of interest)
* Tolerances for warnings, e.g. +/- 20%, No more than 5 GW less than previous (Defined as either percentage change, or absolute values)

The test harness will then calculate the metric of interest for the specified unit of analysis both with, and without the new data incorporated in the dataset, and attach a warning to the new data if the change lies outside the specified threshold.

We SHOULD integrate data, even if it has warnings attached to it, because data may be impossible to verify (in a timely manner).
Halting the data import process for suspicious data is more detrimental to the organization than importing, but attaching warnings.
This integration is predicated on the assumption that important discrepancies in the data will be noticed quickly, because their warnings will be encountered sooner.

We MUST provide a method for analysts to easily see what data has warnings attached, and the nature of those warnings.
We MUST develop a method to roll up and aggregate data warnings, along with the data that is being summarized.
Because attaching warnings to data can very easily cast suspicion on any summary which includes that data we need to have methods of reconciling warnings.
We MUST develop a system by which a warning can be overridden, verified as acceptable, or confirmed as accurate.
Further, We MUST have functionality to replace or overwrite data that is known to be erroneous, if more accurate data is obtained from a vendor.

### Environments

Cloud hosting allows us to easily activate or deactivate duplicates of our database, either with real-time replication between instances, or as a one-time (static) clone.
This allows us to reduce costs by only running instances that the organization needs at any time, but also grants us flexibility to experiment in an environment, without a large administrative overhead.

The current availability plan has a single persistent instance (`PROD`), perhaps with several long-running replicates in other availability zones, as needed.
There would also be more ephemeral instances for shared development, either by the Data Warehousing Team (see "Blue/Green", below), or by the analysis team for experiments, reports, or other special projects.

### `Postgres` Version

Both versions `11.5` and `9.6.15` are widely supported across cloud hosts, however `11.5` has increased functionality, in particular, better support for parallel processing, and support for stored procedures, which `9.6` does not.
Additionally `Postgres 11` has a scheduled final release date of November 9, 2023, opposed to `9.6`, which has a date of November 11, 2021, meaning that we will not be forced into an end-of-life upgrade as soon.

### Fuzzy Matching `Postgres` Extensions

There are multiple extensions for `Postgres` that implement fuzzy matching for strings.
Although `pg_similarity` offers the most matching algorithms, it is only supported by AWS RDS, so other extensions are more viable for our current situation.
Alternately, we can implement a method using custom user-defined functions.

|extension|Azure DB for Postgres|AWS RDS|Google Cloud DB|
|---|---|---|---|
|[`fuzzystrmatch`](https://www.postgresql.org/docs/9.1/fuzzystrmatch.html)|1.1|1.1|Yes|
|[`pg_trgm`](https://www.postgresql.org/docs/9.6/pgtrgm.html)|1.4|1.3|Yes|
|[`pg_similarity`](https://github.com/eulerto/pg_similarity)|No|1.0|No|

### Structure as API

Because the team responsible for developing the Data Warehouse is not (entirely) the team that primarily consumes from the DW, we must consider the structure of the DW to be a contract between those two teams.
Because analysts will be writing scripts against a particular database structure, that particular structure becomes a dependency for their scripts.
Therefore, the DW _has_ an API, even if its documentation is not complete.

The database's primary access schema (`dw`) SHOULD be as stable as possible, and version MUST be declared using [Semantic Versioning](https://semver.org).
This will decouple the process of tuning the database for performance or making structural changes for import, from the fields used in analysis.
Note that this "API" SHOULD only apply to the outward facing schema (including any views).
The `staging` and `rawdata` schemata SHOULD NOT be consumed by most users, and therefore MAY be unstable, beyond what is needed for the Data Warehousing Team.

Although the version bump for each change is dependent on the specifics of the change, some sample commands for each semver level might be:

* Major (Breaking Changes):
  * `DROP TABLE`
  * `DROP` analysis columns
  * `REPLACE FUNCTION` which changes outputs
* Minor (Backwards Compatible functionality)
  * `ADD` key analysis columns
  * `ADD`/`DROP` non-analysis columns
  * `REPLACE FUNCTION` for performance only (identical test cases still pass)
* Patch (Backwards Compatible Bugfix)
  * `CREATE`/`DROP INDEX`
  * `ADD`/`DROP CONSTRAINT`
  * Changes to "back end" schemata (`staging` or `rawdata`)

### Modified "Blue/Green" Migrations

Cloud-deployed databases are easily duplicated.
This allows us to use a modification of the "Blue/Green" strategy when deploying a migration to our database.
This method consists of:

1. Locally develop a release candidate.
2. Create a duplicate of `PROD` database, called `STAGING`.
3. Deploy candidate migration to `STAGING`.
4. Ensure migration was successful (including any checks by SMEs needed).
5. **If** migration is successful, **then** rename `STAGING` to `PROD`, reroute traffic to the new, updated database, and turn off the old one. **Otherwise**, destroy `STAGING` and return to step 1.

In practice, this method can be used with names other than `PROD` and `STAGING`, in order to avoid the re-naming step (`BLUE` and `GREEN` are traditional).

Suggested Reading:

* [Martin Fowler on Blue/Green](https://martinfowler.com/bliki/BlueGreenDeployment.html)

### Database Migration Strategy

Migrations MUST be written as `.sql` files, and stored in the `sql` directory of this repository.
Migration files MUST be named with the semver of the database created by that migration, in the format `MAJOR_MINOR_PATCH.sql` (e.g. `001_005_014.sql`).
Note that each component is prepended by `0`, to give 3 digits, to ensure correct sorting, even by naïve systems.
A new migration file MUST NOT have a lower sort order than any of the existing migrations.

Each file SHOULD begin with `BEGIN TRANSACTION` and conclude with `COMMIT TRANSACTION`, or provide comments as to why transactions are not possible for that migration.
The first line within each transaction MUST insert to the migration tracking table, to bump the version appropriately, and insert any notes about the new version.

Suggested Reading:

* [Martin Fowler - Evolutionary Database Design](https://martinfowler.com/articles/evodb.html)
* [Wikipedia - Schema Migration](https://en.wikipedia.org/wiki/Schema_migration)

## Hosting

Currently, our organization uses Azure as a host, and we intend to continue with this.
To avoid vendor lock-in, we SHOULD use open source technologies, especially with an eye towards technologies that are functionally identical across platforms (Azure, AWS, GCP).
In particular, the Data Warehousing Team SHOULD use versions of software that are common to multiple hosts.
For example, as of this writing, Postgres 11.5 is supported on all three major platforms.
