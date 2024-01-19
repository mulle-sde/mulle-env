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

env::plugin::none::print_startup()
{
   log_entry "env::plugin::none::print_startup" "$@"

   cat <<EOF
#######
### none startup
#######
[ "\${TRACE}" = 'YES' -o "\${ENVIRONMENT_SH_TRACE}" = 'YES' ] && set -x  && : "\$0" "\$@"

#
# If mulle-env is broken, sometimes its nice just to source this file.
# If you're sourcing this manually on a regular basis, you're doing it wrong.
#
if [ -z "\${MULLE_VIRTUAL_ROOT}" ]
then
   MULLE_VIRTUAL_ROOT="\`PATH=/bin:/usr/bin pwd -P\`"
   echo "Using \${MULLE_VIRTUAL_ROOT} as MULLE_VIRTUAL_ROOT for \\
your convenience" >&2
fi

if [ -z "\${MULLE_UNAME}" ]
then
   MULLE_UNAME="\`PATH=/bin:/usr/bin uname -s 2> /dev/null | tr '[:upper:]' '[:lower:]'\`"
   MULLE_UNAME="\${MULLE_UNAME:-unknown}"
   echo "Using \${MULLE_UNAME} as MULLE_UNAME for your convenience" >&2
fi

#
# now read in custom envionment (required)
#
. "\${MULLE_VIRTUAL_ROOT}/.mulle/share/env/include-environment.sh"

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
            PS1="\$( PATH=/bin:/usr/bin sed 's/\\\\h/\\\\h\\['\${envname}'\\]/' <<< "\${PS1}" )"
         ;;

         *)
            PS1='\\u@\\h['\${envname}'] \\W\$ '
         ;;
      esac
      export PS1

      unset envname

      # install cd catcher
      if [ ! -z "\${MULLE_ENV_LIBEXEC_DIR}" ]
      then
         . "\${MULLE_ENV_LIBEXEC_DIR}/mulle-env-cd.sh"
         unset MULLE_ENV_LIBEXEC_DIR
      fi

      # install mulle-env-reload

      alias mulle-env-reload='. "\${MULLE_VIRTUAL_ROOT}/.mulle/share/env/include-environment.sh"'

      #
      # source in any bash completion files
      #
      DEFAULT_IFS="\${IFS}"
      IFS=$'\n'
      # memo: nullglob not easily done on both bash and zsh
      for FILENAME in "\${MULLE_VIRTUAL_ROOT}/.mulle/share/env/libexec"/*-bash-completion.sh
      do
         if [ -f "\${FILENAME}" ]
         then
            . "\${FILENAME}"
         fi
      done
      IFS="\${DEFAULT_IFS}"

      unset DEFAULT_IFS
      unset FILENAME

      vardir="\${MULLE_VIRTUAL_ROOT}/.mulle/var/\${MULLE_HOSTNAME:-unknown-host}"
      [ -d "\${vardir}" ] || PATH=/bin:/usr/bin mkdir -p "\${vardir}"

      HISTFILE="\${vardir}/bash_history"
      export HISTFILE

      unset vardir

      #
      # show motd, if any
      #
      if [ -z "\${NO_MOTD}" ]
      then
         if [ -f "\${MULLE_VIRTUAL_ROOT}/.mulle/etc/env/motd" ]
         then
            cat "\${MULLE_VIRTUAL_ROOT}/.mulle/etc/env/motd"
         else
            if [ -f "\${MULLE_VIRTUAL_ROOT}/.mulle/share/env/motd" ]
            then
               cat "\${MULLE_VIRTUAL_ROOT}/.mulle/share/env/motd"
            fi
         fi
      fi
   ;;
esac

# remove some uglies
unset NO_MOTD
unset TRACE

EOF
}


env::plugin::none::print_include_header()
{
   log_entry "env::plugin::none::print_include_header" "$@"

   cat <<EOF
[ -z "\${MULLE_VIRTUAL_ROOT}" -o -z "\${MULLE_UNAME}"  ] && \\
   echo "Your script needs to setup MULLE_VIRTUAL_ROOT \\
and MULLE_UNAME properly" >&2  && exit 1

MULLE_ENV_SHARE_DIR="\${MULLE_VIRTUAL_ROOT}/.mulle/share/env"
MULLE_ENV_ETC_DIR="\${MULLE_VIRTUAL_ROOT}/.mulle/etc/env"
EOF
}


env::plugin::none::print_include_environment()
{
   log_entry "env::plugin::none::print_include_environment" "$@"

   cat <<EOF
# Top/down order of inclusion.
# Keep these files (except environment-custom.sh) clean off manual edits so
# that mulle-env can read and set environment variables.
#
# .mulle/etc/env                        | .mulle/share/env
# --------------------------------------|--------------------
#                                       | environment-plugin.sh
#                                       | environment-plugin-os-\${MULLE_UNAME}.sh
# environment-project.sh                |
# environment-global.sh                 |
# environment-os-\${MULLE_UNAME}.sh      |
# environment-host-\${MULLE_HOSTNAME}.sh |
# environment-user-\${MULLE_USERNAME}.sh |
# environment-custom.sh                 |
# environment-post-global.sh            |
#
scopes="s:plugin;5
s:plugin-os-\${MULLE_UNAME};15
e:global;40
e:os-\${MULLE_UNAME};60
e:host-\${MULLE_HOSTNAME};80
e:user-\${MULLE_USERNAME};100
e:custom;1000
e:post-global;2000"

if [ -f "\${MULLE_ENV_ETC_DIR}/auxscope" ]
then
   auxscopes="\`PATH=/bin:/usr/bin sed -e 's/^/e:/'  \\
                    -e "s/\\\${MULLE_UNAME}/\${MULLE_UNAME}/" \\
                    -e "s/\\\${MULLE_HOSTNAME}/\${MULLE_HOSTNAME}/" \\
                    -e "s/\\\${MULLE_USERNAME}/\${MULLE_USERNAME}/" \\
                    "\${MULLE_ENV_ETC_DIR}/auxscope"\`"
   scopes="\${scopes}"\$'\\n'"\${auxscopes}"
fi

if [ -f "\${MULLE_ENV_SHARE_DIR}/auxscope" ]
then
   auxscopes="\`PATH=/bin:/usr/bin sed -e 's/^/s:/'  \\
                    -e "s/\\\${MULLE_UNAME}/\${MULLE_UNAME}/" \\
                    -e "s/\\\${MULLE_HOSTNAME}/\${MULLE_HOSTNAME}/" \\
                    -e "s/\\\${MULLE_USERNAME}/\${MULLE_USERNAME}/" \\
                    "\${MULLE_ENV_SHARE_DIR}/auxscope"\`"
   scopes="\${scopes}"\$'\\n'"\${auxscopes}"
fi

#
# Load scopes according to priority now
# put in local var for crazy old bashes
#
prioscopes=\`printf "%s\\n" "\${scopes}" \\
              | PATH=/bin:/usr/bin sort -t';' -k2n -k1 \\
              | PATH=/bin:/usr/bin sed -n -e 's/\(.*\);.*$/\1/p'\`

for scope in \${prioscopes}
do
   case "\${scope}" in
      e:*)
         includefile="\${MULLE_ENV_ETC_DIR}/environment-\${scope#?:}.sh"
      ;;

      s:*)
         includefile="\${MULLE_ENV_SHARE_DIR}/environment-\${scope#?:}.sh"
      ;;

      *)
         continue;
      ;;
   esac

   if [ -f "\${includefile}" ]
   then
      . "\${includefile}"
   fi
done

unset scope
unset scopes
unset auxscopes
unset includefile

EOF
}


env::plugin::none::print_include_footer()
{
   log_entry "env::plugin::none::print_include_footer" "$@"

   cat <<EOF
unset MULLE_ENV_ETC_DIR
unset MULLE_ENV_SHARE_DIR

EOF
}


env::plugin::none::print_include()
{
   log_entry "env::plugin::none::print_include" "$@"

   env::plugin::none::print_include_header "$@"
   env::plugin::none::print_include_environment "$@"
   env::plugin::none::print_include_footer "$@"
}


env::plugin::none::print_environment_aux()
{
   log_entry "env::plugin::none::print_environment_aux" "$@"
}


env::plugin::none::print_auxscope()
{
   log_entry "env::plugin::none::print_auxscope" "$@"
}


env::plugin::none::setup_tools()
{
   log_entry "env::plugin::developer::setup_tools" "$@"
}


# callback
env::plugin::none::print_tools()
{
   log_entry "env::plugin::none::print_tools" "$@"
}

