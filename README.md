FileDeliverServer
===

[![Build Status](https://travis-ci.org/cosmo0920/FileDeliverServer.png?branch=master)](https://travis-ci.org/cosmo0920/FileDeliverServer)

File Deliver Server with file monitoring writen in Haskell.

## Requirement

* Haskell Platform 2012.1.0.0 or later

### currently, it can build following platforms:

* ghc 7.4.1 @ Ubuntu 12.04.3 LTS
* ghc 7.6.3 @ Windows 7 and 8
   - Lexical error occurred when it installs dependent libraries, it must define `LANG=C` to avoid this error.

## Try it

If you install cabal packages, __strongly recommended__ use cabal-dev.

### git clone

```bash
$ git clone https://github.com/cosmo0920/FileDeliverServer.git
$ cd FileDeliverServer
```

### Install dependent libraries

when you use __Debian and related distributions...__

```bash
$ cabal update
$ cabal install cabal-dev
$ ~/.cabal/bin/cabal-dev install --dry-run --only-dependencies #prevent dependency hell
$ ~/.cabal/bin/cabal-dev install --only-dependencies
```

### build application

```bash
$ ~/.cabal/bin/cabal-dev configure
$ ~/.cabal/bin/cabal-dev build
$ cp setting-dummy.yaml setting.yaml
```

* * * *

### Haddock

This code contains haddock style comments.

So, you can generate haddock document as follows:

```bash
$ cabal[-dev] haddock --executables [--hyperlink-source] # if you want to see highlighted code in document.
```

* * * *

### Settings

setting.yml contains follwing items:

* basepath
    - base directory path
* port
    - port number
* monitorpath
    - monitoring directory path
* jsonpath
    - json file name
* monitoronly
    - true
        + Filesystem event monitoring only
    - false (experimental)
        + Filesystem event monitoring and generate json when file (added|modified|changed). But, this feature is too heavy and buggy...

#### File path format

* Linux and other unix like Platform example
  ```/home/<username>/```
* OSX example
  ```/Users/<usename>/```
* Windows
  ```C:\Users\<username>\```
    - when using "", ```"C:\\Users\\<username>\\"```
    - allow '/' instead of '\'

* * * *

This code is provided under the MIT LICENSE. see: [LICENSE](LICENSE)
