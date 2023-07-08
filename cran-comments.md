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

> Please always write package names, software names and API (application
programming interface) names in single quotes in title and description.
e.g: --> 'Rust'

> Please note that package names are case sensitive. -> in your
description you write 'Polars' but your package name starts with a lower
case "p" ?

We have put the software and package names between single quotes. Regarding 
"Polars", there is a distinction between "polars" (all lowercase) which is the
name of the R package, and "Polars" (first letter uppercase) which is the name
of the query engine that is used by "polars". This is why we use 'Polars' in the
description.


> Please add \value to .Rd files regarding exported methods and explain
the functions results in the documentation. Please write about the
structure of the output (class) and also what the output means.

We have added \value where it was missing. 

> Using foo:::f instead of foo::f allows access to unexported objects.
This is generally not recommended, as the semantics of unexported
objects may be changed by the package author in routine maintenance."
Please omit one colon.

We either removed one colon or dropped the examples from the documentation (most
of these were internal functions).

> You have examples for unexported functions. Please either omit these
examples or export these functions.

All of these unexported functions are called through `$` and correspond to the
functions provided by the upstream Polars query engine. They are not exported
to avoid cluttering the package namespace and to reduce the risk of namespace
conflicts with other packages. Still, these functions are key to the use of
"polars", which is why we have examples for them. We didn't change anything 
about this.

> Some code lines in examples are commented out.
Please never do that. Ideally find toy examples that can be regularly
executed and checked. Lengthy examples (> 5 sec), can be wrapped in
\donttest{}.

> Please unwrap the examples if they are executable in < 5 sec, or replace
\dontrun{} with \donttest{}.

We have replace \dontrun{} with \donttest{}. The comments in the examples are
to explain the code used. After removing some Rd files (cf comment above), we
don't find any code line that is mistakenly commented out. We also didn't find
examples that ran in more than 5 seconds.

> Instead of print()/cat() rather use message()/warning() or
if(verbose)cat(..) (or maybe stop()) if you really have to write text to
the console. (except for print, summary, interactive functions)

All the cat() and print() we saw were either used in print() methods, in methods
that are only used interactively (e.g knit_print()), or were behind a flag used
only for debugging. Therefore, we remove any cat() or print() call.
