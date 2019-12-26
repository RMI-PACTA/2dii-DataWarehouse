/* Create a TABLE ON the PUBLIC SCHEMA (which we know nearly always EXISTS, so
 * we can use it AS a bootstrap), which will contain a record ON the changes
 * that we have already made TO the databse structure. See that we use the
 * "migrations" TO refer TO irreversible changes TO the database structure. */
CREATE TABLE public.dw_version (
  major INT NOT NULL,
  minor INT NOT NULL,
  patch INT NOT NULL,
  filename VARCHAR(255) NOT NULL,
  filehash VARCHAR(32) NOT NULL,
  migration_time TIMESTAMP NOT NULL,
  PRIMARY KEY (major, minor, patch),
  CONSTRAINT dw_version_unique UNIQUE (major, minor, patch),
  CONSTRAINT dw_version_positive CHECK (major >= 0 AND minor >= 0 AND patch >= 0)
);
