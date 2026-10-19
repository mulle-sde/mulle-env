# 🌳 Virtual environment for C and Objective-C

... for Android, BSDs, Linux, macOS, SunOS, Windows (MinGW, WSL)

**mulle-env** provides a virtual environment as an interactive bash shell.
Developing inside the virtual environment protects you from the following
common mistakes:

* inadvertant reliance on non-standard tools
* reproducability problems due to personal or non-standard environment variables

With **mulle-env** you can easily manage

* the command line tools available in the virtual environment
* additional environment variables with multiple scopes, like on a per-user or per-host basis.

You can turn any directory into a self contained virtual environment.
`mulle-env init` will create a `.mulle` folder to hold all permanent and
temporary data. Remove that folder and the virtual environment is gone.

Another benefit of the virtual environment is a per-project command shell
history.






| Release Version                                       | Release Notes
|-------------------------------------------------------|--------------
| ![Mulle kybernetiK tag](https://img.shields.io/github/tag/mulle-sde/mulle-env.svg)  | [RELEASENOTES](RELEASENOTES.md) |

| Executable          | Description
|---------------------|--------------------------------
| `mulle-env`         | Virtual environment sub-shell
| `mudo`              | Run a command with the unrestricted PATH/environment
| `mulle-env-reload`  | Refresh virtual environment variables






## Init a directory to use mulle-env

A directory must be initialized, before you can run the **mulle-env** subshell
it it. Let's try an example with a `project` directory. We want a minimal
portable set of commandline tools, so we specify the 'style' as "minimal/tight".

``` sh
mulle-env init -d project --style minimal/tight
```

And this is what happens:

![Filesystem overview](dox/mulle-env-overview.svg)

Temporary and host-specific data is kept in `var`. User edits in `etc`.
`mulle-env` installs its content in `share` (and write protects it).

``` sh
$ mulle-env project
Enter the environment:
   mulle-env "project"
$ mulle-env "project"
$ ls
$ echo $PATH
/tmp/project/.mulle/var/<hostname>-<username>/env/bin
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

``` sh
$ exit
```

You can also run a command in the environment without an interactive subshell
with the '-c' flag, like you would using bash:


``` sh
$ mulle-env -c 'printf "%s\n" "${PATH}"'
```


### Manage tools

Tools are your standard unix tools, executables like `cc`, `ls` or `make`.
With the PATH restrictions enforced my mulle-env, you can prune the number
of available tools to the subshell.

To list all tools use `mulle-env tool list`. You can add a tool with
`mulle-env tool add git` and remove it with `mulle-env tool remove git`.

### Styles

A style is mix of a tool-style and an env-style of the form
`<tool>/<env>`. The env-style determines the filtering of the environment
variables. The tool-style influences the content of the `PATH` variable.

> Toolstyles can be augmented with plugins. See `mulle-env toolstyles` for
> what's available.

| Tool Style  | Descripton
|-------------|--------------------------
| `none`      | No default commands available.
| `minimal`   | PATH with a minimal `/bin` like set of tools like `ls` or `chmod`
| `developer` | PATH with a a set of common unix tools like `awk` or `man` in addition to `minimal`
| `mulle`     | *if mulle-sde is installed this tool style is also available*


| Environment Style | Description
|-------------------|--------------------------
| `tight`           | All environment variables must be defined via `mulle-env` (academic needs only)
| `restrict`        | Inherit some environment environment variables (e.g. SSH_TTY)
| `frugal`          | Like `restrict` plus `PATH` adds all `/bin` tools
| `relax`           | Like `frugal` plus `PATH` adds all `/usr/bin` tools
| `inherit`         | The environment is restricted but tool style is ignored and the original PATH is unchanged.
| `wild`            | The user environment remains unchanged and the tool style is ignored.


### Sandbox

Set `MULLE_ENV_SANDBOX` to an executable (for example a
[landlock](https://landlock.io) based `lljail` wrapper) to run the subshell
or `-c` command inside a sandbox. Additional arguments are passed via
`MULLE_ENV_SANDBOX_FLAGS`. It is up to you not to stack sandboxes:

``` bash
export MULLE_ENV_SANDBOX="lljail"
mulle-env -c 'make'
```

The sandbox wrapper is invoked as `sandbox [flags] env <environment> <command>`.
It can read `MULLE_ENV_SANDBOX_SRC_DIR` to learn the environment root, which is
not necessarily the current directory (e.g. with `--keep-pwd` or `-d <subdir>`).


## What mulle-env does in a nutshell

mulle-env uses `env` to restrict the environment of the subshell to a minimal
set of values. With `env -i bash -c env` you can see the restricted environment

``` bash
PWD=/home/src/srcS/mulle-env
SHLVL=1
_=/usr/bin/env
```

mulle-env adds a few environment variables back to the environment, like
`LOGNAME` or `SSH_AUTH_SOCK`, so that an interactive shell keeps functioning
like one would expect it to. You can see the effect for yourself with:

``` bash
mulle-env invoke env  # this does not read a custom environment
```

### Custom environment

When a mulle-env subshell executes, the environment is modified by reading a 
profile file `.mulle/share/env/environment.sh`. This file in turn will read 
other files in `.mulle/share/env` and `.mulle/etc/env`. With these files 
you define new environment variables and aliases. 

Usually you do not manually edit this files, but use mulle-env *commands*
to customize these environment files.

If you want to go manual, it's suggested you use `.mulle/etc/env/environment-global.sh`
as a starting point:

Example:

``` bash
mkdir -p .mulle/etc/env
echo "FOO=xxx" > .mulle/etc/env/environment-global.sh
```

## Repository layout

**mulle-env** is a collection of POSIX shell scripts. The main program is the
top-level `mulle-env` script. It is hand-maintained and contains the argument
parser, the command dispatch and the core environment functions (`env::main`,
`env::run_subshell`, `env::clean`, `env::reset`, `env::reinit`).

The sub-commands are implemented as separate modules in `src/` and are sourced
at runtime from `MULLE_ENV_LIBEXEC_DIR`. Each module supplies its own usage
text and an `env::<command>::main` entry point.

| Path                         | Purpose
|------------------------------|----------------------------------
| `mulle-env`                  | main program, dispatch and core env functions
| `mudo`                       | run a command with the unrestricted environment
| `src/mulle-env-shell`        | helper that sets up the restricted subshell
| `src/mulle-env-<command>.sh` | one sub-command module each
| `src/plugins/*.sh`           | tool styles (none/minimal/developer/mulle)
| `test/*/run-test`            | test suites, driven by `test/run-test`
| `cola/*.md.bud`              | README fragments, composed by `mulle-readme-cms`

To add a sub-command, implement `env::<command>::main` in a new
`src/mulle-env-<command>.sh`, source it from the `case` in `mulle-env` and add
a test directory below `test/`.

### Building and testing

**mulle-env** needs
[mulle-bashfunctions](https://github.com/mulle-sde/mulle-bashfunctions) at
runtime. With `mulle-bashfunctions` on the `PATH`, the test suite runs with:

``` sh
./test/run-test
```

To run it through CMake, configure the project first and then build the `test`
target:

``` sh
cmake -S . -B build
cmake --build build --target test
```

See the `AGENTS.md` file in the repository root for the full build, test and
lint commands.



## Environment

### In an out

Enter the subshell with `mulle-env` and leave the subshell `exit`.
Run any command in the subshell (from the outside to the inside) with a
command like `mulle-env -c env` and escape the subshell (from the inside to
the outside) with `mudo -e env`.

#### Nested environments

By default mulle-env refuses to enter an environment while already inside one
(the inherited `MULLE_VIRTUAL_ROOT` would shadow the new one). When you really
need to run a mulle-env environment from within another one (for example a
release workspace that drives many per-repo environments), allow it explicitly:

``` sh
mulle-env --allow-nested-env -c 'make'
```

or set `MULLE_ENV_ALLOW_NESTED=YES` in the outer environment. The inherited
virtual root is then discarded and the nested environment is derived from the
working directory.

#### Disabling mudo

On entry mulle-env saves the caller's environment so that `mudo -e` can escape
the subshell later. Use `--no-mudo` (or `MULLE_ENV_NO_MUDO=YES`) to keep the
caller's `PATH` and environment out of the subshell entirely:

``` sh
mulle-env --no-mudo
```

Then no `MULLE_OLDPATH` is exported and no old environment is written to
`.mulle/var`, so `mudo -e` can not recover it and plain `mudo` is a no-op with
respect to `PATH`. This is useful when the subshell should not be able to
escape to the user environment (and when the environment must not be persisted
to disk).

#### Hermetic environments

A workspace driven from within a mulle-env subshell exports its bookkeeping
variables (`MULLE_VIRTUAL_ROOT`, `MULLE_VIRTUAL_ROOT_ID`,
`MULLE_ENV_LIBEXEC_DIR`, `MULLE_BASHFUNCTIONS_LIBEXEC_DIR`, `MULLE_OLDPATH`) to
every child process. When those children descend into nested environments, the
inherited root shadows the nested one — which is not supported and is rejected
with a `MULLE_VIRTUAL_ROOT_ID mismatch`. Use `--hermetic` (or
`MULLE_ENV_HERMETIC=YES`) to keep them out of the subshell:

``` sh
mulle-env --hermetic
```

`--hermetic` implies `--no-mudo`. Every tool then derives its own root from the
working directory instead of extending the enclosing environment.

## Upgrade an environment

To upgrade an environment to a newer mulle-env release use

``` sh
mulle-env upgrade
```

### Reset and reinit

To rebuild the environment in place, keeping the previously saved style, use

``` sh
mulle-env reinit
```

To throw away the generated `var` directories and set up the environment
again from scratch use

``` sh
mulle-env reset
```


### Manage variables

List all environment variables defined by the virtual environment
with `mulle-env environment list`. Set an environment variable
with `mulle-env environment --scope global set FOO "whatever"`.

You can also get an environment variable with `mulle-env environment get FOO`
and remove it with `mulle-env environment remove FOO`.

#### Scopes

There are multiple environment variable scopes, that override each other
in top (weakest) to bottom (strongest) fashion. Non-user values will lose
changes on mulle-env upgrades, so don't write into those scopes.


| Scope         | User Value | Description
|---------------|------------|----------------------------------
| `plugin`      | NO         | Values set by a mulle-env plugin
| `global`      | YES        | Global user values
| `os-<name>`   | YES        | Operating system specific user values
| `host-<name>` | YES        | Host specific user values
| `user-<name>` | YES        | User specific user values





## Install

See [mulle-sde-developer](//github.com/mulle-sde/mulle-sde-developer) how to
install mulle-sde, which will also install mulle-env with required
dependencies.

The command to install only the latest mulle-env into
`/usr/local` (with **sudo**) is:

``` bash
curl -L 'https://github.com/mulle-sde/mulle-env/archive/latest.tar.gz' \
 | tar xfz - && cd 'mulle-env-latest' && sudo ./bin/installer /usr/local
```



## Author

[Nat!](https://mulle-kybernetik.com/weblog) for Mulle kybernetiK


