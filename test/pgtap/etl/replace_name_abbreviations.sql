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
  ('this and that', 'this & that', '''and'' to ampersand'),
  ('THIS AND THAT', 'this & that', '''and'' case-insensitive'),
  ('this  and  that', 'this & that', '''and'' with multiple spaces'),
  ('this	and that', 'this & that', '''and'' with tab before'),
  ('bandcamp', 'bandcamp', '''and'' in middle of word not replaced'),
  ('band camp', 'band camp', '''and'' at end of word not replaced'),
  ('robot android', 'robot android', '''and'' at beginning of word not replaced')
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
