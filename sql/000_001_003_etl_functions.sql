CREATE OR REPLACE FUNCTION etl.normalize_accents_lowercase(string TEXT)
RETURNS TEXT AS $$
BEGIN
  string := replace(string, 'ä', 'ae');
  string := replace(string, 'å', 'a');
  string := replace(string, 'ü', 'u');
  string := replace(string, 'ß', 'ss');
  string := replace(string, 'ï', 'i');
  string := replace(string, 'é', 'e');
  string := replace(string, 'è', 'e');
  string := replace(string, 'ö', 'oe');
  string := replace(string, 'ø', 'o');
  string := replace(string, 'ó', 'o');
  string := replace(string, 'ğ', 'g');
  string := replace(string, 'ç', 'c');
  string := replace(string, 'ı', 'i');
  string := replace(string, 'ş', 's');
  string := replace(string, 'à', 'a');
  RETURN string;
END; $$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION etl.normalize_accents_uppercase(string TEXT)
RETURNS TEXT AS $$
BEGIN
  string := replace(string, 'Ä', 'AE');
  string := replace(string, 'Å', 'A');
  string := replace(string, 'Ü', 'U');
  -- No ß in uppercase
  string := replace(string, 'Ï', 'I');
  string := replace(string, 'É', 'E');
  string := replace(string, 'È', 'E');
  string := replace(string, 'Ö', 'OE');
  string := replace(string, 'Ø', 'O');
  string := replace(string, 'Ó', 'O');
  string := replace(string, 'Ğ', 'G');
  string := replace(string, 'Ç', 'C');
  -- No ı in uppercase
  string := replace(string, 'Ş', 'S');
  string := replace(string, 'À', 'A');
  RETURN string;
END; $$
LANGUAGE PLPGSQL;
