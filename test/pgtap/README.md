# pgTAP tests

These tests are intended to be run with pgTAP.
The simplest way to run the tests is by calling `make test_pgtap` (which is included in `make test`).
`make` will start up docker-compose using the `docker-compose.test_pgtap.yml` override file.
This file has the appropriate definitions to start a separate docker container and volume to avoid contaminating any local development.
It will then install pgTAP on the new testing database, run `pg_prove` with all `*.sql` files in this directory, and tear down and remove the testing volumes and containers afterwards.

These tests are organized by the objects they are testing, with the schema as a directory, and the object (table or function) as the filename.
For example, the tests for function `etl.regexp_escape`, are located in `/test/pgtap/etl/regexp_escape.sql`.

pgTAP tests all accept a description argument, which describes the purpose of the test.
In many of the tests written, this description is filled in, at least in part, dynamically, based on a `SELECT` statement.

## Examples

the pgTAP syntax for the test `is()`, which is the most common test in what we have written, is:

```SQL
SELECT is(:have, :want, :description);
```

where
`:have` is replaced by a SQL expression to be tested,
`:want` is replaced by a SQL expression with the expected results, and
`description` is a string describing what is being tested, useful for identifying and debugging test failures.

In `/test/pgtap/etl/regexp_escape.sql`, one of the tests is:

```SQL
SELECT is(
  etl.regexp_escape('!'), --:have
  '\!', --:want
  'Test regexp_escape: ' || quote_literal('!')); --description
```

Note that the description is a constructed string, made using the `||` concatenator in `PL/SQL`, connecting the generic test description, with the quoted literal version of character `!`.
When run, this string will evaluate to: `Test regexp_escape: '!'`

Similarly, some of the tests initiate a table with test data, and run multiple tests against that data, such as in `/test/pgtap/etl/unicode_functions.sql`, which creates a `TEMP TABLE` called `unicode_tests`.
The tests in that file, make `SELECT` statements from that table, such as:

```SQL
/* check that the strings have non-simplified characters */
SELECT is(
  etl.simplify_unicode(unicode), --:have
  simplified, --:want
  'Simplify unicode string \u' ||codepoint || ': ' || quote_literal(unicode) --:description
) FROM unicode_tests;
```

Notice here that the structure is `SELECT is() FROM <table>`, and the columns from the table are available to use in the `is()` function.
They are being used here both in constructing the `:have` argument, as well as the `:description`.
The description assembles both the `codepoint` and the `unicode` elements from the table, giving for example: `Simplify unicode string \u00E4': 'ä'`
