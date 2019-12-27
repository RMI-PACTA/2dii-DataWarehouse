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
('associate', 'assoc', 'ig'),
('associates', 'assoc', 'ig'),
('berhad', 'bhd', 'ig'),
('company', 'co', 'ig'),
('corporation', 'corp', 'ig'),
('designated\s+activity\s+company', 'dac', 'ig'),
('develop', 'dev', 'ig'),
('development', 'dev', 'ig'),
('financial', 'fin', 'ig'),
('generation', 'gen', 'ig'),
('government', 'govt', 'ig'),
('group', 'grp', 'ig'),
('holding', 'hldgs', 'ig'),
('holdings', 'hldgs', 'ig'),
('incorporated', 'inc', 'ig'),
('international', 'intl', 'ig'),
('investment', 'invest', 'ig'),
('limited\s+partnership', 'lp', 'ig'),
('limited', 'ltd', 'ig'),
('ltd\s+liability\s+co', 'llc', 'ig'),
('partner', 'prt', 'ig'),
('partners', 'prt', 'ig'),
('public\s+ltd\s+co', 'plc', 'ig'),
('resource', 'res', 'ig'),
('resources', 'res', 'ig'),
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

CREATE FUNCTION etl.replace_name_abbreviations(string TEXT)
RETURNS TEXT STABLE AS $$
DECLARE name_replacement RECORD;
BEGIN
  FOR name_replacement IN (
    SELECT
      to_replace,
      replacement,
      regexp_flags
    FROM etl.company_name_abbreviations
    WHERE string ~* to_replace  
  )
  LOOP
    string = regexp_replace(
      string,
      name_replacement.to_replace,
      name_replacement.replacement,
      name_replacement.regexp_flags
    );
  END LOOP;
  RETURN string;
END; $$
LANGUAGE PLPGSQL;
