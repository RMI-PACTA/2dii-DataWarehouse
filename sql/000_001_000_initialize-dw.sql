BEGIN TRANSACTION;

  CREATE TABLE public.dw_version (
    major INT NOT NULL,
    minor INT NOT NULL,
    patch INT NOT NULL,
    notes TEXT NOT NULL, -- Description of changes.
    PRIMARY KEY (major, minor, patch),
    CONSTRAINT dw_version_unique UNIQUE (major, minor, patch),
    CONSTRAINT dw_version_positive CHECK (major >= 0 AND minor >= 0 AND patch >= 0)
  );

  INSERT INTO PUBLIC.dw_version (major, minor, patch, notes)
  VALUES (
    0,
    1,
    0,
    'Initial Database creation'
  );

COMMIT TRANSACTION;
