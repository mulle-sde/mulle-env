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

env::plugin::minimal::print_startup()
{
   log_entry "env::plugin::minimal::print_startup" "$@"

   env::plugin::none::print_startup "$@"
}


env::plugin::minimal::print_include()
{
   log_entry "env::plugin::minimal::print_include" "$@"

   env::plugin::none::print_include "$@"
}


env::plugin::minimal::print_environment_aux()
{
   log_entry "env::plugin::minimal::print_environment_aux" "$@"

   env::plugin::none::print_environment_aux "$@"
}


env::plugin::minimal::print_auxscope()
{
   log_entry "env::plugin::minimal::print_auxscope" "$@"
}


# callback
env::plugin::minimal::print_tools()
{
   log_entry "env::plugin::minimal::print_tools" "$@"

   env::plugin::none::print_tools "$@"

#
# http://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch03s04.html
# i am not really sure that this is POSIX so I called it minimal
# though posix would be nicer
#
   MINIMAL_BIN_BINARIES="
cat
chgrp
chmod
chown
cp
date
dd
df
dmesg
echo
false
hostname
kill
ln
login
ls
mkdir
mknod
more
mount
mv
ps
pwd
rm
rmdir
sed
sh
stty
su
sync
true
umount
uname
"

   printf "%s\n" "${MINIMAL_BIN_BINARIES}"
}


env::plugin::minimal::setup_tools()
{
   log_entry "env::plugin::minimal::setup_tools" "$@"

   env::plugin::none::setup_tools "$@"

   # there are no "special" tools to do here
   # minimal is still an environment, where you don't do mulle stuff
   # so no mulle-env or mulle-bashfunctions here
}


env::plugin::minimal::initialize()
{
   env::plugin::load "none"
}


env::plugin::minimal::initialize
