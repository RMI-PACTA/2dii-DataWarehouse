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
  ('00E4', 'Jyväskylä', 'Jyvaeskylae', 'jyvaeskylae')
  -- End of Initial Testcases, these are listed by number or string in PROD which have this character.
  /* these are the cases which _must_ be covered, becasue they exist in prod */
  /* ('0020', '2', NULL, NULL), */	 
  /* ('0065', 'e', NULL, NULL), */
  /* ('006E', 'n', NULL, NULL), */
  /* ('0061', 'a', NULL, NULL), */
  /* ('0072', 'r', NULL, NULL), */
  /* ('0069', 'i', NULL, NULL), */
  /* ('006F', 'o', NULL, NULL), */
  /* ('0074', 't', NULL, NULL), */
  /* ('006C', 'l', NULL, NULL), */
  /* ('0073', 's', NULL, NULL), */
  /* ('0063', 'c', NULL, NULL), */
  /* ('0064', 'd', NULL, NULL), */
  /* ('0075', 'u', NULL, NULL), */
  /* ('0043', 'C', NULL, NULL), */
  /* ('0067', 'g', NULL, NULL), */
  /* ('0053', 'S', NULL, NULL), */
  /* ('004C', 'L', NULL, NULL), */
  /* ('0070', 'p', NULL, NULL), */
  /* ('006D', 'm', NULL, NULL), */
  /* ('0068', 'h', NULL, NULL), */
  /* ('0079', 'y', NULL, NULL), */
  /* ('0049', 'I', NULL, NULL), */
  /* ('0050', 'P', NULL, NULL), */
  /* ('0041', 'A', NULL, NULL), */
  /* ('0076', 'v', NULL, NULL), */
  /* ('0045', 'E', NULL, NULL), */
  /* ('004D', 'M', NULL, NULL), */
  /* ('0044', 'D', NULL, NULL), */
  /* ('0062', 'b', NULL, NULL), */
  /* ('0054', 'T', NULL, NULL), */
  /* ('006B', 'k', NULL, NULL), */
  /* ('0047', 'G', NULL, NULL), */
  /* ('0066', 'f', NULL, NULL), */
  /* ('0042', 'B', NULL, NULL), */
  /* ('0077', 'w', NULL, NULL), */
  /* ('0048', 'H', NULL, NULL), */
  /* ('004F', 'O', NULL, NULL), */
  /* ('0052', 'R', NULL, NULL), */
  /* ('0046', 'F', NULL, NULL), */
  /* ('004E', 'N', NULL, NULL), */
  /* ('0057', 'W', NULL, NULL), */
  /* ('002E', '.', NULL, NULL), */
  /* ('004B', 'K', NULL, NULL), */
  /* ('0078', 'x', NULL, NULL), */
  /* ('0056', 'V', NULL, NULL), */
  /* ('0055', 'U', NULL, NULL), */
  /* ('0026', '&', NULL, NULL), */
  /* ('002D', '-', NULL, NULL), */
  /* ('007A', 'z', NULL, NULL), */
  /* ('004A', 'J', NULL, NULL), */
  /* ('006A', 'j', NULL, NULL), */
  /* ('002C', ',', NULL, NULL), */
  /* ('002F', '/', NULL, NULL), */
  /* ('0071', 'q', NULL, NULL), */
  /* ('0059', 'Y', NULL, NULL), */
  /* ('0031', '1', NULL, NULL), */
  /* ('005A', 'Z', NULL, NULL), */
  /* ('0032', '2', NULL, NULL), */
  /* ('0028', '(', NULL, NULL), */
  /* ('0029', ')', NULL, NULL), */
  /* ('0030', '0', NULL, NULL), */
  /* ('0033', '3', NULL, NULL), */
  /* ('0058', 'X', NULL, NULL), */
  /* ('0051', 'Q', NULL, NULL), */
  /* ('0034', '4', NULL, NULL), */
  /* ('0035', '5', NULL, NULL), */
  /* ('0027', ''', NULL, NULL), */
  /* ('0036', '6', NULL, NULL), */
  /* ('0037', '7', NULL, NULL), */
  /* ('0038', '8', NULL, NULL), */
  /* ('0039', '9', NULL, NULL), */
  /* ('0023', '#', NULL, NULL), */
  /* ('002B', '+', NULL, NULL), */
  /* ('2019', '’', NULL, NULL), */
  /* ('00A0', ' ', NULL, NULL), */
  /* ('0025', '%', NULL, NULL), */
  /* ('2013', '–', NULL, NULL), */
  /* ('0022', '"', NULL, NULL), */
  /* ('00FC', 'ü', NULL, NULL), */
  /* ('00E9', 'é', NULL, NULL), */
  /* ('00ED', 'í', NULL, NULL), */
  /* ('00C7', 'Ç', NULL, NULL), */
  /* ('003F', '?', NULL, NULL), */
  /* ('003A', ':', NULL, NULL), */
  /* ('00F6', 'ö', NULL, NULL), */
  /* ('00E4', 'ä', NULL, NULL), */
  /* ('0021', '!', NULL, NULL), */
  /* ('0009', '"', NULL, NULL), */
  /* ('00E7', 'ç', NULL, NULL), */
  /* ('00C9', 'É', NULL, NULL), */
  /* ('201D', '”', NULL, NULL), */
  /* ('201C', '“', NULL, NULL), */
  /* ('0040', '@', NULL, NULL), */
  /* ('00F3', 'ó', NULL, NULL), */
  /* ('00FA', 'ú', NULL, NULL), */
  /* ('002A', '*', NULL, NULL), */
  /* ('00E1', 'á', NULL, NULL), */
  /* ('00F8', 'ø', NULL, NULL), */
  /* ('00E6', 'æ', NULL, NULL), */
  /* ('005F', '_', NULL, NULL), */
  /* ('007C', '|', NULL, NULL), */
  /* ('00DF', 'ß', NULL, NULL), */
  /* ('0024', '$', NULL, NULL), */
  /* ('005D', ']', NULL, NULL), */
  /* ('00E2', 'â', NULL, NULL), */
  /* ('005B', '[', NULL, NULL), */
  /* ('00EF', 'ï', NULL, NULL), */
  /* ('00E3', 'ã', NULL, NULL), */
  /* ('005C', '\', NULL, NULL), */
  /* ('00C3', 'Ã', NULL, NULL), */
  /* ('00F1', 'ñ', NULL, NULL), */
  /* ('00AD', '­', NULL, NULL), */
  /* ('003C', '<', NULL, NULL), */
  /* ('00BD', '½', NULL, NULL), */
  /* ('00C2', 'Â', NULL, NULL), */
  /* ('2014', '—', NULL, NULL), */
  /* ('00D6', 'Ö', NULL, NULL), */
  /* ('00E8', 'è', NULL, NULL), */
  /* ('00F4', 'ô', NULL, NULL), */
  /* ('00B7', '·', NULL, NULL), */
  /* ('00B2', '²', NULL, NULL), */
  /* ('00B0', '°', NULL, NULL), */
  /* ('00EA', 'ê', NULL, NULL), */
  /* ('00DC', 'Ü', NULL, NULL), */
  /* ('2026', '…', NULL, NULL), */
  /* ('0060', '`', NULL, NULL), */
  /* ('201A', '‚', NULL, NULL), */
  /* ('00B4', '´', NULL, NULL), */
  /* ('00A6', '¦', NULL, NULL), */
  /* ('20AC', '€', NULL, NULL), */
  /* ('003B', ';', NULL, NULL), */
  /* ('00C5', 'Å', NULL, NULL), */
  /* ('00BA', 'º', NULL, NULL), */
  /* ('00F5', 'õ', NULL, NULL), */
  /* ('003E', '>', NULL, NULL), */
  /* ('009D', '', NULL, NULL), */
  /* ('0192', 'ƒ', NULL, NULL), */
  /* ('00F0', 'ð', NULL, NULL), */
  /* ('00A2', '¢', NULL, NULL), */
  /* ('00AA', 'ª', NULL, NULL), */
  /* ('00EE', 'î', NULL, NULL), */
  /* ('201E', '„', NULL, NULL), */
  /* ('00BE', '¾', NULL, NULL), */
  /* ('00FE', 'þ', NULL, NULL), */
  /* ('00EC', 'ì', NULL, NULL), */
  /* ('2018', '‘', NULL, NULL), */
  /* ('017D', 'Ž', NULL, NULL), */
  ;

  SELECT plan(COUNT(*)::INT * 8) FROM unicode_tests;

  /*-----Test the test cases, to make sure we are covering what we want.-----*/

  /* check that the uniciode string actually contains the listed codepoint. */
  SELECT matches(
    unicode, chr(('x' ||codepoint)::bit(16)::int),
    'Test the test: unicode string contains the listed codepoint \u' ||codepoint || ': ' || quote_literal(unicode)
  ) FROM unicode_tests;

  /* check that the romanized string does not actually contains the listed codepoint. */
  SELECT doesnt_match(
    romanized, chr(('x' ||codepoint)::bit(16)::int),
    'Test the test: romanized string does not contain the listed codepoint \u' ||codepoint || ': ' || quote_literal(romanized)
  ) FROM unicode_tests;

  /* check that the simplified string does not actually contains the listed codepoint. */
  SELECT doesnt_match(
    simplified, chr(('x' ||codepoint)::bit(16)::int),
    'Test the test: simplified string does not contain the listed codepoint \u' ||codepoint || ': ' || quote_literal(simplified)
  ) FROM unicode_tests;

  /* check that the simplified string does not have uppercase letters. */
  SELECT matches(
    simplified, '[a-z0-9 ''&]', --Lowers, digits, Ampersand, space, apostrophe
    'Test the test: simplified string ONLY has restrited subset \u' ||codepoint || ': ' || quote_literal(simplified)
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

ROLLBACK;
