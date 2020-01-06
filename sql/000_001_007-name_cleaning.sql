/* this is the function which unifies the different string cleaning functions */
/* into a single company name cleaning function */
CREATE FUNCTION etl.clean_company_name(string TEXT)
RETURNS TEXT STABLE AS $$
BEGIN
  string := etl.clean_whitespace(string);
  string := etl.simplify_unicode(string);
  string := etl.replace_name_abbreviations(string);
  /* remove any inner whitespace */
  string := regexp_replace(string, '\s', '', 'g');
  /* replace dollarsign for suffix with space */
  string := replace(string, '$', ' ');
  RETURN string;
END; $$
LANGUAGE PLPGSQL;

