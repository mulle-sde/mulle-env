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

print_minimal_startup_sh()
{
   log_entry "print_minimal_startup_sh" "$@"

   print_none_startup_sh "$@"
}


print_minimal_include_sh()
{
   log_entry "print_minimal_include_sh" "$@"

   print_none_include_sh "$@"
}


print_minimal_environment_all_sh()
{
   log_entry "print_minimal_environment_all_sh" "$@"

   print_none_environment_all_sh "$@"
}


# callback
print_minimal_tools_sh()
{
   log_entry "print_minimal_tools_sh" "$@"

   print_none_tools_sh "$@"

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

   echo "${MINIMAL_BIN_BINARIES}"
}


print_minimal_optional_tools_sh()
{
   log_entry "print_minimal_optional_tools_sh" "$@"

   print_none_optional_tools_sh "$@"
}


env_mulle_initialize()
{
   env_load_plugin "none"
}


env_mulle_initialize
