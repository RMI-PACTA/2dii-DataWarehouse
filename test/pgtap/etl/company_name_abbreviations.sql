BEGIN;
  SELECT plan(9);

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


ROLLBACK;
