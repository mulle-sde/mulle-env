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

print_none_startup_sh()
{
   log_entry "print_none_startup_sh" "$@"

   cat <<EOF
[ "\${TRACE}" = "YES" ] && set -x  && : "\$0" "\$@"

#
# If mulle-env is broken, sometimes its nice just to source this file.
# If you're sourcing this manually on a regular basis, you're doing it wrong.
#
# We need some minimal stuff to get things going though:
#     sed, cut, tr, hostname, pwd, uname
#
if [ -z "\${MULLE_UNAME}" ]
then
   MULLE_UNAME="\`PATH=/bin:/usr/bin uname | \\
                  PATH=/bin:/usr/bin cut -d_ -f1 | \\
                  PATH=/bin:/usr/bin sed 's/64\$//' | \\
                  PATH=/bin:/usr/bin tr 'A-Z' 'a-z'\`"
   export MULLE_UNAME
fi
if [ -z "\${MULLE_VIRTUAL_ROOT}" ]
then
   MULLE_VIRTUAL_ROOT="\`PATH=/bin:/usr/bin pwd -P\`"
   echo "Using \${MULLE_VIRTUAL_ROOT} as MULLE_VIRTUAL_ROOT for \\
your convenience" >&2
fi

alias mulle-env-reload='. "\${MULLE_VIRTUAL_ROOT}/.mulle-env/share/environment-include.sh"'


if [ "\${MULLE_SHELL_MODE}" = "INTERACTIVE" ]
then
   #
   # Set PS1 so that we can see, that we are in a mulle-env
   #
   envname="\`PATH=/bin:/usr/bin basename -- "\${MULLE_VIRTUAL_ROOT}"\`"

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

   # install cd catcher
   . "\${MULLE_ENV_LIBEXEC_DIR}/mulle-env-cd.sh"
   unset MULLE_ENV_LIBEXEC_DIR

   mulle-env-reload
else
   set -a ; mulle-env-reload     # export all definitions for command
   \${COMMAND}
   exit \$?
fi

EOF
}


print_none_include_sh()
{
   log_entry "print_none_include_sh" "$@"

   cat <<EOF
[ "\${TRACE}" = "YES" ] && set -x  && : "\$0" "\$@"

[ -z "\${MULLE_VIRTUAL_ROOT}" -o -z "\${MULLE_UNAME}"  ] && \\
   echo "Your script needs to setup MULLE_VIRTUAL_ROOT \\
and MULLE_UNAME properly" >&2  && exit 1

MULLE_HOSTNAME="\`PATH=/bin:/usr/bin hostname -s\`" # don't export it

MULLE_ENV_SHARE_DIR="\${MULLE_VIRTUAL_ROOT}/.mulle-env/share"
MULLE_ENV_ETC_DIR="\${MULLE_VIRTUAL_ROOT}/.mulle-env/etc"


#
# The aux file if present is to be set by mulle-sde extensions.
# The trick here is that mulle-env doesn't clobber this file
# when doing an init -f, which can be useful. There is no etc
# equivalent.
#
if [ -f "\${MULLE_ENV_SHARE_DIR}/environment-aux.sh" ]
then
   . "\${MULLE_ENV_SHARE_DIR}/environment-aux.sh"
fi

#
# Default environment values set by plugins and extensions.
# The user should never edit them. He can override settings
# in etc.
#
if [ -f "\${MULLE_ENV_ETC_DIR}/environment-global.sh" ]
then
   . "\${MULLE_ENV_ETC_DIR}/environment-global.sh"
else
   if [ -f "\${MULLE_ENV_SHARE_DIR}/environment-global.sh" ]
   then
      . "\${MULLE_ENV_SHARE_DIR}/environment-global.sh"
   fi
fi

if [ -f "\${MULLE_ENV_ETC_DIR}/environment-os-\${MULLE_UNAME}.sh" ]
then
   . "\${MULLE_ENV_ETC_DIR}/environment-os-\${MULLE_UNAME}.sh"
else
   if [ -f "\${MULLE_ENV_SHARE_DIR}/environment-os-\${MULLE_UNAME}.sh" ]
   then
      . "\${MULLE_ENV_SHARE_DIR}/environment-os-\${MULLE_UNAME}.sh"
   fi
fi

#
# Load in some modifications depending on  hostname, username. These
# won't be provided by extensions or plugins.
#
# These settings could be "cased" in a single file, but it seems convenient.
# And more managable for mulle-env environment
#

if [ -f "\${MULLE_ENV_ETC_DIR}/environment-host-\${MULLE_HOSTNAME}.sh" ]
then
   . "\${MULLE_ENV_ETC_DIR}/environment-host-\${MULLE_HOSTNAME}.sh"
fi

if [ -f "\${MULLE_ENV_ETC_DIR}/environment-user-\${USER}.sh" ]
then
   . "\${MULLE_ENV_ETC_DIR}/environment-user-\${USER}.sh"
fi

#
# For more complex edits, that don't work with the cmdline tool
#
if [ -f "\${MULLE_ENV_ETC_DIR}/environment-aux.sh" ]
then
   . "\${MULLE_ENV_ETC_DIR}/environment-aux.sh"
fi

unset MULLE_ENV_ETC_DIR
unset MULLE_ENV_SHARE_DIR
unset MULLE_HOSTNAME

EOF
}


print_none_environment_global_sh()
{
   cat <<EOF
# add your stuff here
EOF
}


# callback
print_none_tools_sh()
{
   log_entry "print_none_tools_sh" "$@"

   echo "mudo"

   if [ ! -z "${OPTION_OTHER_TOOLS}" ]
   then
      echo "${OPTION_OTHER_TOOLS}"
   fi
}


print_none_optional_tools_sh()
{
   log_entry "print_none_optional_tools_sh" "$@"

   if [ ! -z "${OPTION_OTHER_OPTIONAL_TOOLS}" ]
   then
      echo "${OPTION_OTHER_OPTIONAL_TOOLS}"
   fi
}

