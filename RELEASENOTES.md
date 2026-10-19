## 6.3.0


feature: add --no-mudo and --hermetic environment isolation options

* `--no-mudo` (or ``MULLE_ENV_NO_MUDO=YES`)` prevents the caller's `PATH` and environment from being saved into the subshell, so `mudo -e` can no longer escape to the user environment and no old environment is persisted to `.mulle/var`
* `--hermetic` (or ``MULLE_ENV_HERMETIC=YES`)` keeps inherited mulle bookkeeping variables `(`MULLE_VIRTUAL_ROOT`,` ``MULLE_VIRTUAL_ROOT_ID`,` libexec dirs, ``MULLE_OLDPATH`)` out of the subshell, letting nested tools derive their own root instead of failing with a ``MULLE_VIRTUAL_ROOT_ID` mismatch`; implies `--no-mudo`
* both flags are available in shell completion















feature: allow nested environments and make tool addition idempotent

* add `--allow-nested-env` and ``MULLE_ENV_ALLOW_NESTED=YES`` to explicitly enter an environment from within another one, overriding the inherited ``MULLE_VIRTUAL_ROOT``
* `mulle-env tool add` of an already installed tool now warns and succeeds instead of failing (silent with `--if-missing`/`--force`)
* `reset` and `reinit` now print usage for `-h` and work without a pre-initialized environment
* sandbox wrappers can read ``MULLE_ENV_SANDBOX_SRC_DIR`` to learn the environment root, which may differ from the working directory


feature: add sandbox and keep-pwd options, new frugal env-style

* new `--sandbox `<file>`` option and ``MULLE_ENV_SANDBOX`` to run the subshell or `-c` command inside a sandbox executable (e.g. an lljail wrapper), with extra arguments via ``MULLE_ENV_SANDBOX_FLAGS``
* new `--keep-pwd` option and ``MULLE_ENV_KEEP_PWD`` to run the subshell or command in the current directory instead of the environment root
* new `frugal` env-style: like `restrict` plus all `/bin` tools; `relax` now builds on it and adds all `/usr/bin` tools
* new `rm` command as a shortcut for `tool remove`
* `init` now refuses to re-initialize an already initialized directory unless `-f` is given
* fix tool linking to resolve tools against the current `PATH` instead of an inherited ``MULLE_OLDPATH``
* fix eval getters/listers to represent locally inherited variables symbolically, so stale local values or bash defaults no longer leak into `get`/`list` output


## 6.2.0





feature: allow nested environments and make tool addition idempotent

* add `--allow-nested-env` and ``MULLE_ENV_ALLOW_NESTED=YES`` to explicitly enter an environment from within another one, overriding the inherited ``MULLE_VIRTUAL_ROOT``
* `mulle-env tool add` of an already installed tool now warns and succeeds instead of failing (silent with `--if-missing`/`--force`)
* `reset` and `reinit` now print usage for `-h` and work without a pre-initialized environment
* sandbox wrappers can read ``MULLE_ENV_SANDBOX_SRC_DIR`` to learn the environment root, which may differ from the working directory


feature: add sandbox and keep-pwd options, new frugal env-style

* new `--sandbox `<file>`` option and ``MULLE_ENV_SANDBOX`` to run the subshell or `-c` command inside a sandbox executable (e.g. an lljail wrapper), with extra arguments via ``MULLE_ENV_SANDBOX_FLAGS``
* new `--keep-pwd` option and ``MULLE_ENV_KEEP_PWD`` to run the subshell or command in the current directory instead of the environment root
* new `frugal` env-style: like `restrict` plus all `/bin` tools; `relax` now builds on it and adds all `/usr/bin` tools
* new `rm` command as a shortcut for `tool remove`
* `init` now refuses to re-initialize an already initialized directory unless `-f` is given
* fix tool linking to resolve tools against the current `PATH` instead of an inherited ``MULLE_OLDPATH``
* fix eval getters/listers to represent locally inherited variables symbolically, so stale local values or bash defaults no longer leak into `get`/`list` output


### 6.1.1


* platform/cross-compilation variables `(MULLE_CRAFT_PLATFORMS,` `MULLE_SOURCETREE_PLATFORMS,` `MULLE_EMULATOR__*,` `MULLE_CRAFT_CROSS_COMPILER_ROOT__*,` `MULLE_CRAFT_TOOLCHAIN__*)` are now stored and listed in their regular scope instead of being redirected to user-host scope
* `mulle-env environment set` no longer silently rewrites the scope for these keys, and `mulle-env environment list` no longer filters them out of the global scope



* small speedup for -c

* fix in -D handling

## 6.1.0


* small speedup for -c

* fix in -D handling
