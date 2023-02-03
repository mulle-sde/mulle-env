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
# somewhat arbitrarily hand-picked. Rule of thumb: if a mulle-script uses
# it, it's in here for sure (like stat by mulle-bashfunctions) and not optional
# on a bare minimum ubuntu, the following commands are not there:
#  ed, vi
#
# command is a bash builtin
#
   DEVELOPER_BINARIES="awk;required
basename;required
base64
bash
clear
cut;required
dirname;required
egrep
env;required
expr;required
find;required
file
fgrep
grep;required
head;required
less
more
readlink;required
sh;required
sleep;required
sort;required
stat;required
tail;required
test;required
tee;required
touch;required
tr;required
uuidgen
wc;required
which;required
ed
emacs
nano
xargs
vi
zsh"

   printf "%s\n" "${DEVELOPER_BINARIES}"
}


env::plugin::developer::setup_tools()
{
   log_entry "env::plugin::developer::setup_tools" "$@"

   env::plugin::minimal::setup_tools "$@"
}


env::plugin::developer::initialize()
{
   env::plugin::load "minimal"
}


env::plugin::developer::initialize
