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

print_none_startup_header_sh()
{
   log_entry "print_none_startup_header_sh" "$@"

   cat <<EOF
#
# If mulle-env is broken, sometimes its nice just to source this file
# But we need some stuff to get things going:
#     sed, cut, tr, hostname, pwd, uname
#
if [ -z "\${MULLE_UNAME}" ]
then
   MULLE_UNAME="`uname | cut -d_ -f1 | sed 's/64$//' | tr 'A-Z' 'a-z'`"
   export MULLE_UNAME
fi
if [ -z "\${MULLE_VIRTUAL_ROOT}" ]
then
   MULLE_VIRTUAL_ROOT="\`pwd -P\`"
   echo "Using \${MULLE_VIRTUAL_ROOT} as MULLE_VIRTUAL_ROOT for \
your convenience" >&2
fi

EOF
}


print_none_startup_footer_sh()
{
   log_entry "print_none_startup_footer_sh" "$@"

   cat <<EOF
#
# Load in some modifications depending on osname, hostname, username
# Of course this could be "cased" in a single file, but it seems convenient.
#
HOSTNAME="\`hostname -s\`" # don't export it

if [ -f .mulle-env/environment-\${MULLE_UNAME}-os.sh ]
then
   . .mulle-env/environment-\${MULLE_UNAME}-os.sh
fi

if [ -f .mulle-env/environment.\${HOSTNAME}-host.sh ]
then
   . .mulle-env/environment-\${HOSTNAME}-host.sh
fi

if [ -f .mulle-env/environment-\${USER}-user.sh ]
then
   . .mulle-env/environment-\${USER}-user.sh
fi
EOF
}


##
## CALLBACKS
##

# callback
print_none_startup_sh()
{
   log_entry "print_none_startup_sh" "$@"

   print_none_startup_header_sh "$@"
   print_none_startup_footer_sh "$@"
}


# callback
print_none_tools_sh()
{
   log_entry "print_none_tools_sh" "$@"

   #
   # set of "minimal" commands for use in development
   #
   case "$1" in
      *:inherit)
         return
      ;;

      *:restricted)
      ;;

#
# [ is built in
#
      *)
         cat <<EOF
awk
basename
bash
cat
chmod
cp
chown
command
date
dirname
echo
ed
env
expr
find
fgrep
grep
head
hostname
less
ls
ln
man
mkdir
more
mv
readlink
rm
rmdir
ps
sed
sh
sleep
sort
stat
tail
test
tr
vi
wc
which
EOF
   esac

   if [ ! -z "${OPTION_OTHER_TOOLS}" ]
   then
      echo "${OPTION_OTHER_TOOLS}"
   fi
}


