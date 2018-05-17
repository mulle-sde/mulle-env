# mulle-env, 🌳 Virtual environment for Unix

**mulle-env** is a sub-shell that provides a restricted environment.
Developing inside the **mulle-env** sub-shell protects you from the following
common mistakes:

* inadvertant reliance on non-standard tools
* reproducabilty problems due to non-standard environment variables

Executable          | Description
--------------------|--------------------------------
`mulle-env`         | Virtual environment sub-shell
`mudo`              | Run a command with the unrestricted PATH


## Install

Install the pre-requisite [mulle-bashfunctions](https://github.com/mulle-nat/mulle-bashfunctions).

Install into `/usr` with sudo:

```
curl -L 'https://github.com/mulle-sde/mulle-env/archive/latest.tar.gz' \
 | tar xfz - && cd 'mulle-env-latest' && sudo ./install /usr
```

### Packages

OS          | Command
------------|------------------------------------
macos       | `brew install mulle-kybernetik/software/mulle-env`


## What mulle-env does in a nutshell


mulle-env uses `env -i` to restrict the environment of the subshell to a minimal
set of values. The PATH is modified, so that only a definable subset of tools
is available.

As an example here is my environment when running in a macos Terminal.app
session:

```
Apple_PubSub_Socket_Render=/private/tmp/com.apple.launchd.yxJqn34O3N/Render
CAML_LD_LIBRARY_PATH=/Volumes/Users/nat/.opam/system/lib/stublibs:/usr/local/lib/ocaml/stublibs
DISPLAY=/private/tmp/com.apple.launchd.gKyY8aVeiV/org.macosforge.xquartz:0
HOME=/Volumes/Users/nat
LANG=de_DE.UTF-8
LOGNAME=nat
MANPATH=:/Volumes/Users/nat/.opam/system/man
OCAML_TOPLEVEL_PATH=/Volumes/Users/nat/.opam/system/lib/toplevel
OLDPWD=/Volumes/Source/srcO
OPAMUTF8MSGS=1
PATH=/Volumes/Users/nat/.opam/system/bin:/Volumes/Source/srcO/mulle-foundation-developer:/Volumes/Source/srcO/mulle-objc-developer:/Volumes/Source/srcM/mulle-env:/Volumes/Source/srcM/mulle-templates:/Volumes/Source/srcM/mulle-project:/Volumes/Source/srcM/mulle-build:/Volumes/Source/srcM/mulle-dispense:/Volumes/Source/srcM/mulle-bootstrap:/Volumes/Source/srcM/mulle-sourcetree:/Volumes/Source/srcM/mulle-settings:/Volumes/Source/srcM/mulle-make:/Volumes/Source/srcM/mulle-fetch:/Volumes/Source/srcM/mulle-bashfunctions:/Volumes/Applications/Applications/Sublime Text.app/Contents/SharedSupport/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin
PERL5LIB=/Volumes/Users/nat/.opam/system/lib/perl5:
PWD=/Volumes/Source/srcO/MulleObjC-master
SHELL=/bin/bash
SHLVL=1
SSH_AUTH_SOCK=/private/tmp/com.apple.launchd.YrEMJV1DUq/Listeners
TERM=xterm-color
TERM_PROGRAM=Apple_Terminal
TERM_PROGRAM_VERSION=388.1.1
TERM_SESSION_ID=852D5E60-9A1B-43E0-A3D4-BC61BCD9134E
TMPDIR=/var/folders/jb/svqk0p3n73j46c3hfj_4fn3r0000xv/T/
USER=nat
XPC_FLAGS=0x0
XPC_SERVICE_NAME=0
_=/usr/bin/env
__CF_USER_TEXT_ENCODING=0x3BB:0x0:0x3
```

and this is inside **mulle-env**

```
DISPLAY=/private/tmp/com.apple.launchd.gKyY8aVeiV/org.macosforge.xquartz:0
HOME=/Volumes/Users/nat
LOGNAME=nat
MULLE_UNAME=darwin
MULLE_VIRTUAL_ROOT=/Volumes/Source/srcO/MulleObjC-master
PATH=/Volumes/Source/srcO/MulleObjC-master/bin
PS1=\u@\h[MulleObjC-master] \W$
PWD=/Volumes/Source/srcO/MulleObjC-master
SHLVL=2
TERM=xterm-color
TMPDIR=/var/folders/jb/svqk0p3n73j46c3hfj_4fn3r0000xv/T/
USER=nat
_=/Volumes/Source/srcO/MulleObjC-master/bin/env
```

Notice the absence of most environment variables and see how restricted the
`PATH` has become.


## Prepare a directory to use mulle-env

A directory must be "init"ed, before you can use **mulle-env** with it.
Let's try an example with a `project` directory. We want a minimal portable set
of commandline tools, so we specify the style as "minimal/tight".

```
mulle-env init -d project --style minimal/tight
```

And this is what happens:

![dox](dox/mulle-env-overview.png)



```
$ mulle-env project
Enter the environment:
   mulle-env "project"
$ mulle-env "project"
$ ls
$ echo $PATH
/tmp/project/.mulle-env/bin
$ ls -l $PATH
total 0
lrwxrwxrwx 1 nat nat 12 Jan 21 22:28 awk -> /usr/bin/awk
lrwxrwxrwx 1 nat nat 15 Jan 21 22:28 base64 -> /usr/bin/base64
...
...
...
lrwxrwxrwx 1 nat nat 14 Jan 21 22:28 which -> /usr/bin/which
```

And we leave the subshell with

```
$ exit
```

## Styles

A style is mix of a tool-style and an environment style of the form
`<tool>/<env>`.

The env style determines the filtering of the environment variables.

The tool style determines the change of the PATH variables,
in the environment styles `tight`, `relax`, `inherit`.

Tool Style  | Descripton
------------|--------------------------
`none`      | No default commands available.
`minimal`   | PATH with a minimal `/bin` like set of tools like `ls` or `chmod`
`developer` | PATH with a a set of common unix tools like `awk` or `man` in addition to `minimal`
`mulle`     | developer + support mulle-sde (default)


Environment Style | Description
------------------|--------------------------
`tight`           | All environment variables must be defined via `mulle-env`
`relax`           | Inherit some environment environment variables (e.g. SSH_TTY)
`restrict`        | In addition to `relax`  + all /bin and /usr/bin tools (default)
`inherit`         | The environment is restricted but tool style is ignored and the original PATH is unchanged.
`wild`            | The environment unchanged and the tool style is ignored.

## Tasks

#### Enter the subshell

```
mulle-env
```


#### Leave the subshell

```
exit
```

## Manage tools

List all tools

```
mulle-env tool list
```

Add a tool

```
mulle-env tool add git
```

Remove a tool

```
mulle-env tool remove git
```

## Manage environment variables


List all environment variables

```
mulle-env environment list
```

Get an environment variable

```
mulle-env environment get FOO
```

Set an environment variable

```
mulle-env environment set FOO "whatever"
```

Remove an environment variable

```
mulle-env tool set FOO ""
```



## Tips and Tricks


#### Add /bin and /usr/bin to your sub-shell PATH

Use `mulle-env --style none/restrict init` when initalizing your environment.
> `mulle-restrict` is the default as it gives access to the **mulle-sde**.

#### Reinitialize an environment

Use `mulle-env -f init` to overwrite a previous environment.


#### Specify a global list of tools

Tools that you always require can be specified globally
`~/.config/mulle-env/tool`. These will be installed in addition to those found
in `.mulle-env/etc/tool`.

#### Specify optionals tools

Tools that are nice to have, but aren't required for building the project
can be placed into `.mulle-env/etc/optionaltool`.

#### Specify platform specific tools

If you need some tools only on a certain platform, figure out the platform name
with `mulle-env uname`. Then use this name (`MULLE_UNAME`) as the extension for
`~/.config/mulle-env/tool.${MULLE_UNAME}` or
`.mulle-env/etc/tool.${MULLE_UNAME}`.

Platform specific tool configuration files take precedence over the
cross-platform ones without the extension.

#### Specify personal preferences (like a different shell)

Short of executing `exec zsh` - or whatever the shell flavor du jour is -
everytime you enter the **mulle-env** subshell, you can add this to your
`.mulle-env/etc/environment-${USER}-user.sh` file:

```
$ cat <<EOF >> .mulle-env/etc/environment-${USER}-user.sh
case "${MULLE_SHELL_MODE}" in
   *INTERACTIVE*)
      exec /bin/zsh
   ;;
esac
EOF
```



