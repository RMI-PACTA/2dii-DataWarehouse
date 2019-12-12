BEGIN;
  SELECT plan(2);
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
