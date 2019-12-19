# Known Issues

This document compiles a list of the known issues that have come up in discussions while preparing the Data Warehouse

## Romanization of company names (Transliteration and Stripping Accents)

An issue that has popped up in discussions is our transliteration engine.
Our data sources come to us in a variety of encodings, with an unknown level of pre-processing.
To increase the number of matches across data sources, we convert all the text to lowercase ASCII characters (`[a-z]+`).

A concern that we've identified is the possibility that data vendors are Romanizing names as part of pre-processing in a different way than we are.
For example: they might be mapping the character `ä` to `a`, rather than `ae`.
We map `ä -> ae` as part of our transliteration code, but if a vendor maps `ä -> a`, it could result in a mismatch.
Fuzzy matching _should_ address some of these issues, but mismatches early in the strings will be disproportionately influential, due to the use of the Jaro-Winkler algorithm.

A future concern is the transliteration of characters that are not even in the extended Latin set, namely strings in Katakana (Japanese) or Hangul (Korean) scripts, but any non-Latin character set is a point of concern.
To this end, the `rawdata` schema text fields, needs to be able to be written to in the `UTF-8` encodings (already enabled).
As data moves through the processing pipeline, there should be an early check that the data is in the character range that our system is capable of processing.
This is most likely to be a function that checks the string against a regex as a column check.
