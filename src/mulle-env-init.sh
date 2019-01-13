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
MULLE_ENV_INIT_SH="included"


env_init_usage()
{
   [ $# -ne 0 ] && log_error "$*"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} [flags] init [options]

   Initialize the working directory for mulle-env.

Options:
   -d <dir>           : use directory "dir" instead of working directory
   --no-blurb         : don't print helpful info at exit
   --style <tool/env> : specify environment style

EOF

   cat <<EOF >&2
Tool-style: (built-in only, see \`mulle-sde toolstyles\` for all available)
   none          : no additions
   minimal       : a minimal set of tools (like cd, ls)
   developer     : a common set of tools (like cd, ls, awk, man) (default)

Env-style:
   tight         : all environment variables are user defined
   relax         : none + inherit some environment (e.g. SSH_TTY) (default)
   restrict      : relax + all /bin and /usr/bin tools
   inherit       : restrict + all PATH tools
   wild          : no restrictions
EOF
   exit 1
}


custom_environment_init()
{
   log_entry "custom_environment_init" "$@"

   local keyvalue

   local key
   local quotedvalue

   [ -z "${CUSTOM_ENVIRONMENT}" ] && return

#   [ -z "${MULLE_ENV_ENVIRONMENT_SH}" ] && . "${MULLE_ENV_LIBEXEC_DIR}/mulle-env-environment.sh"

   #
   # use custom environment values to set environment
   #
   set -f; IFS="
"
   for keyvalue in ${CUSTOM_ENVIRONMENT}
   do
      set +f; IFS="${DEFAULT_IFS}"

      eval "export ${keyvalue}"
   done
   set +f; IFS="${DEFAULT_IFS}"
}


env_init_main()
{
   log_entry "env_init_main" "$@"

   local OPTION_OTHER_TOOLS=
   local OPTION_BLURB="DEFAULT"
   local OPTION_STYLE="DEFAULT"

   local directory
   directory="${PWD}"

   while [ $# -ne 0 ]
   do
      case "$1" in
         -h*|--help|help)
            env_init_usage
         ;;

         -d|--directory)
            [ $# -eq 1 ] && fail "Missing argument to $1"
            shift

            directory="$1"
         ;;

         --blurb)
            OPTION_BLURB='YES'
         ;;

         --no-blurb)
            OPTION_BLURB='NO'
         ;;

         --style)
            [ $# -eq 1 ] && fail "missing argument to $1"
            shift

            OPTION_STYLE="$1"
         ;;

         -t|--tool)
            [ $# -eq 1 ] && fail "missing argument to $1"
            shift

            OPTION_OTHER_TOOLS="`add_line "${OPTION_OTHER_TOOLS}" "$1" `"
         ;;

         --upgrade)
            OPTION_UPGRADE='YES'
         ;;

         -*)
            env_init_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   [ "$#" -eq 0 ] || fail "Superflous arguments $*"

   #
   # command line parameters added via -D will just be exported here
   # for orthogonality so they don't get lost, but they won't be persisted
   # in any way
   #
   custom_environment_init


   local envfile
   local envincludefile
   local auxscopesfile
   local toolsfile
   local stylefile
   local versionfile
   local sharedir
   local optional_toolsfile
   local completionfile
   local style
   local flavor

   MULLE_ENV_SHARE_DIR="${directory}/.mulle/share/env"

   if [ "${OPTION_UPGRADE}" = 'YES' ]
   then
      if ! _r_get_saved_version "${MULLE_ENV_SHARE_DIR}" "${MULLE_VIRTUAL_ROOT:-${PWD}}"
      then
         fail "Can not upgrade \"$PWD\" as there is no ${MULLE_ENV_SHARE_DIR}/version"
      fi
      version="${RVAL}"

      if [ "${version%%.*}" -lt 2 ]
      then
         # shellcheck source=src/mulle-env-migrate.sh
         . "${MULLE_ENV_LIBEXEC_DIR}/mulle-env-migrate.sh"
         env_migrate_from_v1_to_v2
      fi

      if [ "${OPTION_STYLE}" = 'DEFAULT' ]
      then
         if ! __get_saved_style_flavor "${MULLE_VIRTUAL_ROOT:-${PWD}}/.mulle/etc/env" \
                                       "${MULLE_VIRTUAL_ROOT:-${PWD}}/.mulle/share/env"
         then
            __fail__get_saved_style_flavor "${MULLE_VIRTUAL_ROOT:-${PWD}}/.mulle/etc/env"
         fi
         OPTION_STYLE="${style:-DEFAULT}"
      fi
   fi

   sharedir="${MULLE_ENV_SHARE_DIR}"

   envfile="${sharedir}/environment.sh"
   envincludefile="${sharedir}/include-environment.sh"

   pluginfile="${sharedir}/environment-plugin.sh"
   completionfile="${sharedir}/libexec/mulle-env-bash-completion.sh"
   auxscopesfile="${sharedir}/auxscopes"

   toolsfile="${sharedir}/tool"
   optional_toolsfile="${sharedir}/optionaltool"
   versionfile="${sharedir}/version"

   stylefile="${sharedir}/style"

   if [ "${OPTION_STYLE}" = 'DEFAULT' ]
   then
      OPTION_STYLE="${MULLE_ENV_DEFAULT_STYLE}"
   fi

   __get_style_flavor "${OPTION_STYLE}"
   __load_flavor_plugin "${flavor}"

   case "${style}" in
      */inherit|*/relax|*/restrict|*/tight|*/wild)
      ;;

      *)
         fail "Unknown style \"${style}\""
      ;;
   esac
   log_verbose "Init style is \"${style}\""

   if [ "${OPTION_UPGRADE}" != 'YES' -a -f "${envfile}" ]
   then
      log_warning "\"${envfile}\" already exists"
      return 2
   fi

   mkdir_if_missing "${sharedir}"
   find "${sharedir}" -type f -exec chmod ug+w {} \; || return 1

   # indicate a fresh init by removing a possibly old versionfile
   remove_file_if_present "${versionfile}"

   log_verbose "Creating \"${envfile}\""

   local text

   if ! text="`print_${flavor}_startup_sh "${style}" `"
   then
      return 1
   fi
   redirect_exekutor "${envfile}" echo "${text}"

   text="`print_${flavor}_auxscopes_sh "${style}" `"
   if [ ! -z "${text}" ]
   then
      log_verbose "Creating \"${auxscopesfile}\""
      redirect_exekutor "${auxscopesfile}" echo "${text}"
   fi

   log_verbose "Creating \"${envincludefile}\""
   if ! text="`print_${flavor}_include_sh "${style}" `"
   then
      return 1
   fi
   redirect_exekutor "${envincludefile}" echo "${text}"

   log_verbose "Creating \"${pluginfile}\""
   if ! text="`print_${flavor}_environment_aux_sh "${style}" `"
   then
      return 1
   fi
   if [ ! -z "${text}" ]
   then
      redirect_exekutor "${pluginfile}" echo "${text}"
   fi

   # add more os flavors later
   for os in darwin freebsd linux mingw
   do
      callback="print_${flavor}_environment_os_${os}_sh"
      if [ "`type -t "${callback}"`" = "function" ]
      then
         local pluginosfile

         pluginosfile="${sharedir}/environment-plugin-os-${os}.sh"
         log_verbose "Creating \"${pluginosfile}\""
         if ! text="`${callback} "${style}" `"
         then
            return 1
         fi
         redirect_exekutor "${pluginosfile}" echo "${text}"
      fi
   done

   log_verbose "Creating \"${toolsfile}\""
   if ! text="`print_${flavor}_tools_sh "${style}" | sort -u`"
   then
      return 1
   fi
   redirect_exekutor "${toolsfile}" echo "${text}"

   log_verbose "Creating \"${optional_toolsfile}\""
   if ! text="`print_${flavor}_optional_tools_sh "${style}" | sort -u`"
   then
      return 1
   fi
   redirect_exekutor "${optional_toolsfile}" echo "${text}"

   mkdir_if_missing "${sharedir}/libexec"
   log_verbose "Installing \"${completionfile}\""
   exekutor cp "${MULLE_ENV_LIBEXEC_DIR}/mulle-env-bash-completion.sh" \
                ${completionfile}

   log_verbose "Creating \"${stylefile}\""
   redirect_exekutor "${stylefile}" echo "${style}"

   # we create this last, if its present than the init ran through
   log_verbose "Creating \"${versionfile}\""
   redirect_exekutor "${versionfile}" echo "${MULLE_ENV_VERSION}"

   # chowning the directory is bad for git
   find "${sharedir}" -type f -exec chmod a-w {} \;

   if [ "${OPTION_UPGRADE}" != 'YES' -a "${OPTION_BLURB}" != 'NO' ]
   then
      log_info "Enter the environment:
   ${C_RESET_BOLD}${MULLE_EXECUTABLE_NAME} \"${directory#${MULLE_USER_PWD}/}\"${C_INFO}"
   fi
}
