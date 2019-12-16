BEGIN;

  /* TODO: Write tests for etl.clean_whitespace */

  CREATE TEMPORARY TABLE unicode_tests (
    codepoint TEXT,
    unicode TEXT,
    romanized TEXT,
    simplified TEXT,
    pre_simplified BOOLEAN
  );

  INSERT INTO unicode_tests (
    codepoint, unicode, romanized, simplified, pre_simplified
  ) VALUES
  /* ('0009', '"', NULL, NULL, false), */
  /* ('0020', '2', NULL, NULL, false), */	 
  /* ('0021', '!', NULL, NULL, false), */
  /* ('0022', '"', NULL, NULL, false), */
  /* ('0023', '#', NULL, NULL, false), */
  /* ('0024', '$', NULL, NULL, false), */
  /* ('0025', '%', NULL, NULL, false), */
  /* ('0026', '&', NULL, NULL, false), */
  /* ('0027', ''', NULL, NULL, false), */
  /* ('0028', '(', NULL, NULL, false), */
  /* ('0029', ')', NULL, NULL, false), */
  /* ('002A', '*', NULL, NULL, false), */
  /* ('002B', '+', NULL, NULL, false), */
  /* ('002C', ',', NULL, NULL, false), */
  /* ('002D', '-', NULL, NULL, false), */
  /* ('002E', '.', NULL, NULL, false), */
  /* ('002F', '/', NULL, NULL, false), */
  /* ('0030', '0', NULL, NULL, false), */
  /* ('0031', '1', NULL, NULL, false), */
  /* ('0032', '2', NULL, NULL, false), */
  /* ('0033', '3', NULL, NULL, false), */
  /* ('0034', '4', NULL, NULL, false), */
  /* ('0035', '5', NULL, NULL, false), */
  /* ('0036', '6', NULL, NULL, false), */
  /* ('0037', '7', NULL, NULL, false), */
  /* ('0038', '8', NULL, NULL, false), */
  /* ('0039', '9', NULL, NULL, false), */
  /* ('003A', ':', NULL, NULL, false), */
  /* ('003B', ';', NULL, NULL, false), */
  /* ('003C', '<', NULL, NULL, false), */
  /* ('003E', '>', NULL, NULL, false), */
  /* ('003F', '?', NULL, NULL, false), */
  /* ('0040', '@', NULL, NULL, false), */
  /* ('0041', 'A', NULL, NULL, false), */
  /* ('0042', 'B', NULL, NULL, false), */
  /* ('0043', 'C', NULL, NULL, false), */
  /* ('0044', 'D', NULL, NULL, false), */
  /* ('0045', 'E', NULL, NULL, false), */
  /* ('0046', 'F', NULL, NULL, false), */
  /* ('0047', 'G', NULL, NULL, false), */
  /* ('0048', 'H', NULL, NULL, false), */
  /* ('0049', 'I', NULL, NULL, false), */
  /* ('004A', 'J', NULL, NULL, false), */
  /* ('004B', 'K', NULL, NULL, false), */
  /* ('004C', 'L', NULL, NULL, false), */
  /* ('004D', 'M', NULL, NULL, false), */
  /* ('004E', 'N', NULL, NULL, false), */
  /* ('004F', 'O', NULL, NULL, false), */
  /* ('0050', 'P', NULL, NULL, false), */
  /* ('0051', 'Q', NULL, NULL, false), */
  /* ('0052', 'R', NULL, NULL, false), */
  /* ('0053', 'S', NULL, NULL, false), */
  /* ('0054', 'T', NULL, NULL, false), */
  /* ('0055', 'U', NULL, NULL, false), */
  /* ('0056', 'V', NULL, NULL, false), */
  /* ('0057', 'W', NULL, NULL, false), */
  /* ('0058', 'X', NULL, NULL, false), */
  /* ('0059', 'Y', NULL, NULL, false), */
  /* ('005A', 'Z', NULL, NULL, false), */
  /* ('005B', '[', NULL, NULL, false), */
  /* ('005C', '\', NULL, NULL, false), */
  /* ('005D', ']', NULL, NULL, false), */
  /* ('005F', '_', NULL, NULL, false), */
  /* ('0060', '`', NULL, NULL, false), */
  /* ('0061', 'a', NULL, NULL, false), */
  /* ('0062', 'b', NULL, NULL, false), */
  /* ('0063', 'c', NULL, NULL, false), */
  /* ('0064', 'd', NULL, NULL, false), */
  /* ('0065', 'e', NULL, NULL, false), */
  /* ('0066', 'f', NULL, NULL, false), */
  /* ('0067', 'g', NULL, NULL, false), */
  /* ('0068', 'h', NULL, NULL, false), */
  /* ('0069', 'i', NULL, NULL, false), */
  /* ('006A', 'j', NULL, NULL, false), */
  /* ('006B', 'k', NULL, NULL, false), */
  /* ('006C', 'l', NULL, NULL, false), */
  /* ('006D', 'm', NULL, NULL, false), */
  /* ('006E', 'n', NULL, NULL, false), */
  /* ('006F', 'o', NULL, NULL, false), */
  /* ('0070', 'p', NULL, NULL, false), */
  /* ('0071', 'q', NULL, NULL, false), */
  /* ('0072', 'r', NULL, NULL, false), */
  /* ('0073', 's', NULL, NULL, false), */
  /* ('0074', 't', NULL, NULL, false), */
  /* ('0075', 'u', NULL, NULL, false), */
  /* ('0076', 'v', NULL, NULL, false), */
  /* ('0077', 'w', NULL, NULL, false), */
  /* ('0078', 'x', NULL, NULL, false), */
  /* ('0079', 'y', NULL, NULL, false), */
  /* ('007A', 'z', NULL, NULL, false), */
  /* ('007C', '|', NULL, NULL, false), */
  /* ('009D', '', NULL, NULL, false), */
  ('00A0', 'foo bar', 'foo bar', 'foo bar', false),
  ('00A0', ' ', ' ', ' ', false),
  /* ('00A0', ' ', NULL, NULL, false), */
  /* ('00A2', '¢', NULL, NULL, false), */
  /* ('00A6', '¦', NULL, NULL, false), */
  /* ('00AA', 'ª', NULL, NULL, false), */
  /* ('00AD', '­', NULL, NULL, false), */
  /* ('00B0', '°', NULL, NULL, false), */
  /* ('00B2', '²', NULL, NULL, false), */
  /* ('00B4', '´', NULL, NULL, false), */
  /* ('00B7', '·', NULL, NULL, false), */
  /* ('00BA', 'º', NULL, NULL, false), */
  /* ('00BD', '½', NULL, NULL, false), */
  /* ('00BE', '¾', NULL, NULL, false), */
  /* ('00C2', 'Â', NULL, NULL, false), */
  /* ('00C3', 'Ã', NULL, NULL, false), */
  /* ('00C5', 'Å', NULL, NULL, false), */
  /* ('00C7', 'Ç', NULL, NULL, false), */
  /* ('00C9', 'É', NULL, NULL, false), */
  /* ('00D6', 'Ö', NULL, NULL, false), */
  /* ('00DC', 'Ü', NULL, NULL, false), */
  /* ('00DF', 'ß', NULL, NULL, false), */
  /* ('00E1', 'á', NULL, NULL, false), */
  /* ('00E2', 'â', NULL, NULL, false), */
  /* ('00E3', 'ã', NULL, NULL, false), */
  ('00E4', 'Jyväskylä', 'Jyvaeskylae', 'jyvaeskylae', false),
  ('00E4', 'ä', 'ae', 'ae', false),
  /* ('00E4', 'ä', NULL, NULL, false), */
  /* ('00E6', 'æ', NULL, NULL, false), */
  /* ('00E7', 'ç', NULL, NULL, false), */
  /* ('00E8', 'è', NULL, NULL, false), */
  /* ('00E9', 'é', NULL, NULL, false), */
  /* ('00EA', 'ê', NULL, NULL, false), */
  /* ('00EC', 'ì', NULL, NULL, false), */
  /* ('00ED', 'í', NULL, NULL, false), */
  /* ('00EE', 'î', NULL, NULL, false), */
  /* ('00EF', 'ï', NULL, NULL, false), */
  /* ('00F0', 'ð', NULL, NULL, false), */
  /* ('00F1', 'ñ', NULL, NULL, false), */
  /* ('00F3', 'ó', NULL, NULL, false), */
  /* ('00F4', 'ô', NULL, NULL, false), */
  /* ('00F5', 'õ', NULL, NULL, false), */
  /* ('00F6', 'ö', NULL, NULL, false), */
  /* ('00F8', 'ø', NULL, NULL, false), */
  /* ('00FA', 'ú', NULL, NULL, false), */
  /* ('00FC', 'ü', NULL, NULL, false), */
  /* ('00FE', 'þ', NULL, NULL, false), */
  /* ('017D', 'Ž', NULL, NULL, false), */
  /* ('0192', 'ƒ', NULL, NULL, false), */
  /* ('2013', '–', NULL, NULL, false), */
  /* ('2014', '—', NULL, NULL, false), */
  /* ('2018', '‘', NULL, NULL, false), */
  /* ('2019', '’', NULL, NULL, false), */
  /* ('201A', '‚', NULL, NULL, false), */
  /* ('201C', '“', NULL, NULL, false), */
  /* ('201D', '”', NULL, NULL, false), */
  /* ('201E', '„', NULL, NULL, false), */
  /* ('2026', '…', NULL, NULL, false), */
  ('20AC', '€', 'EUR', 'eur', false),
  ('20AC', '€9001', 'EUR9001', 'eur9001', false),
  ('20AC', 'Sw€€t', 'SwEUREURt', 'sweureurt', false)
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
