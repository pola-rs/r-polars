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
  
  
## CRAN first submission

* checking HTML version of manual ... [73s] NOTE
Found the following HTML validation problems:
* checking installed package size ... NOTE
  installed size is 73.9Mb
  sub-directories of 1Mb or more:
    libs  72.1Mb
* checking CRAN incoming feasibility ... [13s] NOTE
Maintainer: 'Soren Welling <sorhawell@gmail.com>'

New submission

Possibly misspelled words in DESCRIPTION:
  DataFrame (2:23, 11:29)
