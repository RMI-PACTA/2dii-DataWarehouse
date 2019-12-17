BEGIN;

  SELECT plan(25);

  SELECT has_function(
   'etl', 'regexp_escape',
    'etl.regexp_escape function exists'
  );

  SELECT is(
    etl.regexp_escape('!'),
    '\!',
    'Test regexp_escape: ' || quote_literal('!'));
  SELECT is(
    etl.regexp_escape('$'),
    '\$',
    'Test regexp_escape: ' || quote_literal('$'));
  SELECT is(
    etl.regexp_escape('('),
      '\(',
        'Test regexp_escape: ' || quote_literal('('));
        SELECT is(
          etl.regexp_escape(')'),
        '\)',
      'Test regexp_escape: ' || quote_literal(')'));
  SELECT is(
    etl.regexp_escape('*'),
    '\*',
    'Test regexp_escape: ' || quote_literal('*'));
  SELECT is(
    etl.regexp_escape('+'),
    '\+',
    'Test regexp_escape: ' || quote_literal('+'));
  SELECT is(
    etl.regexp_escape('.'),
    '\.',
    'Test regexp_escape: ' || quote_literal('.'));
  SELECT is(
    etl.regexp_escape(':'),
    '\:',
    'Test regexp_escape: ' || quote_literal(':'));
  SELECT is(
    etl.regexp_escape('<'),
    '\<',
    'Test regexp_escape: ' || quote_literal('<'));
  SELECT is(
    etl.regexp_escape('='),
    '\=',
    'Test regexp_escape: ' || quote_literal('='));
  SELECT is(
    etl.regexp_escape('>'),
    '\>',
    'Test regexp_escape: ' || quote_literal('>'));
  SELECT is(
    etl.regexp_escape('?'),
    '\?',
    'Test regexp_escape: ' || quote_literal('?'));
  SELECT is(
    etl.regexp_escape('['),
    '\[',
    'Test regexp_escape: ' || quote_literal('['));
  SELECT is(
    etl.regexp_escape('\'),
    '\\',
    'Test regexp_escape: ' || quote_literal('\'));
  SELECT is(
    etl.regexp_escape(']'),
    '\]',
    'Test regexp_escape: ' || quote_literal(']'));
  SELECT is(
    etl.regexp_escape('^'),
    '\^',
    'Test regexp_escape: ' || quote_literal('^'));
  SELECT is(
    etl.regexp_escape('{'),
    '\{',
    'Test regexp_escape: ' || quote_literal('{'));
  SELECT is(
    etl.regexp_escape('|'),
    '\|',
    'Test regexp_escape: ' || quote_literal('|'));
  SELECT is(
    etl.regexp_escape('}'),
    '\}',
    'Test regexp_escape: ' || quote_literal('}'));
  SELECT is(
    etl.regexp_escape('-'),
    '\-',
    'Test regexp_escape: ' || quote_literal('-'));

  SELECT is(
    etl.regexp_escape('test(1) > Foo*'),
    'test\(1\) \> Foo\*',
    'Test case from https://stackoverflow.com/a/45741630'
  );

  SELECT is(
    etl.regexp_escape('Normal text with no special characters'),
    'Normal text with no special characters',
    'Test regexp_escape: Normal text with no special characters'
  );

  SELECT is(
    etl.regexp_escape('Slightly longer text with a few special characters, but no regexed ones, such as tab	or line break
      this is nice'),
    'Slightly longer text with a few special characters, but no regexed ones, such as tab	or line break
      this is nice',
    'Test regexp_escape: string with special whitespace'
  );

  SELECT is(
    etl.regexp_escape('Short words, (some) punctuation. Does it work?'),
    'Short words, \(some\) punctuation\. Does it work\?',
    'Test regexp_escape: string with punctuation'
  );

ROLLBACK;

