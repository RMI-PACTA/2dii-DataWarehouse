BEGIN;
  SELECT plan(6);
  /* TODO: Write tests for etl.clean_whitespace */

  SELECT is(etl.has_nonsimplified_characters(' '), true, 'Check character is non-simplified \u00A0 - Nonbreaking Space');
  SELECT is(etl.has_nonsimplified_characters('foo bar'), true, 'Check string is non-simplified \u00A0 - Nonbreaking Space');
  SELECT is(etl.romanize_unicode(' '), ' ', 'Romanize single character \u00A0 - Nonbreaking Space');
  SELECT is(etl.romanize_unicode('foo bar'), 'foo bar', 'Romanize string containing \u00A0 - Nonbreaking Space');

  SELECT is(
    etl.romanize_unicode('Jyväskylä'),
    'Jyvaeskylae',
    'Test transliteration of ä TO ae'
  );
  SELECT isnt(
    etl.romanize_unicode('Jyväskylä'),
    'Jyvaskyla',
    'Test transliteration of ä TO ae'
  );
ROLLBACK;
