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
  ('and more', 'and more', '''and'' at beginning of string not replaced (~* ^and\s)'),
  ('foo and', 'foo and', '''and'' at end of string not replaced (~* \sand$)'),
  /* \s+en\s+ */
  ('dit en dat', 'dit & dat', '''en'' to ampersand'),
  ('DIT EN DAT', 'DIT & DAT', '''en'' to ampersand'),
  ('Levenshtein', 'Levenshtein', '''en'' in middle of word not replaced'),
  ('dit	en  dat', 'dit & dat', '''en'' with spacings'),
  ('ten thousand', 'ten thousand', '''en'' at end of word not replaced'),
  ('The End', 'The End', '''en'' at beginning of word not replaced'),
  ('en more', 'en more', '''en'' at beginning of string not replaced (~* ^en\s)'),
  ('foo en', 'foo en', '''en'' at end of string not replaced (~* \sen$)'),
  /* \s+och\s+ */
  ('A och B', 'A & B', '''och'' to ampersand'),
  ('A OCH B', 'A & B', '''och'' case-insensitive'),
  ('A	och  B', 'A & B', '''och'' alternative_spacing'),
  ('Sochi', 'Sochi', '''och'' in middle of word not replaced'),
  ('tengo ocho llamas', 'tengo ocho llamas', '''och'' at beginning of word not replaced'),
  ('Loch Ness', 'Loch Ness', '''och'' at end of word not replaced'),
  ('och more', 'och more', '''och'' at beginning of string not replaced (~* ^och\s)'),
  ('foo och', 'foo och', '''och'' at end of string not replaced (~* \soch$)'),
  /* \s+und\s+ */
  ('A und B', 'A & B', '''und'' to ampersand'),
  ('A UND B', 'A & B', '''und'' case-insensitive'),
  ('A	und  B', 'A & B', '''und'' alternative_spacing'),
  ('Bundesliga', 'Bundesliga', '''und'' in middle of word not replaced'),
  ('towed under', 'towed under', '''und'' at beginning of word not replaced'),
  ('fund manager', 'fund manager', '''und'' at end of word not replaced'),
  ('und more', 'und more', '''und'' at beginning of string not replaced (~* ^und\s)'),
  ('foo und', 'foo und', '''und'' at end of string not replaced (~* \sund$)'),
  /* ampersand */
  ('this & that', 'this & that', 'ampersand does not change'),
  /* (inactive) */
  ('noparens inactive', 'noparens inactive', '''inactive'' without parens not replaced'),
  ('foobar(inactive)', 'foobar', NULL),
  ('foobar (inactive)', 'foobar ', '''(inactive)'' with spaces does not remove spaces'),
  ('foobar	(inactive)', 'foobar	', '''inactive'' with tabs'),
  ('(inactive) outdated organization', ' outdated organization', '''(inactive)'' at beginning of string does not replace space'),
  ('inactive outdated organization', 'inactive outdated organization', '''inactive'' without parens not replaced'),
  /* aktg */
  ('foobar aktg', 'foobar$ag', NULL),
  ('foobar-aktg', 'foobar-ag', NULL),
  ('Foobar AKTG', 'Foobar$ag', NULL),
  ('foo aktg bar', 'foo ag bar', NULL),
  ('baraktgfoo', 'baragfoo', NULL),
  /* aktiengesellschaft */
  ('foobar aktiengesellschaft', 'foobar$ag', NULL),
  ('foobar-aktiengesellschaft', 'foobar-ag', NULL),
  ('Foobar AKTIENGESELLSCHAFT', 'Foobar$ag', NULL),
  ('Foobar Aktiengesellschaft', 'Foobar$ag', NULL),
  ('foo aktiengesellschaft bar', 'foo ag bar', NULL),
  ('baraktiengesellschaftfoo', 'baragfoo', NULL),
  /* associate */
  ('testing associate', 'testing assoc', '''associate'' reduces to assoc'),
  ('Testing Associate', 'Testing assoc', NULL),
  ('foo, bar, & associate', 'foo, bar, & assoc', NULL),
  ('Foo, Bar, & Associate', 'Foo, Bar, & assoc', NULL),
  /* associated, Note the d at the end. */
  ('Associated Media', 'assocd Media', '''associated'' reduces to assocd'),
  ('foo associate bar', 'foo assoc bar', NULL),
  /* associates */
  ('testing associates', 'testing assoc', '''associates'' reduces to assoc'),
  ('Testing Associates', 'Testing assoc', NULL),
  ('foo, bar, & associates', 'foo, bar, & assoc', NULL),
  ('Foo, Bar, & Associates', 'Foo, Bar, & assoc', NULL),
  /* berhad */
  ('foobar berhad', 'foobar$bhd', NULL),
  ('Foobar Berhad', 'Foobar$bhd', NULL),
  ('foo berhad bar', 'foo bhd bar', NULL),
  ('fooberhadbar', 'foobhdbar', NULL),
  /* company */
  ('foobar company', 'foobar$co', NULL),
  ('FooBar Company', 'FooBar$co', NULL),
  ('foo company bar', 'foo co bar', NULL),
  ('Foo Company Bar', 'Foo co Bar', NULL),
  ('Company Foobar', 'co Foobar', NULL),
  ('Foo BarCompany', 'Foo Barco', '~* company, !~* \scompany'),
  ('foo barcompany', 'foo barco', NULL),
  /* corporation */
  ('foobar corporation', 'foobar$corp', NULL),
  ('FooBar Corporation', 'FooBar$corp', NULL),
  ('foobar corporation private', 'foobar corp private', NULL),
  ('FooBar Corporation Private', 'FooBar corp Private', NULL),
  ('foobar (corporation)', 'foobar (corp)', NULL),
  ('corporation foobar', 'corp foobar', NULL),
  ('foobar bancorporation', 'foobar bancorp', NULL),
  ('foobar incorporation', 'foobar incorp', NULL),
  /* designated\s+activity\s+company */
  ('foobar designated activity company', 'foobar$dac', NULL),
  ('Foobar Designated Activity Company', 'Foobar$dac', NULL),
  ('foobar designated activity co', 'foobar$dac', 'company collapses to co'),
  ('Foobar Designated Activity Co', 'Foobar$dac', 'company collapses to co'),
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
  ('foobar ag', 'foobar$ag', NULL),
  ('FooBar AG', 'FooBar$ag', NULL),
  ('FooBar	AG', 'FooBar$ag', 'tab whitespace'),
  ('big bag', 'big bag', 'ag suffix must have space before.'),
  ('foo ag bar', 'foo ag bar', NULL),
  ('foobar ag ag', 'foobar ag$ag', NULL),
  /* \s+as$ */
  /* \s+asa$ */
  /* \s+bhd$ */
  ('Foobar bhd', 'Foobar$bhd', NULL),
  ('Foobar Bhd', 'Foobar$bhd', NULL),
  ('Foobar	Bhd', 'Foobar$bhd', 'tab whitespace'),
  ('foobhdbar', 'foobhdbar', NULL),
  ('foo bhd bar', 'foo bhd bar', NULL),
  /* \s+bsc$ */
  /* \s+bv$ */
  /* \s+co$ */
  ('Foobar co', 'Foobar$co', NULL),
  ('Foobar Co', 'Foobar$co', NULL),
  ('Foobar	Co', 'Foobar$co', 'tab whitespace'),
  ('Foobar & Co', 'Foobar &$co', NULL),
  ('foocobar', 'foocobar', NULL),
  ('foo co bar', 'foo co bar', NULL),
  /* \s+corp$ */
  ('Foobar corp', 'Foobar$corp', NULL),
  ('Foobar Corp', 'Foobar$corp', NULL),
  ('Foobar	Corp', 'Foobar$corp', 'tab whitespace'),
  ('Foocorp', 'Foocorp', 'replacing a suffix needs whitespace'),
  ('corpFoo', 'corpFoo', NULL),
  ('Scorpion', 'Scorpion', 'do not replace corp in middle of word'),
  ('foo corp bar', 'foo corp bar',  'do not replace corp in middle of string'),
  /* \s+cv$ */
  /* \s+dac$ */
  ('foobar dac', 'foobar$dac', NULL),
  ('Foobar Dac', 'Foobar$dac', NULL),
  ('Foobar	Dac', 'Foobar$dac', 'tab whitespace'),
  ('Big Bad Ac', 'Big Bad Ac', '''d ac'' does not replace on dac'),
  ('Foodac', 'Foodac', NULL),
  ('foo dac bar', 'foo dac bar', NULL),
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
    COALESCE(quote_literal(description) || ': ', '') ||
      quote_literal(test_string) || ' -> ' ||
      quote_literal(expected)
  ) FROM name_abbreviation_tests;

ROLLBACK;
