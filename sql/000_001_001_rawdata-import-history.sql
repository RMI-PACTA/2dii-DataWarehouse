  CREATE SCHEMA IF NOT EXISTS rawdata;

  CREATE TABLE rawdata.import_history (
    id serial PRIMARY KEY,
    import_time TIMESTAMP NOT NULL,
    filetype varchar(128) NOT NULL,
    filename VARCHAR(255) NOT NULL,
    filehash VARCHAR(32) NOT NULL
  );
