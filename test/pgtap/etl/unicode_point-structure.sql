BEGIN;
  SELECT plan(19);

  SELECT has_table(
   'etl', 'unicode_point',
    '000_001_003_b_1 etl.unicode_point table exists'
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
    ]
  );

  SELECT skip(14);
  /* SELECT col_type_is('etl', 'unicode_point', 'unicode_character', 'TEXT'); */
  /* SELECT col_type_is('etl', 'unicode_point', 'codepoint', 'TEXT'); */
  /* SELECT col_type_is('etl', 'unicode_point', 'romanized_character', 'TEXT'); */
  /* SELECT col_type_is('etl', 'unicode_point', 'simple_romanized_character', 'TEXT'); */
  /* SELECT col_type_is('etl', 'unicode_point', 'description', 'TEXT'); */
  /* SELECT col_type_is('etl', 'unicode_point', 'block_name', 'TEXT'); */
  /* SELECT col_type_is('etl', 'unicode_point', 'category', 'TEXT'); */
  /* SELECT col_type_is('etl', 'unicode_point', 'notes', 'TEXT'); */
  /* SELECT col_type_is('etl', 'unicode_point', 'is_simplified', 'TEXT'); */

  /* SELECT col_not_null('etl', 'unicode_point', 'unicode_character'); */
  /* SELECT col_not_null('etl', 'unicode_point', 'codepoint'); */
  /* SELECT col_not_null('etl', 'unicode_point', 'romanized_character'); */
  /* SELECT col_not_null('etl', 'unicode_point', 'simple_romanized_character'); */
  /* SELECT col_not_null('etl', 'unicode_point', 'is_simplified'); */

  SELECT has_index(
    'etl', 'unicode_point',
    'ix_unicode_point_cover_simple',
    ARRAY[
      'unicode_character',
      'is_simplified',
      'simple_romanized_character'
    ],
    '000_001_003_b_1 has cover index.'
  );

  SELECT has_index(
    'etl', 'unicode_point',
    'ix_unicode_point_codepoint',
    'codepoint',
    '000_001_003_b_1 has codepoint index.'
  );

  SELECT has_index(
    'etl', 'unicode_point',
    'ix_unicode_point_block_name',
    'block_name'
    '000_001_003_b_1 has block_name index.'
  );


ROLLBACK;

  /* unicode_character TEXT PRIMARY KEY, */
  /* codepoint TEXT UNIQUE NOT NULL, */
  /* romanized_character TEXT NOT NULL, */
  /* simple_romanized_character TEXT NOT NULL, */
  /* description TEXT, */
  /* block_name TEXT, */
  /* category TEXT, */
  /* notes TEXT, */
  /* is_simplified BOOLEAN NOT NULL DEFAULT FALSE */
