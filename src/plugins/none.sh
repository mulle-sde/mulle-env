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
#######
### none startup
#######
[ "\${TRACE}" = 'YES' -o "\${ENVIRONMENT_SH_TRACE}" = 'YES' ] && set -x  && : "\$0" "\$@"

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

#
# now read in custom envionment (required)
#
. "\${MULLE_VIRTUAL_ROOT}/.mulle-env/share/include-environment.sh"

#
# basic setup for interactive shells
#
case "\${MULLE_SHELL_MODE}" in
   *INTERACTIVE*)
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

      # install mulle-env-reload

      alias mulle-env-reload='. "\${MULLE_VIRTUAL_ROOT}/.mulle-env/share/include-environment.sh"'


      #
      # source in any bash completion files
      #
      DEFAULT_IFS="\${IFS}"
      shopt -s nullglob; IFS="
"
      for FILENAME in "\${MULLE_VIRTUAL_ROOT}/.mulle-env/share/libexec"/*-bash-completion.sh
      do
         . "\${FILENAME}"
      done
      shopt -u nullglob; IFS="\${DEFAULT_IFS}"

      unset FILENAME
      unset DEFAULT_IFS


      #
      # show motd, if any
      #
      if [ -z "\${NO_MOTD}" ]
      then
         if [ -f "\${MULLE_VIRTUAL_ROOT}/.mulle-env/etc/motd" ]
         then
            cat "\${MULLE_VIRTUAL_ROOT}/.mulle-env/etc/motd"
         else
            if [ -f "\${MULLE_VIRTUAL_ROOT}/.mulle-env/share/motd" ]
            then
               cat "\${MULLE_VIRTUAL_ROOT}/.mulle-env/share/motd"
            fi
         fi
      else
         unset NO_MOTD
      fi
   ;;
esac

EOF
}


print_none_include_header_sh()
{
   log_entry "print_none_include_header_sh" "$@"

   cat <<EOF
[ -z "\${MULLE_VIRTUAL_ROOT}" -o -z "\${MULLE_UNAME}"  ] && \\
   echo "Your script needs to setup MULLE_VIRTUAL_ROOT \\
and MULLE_UNAME properly" >&2  && exit 1

case "\${MULLE_UNAME}" in
   'mingw'*)
      MULLE_HOSTNAME="\`PATH=/bin:/usr/bin hostname\`" # don't export it
   ;;

   *)
      MULLE_HOSTNAME="\`PATH=/bin:/usr/bin hostname -s\`" # don't export it
   ;;
esac

MULLE_ENV_SHARE_DIR="\${MULLE_VIRTUAL_ROOT}/.mulle-env/share"
MULLE_ENV_ETC_DIR="\${MULLE_VIRTUAL_ROOT}/.mulle-env/etc"
EOF
}


print_none_include_environment_sh()
{
   log_entry "print_none_include_environment_sh" "$@"

   cat <<EOF
# Top/down order of inclusion. Left overrides right if present.
# Keep these files (except environment-custom.sh) clean off manual edits so
# that mulle-env can read and set environment variables.
#
# .mulle-env/etc                        | .mulle-env/share
# --------------------------------------|--------------------
#                                       | environment-plugin.sh
# environment-global.sh                 |
# environment-os-\${MULLE_UNAME}.sh      | environment-os-\${MULLE_UNAME}.sh
# environment-host-\${MULLE_HOSTNAME}.sh |
# environment-user-\${USER}.sh           |
# environment-custom.sh                 |
#

#
# The plugin file, if present is to be set by a mulle-env plugin
#
if [ -f "\${MULLE_ENV_SHARE_DIR}/environment-plugin.sh" ]
then
   . "\${MULLE_ENV_SHARE_DIR}/environment-plugin.sh"
fi


#
# Global user settings
#
if [ -f "\${MULLE_ENV_ETC_DIR}/environment-global.sh" ]
then
   . "\${MULLE_ENV_ETC_DIR}/environment-global.sh"
fi

#
# "os-" can be written by extensions also
#
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
# Load in some user modifications depending on hostname, username. These
# won't be provided by extensions or plugins.
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
if [ -f "\${MULLE_ENV_ETC_DIR}/environment-custom.sh" ]
then
   . "\${MULLE_ENV_ETC_DIR}/environment-custom.sh"
fi
EOF
}


print_none_include_footer_sh()
{
   log_entry "print_none_include_footer_sh" "$@"

   cat <<EOF
unset MULLE_ENV_ETC_DIR
unset MULLE_ENV_SHARE_DIR
unset MULLE_HOSTNAME

EOF
}


print_none_include_sh()
{
   log_entry "print_none_include_sh" "$@"

   print_none_include_header_sh "$@"
   print_none_include_environment_sh "$@"
   print_none_include_footer_sh "$@"
}


print_none_environment_aux_sh()
{
   cat <<EOF
# add your stuff here
EOF
}



print_none_auxscopes_sh()
{
   log_entry "print_none_auxscopes_sh" "$@"
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

