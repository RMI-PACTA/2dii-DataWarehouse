/* this file has character cleaning functions. that is, they operate on */
/* strings, but are only concerned with characters, rather than trimming spaces */
/* or reordering words. */

/* See: https://stackoverflow.com/a/45741630 */
CREATE FUNCTION etl.regexp_escape(string TEXT)
RETURNS TEXT IMMUTABLE STRICT PARALLEL SAFE AS $$
BEGIN
  RETURN regexp_replace($1, '([!$()*+.:<=>?[\\\]^{|}-])', '\\\1', 'g');
END; $$
LANGUAGE PLPGSQL;
  
CREATE FUNCTION etl.has_nonsimplified_characters(string TEXT)
RETURNS BOOLEAN IMMUTABLE AS $$
BEGIN
  /* matches the defines the regex for simplifying unicode characters */
  /* Currently this is: */
  /* All ASCII letters (uppercase can be cleaned further with LOWER) */
  /* Digits */
  /* Literal "Space" */
  /* literal "Ampersand" */
  /* literal "Apostrophe" */
  return string ~ '[^a-zA-Z0-9 &'']';
END; $$
LANGUAGE PLPGSQL;

CREATE FUNCTION etl.romanize_unicode(string TEXT)
RETURNS TEXT STABLE AS $$
DECLARE codepoint RECORD;
BEGIN
  FOR codepoint IN (
    SELECT
    unicode_character,
    romanized_character
    FROM etl.unicode_point
    INNER JOIN (select regexp_split_to_table(string, '') as c) as s
      on (unicode_character = s.c)
  )
  LOOP
    string = replace(string, codepoint.unicode_character, codepoint.romanized_character);
  END LOOP;
  RETURN string;
END; $$
LANGUAGE PLPGSQL;

CREATE FUNCTION etl.simplify_unicode(string TEXT)
RETURNS TEXT STABLE AS $$
DECLARE codepoint RECORD;
BEGIN
  IF etl.has_nonsimplified_characters(string) THEN
    FOR codepoint IN (
      SELECT
      unicode_character,
      simple_romanized_character
      FROM etl.unicode_point
      INNER JOIN (select regexp_split_to_table(string, '') AS c) AS s
        ON (unicode_character = s.c)
      WHERE unicode_point.is_simplified = FALSE
    )
    LOOP
      string = replace(string, codepoint.unicode_character, codepoint.simple_romanized_character);
    END LOOP;
  END IF;
  RETURN LOWER(string);
END; $$
LANGUAGE PLPGSQL;

