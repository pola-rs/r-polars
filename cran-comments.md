## Test environments

- local: x86_64-pc-linux-gnu
- GitHub Actions
  - { os: macos-latest, r: "release" }
  - { os: windows-latest, r: "devel" }
  - { os: windows-latest, r: "release" }
  - { os: ubuntu-latest, r: "devel" }
  - { os: ubuntu-latest, r: "release" }
  - { os: ubuntu-latest, r: "oldrel-1" }

## R CMD check results

- There were no ERRORs or WARNINGs.
- There was 2 NOTEs.
  - New submission
  - installed size is 140.8Mb
  

## Resubmission

This is a resubmission. Thank your for the comments, below are our answers:


> Please add \value to .Rd files regarding exported methods and explain
the functions results in the documentation. Please write about the
structure of the output (class) and also what the output means.

We have added \value where it was missing. 


> You have examples for unexported functions. Please either omit these
examples or export these functions.

Most polars unexported functions (427 closures with a `self`) are actually the
public methods called through `object$method()`. They should NOT be exported as
plain functions. Public methods should be documented though.

The vast number of methods makes it unfeasible to bundle all methods in a single
doc page per class, like common practice for another class-system as R6. Imagine
a .Rd params section with +500 parameters? Many param-names will collide. Then a
details section with +100 out-of-context sections. Then +100 different return
values. Then +400 mixed use examples. It would be completely unreadable and
unsearchable. The number of methods are only expected to increase further in
future versions.

Besides methods, upstream Polars also has a number of functions/objects that
collide with `base`, `utils`, `stats`, and many popular packages.  Polars strives
to be a cross-language syntax (Rust, Python, R, NodeJS). It is not possible to 
rename functions to avoid namespace collisions locally in R. Package functions
(and other objects types) are in all languages bundled in a namespace `pl` to 
not clutter user search()-namespace and to remove the risk of conflicts.


> In your LICENSE file you state "rpolars authors" to be the
copyrightholders. Do you mean yourself? In that case please write "polar
authors" instead. Otherwise please add the copyrightholders to the
Authors@R field in your description.

We have changed to 'polars authors' in LICENCE to:

YEAR: 2023
COPYRIGHT HOLDER: polars authors (polars the R package)

We add also (polars the R package) to not claim authorship or copyright to e.g.
rust-polars or py-polars. Ritchie Vink is the first author to all r-polars,
py-polars and rust-polars. No organization is 'cph'.
