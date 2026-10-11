# AGENTS.md

**mulle-env** provides a virtual environment (restricted `PATH` and
environment) for C and Objective-C development on Android, BSDs, Linux,
macOS, SunOS and Windows (MinGW, WSL). It is implemented in POSIX shell.

## Repository layout

The main program is the top-level, hand-maintained `mulle-env` script. It
contains the argument parser, the command dispatch and the core environment
functions (`env::main`, `env::run_subshell`, `env::clean`, `env::reset`,
`env::reinit`, `env::is_help_request_commandline`).

Sub-commands live in `src/` and are sourced at runtime from
`MULLE_ENV_LIBEXEC_DIR`. Each module provides its own usage text and an
`env::<command>::main` entry point.

| Path                         | Purpose
|------------------------------|----------------------------------
| `mulle-env`                  | main program, dispatch and core env functions
| `mudo`                       | run a command with the unrestricted environment
| `src/mulle-env-shell`        | helper that sets up the restricted subshell
| `src/mulle-env-<command>.sh` | one sub-command module each
| `src/plugins/*.sh`           | tool styles (none/minimal/developer/mulle)
| `test/*/run-test`            | test suites, driven by `test/run-test`
| `cola/*.md.bud`              | README fragments, composed by `mulle-readme-cms`

To add a sub-command:

1. implement `env::<command>::main` (and a `::usage` function) in a new
   `src/mulle-env-<command>.sh`,
2. source it from the `case` dispatch in `mulle-env`,
3. add a test directory below `test/` (copy an existing `run-test`).

Core commands such as `clean`/`reset`/`reinit` are implemented directly in
`mulle-env`, not in a `src/` module.

## Dependencies

Runtime and test dependencies:

* [mulle-bashfunctions](https://github.com/mulle-sde/mulle-bashfunctions)
  must be on the `PATH` (`mulle-bashfunctions libexec-dir` must resolve).
  Install it via the mulle-sde developer setup or a package manager.
* `bash` and, for the full test matrix, `zsh`.

## Build and install

Either use the plain installer:

``` sh
./bin/installer /usr/local      # may need sudo
```

or CMake:

``` sh
cmake -S . -B build
cmake --build build
cmake --install build --prefix /usr/local
```

## Test

Run the whole suite (bash and zsh, if installed):

``` sh
./test/run-test
```

Run a single suite by name pattern, e.g.:

``` sh
./test/run-test 11-scope
```

Through CMake (configures first, then runs the same script):

``` sh
cmake -S . -B build
cmake --build build --target test
```

Test suites use the local `mulle-env`/`mudo` from the repository (see the
`init()` function in each `test/*/run-test`), so no install is required.

## Lint

The project is a set of shell scripts. Check them with shellcheck:

``` sh
shellcheck mulle-env mudo src/*.sh src/mulle-env-shell src/plugins/*.sh
```

The code base intentionally uses non-literal `[ ... ]` tests and a few other
patterns; do not "fix" shellcheck warnings broadly as part of unrelated
changes.

## Documentation

`README.md` is generated. Do **not** edit it by hand. Edit the fragments in
`cola/*.md.bud` and regenerate:

``` sh
mulle-markdown-compose --no-pwd --protect -c README.md.scion
```

`cola/properties.plist` supplies the `project`, `config` (buttons) and
`authors` used by the composer. The shared `README.md.scion` and generic
fragments (`header.md.bud`, `install.md.bud`, `author.md.bud`) come from the
`mulle-sde/cola` repository found in a parent `cola/` directory.

## Conventions

* Functions are named `<tool>::<file>::<function>` for module code and
  `env::<command>` / `env::<command>::main` for core dispatch.
* Keep the `# shellcheck source=...` comments in `mulle-env` accurate when
  adding or moving sourced modules.
* Do not commit generated build files (`build/`, root `Makefile`,
  `CMakeCache.txt`, `cmake_install.cmake`, `CPack*.cmake`); they are listed
  in `.gitignore`.
* Only commit when explicitly asked.
