BEGIN;

  CREATE TEMPORARY TABLE name_abbreviation_tests (
    test_string TEXT UNIQUE NOT NULL,
    expected TEXT NOT NULL,
    description TEXT
  );

  INSERT INTO name_abbreviation_tests (
    test_string,
    expected,
    description
  ) VALUES
  /* \s+and\s+ */
  ('this and that', 'this & that', '''and'' to ampersand'),
  ('THIS AND THAT', 'THIS & THAT', '''and'' case-insensitive'),
  ('this  and  that', 'this & that', '''and'' with multiple spaces'),
  ('this	and that', 'this & that', '''and'' with tab before'),
  ('bandcamp', 'bandcamp', '''and'' in middle of word not replaced'),
  ('band camp', 'band camp', '''and'' at end of word not replaced'),
  ('robot android', 'robot android', '''and'' at beginning of word not replaced'),
  /* \s+en\s+ */
  ('dit en dat', 'dit & dat', '''en'' to ampersand'),
  ('DIT EN DAT', 'DIT & DAT', '''en'' to ampersand'),
  ('Levenshtein', 'Levenshtein', '''en'' in middle of word not replaced'),
  ('dit	en  dat', 'dit & dat', '''en'' with spacings'),
  ('ten thousand', 'ten thousand', '''en'' at end of word not replaced'),
  ('The End', 'The End', '''en'' at beginning of word not replaced'),
  /* \s+och\s+ */
  ('A och B', 'A & B', '''och'' to ampersand'),
  ('A OCH B', 'A & B', '''och'' case-insensitive'),
  ('A	och  B', 'A & B', '''och'' alternative_spacing'),
  ('Sochi', 'Sochi', '''och'' in middle of word not replaced'),
  ('tengo ocho llamas', 'tengo ocho llamas', '''och'' at beginning of word not replaced'),
  ('Loch Ness', 'Loch Ness', '''och'' at end of word not replaced'),
  /* \s+und\s+ */
  ('A und B', 'A & B', '''und'' to ampersand'),
  ('A UND B', 'A & B', '''und'' case-insensitive'),
  ('A	und  B', 'A & B', '''und'' alternative_spacing'),
  ('Bundesliga', 'Bundesliga', '''und'' in middle of word not replaced'),
  ('towed under', 'towed under', '''und'' at beginning of word not replaced'),
  ('fund manager', 'fund manager', '''und'' at end of word not replaced'),
  /* (inactive) */
  ('noparens inactive', 'noparens inactive', '''inactive'' without parens not replaced'),
  ('foobar(inactive)', 'foobar', NULL),
  ('foobar (inactive)', 'foobar ', '''(inactive)'' with spaces does not remove spaces'),
  ('foobar	(inactive)', 'foobar	', '''inactive'' with tabs'),
  ('(inactive) outdated organization', ' outdated organization', '''(inactive)'' at beginning of string does not replace space'),
  ('inactive outdated organization', 'inactive outdated organization', '''inactive'' without parens not replaced'),
  /* aktg */
  ('foobar aktg', 'foobar ag', NULL),
  ('foobar-aktg', 'foobar-ag', NULL),
  ('Foobar AKTG', 'Foobar ag', NULL),
  ('foo aktg bar', 'foo ag bar', NULL),
  /* aktiengesellschaft */
  ('foobar aktiengesellschaft', 'foobar ag', NULL),
  ('foobar-aktiengesellschaft', 'foobar-ag', NULL),
  ('Foobar AKTIENGESELLSCHAFT', 'Foobar ag', NULL),
  ('Foobar Aktiengesellschaft', 'Foobar ag', NULL),
  ('foo aktiengesellschaft bar', 'foo ag bar', NULL),
  /* associate */
  /* associates */
  /* berhad */
  /* company */
  /* corporation */
  /* designated\s+activity\s+company */
  /* develop */
  /* development */
  /* financial */
  /* generation */
  /* government */
  /* group */
  /* holding */
  /* holdings */
  /* incorporated */
  /* international */
  /* investment */
  /* limited\s+partnership */
  /* limited */
  /* ltd\s+liability\s+co */
  /* partner */
  /* partners */
  /* public\s+ltd\s+co */
  /* resource */
  /* resources */
  /* shipping */
  /* \s+ag$ */
  /* \s+as$ */
  /* \s+asa$ */
  /* \s+bhd$ */
  /* \s+bsc$ */
  /* \s+bv$ */
  /* \s+co$ */
  /* \s+corp$ */
  /* \s+cv$ */
  /* \s+dac$ */
  /* \s+govt$ */
  /* \s+hldgs$ */
  /* \s+inc$ */
  /* \s+intl$ */
  /* \s+llc$ */
  /* \s+lp$ */
  /* \s+lt$ */
  /* \s+ltd$ */
  /* \s+nv$ */
  /* \s+pcl$ */
  /* \s+plc$ */
  /* \s+pt$ */
  /* \s+pte$ */
  /* \s+sa$ */
  /* \s+sarl$ */
  /* \s+sas$ */
  /* \s+se$ */
  /* \s+spa$ */
  /* \s+srl$ */

  /* test non-simplified characters */
  ('Jyväskylä', 'Jyväskylä', 'unicode characters not affected'),
  ('Ä änd B', 'Ä änd B', 'unicode characters not affected'),
  ('Ä and B', 'Ä & B', 'unicode characters not affected'),

  /* empty string */
  ('', '', 'Empty string')
;

  SELECT plan(count(*)::INT) FROM name_abbreviation_tests;

  SELECT is(
    etl.replace_name_abbreviations(test_string),
    expected,
    COALESCE(description || ': ', '') ||
      quote_literal(test_string) || ' -> ' ||
      quote_literal(expected)
  ) FROM name_abbreviation_tests;

ROLLBACK;
