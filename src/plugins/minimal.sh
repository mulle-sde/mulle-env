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
# though posix would be nicer. Now some are optional, because mknod
# f.e. is not on dragonfly. tty is in there for mulle-make
#
   MINIMAL_BIN_BINARIES="\
bash;optional
cat;required
chgrp;required
chmod;required
chown;required
cp;required
date;required
dd
df
dmesg
echo;required
false;required
hostname
kill;required
ln;required
login
ls;required
mkdir;required
mknod
more;required
mount
mudo;required
mv;required
ps
pwd;required
readlink;required
rm;required
rmdir;required
sed;required
sh;required
stty
tty
su
sync
true;required
umount
uname;required
zsh;optional"

   printf "%s\n" "${MINIMAL_BIN_BINARIES}"
}


env::plugin::minimal::setup_tools()
{
   log_entry "env::plugin::minimal::setup_tools" "$@"

   env::plugin::none::setup_tools "$@"

   #
   # We need all this for mudo to work
   #
   (
      env::tool::link_mulle_tool "mulle-bash"          "${bindir}" \
      &&
      env::tool::link_mulle_tool "mulle-bashfunctions" "${bindir}"  \
                                                       "${libexecdir}" \
      &&
      env::tool::link_mulle_tool "mulle-env"           "${bindir}" \
                                                       "${libexecdir}" \
                                                       "library"
   ) || return 1
}


env::plugin::minimal::initialize()
{
   env::plugin::load "none"
}


env::plugin::minimal::initialize
