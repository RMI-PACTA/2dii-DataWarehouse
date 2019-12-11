/* transliteration OF codepoints IS hard. */
/* See https://en.wikipedia.org/wiki/Basic_Latin_(Unicode_block) */
/* https://en.wikipedia.org/wiki/Latin-1_Supplement_%28Unicode_block%29 */

/* These functions ARE grouped BY the codepoints that they operate upon.
 * Unless otherwise defined, I'll be using the transliteration rules from
* unidecode: */
/* https://metacpan.org/source/SBURKE/Text-Unidecode-1.30/lib/Text/Unidecode/x00.pm */

/* U+0009		Horizontal tab */
/* U+0020	 	Space	*/
/* U+00A0	 	Non-breaking space */
/* U+00AD		Soft hyphen */
CREATE OR REPLACE FUNCTION etl.clean_whitespace(string TEXT)
RETURNS TEXT AS $$
BEGIN	
  string := regexp_replace(
    string, 
    /* These are the ascii (hexidecimal) codepoints for: (0009: Tab), (0020:
     * Space), (00A0: nonbreaking space), (00AD: soft hyphen). using + at the
     * end means that multiple consecutive characters in this group will be
     * collapsed, so tab-tab would collapse to a single space. */
    '[\u0009\u0020\u00A0\u00AD]+', 
    chr(32), -- 32 is codepoint for simple space character
    'g' -- Replace all occurances in the string
  );
  return TRIM(string);
END; $$
LANGUAGE PLPGSQL;

/* U+0021	!	Exclamation mark */
/* U+0022	"	Quotation mark */
/* U+0023	#	Number sign */	
/* U+0024	$	Dollar sign */	
/* U+0025	%	Percent sign */	
/* U+0026	&	Ampersand */	
/* U+0027	'	Apostrophe */	
/* U+0028	(	Left parenthesis */	
/* U+0029	)	Right parenthesis */	
/* U+002A	*	Asterisk */	
/* U+002B	+	Plus sign */	
/* U+002C	,	Comma */	
/* U+002D	-	Hyphen-minus */	
/* U+002E	.	Full stop or period */	
/* U+002F	/	Solidus or Slash */
/* ---- */
/* U+003A	:	Colon */	
/* U+003B	;	Semicolon */	
/* U+003C	<	Less-than sign */	
/* U+003D	=	Equal sign */	
/* U+003E	>	Greater-than sign */	
/* U+003F	?	Question mark */	
/* U+0040	@	At sign or Commercial at */
/* ---- */
/* U+005B	[	Left Square Bracket */	
/* U+005C	\	Backslash [A] */	
/* U+005D	]	Right Square Bracket */	
/* U+005E	^	Circumflex accent */	
/* U+005F	_	Low line */	
/* U+0060	`	Grave accent */
/* ---- */
/* U+007B	{	Left Curly Bracket */	
/* U+007C	|	Vertical bar */	
/* U+007D	}	Right Curly Bracket */	
/* U+007E	~	Tilde */
CREATE OR REPLACE FUNCTION etl.clean_punctuation(string TEXT)
RETURNS TEXT AS $$
BEGIN	
  RETURN regexp_replace(
    string, 
    '[\u0021-u002F\u003A-\u0040\u005B-\u0060\u007B-\u007E]+', 
    chr(32), -- 32 is codepoint for simple space character
    'g' -- Replace all occurances in the string
  );
END; $$
LANGUAGE PLPGSQL;




CREATE OR REPLACE FUNCTION etl.normalize_accents(string TEXT)
RETURNS TEXT AS $$
BEGIN
  /* for each substitution, replace the unicode character with the
   * transliterated ascii character, in both lower and uppercase. */
  string := replace(string, 'ä', 'ae');
  string := replace(string, 'Ä', 'AE');

  string := replace(string, 'å', 'a');
  string := replace(string, 'Å', 'A');

  string := replace(string, 'ü', 'u');
  string := replace(string, 'Ü', 'U');

  string := replace(string, 'ß', 'ss');
  -- No ß in uppercase

  string := replace(string, 'ï', 'i');
  string := replace(string, 'Ï', 'I');
  
  string := replace(string, 'é', 'e');
  string := replace(string, 'É', 'E');

  string := replace(string, 'è', 'e');
  string := replace(string, 'È', 'E');

  string := replace(string, 'ö', 'oe');
  string := replace(string, 'Ö', 'OE');

  string := replace(string, 'ø', 'o');
  string := replace(string, 'Ø', 'O');

  string := replace(string, 'ó', 'o');
  string := replace(string, 'Ó', 'O');

  string := replace(string, 'ğ', 'g');
  string := replace(string, 'Ğ', 'G');

  string := replace(string, 'ç', 'c');
  string := replace(string, 'Ç', 'C');
  
  string := replace(string, 'ı', 'i');
  -- No ı in uppercase

  string := replace(string, 'ş', 's');
  string := replace(string, 'Ş', 'S');

  string := replace(string, 'à', 'a');
  string := replace(string, 'À', 'A');
  RETURN string;
END; $$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION etl.is_ascii(string TEXT)
RETURNS BOOLEAN AS $$
BEGIN	
  /* (Space) through (Tilde) represents the printable ASCII RANGE */
  return string ~ '[ -~]*';
END; $$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION etl.is_lower_ascii(string TEXT)
RETURNS BOOLEAN AS $$
BEGIN	
  return string ~ '[a-z0-9]*';
END; $$
LANGUAGE PLPGSQL;


