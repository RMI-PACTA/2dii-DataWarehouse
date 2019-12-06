BEGIN;
  SELECT plan(2);
  SELECT is(
    etl.normalize_accents_lowercase('Jyväskylä'),
    'Jyvaeskylae',
    'Test transliteration of ä TO ae'
  );
  SELECT isnt(
    etl.normalize_accents_lowercase('Jyväskylä'),
    'Jyvaskyla',
    'Test transliteration of ä TO ae'
  );
ROLLBACK;
