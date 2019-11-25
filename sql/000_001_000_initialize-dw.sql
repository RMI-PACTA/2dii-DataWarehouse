  CREATE TABLE public.dw_version (
    major INT NOT NULL,
    minor INT NOT NULL,
    patch INT NOT NULL,
    filename VARCHAR(255) NOT NULL,
    filehash VARCHAR(255) NOT NULL,
    migration_time TIMESTAMP NOT NULL,
    PRIMARY KEY (major, minor, patch),
    CONSTRAINT dw_version_unique UNIQUE (major, minor, patch),
    CONSTRAINT dw_version_positive CHECK (major >= 0 AND minor >= 0 AND patch >= 0)
  );
