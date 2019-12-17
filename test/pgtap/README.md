# pgTAP tests.

These tests are intended to be run with pgTAP.
The simplest way to run the tests is by calling `make test_pgtap` (which is included in `make test`).
`make` will start up docker-compose using the `docker-compose.test_pgtap.yml` override file.
This file has the appropriate definitions to start a separate docker container and volume to avoid contaminating any local development.
It will then install pgTAP on the new testing database, run `pg_prove` with all `*.sql` files in this directory, and tear down and remove the testing volumes and containers afterwards.
