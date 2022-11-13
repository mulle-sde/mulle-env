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

env::plugin::developer::print_startup()
{
   log_entry "env::plugin::developer::print_startup" "$@"

   env::plugin::minimal::print_startup "$@"
}


env::plugin::developer::print_include()
{
   log_entry "env::plugin::developer::print_include" "$@"

   env::plugin::minimal::print_include "$@"
}


env::plugin::developer::print_environment_aux()
{
   log_entry "env::plugin::developer::print_environment_aux" "$@"

   env::plugin::minimal::print_environment_aux "$@"
}


env::plugin::developer::print_auxscope()
{
   log_entry "env::plugin::developer::print_auxscope" "$@"
}



# callback
env::plugin::developer::print_tools()
{
   log_entry "env::plugin::developer::print_tools" "$@"

   env::plugin::minimal::print_tools "$@"

#
# somewhat arbitrarily hand-picked. Rule of thumb: if a mulle script uses
# it, it's in here for sure (like base64 by mulle-sourcetree) and not optional
# on a bare minimum ubuntu, the following commands are not there:
#  ed, vi
#
# command is a bash builtin
#
   DEVELOPER_BINARIES="awk
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
less;optional
more;optional
readlink
sleep
sort
stat
tail
test
tee
touch
tr
uuidgen
wc
which
ed;optional
emacs;optional
nano;optional
xargs;optional
vi;optional"

   printf "%s\n" "${DEVELOPER_BINARIES}"
}


env::plugin::developer::setup_tools()
{
   log_entry "env::plugin::developer::setup_tools" "$@"

   local bindir="$1"
   local libexecdir="$2"

   env::plugin::minimal::setup_tools "$@"

   #
   # Since the PATH is restricted, we need a basic set of tools
   # in directory/bin to get things going
   # (We'd also need in PATH: git, tar, sed, tr, gzip, zip. But that's not
   # checked yet)
   #
   (
      env::tool::link_mulle_tool "mulle-bash"          "${bindir}" \
      &&
      env::tool::link_mulle_tool "mulle-bashfunctions" "${bindir}"  \
                                                       "${libexecdir}" \
                                                       "library" \
      &&
      env::tool::link_mulle_tool "mulle-env"           "${bindir}" \
                                                       "${libexecdir}"
   ) || return 1
}


env::plugin::developer::initialize()
{
   env::plugin::load "minimal"
}


env::plugin::developer::initialize
