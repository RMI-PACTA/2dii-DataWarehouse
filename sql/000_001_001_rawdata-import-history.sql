BEGIN TRANSACTION;

  CREATE SCHEMA IF NOT EXISTS rawdata;

  CREATE TABLE rawdata.import_history (
    id serial PRIMARY KEY,
    import_time TIMESTAMP NOT NULL,
    import_source varchar(128) NOT NULL,
    filename text NULL,
    file_md5 VARCHAR(32) NULL
  );

COMMIT TRANSACTION;
