/* this file will create a table defining substituations for simplifying */
/* company names in preparation for fuzzy matching */ 

CREATE TABLE etl.company_name_abbreviations (
  to_replace TEXT NOT NULL UNIQUE,
  replacement TEXT NOT NULL,
  regexp_flags TEXT NOT NULL DEFAULT 'ig'
);
CREATE INDEX ix_company_name_replacement_cover ON etl.company_name_abbreviations (
  to_replace,
  replacement,
  regexp_flags
);

INSERT INTO etl.company_name_abbreviations (
  to_replace,
  replacement,
  regexp_flags
) VALUES
('\s+and\s+', ' & ', 'ig'),
('\s+en\s+', ' & ', 'ig'),
('\s+och\s+', ' & ', 'ig'),
('\s+und\s+', ' & ', 'ig'),
('\(inactive\)', '', 'ig'),
('aktg', 'ag', 'ig'),
('aktiengesellschaft', 'ag', 'ig'),
/* covers associate AND associates, single and plural */
('associate[s]*', 'assoc', 'ig'),
('berhad', 'bhd', 'ig'),
('company', 'co', 'ig'),
('corporation', 'corp', 'ig'),
('designated\s+activity[\s\$]+co', 'dac', 'ig'),
('develop(ment){0,1}', 'dev', 'ig'),
('financial', 'fin', 'ig'),
('generation', 'gen', 'ig'),
('government', 'govt', 'ig'),
('group', 'grp', 'ig'),
('holding(s){0,1}', 'hldgs', 'ig'),
('incorporated', 'inc', 'ig'),
('international', 'intl', 'ig'),
('investment', 'invest', 'ig'),
/* lp: limited -> ltd AND partnership -> prthip, so this turns variants into lp */
('ltd\s+prthip', 'lp', 'ig'),
('limited', 'ltd', 'ig'),
('ltd\s+liability[\s\$]+co', 'llc', 'ig'),
('partner(s){0,1}', 'prt', 'ig'),
/* plc: limited -> ltd AND company -> co, so this turns variants into plc */
('public\s+ltd[\s\$]+co', 'plc', 'ig'),
('resource(s){0,1}', 'res', 'ig'),
('shipping', 'shp', 'ig'),
('\s+ag$', '$ag', 'i'),
('\s+as$', '$as', 'i'),
('\s+asa$', '$asa', 'i'),
('\s+bhd$', '$bhd', 'i'),
('\s+bsc$', '$bsc', 'i'),
('\s+bv$', '$bv', 'i'),
('\s+co$', '$co', 'i'),
('\s+corp$', '$corp', 'i'),
('\s+cv$', '$cv', 'i'),
('\s+dac$', '$dac', 'i'),
('\s+govt$', '$govt', 'i'),
('\s+hldgs$', '$hldgs', 'i'),
('\s+inc$', '$inc', 'i'),
('\s+intl$', '$intl', 'i'),
('\s+llc$', '$llc', 'i'),
('\s+lp$', '$lp', 'i'),
('\s+lt$', '$ltd', 'i'),
('\s+ltd$', '$ltd', 'i'),
('\s+nv$', '$nv', 'i'),
('\s+pcl$', '$pcl', 'i'),
('\s+plc$', '$plc', 'i'),
('\s+pt$', '$pt', 'i'),
('\s+pte$', '$pte', 'i'),
('\s+sa$', '$sa', 'i'),
('\s+sarl$', '$sarl', 'i'),
('\s+sas$', '$sas', 'i'),
('\s+se$', '$se', 'i'),
('\s+spa$', '$spa', 'i'),
('\s+srl$', '$srl', 'i')
;

CREATE FUNCTION etl.replace_name_abbreviations(
  string TEXT,
  max_recursion INT DEFAULT 5,
  recursion INT DEFAULT 0
)
RETURNS TEXT STABLE AS $$
DECLARE
  name_replacement RECORD;
  original_string TEXT;
BEGIN
  /* protect against infinite recursion */
  IF recursion >= max_recursion THEN
    RAISE EXCEPTION 'Name replacement recursion exceeded';
  END IF;
  /* cache the original_string for later comparison */
  original_string := string;
  /* this will be empty for the last recursion, since there will be no */
  /* matching patterns */
  FOR name_replacement IN (
    SELECT
      to_replace,
      replacement,
      regexp_flags
    FROM etl.company_name_abbreviations
    WHERE string ~* to_replace  
    ORDER BY to_replace
  )
  LOOP
    string = regexp_replace(
      string,
      name_replacement.to_replace,
      name_replacement.replacement,
      name_replacement.regexp_flags
    );
  END LOOP;
  /* if there was a change, run the process again, to ensure we are catching */
  /* all the simplifications */
  IF string != original_string THEN
    string = etl.replace_name_abbreviations(
      string := string,
      max_recursion := max_recursion,
      recursion := (recursion + 1)::INT
    );
  END IF;
  /* return the value after all recursions. the lowest level recursion will */
  /* propogate up to the top through the returns */
  RETURN string;
END; $$
LANGUAGE PLPGSQL;
