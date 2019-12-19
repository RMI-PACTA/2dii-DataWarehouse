BEGIN;
  SELECT plan((
    9
    + (SELECT count(*) FROM etl.company_name_abbreviations) * 3
    + (SELECT count(*) FROM etl.company_name_abbreviations) ^ 2
  )::INT);

  SELECT has_table(
    'etl', 'company_name_abbreviations',
    'etl.company_name_abbreviations table exists'
  );

  SELECT columns_are(
    'etl', 'company_name_abbreviations',
    ARRAY[
      'to_replace',
      'replacement',
      'regexp_flags'
    ]
  );

  SELECT col_type_is(
    'etl', 'company_name_abbreviations',
    'to_replace',
    'text',
    'column "to_replace" is text'
  );
  SELECT col_type_is(
    'etl', 'company_name_abbreviations',
    'replacement',
    'text',
    'column "replacement" is text'
  );
  SELECT col_type_is(
    'etl', 'company_name_abbreviations',
    'regexp_flags',
    'text',
    'column "regexp_flags" is text'
  );

  SELECT col_not_null(
    'etl', 'company_name_abbreviations',
    'to_replace',
    'column "to_replace" is text'
  );
  SELECT col_not_null(
    'etl', 'company_name_abbreviations',
    'replacement',
    'column "replacement" is text'
  );
  SELECT col_not_null(
    'etl', 'company_name_abbreviations',
    'regexp_flags',
    'column "regexp_flags" is text'
  );

  SELECT has_index(
    'etl', 'company_name_abbreviations',
    'ix_company_name_replacement_cover',
    ARRAY[
      'to_replace',
      'replacement',
      'regexp_flags'
    ],
    'etl.company_name_abbreviations has cover index.'
  );

  SELECT is(
    to_replace,
    lower(to_replace),
    'String to to find for replacement should be lowercase'
  ) FROM etl.company_name_abbreviations;

  SELECT is(
    replacement,
    lower(replacement),
    'Replacement string should be lowercase'
  ) FROM etl.company_name_abbreviations;

  /* Check that the regex flags are acceptable, see: */
  /* https://github.com/postgres/postgres/blob/master/src/backend/utils/adt/regexp.c */
  SELECT ok(
    regexp_flags ~ '^[gbceimnpqstwx]*$',
    'Validate regex flags for ' || to_replace || ' ('|| regexp_flags ||')'
  ) FROM etl.company_name_abbreviations;

  /* Check that the replacements aren't in the search strings, to avoid */
  /* ordering or race conditions. */
  SELECT doesnt_imatch(
    x.replacement,
    y.to_replace,
    'Check that name replacements are not in search patterns'
  ) FROM etl.company_name_abbreviations As x
  CROSS JOIN etl.company_name_abbreviations As y;

ROLLBACK;
