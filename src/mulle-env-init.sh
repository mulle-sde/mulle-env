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
Tool-style: (built-in only, see \`mulle-env toolstyles\` for all available)
   none               : no additions
   minimal            : a minimal set of tools (like cd, ls)
   developer          : a common set of tools (like cd, ls, awk, man) (default)

Env-style:
   tight              : all environment variables must be user defined
   restrict           : inherit some environment (like SSH_TTY) (default)
   relax              : as relax plus all /bin and /usr/bin tools
   inherit            : as restrict plus all tools in PATH
   wild               : no restrictions
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
   shell_disable_glob; IFS=$'\n'
   for keyvalue in ${CUSTOM_ENVIRONMENT}
   do
      shell_enable_glob; IFS="${DEFAULT_IFS}"

      eval "export ${keyvalue}"
   done
   shell_enable_glob; IFS="${DEFAULT_IFS}"
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

            r_add_line "${OPTION_OTHER_TOOLS}" "$1"
            OPTION_OTHER_TOOLS="${RVAL}"
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

   [ "$#" -eq 0 ] || fail "Superflous arguments \"$*\""

   #
   # command line parameters added via -D will just be exported here
   # for orthogonality so they don't get lost, but they won't be persisted
   # in any way
   #
   custom_environment_init

   local envfile
   local envincludefile
   local auxscopefile
   local stylefile
   local versionfile
   local sharedir
   local completionfile
   local toolfile
   local style
   local flavor

   MULLE_ENV_SHARE_DIR="${directory}/.mulle/share/env"

   sharedir="${MULLE_ENV_SHARE_DIR}"
   envfile="${sharedir}/environment.sh"

   if [ "${OPTION_UPGRADE}" != 'YES' -a -f "${envfile}" ]
   then
      log_warning "\"${envfile}\" already exists"
      return 4
   fi

   if [ "${OPTION_UPGRADE}" = 'YES' ]
   then
      local mulle_dir="${MULLE_VIRTUAL_ROOT:-${PWD}}/.mulle"
      local old_mulleenv_dir="${MULLE_VIRTUAL_ROOT:-${PWD}}/.mulle-env"

      if [ "${OPTION_STYLE}" = 'DEFAULT' ]
      then
         if ! __get_saved_style_flavor "${mulle_dir}/etc/env" \
                                       "${mulle_dir}/share/env"
         then

            # old directories
            if [ ! -d "${mulle_dir}" ]
            then
               if [ -d "${old_mulleenv_dir}" ]
               then
                  if ! __get_saved_style_flavor "${old_mulleenv_dir}/etc" \
                                                "${old_mulleenv_dir}/share"
                  then
                     fail "Could not retrieve style from old .mulle-env directory"
                  fi
               else
                  log_warning "Can not determine style of (${MULLE_VIRTUAL_ROOT:-${PWD}})"
               fi
            else
               __fail_get_saved_style_flavor "${mulle_dir}/etc/env" \
                                             "${mulle_dir}/share/env"
            fi
         fi
         OPTION_STYLE="${style:-DEFAULT}"
      fi
   fi

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

   # chmoding the share directory is bad for git
   if [ "${OPTION_PROTECT}" != 'NO' ] && [ -d "${sharedir}" ]
   then
      exekutor find "${sharedir}" -type f -exec chmod ug+w {} \;
   fi

   (
      # need proper flavor for migration
      if [ "${OPTION_UPGRADE}" = 'YES' ]
      then
         if ! _r_get_saved_version "${MULLE_ENV_SHARE_DIR}" "${MULLE_VIRTUAL_ROOT:-${PWD}}"
         then
            fail "Can not upgrade \"$PWD\" as there is no ${MULLE_ENV_SHARE_DIR}/version"
         fi
         version="${RVAL}"

         # shellcheck source=src/mulle-env-migrate.sh
         . "${MULLE_ENV_LIBEXEC_DIR}/mulle-env-migrate.sh"
         env_migrate "${version}" "${MULLE_ENV_VERSION}" "${flavor}"
      fi

      envincludefile="${sharedir}/include-environment.sh"

      pluginfile="${sharedir}/environment-plugin.sh"
      completionfile="${sharedir}/libexec/mulle-env-bash-completion.sh"
      auxscopefile="${sharedir}/auxscope"
      toolfile="${sharedir}/tool-plugin"
      versionfile="${sharedir}/version"

      stylefile="${sharedir}/style"


      # indicate a fresh init by removing a possibly old versionfile
      remove_file_if_present "${versionfile}"

      log_verbose "Creating \"${envfile}\""

      mkdir_if_missing "${sharedir}"

      local text

      if ! text="`print_${flavor}_startup_sh "${style}" `"
      then
         fail "Plugin \"${flavor}\" failed in startup"
      fi

      redirect_exekutor "${envfile}" printf "%s\n" "${text}" || exit 1

      text="`print_${flavor}_auxscope_sh "${style}" `"
      if [ ! -z "${text}" ]
      then
         log_verbose "Creating \"${auxscopefile}\""
         redirect_exekutor "${auxscopefile}" printf "%s\n" "${text}" || exit 1
      fi

      log_verbose "Creating \"${envincludefile}\""
      if ! text="`print_${flavor}_include_sh "${style}" `"
      then
         fail "Plugin \"${flavor}\" failed in include"
      fi
      redirect_exekutor "${envincludefile}" printf "%s\n" "${text}" || exit 1

      log_verbose "Creating \"${pluginfile}\""
      if ! text="`print_${flavor}_environment_aux_sh "${style}" `"
      then
         fail "Plugin \"${flavor}\" failed in environment_aux"
      fi
      if [ ! -z "${text}" ]
      then
         redirect_exekutor "${pluginfile}" printf "%s\n" "${text}" || exit 1
      fi

      # add more os flavors later
      for os in darwin freebsd linux mingw
      do
         callback="print_${flavor}_environment_os_${os}_sh"
         if shell_is_function "${callback}"
         then
            local pluginosfile

            pluginosfile="${sharedir}/environment-plugin-os-${os}.sh"
            log_verbose "Creating \"${pluginosfile}\""
            if ! text="`${callback} "${style}" `"
            then
               fail "Plugin \"${flavor}\" failed in environment os"
            fi
            redirect_exekutor "${pluginosfile}" printf "%s\n" "${text}" || exit 1
         fi
      done

      log_verbose "Creating \"${toolfile}\""
      if ! text="`print_${flavor}_tools_sh "${style}" | sort -u`"
      then
         fail "Tool install of \"${flavor}\" failed"
      fi
      redirect_exekutor "${toolfile}" printf "%s\n" "${text}" || exit 1

      mkdir_if_missing "${sharedir}/libexec"
      log_verbose "Installing \"${completionfile}\""
      exekutor cp "${MULLE_ENV_LIBEXEC_DIR}/mulle-env-bash-completion.sh" \
                   ${completionfile}

      log_verbose "Creating \"${stylefile}\""
      redirect_exekutor "${stylefile}" printf "%s\n" "${style}" || exit 1

      log_verbose "Creating .mulle/.gitignore"
      redirect_exekutor "${directory}/.mulle/.gitignore" cat <<EOF
var/
environment-host-*.sh
!environment-host-ci-*.sh
EOF

      log_verbose "Creating .mulle/README.md"
      redirect_exekutor "${directory}/.mulle/README.md" cat <<EOF
# .mulle

This \`.mulle\` folder is used by [mulle-sde](//mulle-sde.github.io) to
store project information.

## Structure

* \`etc\` is user editable, changes will be preserved.
* \`share\` is read only, changes will be lost on the next upgrade.
* \`var\` is ephemeral. You can delete and it will get recreated.

Every mulle-sde tool may have its own subfolder within those three folders.
It's name will be the name of the tool without the "mulle-" prefix.

You can edit the files in \`etc\` with any editor, but for consistency and
ease of use, it's usually better to use the appropriate mulle-sde tool.

## Remove .mulle

The share folder is often write protected, to prevent accidental user edits.

\`\`\`
chmod -R ugo+rwX .mulle && rm -rf .mulle
\`\`\`

EOF

      # we create this last, if its present than the init ran through
      log_verbose "Creating \"${versionfile}\""
      redirect_exekutor "${versionfile}" printf "%s\n" "${MULLE_ENV_VERSION}" || exit 1
   )
   rval=$?

   # chmoding the share directory is bad for git
   if [ "${OPTION_PROTECT}" != 'NO' ] && [ -d "${sharedir}" ]
   then
      exekutor find "${sharedir}" -type f -exec chmod a-w {} \;
   fi

   [ $rval -ne 0 ] && exit $rval

   if [ "${OPTION_UPGRADE}" != 'YES' -a "${OPTION_BLURB}" != 'NO' ]
   then
      log_info "Enter the environment:
   ${C_RESET_BOLD}${MULLE_EXECUTABLE_NAME} \"${directory#${MULLE_USER_PWD}/}\"${C_INFO}"
   fi

   RVAL="${directory}"
}
