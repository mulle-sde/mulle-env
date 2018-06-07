### 0.14.1

* fix aux list, export PATH propely for mulle plugin

## 0.14.0

* reintroduction of environment-aux fot plugin env values, improved usage info


### 0.13.11

* mulle-plugin modifies PATH for dependency/bin ...

### 0.13.10

* return status from -c command properly

### 0.13.9

* use scope host instead of hostname

### 0.13.8

* Various small improvements

### 0.13.7

* simplify README

### 0.13.6

* improved brew formula defintion

### 0.13.5

* add mudo to CMakeLists.txt

### 0.13.4

* separate is now default, and default is merged for environment list

### 0.13.3

* dont attempt terminal title sets in script

### 0.13.2

* delete empty value for real now, because empty values mess up overrides

### 0.13.1

* add -C option for passing in command lines

## 0.13.0

* mulle-env -c behaves now like sh -c with respect to variable expansion etc (need to reinit\!)


### 0.12.6

* deal better with absence of USER env var

### 0.12.5

* add missing file to distribution

### 0.12.4

* fix package dependencies more

### 0.12.3

* fix package dependencies

### 0.12.2

* fix homebrew install ruby script

### 0.12.1

* rename install to installer, because of name conflict

## 0.12.0

* Separate environment-project.sh file for mulle-sde


### 0.11.19

* rename install.sh to install

### 0.11.18

* simplified CMakeLists.txt
* add subenv command to eventually support subprojects

### 0.11.17

* fix bug in list, add experimental --output-command

### 0.11.16

* add toolstyls and envstyles command for completion

### 0.11.15

* fix README

### 0.11.14

* improve README

### 0.11.13

* fix dox, fix an ugly

### 0.11.12

* use : as += value delimiter, allow addition

### 0.11.11

* list as single quoted environment variables

### 0.11.10

* fix problems when cding out of the wilderness

### 0.11.9

* fix -c execution, make bin/libexec dependent on hostname

### 0.11.8

* bug fix

### 0.11.7

* fix single quote escapes for sed output

### 0.11.6

* do not write protect share for the benefit of git checkouts

### 0.11.5

* make it possible to append to envionement variables

### 0.11.4

* don't clobber share on init -f, gain reinit command

### 0.11.3

* mulle-env gains environment-aux.sh and a cd catcher

### 0.11.2

* some fixes for different style with / instead of :

### 0.11.1

* update documentation a little

## 0.11.0

* style scheme now uses / as separator for easier bash completion
* experimental bash completion now available


### 0.10.8

* * fix option handling for project, lose .bak seds

### 0.10.6

* improved grokability of mulle-env by subdividing plugins

### 0.10.1

* Various small improvements

## 0.10.0

* change environment file scheme a bit to make it easier for --output-eval
* moved tool from mulle-sde to mulle-env where it belongs
* added environment editing functionality

## 0.9.0

* renamed restricted to restrict


### 0.8.1

* adapt to new mulle-bashfunctions 1.3

### 0.7.4

* improve README.md a bit
* optional tools added
* use --posix mode to avoid SYS_BASHRC backdoor on debian/linux
* add mudo command
* improve TRACE facility
* add environment-aux.sh to read files

### 0.7.3

* optional tools added
* use --posix mode to avoid SYS_BASHRC backdoor on debian/linux
* add mudo command
* improve TRACE facility
* add environment-aux.sh to read files

### 0.7.2

* use mulle-craft instead of mulle-build now

### 0.7.1

* various bugfixes

## 0.7.0

* moved to a plugin architecture


## 0.6.0

* fix stuff for newer mulle-project, don't depend on cmake for install (necessarily)
* changed name to mulle-env for clarity of purpose
