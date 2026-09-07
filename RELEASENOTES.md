### 6.1.1


* platform/cross-compilation variables `(MULLE_CRAFT_PLATFORMS,` `MULLE_SOURCETREE_PLATFORMS,` `MULLE_EMULATOR__*,` `MULLE_CRAFT_CROSS_COMPILER_ROOT__*,` `MULLE_CRAFT_TOOLCHAIN__*)` are now stored and listed in their regular scope instead of being redirected to user-host scope
* `mulle-env environment set` no longer silently rewrites the scope for these keys, and `mulle-env environment list` no longer filters them out of the global scope



* small speedup for -c

* fix in -D handling

## 6.1.0


* small speedup for -c

* fix in -D handling
