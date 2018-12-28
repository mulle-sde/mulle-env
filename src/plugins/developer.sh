#! /usr/bin/env bash
#
#   Copyright (c) 2017 Nat! - Mulle kybernetiK
#   All rights reserved.
#
#   Redistribution and use in source and binary forms, with or without
#   modification, are permitted provided that the following conditions are met:
#
#   Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
#   Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
#   Neither the name of Mulle kybernetiK nor the names of its contributors
#   may be used to endorse or promote products derived from this software
#   without specific prior written permission.
#
#   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
#   ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
#   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
#   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
#   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
#   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
#   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
#   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#   POSSIBILITY OF SUCH DAMAGE.
#

print_developer_startup_sh()
{
   log_entry "print_developer_startup_sh" "$@"

   print_minimal_startup_sh "$@"
}


print_developer_include_sh()
{
   log_entry "print_developer_include_sh" "$@"

   print_minimal_include_sh "$@"
}


print_developer_environment_aux_sh()
{
   log_entry "print_developer_environment_aux_sh" "$@"

   print_minimal_environment_aux_sh "$@"
}


print_developer_auxscopes_sh()
{
   log_entry "print_developer_auxscopes_sh" "$@"
}



# callback
print_developer_tools_sh()
{
   log_entry "print_developer_tools_sh" "$@"

   print_minimal_tools_sh "$@"

#
# somewhat arbitrarily hand-picked. Rule of thumb: if a mulle script uses
# it, it's in here for sure (like base64 by mulle-sourcetree)
# on a bare minimum ubuntu, the following commands are not there:
#  ed, vi
#
# command is a bash builtin
#
   EXPECTED_DEVELOPER_BINARIES="awk
basename
base64
bash
clear
cut
dirname
egrep
env
expr
find
fgrep
grep
head
less
more
readlink
sleep
sort
stat
tail
test
tr
uuidgen
wc
which"

   echo "${EXPECTED_DEVELOPER_BINARIES}"
}


print_developer_optional_tools_sh()
{
   log_entry "print_developer_optional_tools_sh" "$@"

   print_minimal_optional_tools_sh "$@"
}


env_setup_developer_tools()
{
   log_entry "env_setup_developer_tools" "$@"

   local bindir="$1"
   local libexecdir="$2"

   [ -z "${directory}" ] && internal_fail "directory is empty"

   #
   # Since the PATH is restricted, we need a basic set of tools
   # in directory/bin to get things going
   # (We'd also need in PATH: git, tar, sed, tr, gzip, zip. But that's not
   # checked yet)
   #
   (
      env_link_mulle_tool "mulle-bashfunctions-env" "${bindir}"  \
                                                    "${libexecdir}" \
                                                    "library" &&
      env_link_mulle_tool "mulle-env"               "${bindir}" \
                                                    "${libexecdir}"
   ) || return 1
}


env_mulle_initialize()
{
   env_load_plugin "minimal"
}


env_mulle_initialize
