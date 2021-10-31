BEGIN;
  SELECT plan(21);

  SELECT has_table(
   'etl', 'unicode_point',
    'etl.unicode_point table exists'
  );

  SELECT columns_are(
    'etl', 'unicode_point',
    ARRAY[
      'unicode_character',
      'codepoint',
      'romanized_character',
      'simple_romanized_character',
      'description',
      'block_name',
      'category',
      'notes',
      'is_simplified'
    ],
    'etl.unicode_point columns are correct'
  );

  SELECT col_type_is('etl', 'unicode_point', 'unicode_character', 'text', 'column "unicode_character" is text');
  SELECT col_type_is('etl', 'unicode_point', 'codepoint', 'text', 'column "codepoint" is text');
  SELECT col_type_is('etl', 'unicode_point', 'romanized_character', 'text', 'column "romanized_character" is text');
  SELECT col_type_is('etl', 'unicode_point', 'simple_romanized_character', 'text', 'column "simple_romanized_character" is text');
  SELECT col_type_is('etl', 'unicode_point', 'description', 'text', 'column "description" is text');
  SELECT col_type_is('etl', 'unicode_point', 'block_name', 'text', 'column "block_name" is text');
  SELECT col_type_is('etl', 'unicode_point', 'category', 'text', 'column "category" is text');
  SELECT col_type_is('etl', 'unicode_point', 'notes', 'text', 'column "notes" is text');
  SELECT col_type_is('etl', 'unicode_point', 'is_simplified', 'boolean', 'column "is_simplified" is boolean');

  SELECT col_not_null('etl', 'unicode_point', 'unicode_character', 'column "unicode_character" is not NULL');
  SELECT col_not_null('etl', 'unicode_point', 'codepoint', 'column "codepoint" is not NULL');
  SELECT col_not_null('etl', 'unicode_point', 'romanized_character', 'column "romanized_character" is not NULL');
  SELECT col_not_null('etl', 'unicode_point', 'simple_romanized_character', 'column "simple_romanized_character" is not NULL');
  SELECT col_not_null('etl', 'unicode_point', 'is_simplified', 'is_simplified');

  SELECT has_pk('etl', 'unicode_point', 'etl.unicode_point has a PK');
  SELECT col_is_pk('etl', 'unicode_point', 'unicode_character', 'unicode.character is the PK for etl.unicode_point');

  SELECT has_index(
    'etl', 'unicode_point',
    'ix_unicode_point_cover_simple',
    ARRAY[
      'unicode_character',
      'is_simplified',
      'simple_romanized_character'
    ],
    'etl.unicode_point has cover index.'
  );

  SELECT has_index(
    'etl', 'unicode_point',
    'ix_unicode_point_codepoint',
    'codepoint',
    'etl.unicode_point has codepoint index.'
  );

  SELECT has_index(
    'etl', 'unicode_point',
    'ix_unicode_point_block_name',
    'block_name'
    'etl.unicode_point has block_name index.'
  );

ROLLBACK;
