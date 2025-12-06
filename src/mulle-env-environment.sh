# shellcheck shell=bash
#
#   Copyright (c) 2015 Nat! - Mulle kybernetiK
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
MULLE_ENV_ENVIRONMENT_SH='included'


env::environment::print_options()
{
   local space="$1"

   cat <<EOF
Options:
   --host <name>  ${space}: narrow scope to host with name
   --os <name>    ${space}: narrow scope to operating system
   --scope <name> ${space}: use an arbitrarily named scope
   --user <name>  ${space}: narrow scope to user with name
   --this-host    ${space}: narrow scope to this host ($MULLE_HOSTNAME)
   --this-os      ${space}: narrow scope to this operating system ($MULLE_UNAME)
   --this-user    ${space}: user with name ($MULLE_USERNAME)
   --this-os-user ${space}: user and os ($MULLE_USERNAME-$MULLE_UNAME)
   --[a-z]*       ${space}: shortcut for --scope <name> (e.g. --global)
   --cat          ${space}: unsorted output
EOF
}


env::environment::usage()
{
   [ $# -ne 0 ] && log_error "$1"

SHOWN_COMMANDS="\
   list              : list environment variables
   set               : set an environment variable
   editor            : run mulle-environment-editor (needs node.js)
   get               : get value of an environment variable
   remove            : remove an environment variable
   scope             : add remove and list scopes
"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} environment [options] [command]*

   Manage environment variables as set by mulle-env when entering an
   environment. You general settings will be in scope "global". There are
   other scopes based on the login user, the current host and the current
   platform (os). See \`${MULLE_USAGE_NAME} environment scope help\` for more
   information about scopes.

   Specifying no scope invokes the 'DEFAULT' scope, which has special semantics
   depending on the command used. See each commands usage info for specifics.

Example:
   Clear a user set environment variable:
      ${MULLE_USAGE_NAME} environment --user set MULLE_FETCH_SEARCH_PATH ""

EOF
   env::environment::print_options >&2

   cat <<EOF >&2

Commands:
EOF

   (
      printf "%s\n" "${SHOWN_COMMANDS}"
   ) | sed '/^$/d' | LC_ALL=C sort >&2

   cat <<EOF >&2
         (use -v for more commands)
EOF
   exit 1
}


env::environment::get_usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} environment [options] get [cmd-options] <key>

   Get the value of an environment variable. You can check the return value
   to determine if a key exists and is empty (0), or absence of the key (1).

   The 'DEFAULT' scope will check the user and host scopes first before
   looking into the global scope and then the other scopes. Use the
   \`environment\` --scope option, to change the scope:

      mulle-env environment --scope project get PROJECT_NAME

   To get at the fully evaluated value, do not use this command but rather
   the unix \`env\` command:

      mulle-env -c env | sed -n 's/^MULLE_FETCH_SEARCH_PATH=\(.*\)/\1/p'

EOF

   env::environment::print_options >&2

   cat <<EOF >&2

Cmd Options:
   --lenient      : return 0 on not found instead of 4
   --output-eval  : resolve value with other environment variables. This will
                    not evaluate values from other scopes though

EOF
   exit 1
}


env::environment::set_usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} env [options] set [cmd-options] <key> [value] [comment]

   Set the value of an environment variable. By default it will save into
   the user scope. Set the desired scope with 'environment' options.

   Use the alias \`mulle-env-reload\` to update your interactive shell
   after edits.

   When you use the 'DEFAULT' scopes, the variable is set in the global scope
   and all values of the same key are deleted from user and host scopes.

Example:
   ${MULLE_USAGE_NAME} environment --global set FOO "A value"

EOF

   env::environment::print_options "   " >&2

   cat <<EOF >&2

Cmd Options:
   --append          : add value to existing values (using separator ':')
   --concat          : add value to existing value with space
   --concat0         : add value to existing value without separator
   --prepend         : prepent value to existing values (using separator ':')
   --remove          : remove value from existing values (using separator ':')
   --separator <sep> : sepecify custom separator for --append

EOF
   exit 1
}



env::environment::remove_usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} environment [options] remove <key>

   Remove an environment variable. By default it will remove the variable
   from all user scopes. Set the desired scope with options.

   Use the alias \`mulle-env-reload\` to update your interactive shell
   after edits.

   When you use the 'DEFAULT' scopes, the variable is deleted from the global
   scope and all user and host scopes.

Example:
      ${MULLE_USAGE_NAME} environment remove FOO

EOF

   env::environment::print_options >&2

   echo

   exit 1
}


env::environment::list_usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} environment [options] list [cmd-options]

   List environment variables. If you specified no scope (before "list"),
   you will get a combined listing of all scopes. Specify the scope using the
   options. See \`${MULLE_USAGE_NAME} environment scope help\` for information
   about scopes and the files used by them.

Example:
      mulle-env environment --scope merged list

EOF

   env::environment::print_options "  " >&2

   cat <<EOF >&2

Cmd Options:
   --output-eval    : resolve values
   --output-command : emit as mulle-env commands

EOF
   exit 1
}


env::environment::scope_usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} environment scope [cmd-options]

   List scopes applicable to this session. The scopes vary by platform, host
   and user. Use \`${MULLE_USAGE_NAME} environment list\` to see the
   contents of all applicable environment scopes with definitions.

   The scopes are listed in increasing order of precedence. A later entry in
   the user setting will override a previous setting in host, os, global et c.

Scopes:
   plugin             : only used by mulle-env plugins
   project            : set by mulle-sde on init
   extension          : set by mulle-sde extensions
   global             : global settings (user defined)
   os-<name>          : operating system specific settings (user defined)
   host-<name>        : host specific settings (user defined)
   user-<name>        : user specific settings (user defined)

Cmd Options:
   --all              : show also plugin, project and extension scopes
   --output-filename  : emit filename of the scope file

EOF
   exit 1
}


env::environment::key_values_to_command()
{
   local line

   local key
   local value
   local escaped_value
   local escaped_key

   while IFS=$'\n' read -r line
   do
      if [ -z "${line}" ]
      then
         continue
      fi

      key="${line%%=*}"
      value="${line#${key}=}"

      # scope is a cheat!!
      printf "%s\n" "${MULLE_USAGE_NAME} environment set ${key} '${value}'"
   done
}


env::environment::key_values_to_sed()
{
   local line

   local key
   local value
   local escaped_value
   local escaped_key

   while IFS=$'\n' read -r line
   do
      if [ -z "${line}" ]
      then
         continue
      fi

      key="${line%%=*}"
      value="${line#${key}=}"

      r_escaped_sed_pattern "${OPTION_SED_KEY_PREFIX}${key}${OPTION_SED_KEY_SUFFIX}"
      escaped_key="${RVAL}"
      r_escaped_sed_replacement "${value}"
      escaped_value="${RVAL}"

      # escape quotes for "eval line"
      escaped_key="${escaped_key//\'/\'\\\'\'}"
      escaped_value="${escaped_value//\'/\'\\\'\'}"
      #   before:
      #   escaped_key=`sed -e "s/'/'\\\\\\''/g" <<< "${escaped_key}"`"
      #   escaped_value="`sed -e "s/'/'\\\\\\''/g" <<< "${escaped_value}"`"

      printf "%s\n" "-e 's/${escaped_key}/${escaped_value}/g'"
   done
}


env::environment::execute_with_unprotected_files_in_dir()
{
   log_entry "env::environment::execute_with_unprotected_files_in_dir" "$@"

   local directory="$1"; shift

   [ -z "${directory}" ] && _internal_fail "directory is empty"

   local protect
   local rval

   # unprotect files
   if [ "${MULLE_FLAG_MAGNUM_FORCE}" = 'YES' -o "${OPTION_PROTECT}" != 'NO' ] \
      && [ -d "${directory}" ]
   then
      protect='YES'
      exekutor find "${directory}" -type f -exec chmod ug+w {} \;
   fi

   (
      "$@"
   )
   rval=$?
      # protect files only, chmoding the share directory is bad for git
   if [ "${protect}" = 'YES' ]
   then
      exekutor find "${directory}" -type f -exec chmod a-w {} \;
   fi
   return $rval
}


env::environment::r_mkdir_if_missing_or_unprotect()
{
   log_entry "env::environment::r_mkdir_if_missing_or_unprotect" "$@"

   local directory="$1"

   [ -z "${directory}" ] && _internal_fail "directory is empty"
   [ "${directory}" = '/' ] && fail "Won't touch root"

   RVAL=
   if [ -w "${directory}" ]
   then
      return 0
   fi

   if [ ! -d "${directory}" ]
   then
      r_dirname "${directory}"
      parentdir="${RVAL}"

      env::environment::r_mkdir_if_missing_or_unprotect "${parentdir}"

      if ! exekutor mkdir "${directory}"
      then
         return 1
      fi
   else
      if ! exekutor chmod ug+wX "${directory}"
      then
         return 1
      fi
   fi

   r_add_line "${RVAL}" "${directory}"
   return 0
}


env::environment::safe_create_file()
{
   log_entry "env::environment::safe_create_file" "$@"

   local filename="$1"; shift

   [ -z "${filename}" ] && _internal_fail "filename is empty"

   local directory

   r_dirname "${filename}"
   directory="${RVAL}"

   if [ "${OPTION_PROTECT}" = 'NO' ]
   then
      r_mkdir_parent_if_missing "${directory}" &&
      (
         exekutor "$@"
      )
      return $?
   fi

   local protectfile
   local protectdirs
   local rval

   env::environment::r_mkdir_if_missing_or_unprotect "${directory}"
   protectdirs="${RVAL}"

   rval=0
   protectfile='YES'
   if [ -f "${filename}" ]
   then
      if [ -w "${filename}" ]
      then
         protectfile='NO'
      else
         exekutor chmod ug+w "${filename}"
         rval=$?
      fi
   fi

   if [ $rval -eq 0 ]
   then
      (
         exekutor "$@"
      )
      rval=$?
   fi

   if [ "${protectfile}" = 'YES' ]
   then
      if ! exekutor chmod a-w "${filename}"
      then
         rval=1
      fi
   fi

   .foreachline directory in ${protectdirs}
   .do
      if ! exekutor chmod a-w "${directory}"
      then
         rval=1
      fi
   .done

   return ${rval}
}


env::environment::safe_write_file()
{
   log_entry "env::environment::safe_write_file" "$@"

   local filename="$1"; shift

   if [ "${OPTION_PROTECT}" = 'NO' ]
   then
      (
         exekutor "$@"
      )
      return $?
   fi

   local protect
   local rval

   if [ ! -w "${filename}" ]
   then
      [ -e "${filename}" ] || _internal_fail "File must exist for write"

      protect='YES'
      if ! exekutor chmod ug+w "${filename}"
      then
         return 1
      fi
   fi

   (
      exekutor "$@"
   )
   rval=$?

   if [ "${protect}" = 'YES' ]
   then
      if ! exekutor chmod a-w "${filename}"
      then
         rval=1
      fi
   fi
   return ${rval}
}


env::environment::safe_create_or_write_file()
{
   log_entry "env::environment::safe_create_or_write_file" "$@"

   local filename="$1"

   if [ ! -f "${filename}" ]
   then
      env::environment::safe_create_file "$@"
   else
      env::environment::safe_write_file "$@"
   fi
}


#
# as write file but also unprotect directory
#
env::environment::safe_modify_file()
{
   log_entry "env::environment::safe_modify_file" "$@"

   local filename="$1"; shift

   if [ "${OPTION_PROTECT}" = 'NO' ]
   then
      (
         exekutor "$@"
      )
      return $?
   fi

   local protect
   local dir_protect
   local rval
   local dir

   r_dirname "${filename}"
   dir="${RVAL}"

   if [ ! -w "${dir}" ]
   then
      dir_protect='YES'
      if ! exekutor chmod ug+wX "${dir}"
      then
         return 1
      fi
   fi

   rval=0
   if [ ! -w "${filename}" ]
   then
      [ -e "${filename}" ] || _internal_fail "File must exist for write"

      protect='YES'
      exekutor chmod ug+w "${filename}"
      rval=$?
   fi

   if [ $rval -eq 0 ]
   then
      (
         exekutor "$@"
      )
      rval=$?
   fi

   if [ "${protect}" = 'YES' ]
   then
      if ! exekutor chmod a-w "${filename}"
      then
         rval=1
      fi
   fi

   if [ "${dir_protect}" = 'YES' ]
   then
      if ! exekutor chmod a-w "${dir}"
      then
         rval=1
      fi
   fi
   return ${rval}
}


env::environment::safe_remove_file_if_present()
{
   log_entry "env::environment::safe_remove_file_if_present" "$@"

   local filename="$1"

   if [ "${OPTION_PROTECT}" = 'NO' ]
   then
      remove_file_if_present "${filename}"
      return $?
   fi

   local dir_protect
   local rval
   local dir

   r_dirname "${filename}"
   dir="${RVAL}"

   if [ ! -w "${dir}" ]
   then
      dir_protect='YES'
      if ! exekutor chmod ug+wX "${dir}"
      then
         return 1
      fi
   fi

   remove_file_if_present "${filename}"
   rval=$?

   if [ "${dir_protect}" = 'YES' ]
   then
      if ! exekutor chmod a-w "${dir}"
      then
         rval=1
      fi
   fi

   return ${rval}
}

#
# Set
#
env::environment::_set()
{
   log_entry "env::environment::_set" "$@"

   local filename="$1"
   local key="$2"
   local value="$3"
   local comment="$4"
   local safe="$5"

   #
   # put quotes around it
   # we don't want to escape ${X} since this is supposed to expand
   # except when presented as '${X}'
   #
   case "${value}" in
      "")
         # otherwise the list grep fails
         value="\"\""
      ;;

      *)
         r_escaped_doublequotes "${value}"
         value="\"${RVAL}\""
      ;;
   esac

   local escaped_value
   local sed_escaped_value
   local sed_escaped_key

   r_escaped_sed_pattern "${key}"
   sed_escaped_key="${RVAL}"

   r_escaped_sed_replacement "${value}"
   sed_escaped_value="${RVAL}"

   log_debug "Key:   >>${key}<<"
   log_debug "Value: >>${value}<<"

   case "${MULLE_SHELL_MODE}" in
      *INTERACTIVE)
         _log_info "Use ${C_RESET_BOLD}mulle-env-reload${C_INFO} to update your \
shell environment"
      ;;
   esac

   #
   # on request, we comment out instead, when value is empty
   #
   if [ -z "${value}" -a "${OPTION_COMMENT_OUT_EMPTY}" = 'YES' ]
   then
      if [ -f "${filename}" ]
      then
         log_fluff "${filename} does not exist"
         return 4
      fi

      if ! env::environment::_file_defines_key "${filename}" "${key}"
      then
         log_fluff "${key} does not exist in ${filename}"
         return 4
      fi

      # if you get weird protection errors here, it might because of lljail
      if [ "${safe}" = 'YES' ]
      then
         env::environment::safe_modify_file "${filename}" \
            inplace_sed -e "s/^\\( *export *${sed_escaped_key}=.*\\)/\
# \\1/" "${filename}"
      else
         exekutor chmod ug+w "${filename}"
         inplace_sed -e "s/^\\( *export *${sed_escaped_key}=.*\\)/\
# \\1/" "${filename}"
      fi
      return $?
   fi

   local file_exists

   #
   # first try inplace-replacement
   #
   if [ -f "${filename}" ]
   then
      if env::environment::_file_defines_key "${filename}" "${key}"
      then
         # inplace sed creates a temporary file, so we need create to unprotect
         # the parent
         if [ "${safe}" = 'YES' ]
         then
            env::environment::safe_modify_file "${filename}" \
               inplace_sed -e "s/^[ #]*export *${sed_escaped_key}=.*/\
export ${sed_escaped_key}=${sed_escaped_value}/" "${filename}"
         else
            exekutor chmod ug+w "${filename}"
            inplace_sed -e "s/^[ #]*export *${sed_escaped_key}=.*/\
export ${sed_escaped_key}=${sed_escaped_value}/" "${filename}"
         fi
         return $?
      fi
      file_exists='YES'
   fi

   if [ -z "${value}" -a "${OPTION_ADD_EMPTY}" = 'NO' ]
   then
      return 0
   fi

   case "${comment}" in
      '#'*)
         comment="#
${comment}
#"
      ;;

      "")
         comment="#
#
#"
      ;;

      *)
         comment="#
# ${comment}
#"
      ;;
   esac

   local text

   text="\
${comment}
export ${key}=${value}

"
   # unprotect if needed
   if [ "${safe}" = 'YES' ]
   then
      env::environment::safe_create_or_write_file "${filename}" \
         redirect_append_exekutor "${filename}" printf "%s\n" "${text}"
   else
      if [ "${file_exists}" = 'YES' ]
      then
         exekutor chmod ug+w "${filename}"
      else
         r_mkdir_parent_if_missing "${filename}"
      fi
      redirect_append_exekutor "${filename}" printf "%s\n" "${text}"
   fi
   # protect if unprotected
}


#
# global (specified implicitly as DEFAULT) is special because it cleans
# everything below it, even scopes not applicable to the current os/machine/usr
#
env::environment::remove_from_global_subscopes()
{
   log_entry "env::environment::remove_from_global_subscopes" "$@"

   local key="$1"

   local i

   #
   # TODO: need to do this properly with scopes and prorities
   #
   .foreachfile i in ${MULLE_ENV_ETC_DIR}/environment-os-*.sh \
                     ${MULLE_ENV_ETC_DIR}/environment-host-*.sh \
                     ${MULLE_ENV_ETC_DIR}/environment-user-*.sh
   .do
      env::environment::_remove "$i" "${key}"
   .done
}


# todo: set is still too hacky
#       and doesn't respect env::scope::r_get_scopes information

env::environment::set_main()
{
   log_entry "env::environment::set_main" "$@"

   local scopename="$1"; shift

   local OPTION_COMMENT_OUT_EMPTY='NO'
   local OPTION_ADD_EMPTY='YES'
   local OPTION_ADD='NO'
   local OPTION_SEPARATOR=":"  # convenient for PATH like behaviour

   # shellcheck source=src/mulle-env-scope.sh
   include "env::scope"

   while [ $# -ne 0 ]
   do
      case "$1" in
         -h|--help|help)
            env::environment::set_usage
         ;;

         --no-add-empty)
            OPTION_ADD_EMPTY='NO'
         ;;

         -a|--add|--append)
            OPTION_ADD='APPEND'
         ;;

         -c|--comment-out-empty)
            OPTION_COMMENT_OUT_EMPTY='YES'
         ;;

         --concat)
            OPTION_ADD='CONCAT'
         ;;

         --concat0)
            OPTION_ADD='CONCAT0'
         ;;

         -p|--prepend)
            OPTION_ADD='PREPEND'
         ;;

         --remove)
            OPTION_ADD='REMOVE'
         ;;

         -s|--separator|--seperator)
            [ "$#" -eq 1 ] && env::environment::set_usage "Missing argument to \"$1\""
            shift

            OPTION_SEPARATOR="$1"
         ;;

         -*)
            env::environment::set_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   local protect

   local key="$1"
   local value="$2"
   local comment="$3"

   # allow also key=value
   case "${key}" in
      *=*)
         value="${key#*=}"
         key="${key%%=*}"
         comment="$2"

         [ $# -lt 1 -o $# -gt 2 ] && env::environment::set_usage
      ;;

      *)
         [ $# -lt 2 -o $# -gt 3 ] && env::environment::set_usage
      ;;
   esac


   [ -z "${key}" ] && env::environment::set_usage "empty key for set"

   env::assert_valid_environment_key "${key}"

   if [ "${OPTION_ADD}" != 'NO' ]
   then
      local prev

      prev="`env::environment::get_main "${scopename}" "${key}"`"
      log_debug "Previous value is \"${prev}\""

      case "${OPTION_ADD}" in
         CONCAT)
            r_concat "${prev}" "${value}"
            value="${RVAL}"
         ;;

         CONCAT0)
            value="${prev}${value}"
         ;;

         REMOVE)
            case "${value}" in
               *${OPTION_SEPARATOR}*)
                  fail "${value} contains '${OPTION_SEPARATOR}', which is not \
possible for removal as this is used to concatenate values.
${C_INFO}Tip: use multiple removal statements."
               ;;
            esac

            local oldvalue
            local newvalue

            IFS="${OPTION_SEPARATOR}"
            .for oldvalue in ${prev}
            .do
               if [ "${oldvalue}" = "${value}" ]
               then
                  .continue
               fi
               r_concat "${newvalue}" "${oldvalue}" "${OPTION_SEPARATOR}"
               newvalue="${RVAL}"
            .done
            IFS="${DEFAULT_IFS}"

            if [ "${newvalue}" = "${oldvalue}" ]
            then
               log_verbose "No change"
               return
            fi
            value="${newvalue}"
         ;;

         *)
            case "${value}" in
               *${OPTION_SEPARATOR}*)
                  fail "${value} contains '${OPTION_SEPARATOR}', which is not \
possible for addition as this is used to concatenate values.
${C_INFO}Tip: use multiple addition statements."
               ;;
            esac

            local oldvalue

            IFS="${OPTION_SEPARATOR}"
            .for oldvalue in ${prev}
            .do
               if [ "${oldvalue}" = "${value}" ]
               then
                  log_fluff "\"${value}\" already set"
                  return 0
               fi
            .done
            IFS="${DEFAULT_IFS}"

            if [ "${OPTION_ADD}" = 'PREPEND' ]
            then
               r_concat "${value}" "${prev}" "${OPTION_SEPARATOR}"
               value="${RVAL}"
            else
               r_concat "${prev}" "${value}" "${OPTION_SEPARATOR}"
               value="${RVAL}"
            fi
         ;;
      esac
   fi

   local filename

   #   log_verbose "Use \`mulle-env-reload\` to get the actual value in your shell"

   log_debug "Environment scope \"${scopename}\" set $key=\"${value}\""

   if [ "${scopename}" = 'DEFAULT' ]
   then
      filename="${MULLE_ENV_ETC_DIR}/environment-global.sh"
      env::environment::_set "${filename}" "${key}" "${value}" "${comment}" 'NO' &&
      env::environment::remove_from_global_subscopes "${key}"
      return $?
   fi

   local scopeprefix
   local rval

   if ! env::scope::r_filename_for_scopeid "${scopename}"
   then
      if env::scope::is_keyword "${scopename}"
      then
         fail "You can't set values in scope \"${scopename}\""
      fi
      fail "Unknown scope \"${scopename}\""
   fi
   filename="${RVAL}"

   safe='YES'
   case "${filename}" in
      ${MULLE_ENV_ETC_DIR}/*)
         safe='NO'
      ;;
   esac

   env::environment::_set "${filename}" "${key}" "${value}" "${comment}" "${safe}"
   rval=$?

   if [ "${MULLE_FLAG_LOG_SETTINGS}" = 'YES' ]
   then
      log_setting "filename : ${filename}"
      cat "${filename}" >&2
   fi

   [ $rval -eq 1 ] && exit 1

   return $rval
}



#
# interface for mulle-sde
#
env::environment::mset_main()
{
   log_entry "env::environment::mset_main" "$@"

   local scopename="$1"; shift

   local key
   local value
   local comment
   local option
   local protect
   local rval

   while [ $# -ne 0 ]
   do
      case "$1" in
         -h|--help)
            fail "mset is an internal command, no help available"
         ;;

         *+=\"*\"*)
            key="${1%%+=*}"
            value="${1#${key}+=}"
            option="--append"
         ;;

         *=*)
            key="${1%%=*}"
            value="${1#${key}=}"
            option=
         ;;

         *)
            fail "$1 is missing a '='"
         ;;
      esac


      comment=

      #
      # value is still in double quotes
      # possible comment trailing with ##
      #
      case "${value}" in
         *\#\#*)
            comment="${value##*##}"
            value="${value%##*}"
         ;;
      esac

      case "${value}" in
         \"*\")
            value="${value:1}"
            value="${value%?}"
         ;;

         *)
            fail "$1: value \"${value}\" is not doublequoted"
         ;;
      esac

      if [ ! -z "${comment}" ]
      then
         comment="${comment//\\n/$'\n'}"
         comment="`sed -e 's/^/# /' <<< "${comment}"`"
      fi

      env::environment::set_main "${scopename}" ${option} "${key}" "${value}" "${comment}"

      shift
   done
}


#
# Get
#
env::environment::_get()
{
   log_entry "env::environment::_get" "$@"

   local filename="$1"
   local key="$2"

   if [ ! -f "${filename}" ]
   then
      log_fluff "\"${filename}\" does not exist"
      return 1
   fi

   log_fluff "Reading \"${filename}\""

   env::assert_valid_environment_key "${key}"

   local sedcmd

   r_escaped_sed_pattern "${key}"
   sedcmd="s/^ *export *${RVAL} *= *\"\\(.*\\)\$/\\1/p"

   if [ "${MULLE_FLAG_LOG_SETTINGS}" = 'YES' ]
   then
      log_setting "filename : ${filename}"
      cat "${filename}" >&2
   fi

   value="`rexekutor sed -n -e "${sedcmd}" "${filename}" `"
   value="`rexekutor sed -e 's/\(.*\)\".*/\1/' <<< "${value}"`"

   if [ -z "${value}" ]
   then
      env::environment::_file_defines_key "${filename}" "${key}"
      return $?
   fi

   log_fluff "Found \"${key}\" with value \"${value}\" in \"${filename}\""

   case "${value}" in
      \"*\")
         value="${value%?}"
         printf "%s\n" "${value:1}"
      ;;

      *)
         printf "%s\n" "${value}"
      ;;
   esac
}


env::environment::_file_defines_key()
{
   log_entry "env::environment::_file_defines_key" "$@"

   local filename="$1"
   local key="$2"

   local rval

   r_escaped_grep_pattern "${key}"
   rexekutor grep -E -q -s "^ *export *${RVAL}=" "${filename}"
   rval=$?

   if [ $rval -eq 0 ]
   then
      log_debug "${key} exists in \"${filename#"${MULLE_USER_PWD}/"}\""
   else
      log_debug "${key} does not exist in \"${filename#"${MULLE_USER_PWD}/"}\""
   fi
   return $rval
}


env::environment::_eval_get()
{
   log_entry "env::environment::_eval_get" "$@"

   local filename="$1"; shift
   local key="$1"; shift

   [ -z "${MULLE_VIRTUAL_ROOT}" ] && _internal_fail "MULLE_VIRTUAL_ROOT not set up"
   [ -z "${MULLE_UNAME}" ]        && _internal_fail "MULLE_UNAME not set up"

   if [ ! -f "${filename}" ]
   then
      log_fluff "\"${filename}\" does not exist"
      return 1
   fi

   local value
   local cmd

   while [ $# -ne 0 ]
   do
      r_concat "${cmd}" ". '$1' ;"
      cmd="${RVAL}"
      shift
   done

   r_concat "${cmd}" ". '${filename}' ;"
   r_concat "${RVAL}" "echo \${${key}}"
   cmd="${RVAL}"

   log_debug "cmd: $cmd"

   local environment

   env::r_environment_string
   environment="${RVAL}"

   value="`eval_rexekutor env -i "${environment}" '${BASH}' -c "'${cmd}'" `"
   if [ ! -z "${value}" ]
   then
      printf "%s\n" "$value"
      return 0
   fi

   env::environment::_file_defines_key "${filename}" "${key}"
   return $?
}


env::environment::_sed_get()
{
   log_entry "env::environment::_sed_get" "$@"

   local value

   if ! value="`env::environment::_eval_get "$@"`"
   then
      return 1
   fi

   local escaped_key
   local escaped_value

   r_escaped_sed_pattern "${OPTION_SED_KEY_PREFIX}${key}${OPTION_SED_KEY_SUFFIX}"
   escaped_key="${RVAL}"
   r_escaped_sed_replacement "${value}"
   escaped_value="${RVAL}"

   # escape quotes for "eval line"
   escaped_key="${escaped_key//\'/\'\\\'\'}"
   escaped_value="${escaped_value//\'/\'\\\'\'}"

   printf "%s\n" "-e 's/${escaped_key}/${escaped_value}/g'"
}


#
# TODO: make sure the quoting and unquoting of values read and put into
#       the environment files is a the proper level. Not sure if
#       r_unescaped_doublequotes is correct here, or should be lower/higher
#
env::environment::get_main()
{
   log_entry "env::environment::get_main" "$@"

   local scopename="$1"; shift

   local infix="_"
   local getter
   local reverse="--reverse"
   local OPTION_NOT_FOUND_RC

   getter="env::environment::_get"

   while [ $# -ne 0 ]
   do
      case "$1" in
         -h|--help|help)
            env::environment::get_usage
         ;;

         --lenient)
            OPTION_NOT_FOUND_RC="0"
         ;;

         --notfound-rc)
            [ $# -eq 1 ] && env::environment::get_usage "missing argument to $1"
            shift

            OPTION_NOT_FOUND_RC="$1"
         ;;

         --output-eval)
            getter="env::environment::_eval_get"
            reverse=""
         ;;

         --output-sed)
            getter="env::environment::_sed_get"
            reverse=""
         ;;

         --sed-key-prefix)
            [ $# -eq 1 ] && env::environment::get_usage "missing argument to $1"
            shift

            OPTION_SED_KEY_PREFIX="$1"
         ;;

         --sed-key-suffix)
            [ $# -eq 1 ] && env::environment::get_usage "missing argument to $1"
            shift

            OPTION_SED_KEY_SUFFIX="$1"
         ;;

         -*)
            env::environment::get_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   [ "$#" -ne 1 ]  && env::environment::get_usage "wrong number of arguments \"$*\""

   local key="$1"

   [ -z "${key}" ] && fail "empty key for get"

   # shellcheck source=src/mulle-env-scope.sh
   [ -z "${MULLE_ENV_SCOPE_SH}" ] && . "${MULLE_ENV_LIBEXEC_DIR}/mulle-env-scope.sh"

   local filename
   local filenames

   case "${scopename}" in
      include)
         ${getter} "${MULLE_ENV_SHARE_DIR}/include-environment.sh" "${key}"
         return $?
      ;;
   esac

   env::scope::r_get_existing_scope_files ${reverse} "${scopename}"
   filenames="${RVAL}"

   local rval
   local value
   local prevfiles

   rval="${OPTION_NOT_FOUND_RC:-4}"

   .foreachline filename in ${filenames}
   .do
      if value="`eval ${getter} "'${filename}'" "'${key}'" "${prevfiles}"`"
      then
         rval=0
         if [ ! -z "${reverse}" ]
         then
            r_unescaped_doublequotes "${value}"
            printf "%s\n" "${RVAL}"
            return 0
         fi
      fi

      r_concat "${prevfiles}" "'${filename}'"
      prevfiles="${RVAL}"
   .done

   if [ "${rval}" -eq 0 ]
   then
      r_unescaped_doublequotes "${value}"
      printf "%s\n" "${RVAL}"
   fi

   return $rval
}


env::environment::remove_environmentfile_if_empty()
{
   log_entry "env::environment::remove_environmentfile_if_empty" "$@"

   local filename="$1"

   local contents

   contents="`grep -E -v '^#' "${filename}" | sed '/^[ ]*$/d'`"
   if [ -z "${contents}" ]
   then
      env::environment::safe_remove_file_if_present "${filename}"
   fi
}


env::environment::_remove()
{
   log_entry "env::environment::_remove" "$@"

   local filename="$1"
   local key="$2"

   local sed_escaped_key

   r_escaped_sed_pattern "${key}"
   sed_escaped_key="${RVAL}"

   if [ "${MULLE_FLAG_LOG_SETTINGS}" = 'YES' ]
   then
      log_setting "filename : ${filename}"
      cat "${filename}" >&2
   fi

   #
   # TODO: need to remove three comments above the line
   #       probably easier to do with a cleanup path that removes
   #       three comments above an empty line, that's why we don't
   #       delete here
   env::environment::safe_modify_file "${filename}" \
      inplace_sed -e "s/^\\( *export *${sed_escaped_key}=.*\\)//" "${filename}"

   if [ "${OPTION_REMOVE_FILE}" != 'NO' ]
   then
      env::environment::remove_environmentfile_if_empty "${filename}"
   fi
}


env::environment::clobber_main()
{
   log_entry "env::environment::clobber_main" "$@"

   local scopename="$1"; shift

   while [ $# -ne 0 ]
   do
      case "$1" in
         -*)
            fail "clobber is an internal command, help is unavailable"
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   [ $# -ne 0 ] && fail "Superfluous arguments \"$*\""

   # shellcheck source=src/mulle-env-scope.sh
   [ -z "${MULLE_ENV_SCOPE_SH}" ] && . "${MULLE_ENV_LIBEXEC_DIR}/mulle-env-scope.sh"

   local filename
   local filenames

   if [ "${scopename}" = 'DEFAULT' ]
   then
      fail "won't clobber default scope"
   fi

   env::scope::r_get_existing_scope_files "${scopename}"
   filenames="${RVAL}"

   .foreachline filename in ${filenames}
   .do
      env::environment::safe_remove_file_if_present "${filename}"
   .done
}


env::environment::remove_main()
{
   log_entry "env::environment::remove_main" "$@"

   local scopename="$1"; shift

   local OPTION_REMOVE_FILE='DEFAULT'

   while [ $# -ne 0 ]
   do
      case "$1" in
         -h|--help|help)
            env::environment::remove_usage
         ;;

         --no-remove-file)
            OPTION_REMOVE_FILE='NO'
         ;;

         -*)
            env::environment::remove_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   [ "$#" -ne 1 ]  && env::environment::remove_usage "wrong number of arguments \"$*\""

   # shellcheck source=src/mulle-env-scope.sh
   [ -z "${MULLE_ENV_SCOPE_SH}" ] && . "${MULLE_ENV_LIBEXEC_DIR}/mulle-env-scope.sh"

   local key="$1"

   [ -z "${key}" ] && fail "empty key for remove"

   local filename
   local filenames

   if [ "${scopename}" = 'DEFAULT' ]
   then
      env::scope::r_get_existing_scope_files "--with-inferiors" "global"
   else
      env::scope::r_get_existing_scope_files "${scopename}"
   fi

   r_reverse_lines "${RVAL}"
   filenames="${RVAL}"

   local rval

   rval=1
   .foreachline filename in ${filenames}
   .do
      if env::environment::_file_defines_key "${filename}" "${key}"
      then
         if env::environment::_remove "${filename}" "${key}"
         then
            rval=0
            .break
         fi
      fi
   .done

   return $rval
}



#
# List
#

# diz not pretty, close eyes
# https://stackoverflow.com/questions/1250079/how-to-escape-single-quotes-within-single-quoted-strings

env::environment::merge_awk_filter()
{
   local awkcode

   awkcode='{ left=substr( $0, 1, index( $0, "=") - 1); \
right=substr( $0, index( $0, "=") + 1); \
value[ left] = right; \
keys[ keylen++] = left }; \
END{ for( i in keys) \
print keys[ i] "=\"" substr(value[ keys[ i]], 2, length(value[ keys[ i]]) - 2) "\"" }'
   rexekutor awk "${awkcode}"
}


env::environment::merge_environment_text()
{
   log_entry "env::environment::merge_environment_text" "$@"

   rexekutor sed -n 's/^ *export *\(.*= *\".*\"\).*/\1/p' <<< "${1}" | \
   env::environment::merge_awk_filter | \
   LC_ALL=C rexekutor ${MULLE_ENV_CONTENT_SORT}
}


env::environment::merge_environment_file()
{
   log_entry "env::environment::merge_environment_file" "$@"

   rexekutor sed -n 's/^ *export *\(.*= *\".*\"\).*/\1/p' "${1}" | \
   env::environment::merge_awk_filter | \
   LC_ALL=C rexekutor ${MULLE_ENV_CONTENT_SORT}
}


env::environment::_combined_list()
{
   log_entry "env::environment::_combined_list" "$@"

   local text_lister="$1"; shift

   local text
   local contents

   while [ "$#" -ne 0 ]
   do
      if [ -f "$1" ]
      then
         contents="`cat "$1"`"
         if [ ! -z "${contents}" ]
         then
         	r_add_line "${text}" "${contents}"
            text="${RVAL}"
         fi
      else
         log_fluff "\"$1\" does not exist"
      fi
      shift
   done

   "${text_lister}" "${text}"
}


env::environment::_combined_list_main()
{
   log_entry "env::environment::_combined_list_main" "$@"

   local text_lister="$1" ; shift

   [ "$#" -ne 0 ] && env::environment::list_usage "wrong number of arguments \"$*\""

   local cmdline

   cmdline="env::environment::_combined_list '${text_lister}'"

   local filename
   local filenames

   env::scope::r_get_existing_scope_files 'DEFAULT'
   filenames="${RVAL}"

   .foreachline filename in ${filenames}
   .do
      r_concat "${cmdline}" "'${filename}'"
      cmdline="${RVAL}"
   .done

   eval "${cmdline}"
}


env::environment::_list()
{
   log_entry "env::environment::_list" "$@"

   local scopeprefix="$1"; shift

   local s

   while [ "$#" -ne 0 ]
   do
      if [ -f "$1" ]
      then
         log_verbose "$1"

      	r_basename "$1"
         s="${RVAL}"
         s="${s%.sh}"
         s="${s#environment-}"

         case "${scopeprefix}" in
            'e')
               log_info "${C_MAGENTA}${C_BOLD}${s}"
               printf "${C_RESET}"
            ;;

            *)
               log_info "${C_RESET_BOLD}${s}"
               printf "${C_FAINT}"
            ;;
         esac

         env::environment::merge_environment_file "$1"
      else
         log_fluff "\"$1\" does not exist"
      fi
      shift
   done

   printf "${C_RESET}"
}


env::environment::_eval_list()
{
   log_entry "env::environment::_eval_list" "$@"

   shift

   local cmdline

   [ -z "${MULLE_VIRTUAL_ROOT}" ] && _internal_fail "MULLE_VIRTUAL_ROOT not set up"
   [ -z "${MULLE_UNAME}" ]        && _internal_fail "MULLE_UNAME not set up"
   [ -z "${MULLE_USERNAME}" ]     && _internal_fail "MULLE_USERNAME not set up"

   local environment

   env::r_environment_string
   environment="${RVAL}"

   cmdline="env -i ${environment} \"${BASH}\" -c '"

   [ "$#" -eq 0 ] && _internal_fail "No environment files specified"

   local files

   while [ "$#" -ne 0 ]
   do
      if [ -f "$1" ]
      then
         log_verbose "${C_RESET_BOLD}`basename -- "$1"`:"

         r_concat "${files}" ". \"$1\" ; "
         files="${RVAL}"
      else
         log_fluff "\"$1\" does not exist"
      fi
      shift
   done

   if [ -z "${files}" ]
   then
      log_warning "No environment files exist yet"
      return 0
   fi

   r_concat "${cmdline}" "${files}"
   cmdline="${RVAL}"
   r_concat "${cmdline}" "env | LC_ALL=C ${MULLE_ENV_CONTENT_SORT} '"
   cmdline="${RVAL}"

   #
   # remove a couple of builtins clumsily.
   # Properly: do `env -i bash -c env` and then remove
   # those lines
   #
   eval_rexekutor "${cmdline}" | rexekutor sed -e '/^PWD=/d' \
                                               -e '/^_=/d' \
                                               -e '/^SHLVL=/d' \
                                               -e '/^MULLE_UNAME=/d' \
                                               -e '/^MULLE_HOSTNAME=/d' \
                                               -e '/^MULLE_USERNAME=/d' \
                                               -e '/^MULLE_VIRTUAL_ROOT=/d'
}

env::environment::_sed_list()
{
   log_entry "env::environment::_sed_list" "$@"

   env::environment::_eval_list "$@" | env::environment::key_values_to_sed
}


env::environment::_command_list()
{
   log_entry "env::environment::_command_list" "$@"

   env::environment::_eval_list "$@" | env::environment::key_values_to_command
}



env::environment::list_main()
{
   log_entry "env::environment::list_main" "$@"

   local scopename="$1"; shift

   local lister

   lister="env::environment::_list"

   while [ $# -ne 0 ]
   do
      case "$1" in
         -h|--help|help)
            env::environment::list_usage
         ;;

         --output-eval)
            lister="env::environment::_eval_list"
            if [ "${scopename}" = 'DEFAULT' ]
            then
               scopename="include"
            fi
         ;;

         --output-sed)
            lister="env::environment::_sed_list"
            if [ "${scopename}" = 'DEFAULT' ]
            then
               scopename="include"
            fi
         ;;

         --output-command)
            lister="env::environment::_command_list"
            if [ "${scopename}" = 'DEFAULT' ]
            then
               scopename="include"
            fi
         ;;

         --sed-key-prefix)
            [ $# -eq 1 ] && fail "missing argument to $1"
            shift

            OPTION_SED_KEY_PREFIX="$1"
         ;;

         --sed-key-suffix)
            [ $# -eq 1 ] && fail "missing argument to $1"
            shift

            OPTION_SED_KEY_SUFFIX="$1"
         ;;

         -*)
            env::environment::list_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   [ "$#" -ne 0 ] && env::environment::list_usage "wrong number of arguments \"$*\""

   # shellcheck source=src/mulle-env-scope.sh
   [ -z "${MULLE_ENV_SCOPE_SH}" ] && . "${MULLE_ENV_LIBEXEC_DIR}/mulle-env-scope.sh"

   log_info "Environment"

   BASH="`command -v "bash"`"
   BASH="${BASH:-/usr/bin/bash}"  # panic fallback

   log_debug "scope: \"${scopename}\""

   case "${scopename}" in
      "merged")
         env::environment::_combined_list_main "env::environment::merge_environment_text" "$@"
      ;;

      "include")
         "${lister}" "" "${MULLE_ENV_SHARE_DIR}/include-environment.sh"
      ;;

      *)
         env::scope::r_get_scopes 'YES' 'YES' 'YES' 'YES' 'YES'
         scopes="${RVAL}"

         local i
         local i_name

         .foreachline i in ${scopes}
         .do
            i_name="${i:2}"
            if [ "${scopename}" != 'DEFAULT' -a "${i_name}" != "${scopename}" ]
            then
               .continue
            fi

            case "${i}" in
               [es]':'*)
                  env::scope::r_filename_for_scopeprefix_scopeid "${i:0:1}" "${i_name}"
                  "${lister}" "${i:0:1}" "${RVAL}"
               ;;

               'h:'*)
                  log_info "${C_RESET_BOLD}${i:2}"
                  printf "${C_FAINT}"
                  printf "MULLE_HOSTNAME=\"${MULLE_HOSTNAME}\"\n"
                  printf "MULLE_USERNAME=\"${MULLE_USERNAME}\"\n"
                  printf "MULLE_UNAME=\"${MULLE_UNAME}\"\n"
                  printf "MULLE_VIRTUAL_ROOT=\"${MULLE_VIRTUAL_ROOT}\"\n"
                  printf "MULLE_VIRTUAL_ROOT_ID=\"${MULLE_VIRTUAL_ROOT_ID}\"\n"
               ;;

               *)
                  internal_fail "unknown scope"
               ;;
            esac
         .done
      ;;

   esac
}


env::environment::assert_default_scope()
{
   [ "${OPTION_SCOPE}" = 'DEFAULT' ] || \
      fail "scope has already been specified as \"${OPTION_SCOPE}\""
}


###
### parameters and environment variables
###
env::environment::main()
{
   log_entry "env::environment::main" "$@"

   local OPTION_SCOPE='DEFAULT'
   # local OPTION_SCOPE_SUBDIRS (already set in "main")
   local infix="_"
   local OPTION_SED_KEY_PREFIX
   local OPTION_SED_KEY_SUFFIX
   local OPTION_PROTECT='YES'
   local OPTION_AUX_LIST_ARGS

   MULLE_ENV_CONTENT_SORT='sort'

   include "env::scope"

   local cmd
   #
   # handle options
   #
   while [ $# -ne 0 ]
   do
      case "$1" in
         -h|--help|help)
            env::environment::usage
         ;;

         --host)
            [ $# -eq 1 ] && fail "missing argument to $1"
            shift

            env::environment::assert_default_scope
            OPTION_SCOPE="host-$1"
         ;;

         --os)
            [ $# -eq 1 ] && fail "missing argument to $1"
            shift

            env::environment::assert_default_scope
            OPTION_SCOPE="os-$1"
         ;;

         --user)
            [ $# -eq 1 ] && fail "missing argument to $1"
            shift

            env::environment::assert_default_scope
            OPTION_SCOPE="user-$1"
         ;;

         --host-this|--this-host)
            env::environment::assert_default_scope

            OPTION_SCOPE="host-${MULLE_HOSTNAME}"
         ;;

         --user-this|--this-user|--me|--myself)
            env::environment::assert_default_scope

            [ -z "${MULLE_USERNAME}" ] && fail "MULLE_USERNAME environment variable not set"

            OPTION_SCOPE="user-${MULLE_USERNAME}"
         ;;

         --this-user-os|--this-os-user)
            env::environment::assert_default_scope

            [ -z "${MULLE_USERNAME}" ] && fail "MULLE_USERNAME environment variable not set"

            OPTION_SCOPE="user-${MULLE_USERNAME}-os-${MULLE_UNAME}"
         ;;

         --os-this|--this-os)
            env::environment::assert_default_scope

            OPTION_SCOPE="os-${MULLE_UNAME}"
         ;;

         --protect-flag)
            [ $# -eq 1 ] && fail "missing argument to $1"
            shift

            OPTION_PROTECT="$1"
         ;;

         --scope-subdir)
            [ $# -eq 1 ] && fail "missing argument to $1"
            shift

            r_add_line "${OPTION_SCOPE_SUBDIRS}" "$1"
            OPTION_SCOPE_SUBDIRS="${RVAL}"
         ;;

         --scope)
            [ $# -eq 1 ] && fail "missing argument to $1"
            shift

            env::environment::assert_default_scope
            OPTION_SCOPE="$1"
         ;;

         --cat)
            MULLE_ENV_CONTENT_SORT='cat'
         ;;

         --sort)
            MULLE_ENV_CONTENT_SORT='sort'
         ;;

         --[a-z]*)
            env::environment::assert_default_scope

            if env::scope::is_known_scopeid "${1:2}"
            then
               OPTION_SCOPE="${1:2}"
            else
               r_concat "${OPTION_AUX_LIST_ARGS}" "$1"
               OPTION_AUX_LIST_ARGS="${RVAL}"
            fi
         ;;

         -*)
            cmd="list"

            r_concat "${OPTION_AUX_LIST_ARGS}" "$1"
            OPTION_AUX_LIST_ARGS="${RVAL}"
            shift
            break
         ;;

         *)
            break
         ;;
      esac

      shift
   done


   if [ -z "${cmd}" ]
   then
      cmd="${1:-list}"
      [ $# -ne 0 ] && shift
   fi

   # unset is used for definitions so support it
   if [ "${cmd}" = 'unset' ]
   then
      cmd='remove'
   fi

   if [ "${cmd}" != 'list' -a ! -z "${OPTION_AUX_LIST_ARGS}" ]
   then
      fail "Unknown flags \"${OPTION_AUX_LIST_ARGS}\""
   fi

   case "${cmd}" in
      'clobber'|'mset'|'remove'|'set'|'rm')
         [ -z "${OPTION_SCOPE}" ] && env::environment::usage "Empty scope is invalid"

         cmd="${cmd//rm/remove}"
         cmd="${cmd//mv/move}"
         if [ "${MULLE_FLAG_MAGNUM_FORCE}" != 'YES' -a "${OPTION_PROTECT}" = 'YES' ]
         then
            env::scope::env_validate_scope_write "${OPTION_SCOPE}" "$@"
         fi
         env::environment::${cmd}_main "${OPTION_SCOPE}" "$@"
      ;;

      'editor')
         exekutor npx mulle-sde/mulle-environment-editor "$@"
      ;;

      'list')
         [ -z "${OPTION_SCOPE}" ] && env::environment::usage "Empty scope is invalid"

         if [ "${OPTION_SCOPE}" != 'DEFAULT' ]
         then
            env::scope::is_known_scopeid "${OPTION_SCOPE}" || fail "Scope \"${OPTION_SCOPE}\" is unknown"
         fi
         env::environment::list_main "${OPTION_SCOPE}" ${OPTION_AUX_LIST_ARGS} "$@"
      ;;

      'get')
         [ -z "${OPTION_SCOPE}" ] && env::environment::usage "Empty scope is invalid"

         if [ "${OPTION_SCOPE}" != 'DEFAULT' ]
         then
            env::scope::is_known_scopeid "${OPTION_SCOPE}" || fail "Scope \"${OPTION_SCOPE}\" is unknown"
         fi
         env::environment::get_main "${OPTION_SCOPE}" "$@"
      ;;

      # experimental doesnt really work because remove does too much
      'rename')
         [ -z "${OPTION_SCOPE}" ] && env::environment::usage "Empty scope is invalid"

         if [ "${OPTION_SCOPE}" != 'DEFAULT' ]
         then
            env::scope::is_known_scopeid "${OPTION_SCOPE}" || fail "Scope \"${OPTION_SCOPE}\" is unknown"
         fi

         local value 

         if ! value=$(env::environment::get_main "${OPTION_SCOPE}" "$1")
         then
            fail "Key \"$1\" not found"
         fi
         if ! env::environment::remove_main "${OPTION_SCOPE}" "$1" 
         then
            fail "Could not remove key \"$1\" not found"
         fi
         env::environment::set_main "${OPTION_SCOPE}" "$2" "${value}"
      ;;

      'scope'|'scopes')
         MULLE_USAGE_NAME="${MULLE_USAGE_NAME} environment" env::scope::main "$@"
      ;;

      *)
         env::environment::usage "unknown command \"${cmd}\""
      ;;
   esac
}

