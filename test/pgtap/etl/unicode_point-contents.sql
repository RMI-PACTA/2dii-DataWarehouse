BEGIN;
  SELECT plan(COUNT(*)::INT * 5) FROM etl.unicode_point;

  /* TODO: Write tests coverin strucure, indices AND contents (that the simplified */
  /*   COLUMN actuall partitions ON simplified criteria) */

  /* ---- Test 1: romanized characters are printible ---- */
  SELECT matches(
    romanized_character,
    '^[ -~]*$',
    'Romanization is ASCII printible \u' ||codepoint || ': ' || quote_literal(romanized_character)
  ) FROM etl.unicode_point;

  /* ---- Test 2: simplified characters are simplified ---- */
  SELECT matches(
    simple_romanized_character,
    '^[a-z0-9 ''&]*$',
    'Simplified matches simple regex \u' ||codepoint || ': ' || quote_literal(simple_romanized_character)
  ) FROM etl.unicode_point;

  /* ---- Test 3, 4: unicode characters do or do not match, if pre-simplified ---- */
  SELECT is(
    lower(unicode_character),
    simple_romanized_character,
    'Pre-simplified unicode match simplified characters \u' ||codepoint || ': ' || quote_literal(simple_romanized_character)
  ) FROM etl.unicode_point
  WHERE is_simplified;

  SELECT isnt(
    lower(unicode_character),
    simple_romanized_character,
    'Non-simplified unicode do not match simplified characters \u' ||codepoint || ': ' || quote_literal(simple_romanized_character)
  ) FROM etl.unicode_point
  WHERE NOT is_simplified;

  /* ---- Test 5, 6: unicode characters do or do not match, if pre-simplified ---- */
  SELECT is(
    lower(romanized_character),
    simple_romanized_character,
    'Pre-simplified romanized characters match simplified characters \u' ||codepoint || ': ' || quote_literal(simple_romanized_character)
  ) FROM etl.unicode_point
  WHERE is_simplified
  OR category NOT IN (
    'African',
    'Punctuation'
  );

  SELECT isnt(
    lower(romanized_character),
    simple_romanized_character,
    'Non-simple romanized characters match simplified characters \u' ||codepoint || ': ' || quote_literal(simple_romanized_character)
  ) FROM etl.unicode_point
  WHERE NOT is_simplified
  AND category IN (
    'African',
    'Punctuation'
  );

  /* ---- Test 5: Categories are known---- */
  SELECT ok(
    category IN (
      'ASCII letters',
      'African',
      'Control',
      'Digit',
      'Latin letters',
      'Miscellaneous',
      'Non-European Latin letters',
      'Phonetic',
      'Pinyin',
      'Punctuation',
      'Whitespace'
    ),
    'Category defined FOR codepoint \u' ||codepoint || ': ' || quote_literal(category)
  ) FROM etl.unicode_point;

ROLLBACK;
