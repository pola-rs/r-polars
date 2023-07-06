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
This is a resubmission. In this version I have:

* Converted the DESCRIPTION title to title case.
* Quoted the word 'DataFrame' in Descript
* backticked `<Expr>`
* avoid github binary release urls in README (CRAN could oddly not reach them)
* fix redirection links
* fix dead links

