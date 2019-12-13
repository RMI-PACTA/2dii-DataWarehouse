BEGIN;

  /* TODO: Write tests for etl.clean_whitespace */

  CREATE TEMPORARY TABLE unicode_tests (
    codepoint TEXT,
    unicode TEXT,
    romanized TEXT,
    simplified TEXT
  );

  INSERT INTO unicode_tests (codepoint, unicode, romanized, simplified) VALUES
  ('00A0', ' ', ' ', ' '),
  ('00A0', 'foo bar', 'foo bar', 'foo bar'),
  ('00E4', 'ä', 'ae', 'ae'),
  ('00E4', 'Jyväskylä', 'Jyvaeskylae', 'Jyvaeskylae')
  ;

  SELECT plan(COUNT(*)::INT * 7) FROM unicode_tests;

  /*-----Test the test cases, to make sure we are covering what we want.-----*/

  /* check that the uniciode string actually contains the listed codepoint. */
  SELECT matches(
    unicode, chr(('x' ||codepoint)::bit(16)::int),
    'Test the test: unicode string contains the listed codepoint \u' ||codepoint || ': ' || quote_literal(unicode)
  ) FROM unicode_tests;

  /* check that the uniciode string actually contains the listed codepoint. */
  SELECT doesnt_match(
    romanized, chr(('x' ||codepoint)::bit(16)::int),
    'Test the test: romanized string does not contain the listed codepoint \u' ||codepoint || ': ' || quote_literal(romanized)
  ) FROM unicode_tests;

  /* check that the uniciode string actually contains the listed codepoint. */
  SELECT doesnt_match(
    simplified, chr(('x' ||codepoint)::bit(16)::int),
    'Test the test: simplified string does not contain the listed codepoint \u' ||codepoint || ': ' || quote_literal(simplified)
  ) FROM unicode_tests;

  /* ------ Run tests again the functions ------ */

  /* check that the strings have non-simplified characters */
  SELECT is(etl.has_nonsimplified_characters(unicode),
    true,
    'Check unicode string is non-simplified \u' ||codepoint || ': ' || quote_literal(unicode)
  ) FROM unicode_tests;

  /* check that the simplified strings have only simplified characters */
  SELECT is(etl.has_nonsimplified_characters(simplified),
    false,
    'Check simplified string is simplified \u' ||codepoint || ': ' || quote_literal(simplified)
  ) FROM unicode_tests;

  /* check that the strings have non-simplified characters */
  SELECT is(etl.romanize_unicode(unicode),
    romanized,
    'Romanize unicode string \u' ||codepoint || ': ' || quote_literal(unicode)
  ) FROM unicode_tests;

  /* check that the strings have non-simplified characters */
  SELECT is(etl.simplify_unicode(unicode),
    simplified,
    'Simplify unicode string \u' ||codepoint || ': ' || quote_literal(unicode)
  ) FROM unicode_tests;

  /* SELECT is(etl.has_nonsimplified_characters(' '), true, 'Check character is non-simplified \u00A0 - Nonbreaking Space'); */
  /* SELECT is(etl.has_nonsimplified_characters('foo bar'), true, 'Check string is non-simplified \u00A0 - Nonbreaking Space'); */
  /* SELECT is(etl.romanize_unicode(' '), ' ', 'Romanize single character \u00A0 - Nonbreaking Space'); */
  /* SELECT is(etl.romanize_unicode('foo bar'), 'foo bar', 'Romanize string containing \u00A0 - Nonbreaking Space'); */

ROLLBACK;
