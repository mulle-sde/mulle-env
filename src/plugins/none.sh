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
[ "\${TRACE}" = "YES" ] && set -x  && : \$0 "\$@"

#
# If mulle-env is broken, sometimes its nice just to source this file.
# If you're sourcing this manually on a regular basis, you're doint it wrong.
#
# We need some minimal stuff to get things going though:
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


#
# Set PS1 so that we can see, that we are in a mulle-env
#
envname="\`basename -- "\${MULLE_VIRTUAL_ROOT}"\`"

case "\${PS1}" in
   *\\\\h\\[*)
   ;;

   *\\\\h*)
      PS1="\$(sed 's/\\\\h/\\\\h\\['\${envname}'\\]/' <<< '\${PS1}' )"
   ;;

   *)
      PS1='\\u@\\h['\${envname}'] \\W\$ '
   ;;
esac
export PS1

unset envname

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

MULLE_ENV_DIR="\${MULLE_VIRTUAL_ROOT}/.mulle-env/etc"

if [ -f "\${MULLE_ENV_DIR}/environment-\${MULLE_UNAME}-os.sh" ]
then
   . "\${MULLE_ENV_DIR}/environment-\${MULLE_UNAME}-os.sh"
fi

if [ -f "\${MULLE_ENV_DIR}/environment.\${HOSTNAME}-host.sh" ]
then
   . "\${MULLE_ENV_DIR}/environment-\${HOSTNAME}-host.sh"
fi

if [ -f "\${MULLE_ENV_DIR}/environment-\${USER}-user.sh" ]
then
   . "\${MULLE_ENV_DIR}/environment-\${USER}-user.sh"
fi

#
# it's convenient to put changes into aux, as you can then reinit
# with -f
#
if [ -f "\${MULLE_ENV_DIR}/environment-aux.sh" ]
then
   . "\${MULLE_ENV_DIR}/environment-aux.sh"
fi

unset MULLE_ENV_DIR

EOF
}


print_none_aux_sh()
{
   cat <<EOF
# add your stuff here
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

#
# http://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch03s04.html
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

#
# somewhat arbitrarily hand-picked. Rule of thumb: if a mulle script uses
# it, it's in here for sure (like base64 by mulle-sourcetree)
#
EXPECTED_DEVELOPER_BINARIES="awk
basename
base64
bash
clear
command
cut
dirname
ed
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
vi
wc
which"


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
${MINIMAL_BIN_BINARIES}
${EXPECTED_DEVELOPER_BINARIES}
EOF
   esac

   #
   # stuff that we also need
   #
   cat <<EOF
mudo
EOF

   if [ ! -z "${OPTION_OTHER_TOOLS}" ]
   then
      echo "${OPTION_OTHER_TOOLS}"
   fi
}


print_none_optional_tools_sh()
{
   log_entry "print_none_optional_tools_sh" "$@"

   #
   # set of "minimal" commands for use in development
   #
   case "$1" in
      *:inherit)
         return
      ;;
   esac

   cat <<EOF
${OPTIONAL_BINARIES}
EOF

   if [ ! -z "${OPTION_OTHER_OPTIONAL_TOOLS}" ]
   then
      echo "${OPTION_OTHER_OPTIONAL_TOOLS}"
   fi
}

