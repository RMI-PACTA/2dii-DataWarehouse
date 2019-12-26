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
(' en ', ' & ', 'ig'),
(' och ', ' & ', 'ig'),
(' und ', ' & ', 'ig'),
('(inactive)', '', 'ig'),
('aktg', 'ag', 'ig'),
('aktiengesellschaft', 'ag', 'ig'),
('associate', 'assoc', 'ig'),
('associates', 'assoc', 'ig'),
('berhad', 'bhd', 'ig'),
('company', 'co', 'ig'),
('corporation', 'corp', 'ig'),
('designated activity company', 'dac', 'ig'),
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
('limited partnership', 'lp', 'ig'),
('limited', 'ltd', 'ig'),
('ltd liability co', 'llc', 'ig'),
('partner', 'prt', 'ig'),
('partners', 'prt', 'ig'),
('public ltd co', 'plc', 'ig'),
('resource', 'res', 'ig'),
('resources', 'res', 'ig'),
('shipping', 'shp', 'ig'),
(' ag$', '$ag', 'i'),
(' as$', '$as', 'i'),
(' asa$', '$asa', 'i'),
(' bhd$', '$bhd', 'i'),
(' bsc$', '$bsc', 'i'),
(' bv$', '$bv', 'i'),
(' co$', '$co', 'i'),
(' corp$', '$corp', 'i'),
(' cv$', '$cv', 'i'),
(' dac$', '$dac', 'i'),
(' govt$', '$govt', 'i'),
(' hldgs$', '$hldgs', 'i'),
(' inc$', '$inc', 'i'),
(' intl$', '$intl', 'i'),
(' llc$', '$llc', 'i'),
(' lp$', '$lp', 'i'),
(' lt$', '$ltd', 'i'),
(' ltd$', '$ltd', 'i'),
(' nv$', '$nv', 'i'),
(' pcl$', '$pcl', 'i'),
(' plc$', '$plc', 'i'),
(' pt$', '$pt', 'i'),
(' pte$', '$pte', 'i'),
(' sa$', '$sa', 'i'),
(' sarl$', '$sarl', 'i'),
(' sas$', '$sas', 'i'),
(' se$', '$se', 'i'),
(' spa$', '$spa', 'i'),
(' srl$', '$srl', 'i')
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
  RETURN LOWER(string);
END; $$
LANGUAGE PLPGSQL;
