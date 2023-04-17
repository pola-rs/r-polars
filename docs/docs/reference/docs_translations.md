# `docs_translations`

Translation definitions across python, R and polars.


## Description

#Comments for how the R and python world translates into polars:
 
 R and python are both high-level glue languages great for Data Science.
 Rust is a pedantic low-level language with similar use cases as C and C++.
 Polars is written in ~100k lines of rust and has a rust API. Py-polars the python API for polars,
 is implemented as an interface with the rust API.
 r-polars is very parallel to py-polars except it interfaces with R. The performance and behavior
 are unexpectedly quite similar as the 'engine' is the exact same rust code and data structures.


## Format

info


