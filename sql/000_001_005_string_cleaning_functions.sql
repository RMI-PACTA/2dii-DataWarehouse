/* this file has functions for clenaing strings prior to company matching. */

/* U+0009: Horizontal tab */
/* U+0020: Space*/
/* U+00A0: Non-breaking space */
/* U+00AD: Soft hyphen */
CREATE FUNCTION etl.clean_whitespace(string TEXT)
RETURNS TEXT IMMUTABLE AS $$
BEGIN
  string := regexp_replace(
    string, 
    /* These are the ascii (hexidecimal) codepoints for: (0009: Tab), (0020:
     * Space), (00A0: nonbreaking space), (00AD: soft hyphen). using + at the
     * end means that multiple consecutive characters in this group will be
     * collapsed, so tab-tab would collapse to a single space. */
    '[\u0009\u0020\u00A0]+', 
    chr(32), -- 32 is codepoint for simple space character
    'g' -- Replace all occurances in the string
  );
  return TRIM(string);
END; $$
LANGUAGE PLPGSQL;

