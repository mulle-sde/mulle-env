#! /usr/bin/env bash
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
MULLE_ENV_ENVIRONMENT_SH="included"


env_environment_usage()
{
   [ $# -ne 0 ] && log_error "$1"

SHOWN_COMMANDS="\
   list              : list environment variables
   set               : set an environment variable
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

   Specifying no scope invokes the "DEFAULT" scope, which has special semantics
   depending on the command used. See each commands usage info for specifics.

Example:
   Clear a user set environment variable:
      ${MULLE_USAGE_NAME} environment --user set MULLE_FETCH_SEARCH_PATH ""

Options:
   -h                : show this usage
   --global          : scope for general environments variables
   --host <name>     : narrow scope to host with name
   --host-this       : narrow scope to this host ($MULLE_HOSTNAME)
   --os <name>       : narrow scope to operating system ($MULLE_UNAME)
   --os-this         : narrow scope to this operating system
   --scope <name>    : use an arbitrarily named scope
   --user <name>     : narrow scope to user with name
   --user-this       : user with name ($MULLE_USERNAME)

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


env_environment_get_usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} environment get [options] <key>

   Get the value of an environment variable. You can check the return value
   to determine if a key exists and is empty (0), or absence of the key (1).

   The "DEFAULT" scope will check the user and host scopes first before
   looking into the global scope and then the other scopes.

   To get at the fully evaluated value, do not use this command but rather
   the unix `env` command:

      mulle-env -c env | sed -n 's/^MULLE_FETCH_SEARCH_PATH=\(.*\)/\1/p'

Options:
   --output-eval : resolve value with other environment variables. This will
                   not evaluate values from other scopes though
EOF
   exit 1
}


env_environment_set_usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} environment set [options] <key> [value] [comment]

   Set the value of an environment variable. By default it will save into
   the user scope. Set the desired scope with 'environment' options.

   Use the alias \`mulle-env-reload\` to update your interactive shell
   after edits.

   When you use the "DEFAULT" scopes, the variable is set in the global scope
   and all values of the same key are deleted from user and host scopes.

Example:
   ${MULLE_USAGE_NAME} environment --global set FOO "A value"

Options:
   --append           : add value to existing values (using separator :)
   --prepend          : prepent value to existing values (using separator :)
   --separator <sep>  : sepecify custom separator for --append
EOF
   exit 1
}


env_environment_remove_usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} environment remove <key>

   Remove an environment variable. By default it will remove the variable
   from all user scopes. Set the desired scope with 'environment' options.

   Use the alias \`mulle-env-reload\` to update your interactive shell
   after edits.

   When you use the "DEFAULT" scopes, the variable is deleted from the global
   scope and all user and host scopes.

Example:
      ${MULLE_USAGE_NAME} environment remove FOO
EOF
   exit 1
}


env_environment_list_usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} environment list [options]

   List environment variables. If you specified no scope, you will get
   a combined listing of all scopes. Specify the scope using the
   environment options. See \`${MULLE_USAGE_NAME} environment scope help\` for
   more information about scopes and the files used by them.

Example:
      mulle-env environment --scope merged list

Options:
   --output-eval    : resolve values
   --output-command : emit as mulle-env commands
EOF
   exit 1
}


env_environment_scope_usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} environment scope [options]

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

Options:
   --all              : show also plugin, project and extension scopes
   --output-filename  : emit filename of the scope file

EOF
   exit 1
}


key_values_to_command()
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


key_values_to_sed()
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
   IFS="${DEFAULT_IFS}"
}


env_execute_with_unprotected_files_in_dir()
{
   log_entry "env_execute_with_unprotected_files_in_dir" "$@"

   local directory="$1"; shift

   [ -z "${directory}" ] && internal_fail "directory is empty"

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


r_mkdir_if_missing_or_unprotect()
{
   log_entry "r_mkdir_if_missing_or_unprotect" "$@"

   local directory="$1"

   [ -z "${directory}" ] && internal_fail "directory is empty"
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

      r_mkdir_if_missing_or_unprotect "${parentdir}"

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


env_safe_create_file()
{
   log_entry "env_safe_create_file" "$@"

   local filename="$1"; shift

   [ -z "${filename}" ] && internal_fail "filename is empty"

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

   r_mkdir_if_missing_or_unprotect "${directory}"
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

   IFS=$'\n'
   shell_disable_glob
   for directory in ${protectdirs}
   do
      if ! exekutor chmod a-w "${directory}"
      then
         rval=1
      fi
   done

   IFS="${DEFAULT_IFS}"
   shell_enable_glob

   return ${rval}
}


env_safe_write_file()
{
   log_entry "env_safe_write_file" "$@"

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
      [ -e "${filename}" ] || internal_fail "File must exist for write"

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


env_safe_create_or_write_file()
{
   log_entry "env_safe_create_or_write_file" "$@"

   local filename="$1"

   if [ ! -f "${filename}" ]
   then
      env_safe_create_file "$@"
   else
      env_safe_write_file "$@"
   fi
}


#
# as write file but also unprotect directory
#
env_safe_modify_file()
{
   log_entry "env_safe_modify_file" "$@"

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
      [ -e "${filename}" ] || internal_fail "File must exist for write"

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


env_safe_remove_file_if_present()
{
   log_entry "env_safe_modify_file" "$@"

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
_env_environment_set()
{
   log_entry "_env_environment_set" "$@"

   local filename="$1"
   local key="$2"
   local value="$3"
   local comment="$4"

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

      \"*\")
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
         log_info "Use ${C_RESET_BOLD}mulle-env-reload${C_INFO} to update your \
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

      if ! _env_file_defines_key "${filename}" "${key}"
      then
         log_fluff "${key} does not exist in ${filename}"
         return 4
      fi

      # inplace sed creates a temporary file, so we need create to unprotect
      # the parent
      env_safe_modify_file "${filename}" \
         inplace_sed -e "s/^\\( *export *${sed_escaped_key}=.*\\)/\
# \\1/" "${filename}"
      return $?
   fi

   #
   # first try inplace-replacement
   #
   if [ -f "${filename}" ]
   then
      if _env_file_defines_key "${filename}" "${key}"
      then
         # inplace sed creates a temporary file, so we need create to unprotect
         # the parent
         env_safe_modify_file "${filename}" \
            inplace_sed -e "s/^[ #]*export *${sed_escaped_key}=.*/\
export ${sed_escaped_key}=${sed_escaped_value}/" "${filename}"
         return $?
      fi
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

   if [ -z "${value}" -a "${OPTION_ADD_EMPTY}" = 'NO' ]
   then
      return 0
   fi

   local text

   text="\
${comment}
export ${key}=${value}

"
   # unprotect if needed
   env_safe_create_or_write_file "${filename}" \
      redirect_append_exekutor "${filename}" printf "%s\n" "${text}"
   # protect if unprotected
}


#
# global (specified implicitly as DEFAULT) is special because it cleans
# everything below it, even scopes not applicable to the current os/machine/usr
#
env_environment_remove_from_global_subscopes()
{
   log_entry "env_environment_remove_from_global_subscopes" "$@"

   local key="$1"

   local i

   shell_enable_nullglob
   for i in ${MULLE_ENV_ETC_DIR}/environment-os-*.sh \
            ${MULLE_ENV_ETC_DIR}/environment-host-*.sh \
            ${MULLE_ENV_ETC_DIR}/environment-user-*.sh
   do
      shell_disable_nullglob
      _env_environment_remove "$i" "${key}"
   done
   shell_disable_nullglob
}


# todo: set is still too hacky
#       and doesn't respect r_get_scopes information

env_environment_set_main()
{
   log_entry "env_environment_set_main" "$@"

   local scopename="$1"; shift

   local OPTION_COMMENT_OUT_EMPTY='NO'
   local OPTION_ADD_EMPTY='YES'
   local OPTION_ADD='NO'
   local OPTION_SEPARATOR=":"  # convenient for PATH like behaviour

   # shellcheck source=src/mulle-env-scope.sh
   [ -z "${MULLE_ENV_SCOPE_SH}" ] && . "${MULLE_ENV_LIBEXEC_DIR}/mulle-env-scope.sh"

   while :
   do
      case "$1" in
         -h|--help|help)
            env_environment_set_usage
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

         -p|--prepend)
            OPTION_ADD='PREPEND'
         ;;

         -s|--separator|--seperator)
            [ "$#" -eq 1 ] && env_environment_set_usage "Missing argument to \"$1\""
            shift

            OPTION_SEPARATOR="$1"
         ;;

         -*)
            env_environment_set_usage "Unknown option \"$1\""
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

         [ $# -lt 1 -o $# -gt 2 ] && env_environment_set_usage
      ;;

      *)
         [ $# -lt 2 -o $# -gt 3 ] && env_environment_set_usage
      ;;
   esac


   [ -z "${key}" ] && env_environment_set_usage "empty key for set"

   assert_valid_environment_key "${key}"

   if [ "${OPTION_ADD}" != 'NO' ]
   then
      local prev
      local oldvalue

      prev="`env_environment_get_main "${scopename}" "${key}"`"
      log_debug "Previous value is \"${prev}\""

      case "${value}" in
         *${OPTION_SEPARATOR}*)
            fail "${value} contains '${OPTION_SEPARATOR}', which is not possible for addition \
as this is used to concatenate values.
${C_INFO}Tip: use multiple addition statements."
         ;;
      esac

      shell_disable_glob; IFS="${OPTION_SEPARATOR}"

      for oldvalue in ${prev}
      do
         shell_enable_glob; IFS="${DEFAULT_IFS}"
         if [ "${oldvalue}" = "${value}" ]
         then
            log_fluff "\"${value}\" already set"
            return 0
         fi
      done

      shell_enable_glob; IFS="${DEFAULT_IFS}"

      if [ "${OPTION_ADD}" = 'APPEND' ]
      then
         r_concat "${prev}" "${value}" "${OPTION_SEPARATOR}"
         value="${RVAL}"
      else
         r_concat "${value}" "${prev}" "${OPTION_SEPARATOR}"
         value="${RVAL}"
      fi
   fi

   local filename

   #   log_verbose "Use \`mulle-env-reload\` to get the actual value in your shell"

   log_debug "Environment scope \"${scopename}\" set $key=\"${value}\""

   if [ "${scopename}" = 'DEFAULT' ]
   then
      filename="${MULLE_ENV_ETC_DIR}/environment-global.sh"
      _env_environment_set "${filename}" "${key}" "${value}" "${comment}" &&
      env_environment_remove_from_global_subscopes "${key}"
      return $?
   fi

   local scopeprefix
   local rval

   if ! r_filename_for_scopeid "${scopename}"
   then
      if scope_is_keyword "${scopename}"
      then
         fail "You can't set values in scope \"${scopename}\""
      fi
      fail "Unknown scope \"${scopename}\""
   fi
   filename="${RVAL}"

   _env_environment_set "${filename}" "${key}" "${value}" "${comment}"
   rval=$?

   if [ "${MULLE_FLAG_LOG_SETTINGS}" = 'YES' ]
   then
      log_trace2 "filename : ${filename}"
      cat "${filename}" >&2
   fi

   [ $rval -eq 1 ] && exit 1

   return $rval
}



#
# interface for mulle-sde
#
env_environment_mset_main()
{
   log_entry "env_environment_mset_main" "$@"

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

      env_environment_set_main "${scopename}" ${option} "${key}" "${value}" "${comment}"

      shift
   done
}


#
# Get
#
_env_environment_get()
{
   log_entry "_env_environment_get" "$@"

   local filename="$1"
   local key="$2"

   if [ ! -f "${filename}" ]
   then
      log_fluff "\"${filename}\" does not exist"
      return 1
   fi

   log_fluff "Reading \"${filename}\""

   assert_valid_environment_key "${key}"

   local sedcmd

   r_escaped_sed_pattern "${key}"
   sedcmd="s/^ *export *${RVAL} *= *\"\\(.*\\)\$/\\1/p"

   if [ "${MULLE_FLAG_LOG_SETTINGS}" = 'YES' ]
   then
      log_trace2 "filename : ${filename}"
      cat "${filename}" >&2
   fi

   value="`rexekutor sed -n -e "${sedcmd}" "${filename}" `"
   value="`rexekutor sed -e 's/\(.*\)\".*/\1/' <<< "${value}"`"

   if [ -z "${value}" ]
   then
      _env_file_defines_key "${filename}" "${key}"
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


_env_file_defines_key()
{
   log_entry "_env_file_defines_key" "$@"

   local filename="$1"
   local key="$2"

   local rval

   r_escaped_grep_pattern "${key}"
   rexekutor egrep -q -s "^ *export *${RVAL}=" "${filename}"
   rval=$?

   if [ $rval -eq 0 ]
   then
      log_debug "${key} exists in \"${filename#${MULLE_USER_PWD}/}\""
   else
      log_debug "${key} does not exist in \"${filename#${MULLE_USER_PWD}/}\""
   fi
   return $rval
}


_env_environment_eval_get()
{
   log_entry "_env_environment_eval_get" "$@"

   local filename="$1"; shift
   local key="$1"; shift

   [ -z "${MULLE_VIRTUAL_ROOT}" ] && internal_fail "MULLE_VIRTUAL_ROOT not set up"
   [ -z "${MULLE_UNAME}" ]        && internal_fail "MULLE_UNAME not set up"

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

   value="`eval_rexekutor env -i "MULLE_VIRTUAL_ROOT='${MULLE_VIRTUAL_ROOT}'" \
                                 "MULLE_UNAME='${MULLE_UNAME}'" \
                                 '${BASH}' -c "'${cmd}'" `"
   if [ ! -z "${value}" ]
   then
      printf "%s\n" "$value"
      return 0
   fi

   _env_file_defines_key "${filename}" "${key}"
   return $?
}


_env_environment_sed_get()
{
   log_entry "_env_environment_sed_get" "$@"

   local value

   if ! value="`_env_environment_eval_get "$@"`"
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
env_environment_get_main()
{
   log_entry "env_environment_get_main" "$@"

   local scopename="$1"; shift

   local infix="_"
   local getter
   local reverse="--reverse"

   getter="_env_environment_get"

   while :
   do
      case "$1" in
         -h|--help|help)
            env_environment_get_usage
         ;;

         --output-eval)
            getter="_env_environment_eval_get"
            reverse=""
         ;;

         --output-sed)
            getter="_env_environment_sed_get"
            reverse=""
         ;;

         --sed-key-prefix)
            [ $# -eq 1 ] && env_environment_get_usage "missing argument to $1"
            shift

            OPTION_SED_KEY_PREFIX="$1"
         ;;

         --sed-key-suffix)
            [ $# -eq 1 ] && env_environment_get_usage "missing argument to $1"
            shift

            OPTION_SED_KEY_SUFFIX="$1"
         ;;

         -*)
            env_environment_get_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   [ "$#" -ne 1 ]  && env_environment_get_usage "wrong number of arguments \"$*\""

   local key="$1"

   [ -z "${key}" ] && fail "empty key for get"

   # shellcheck source=src/mulle-env-scope.sh
   [ -z "${MULLE_ENV_SCOPE_SH}" ] && . "${MULLE_ENV_LIBEXEC_DIR}/mulle-env-scope.sh"

   local filename
   local filenames

   case "${scopename}" in
      include)
         ${getter} "${MULLE_ENV_SHARE_DIR}/include-environment.sh" "${key}"
         return
      ;;
   esac

   r_get_existing_scope_files ${reverse} "${scopename}"
   filenames="${RVAL}"

   local rval
   local value
   local prevfiles

   rval=1
   shell_disable_glob; IFS=$'\n'
   for filename in ${filenames}
   do
      shell_enable_glob; IFS="${DEFAULT_IFS}"
      if value="`eval ${getter} "'${filename}'" "'${key}'" "${prevfiles}"`"
      then
         rval=0
         if [ ! -z "${reverse}" ]
         then
            r_unescaped_doublequotes "${value}"
            printf "%s\n" "${RVAL}"
            return $rval
         fi
      fi

      r_concat "${prevfiles}" "'${filename}'"
      prevfiles="${RVAL}"
   done
   shell_enable_glob; IFS="${DEFAULT_IFS}"

   if [ "${rval}" -eq 0 ]
   then
      r_unescaped_doublequotes "${value}"
      printf "%s\n" "${RVAL}"
   fi

   return $rval
}


remove_environmentfile_if_empty()
{
   log_entry "remove_environmentfile_if_empty" "$@"

   local filename="$1"

   local contents

   contents="`egrep -v '^#' "${filename}" | sed '/^[ ]*$/d'`"
   if [ -z "${contents}" ]
   then
      env_safe_remove_file_if_present "${filename}"
   fi
}


_env_environment_remove()
{
   log_entry "_env_environment_remove" "$@"

   local filename="$1"
   local key="$2"

   local sed_escaped_key

   r_escaped_sed_pattern "${key}"
   sed_escaped_key="${RVAL}"

   if [ "${MULLE_FLAG_LOG_SETTINGS}" = 'YES' ]
   then
      log_trace2 "filename : ${filename}"
      cat "${filename}" >&2
   fi

   #
   # TODO: need to remove three comments above the line
   #       probably easier to do with a cleanup path that removes
   #       three comments above an empty line, that's why we don't
   #       delete here
   env_safe_modify_file "${filename}" \
      inplace_sed -e "s/^\\( *export *${sed_escaped_key}=.*\\)//" "${filename}"

   if [ "${OPTION_REMOVE_FILE}" != 'NO' ]
   then
      remove_environmentfile_if_empty "${filename}"
   fi
}


env_environment_remove_main()
{
   log_entry "env_environment_remove_main" "$@"

   local scopename="$1"; shift

   local OPTION_REMOVE_FILE='DEFAULT'

   while :
   do
      case "$1" in
         -h|--help|help)
            env_environment_remove_usage
         ;;

         --no-remove-file)
            OPTION_REMOVE_FILE='NO'
         ;;

         -*)
            env_environment_remove_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   [ "$#" -ne 1 ]  && env_environment_remove_usage "wrong number of arguments \"$*\""

   # shellcheck source=src/mulle-env-scope.sh
   [ -z "${MULLE_ENV_SCOPE_SH}" ] && . "${MULLE_ENV_LIBEXEC_DIR}/mulle-env-scope.sh"

   local key="$1"

   [ -z "${key}" ] && fail "empty key for remove"

   local filename
   local filenames
   if [ "${scopename}" = "DEFAULT" ]
   then
      r_get_existing_scope_files "--with-inferiors" "global"
   else
      r_get_existing_scope_files "${scopename}"
   fi

   r_reverse_lines "${RVAL}"
   filenames="${RVAL}"

   local rval

   rval=1
   shell_disable_glob; IFS=$'\n'
   for filename in ${filenames}
   do
      shell_enable_glob; IFS="${DEFAULT_IFS}"

      if _env_file_defines_key "${filename}" "${key}"
      then
         if _env_environment_remove "${filename}" "${key}"
         then
            rval=0
            break
         fi
      fi
  done
   shell_enable_glob; IFS="${DEFAULT_IFS}"

   return $rval
}


#
# List
#

# diz not pretty, close eyes
# https://stackoverflow.com/questions/1250079/how-to-escape-single-quotes-within-single-quoted-strings

merge_awk_filter()
{
   local awkcode

   awkcode='{ left=substr( $0, 1, index( $0, "=") - 1); \
right=substr( $0, index( $0, "=") + 1); \
value[ left] = right }; \
END{for(i in value) \
print i "=\"" substr(value[ i], 2, length(value[ i]) - 2) "\"" }'
   rexekutor awk "${awkcode}"
}


merge_environment_text()
{
   log_entry "merge_environment_text" "$@"

   rexekutor sed -n 's/^ *export *\(.*= *\".*\"\).*/\1/p' <<< "${1}" | \
   merge_awk_filter | \
   LC_ALL=C rexekutor sort
}


merge_environment_file()
{
   log_entry "merge_environment_file" "$@"

   rexekutor sed -n 's/^ *export *\(.*= *\".*\"\).*/\1/p' "${1}" | \
   merge_awk_filter | \
   LC_ALL=C rexekutor sort
}


_env_environment_combined_list()
{
   log_entry "_env_environment_combined_list" "$@"

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


_env_environment_combined_list_main()
{
   log_entry "_env_environment_combined_list_main" "$@"

   local text_lister="$1" ; shift

   [ "$#" -ne 0 ] && env_environment_list_usage "wrong number of arguments \"$*\""

   local cmdline

   cmdline="_env_environment_combined_list '${text_lister}'"

   local filename
   local filenames

   r_get_existing_scope_files "DEFAULT"
   filenames="${RVAL}"

   shell_disable_glob; IFS=$'\n'
   for filename in ${filenames}
   do
      shell_enable_glob; IFS="${DEFAULT_IFS}"

      r_concat "${cmdline}" "'${filename}'"
      cmdline="${RVAL}"
   done
   shell_enable_glob; IFS="${DEFAULT_IFS}"

   eval "${cmdline}"
}


_env_environment_list()
{
   log_entry "_env_environment_list" "$@"

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

         merge_environment_file "$1"
      else
         log_fluff "\"$1\" does not exist"
      fi
      shift
   done

   printf "${C_RESET}"
}


_env_environment_eval_list()
{
   log_entry "_env_environment_eval_list" "$@"

   shift

   local cmdline

   [ -z "${MULLE_VIRTUAL_ROOT}" ] && internal_fail "MULLE_VIRTUAL_ROOT not set up"
   [ -z "${MULLE_UNAME}" ] && internal_fail "MULLE_UNAME not set up"

   cmdline="env -i MULLE_VIRTUAL_ROOT=\"${MULLE_VIRTUAL_ROOT}\" \
MULLE_UNAME=\"${MULLE_UNAME}\" \
MULLE_HOSTNAME=\"${MULLE_HOSTNAME}\" \
MULLE_USERNAME\"${MULLE_USERNAME}\" \
\"${BASH}\" -c '"

   [ "$#" -eq 0 ] && internal_fail "No environment files specified"

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
   r_concat "${cmdline}" "env | LC_ALL=C sort '"
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

_env_environment_sed_list()
{
   log_entry "_env_environment_sed_list" "$@"

   _env_environment_eval_list "$@" | key_values_to_sed
}


_env_environment_command_list()
{
   log_entry "_env_environment_command_list" "$@"

   _env_environment_eval_list "$@" | key_values_to_command
}



env_environment_list_main()
{
   log_entry "env_environment_list_main" "$@"

   local scopename="$1"; shift

   local lister

   lister="_env_environment_list"

   while :
   do
      case "$1" in
         -h|--help|help)
            env_environment_list_usage
         ;;

         --output-eval)
            lister="_env_environment_eval_list"
            if [ "${scopename}" = "DEFAULT" ]
            then
               scopename="include"
            fi
         ;;

         --output-sed)
            lister="_env_environment_sed_list"
            if [ "${scopename}" = "DEFAULT" ]
            then
               scopename="include"
            fi
         ;;

         --output-command)
            lister="_env_environment_command_list"
            if [ "${scopename}" = "DEFAULT" ]
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
            env_environment_list_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   [ "$#" -ne 0 ] && env_environment_list_usage "wrong number of arguments \"$*\""

   # shellcheck source=src/mulle-env-scope.sh
   [ -z "${MULLE_ENV_SCOPE_SH}" ] && . "${MULLE_ENV_LIBEXEC_DIR}/mulle-env-scope.sh"

   log_info "Environment"

   BASH="`command -v "bash"`"
   BASH="${BASH:-/usr/bin/bash}"  # panic fallback

   log_debug "scope: \"${scopename}\""

   case "${scopename}" in
      "merged")
         _env_environment_combined_list_main "merge_environment_text" "$@"
      ;;

      "include")
         "${lister}" "" "${MULLE_ENV_SHARE_DIR}/include-environment.sh"
      ;;

      *)
         r_get_scopes "YES" "YES" "YES" "YES" "YES"
         scopes="${RVAL}"

         local i
         local i_name

         shell_disable_glob; IFS=$'\n'
         for i in ${scopes}
         do
            shell_enable_glob; IFS="${DEFAULT_IFS}"

            i_name="${i:2}"
            if [ "${scopename}" != "DEFAULT" -a "${i_name}" != "${scopename}" ]
            then
               continue
            fi

            case "${i}" in
               'e:'*)
                  "${lister}" "${i:0:1}" "${MULLE_ENV_ETC_DIR}/environment-${i_name}.sh"
               ;;

               's:'*)
                 "${lister}" "${i:0:1}" "${MULLE_ENV_SHARE_DIR}/environment-${i_name}.sh"
               ;;

               'h:'*)
                  log_info "${C_RESET_BOLD}${i:2}"
                  printf "${C_FAINT}"
                  echo "MULLE_HOSTNAME=\"${MULLE_HOSTNAME}\""
                  echo "MULLE_UNAME=\"${MULLE_UNAME}\""
                  echo "MULLE_VIRTUAL_ROOT=\"${MULLE_VIRTUAL_ROOT}\""
               ;;
            esac
         done
         shell_enable_glob; IFS="${DEFAULT_IFS}"
      ;;

   esac
}


assert_default_scope()
{
   [ "${OPTION_SCOPE}" = "DEFAULT" ] || \
      log_fail "scope has already been specified as \"${OPTION_SCOPE}\""
}


###
### parameters and environment variables
###
env_environment_main()
{
   log_entry "env_environment_main" "$@"

   local OPTION_SCOPE="DEFAULT"
   local infix="_"
   local OPTION_SED_KEY_PREFIX
   local OPTION_SED_KEY_SUFFIX
   local OPTION_PROTECT='YES'

   #
   # handle options
   #
   while :
   do
      case "$1" in
         -h|--help|help)
            env_environment_usage
         ;;

         --global)
            assert_default_scope

            OPTION_SCOPE="${1:2}"
         ;;

         --host)
            [ $# -eq 1 ] && fail "missing argument to $1"
            shift

            assert_default_scope
            OPTION_SCOPE="host-$1"
         ;;

         --os)
            [ $# -eq 1 ] && fail "missing argument to $1"
            shift

            assert_default_scope
            OPTION_SCOPE="os-$1"
         ;;

         --user)
            [ $# -eq 1 ] && fail "missing argument to $1"
            shift

            assert_default_scope
            OPTION_SCOPE="user-$1"
         ;;

         --host-this|--this-host)
            assert_default_scope

            OPTION_SCOPE="host-${MULLE_HOSTNAME}"
         ;;

         --user-this|--this-user|--me|--myself)
            assert_default_scope

            [ -z "${MULLE_USERNAME}" ] && fail "MULLE_USERNAME environment variable not set"

            OPTION_SCOPE="user-${MULLE_USERNAME}"
         ;;

         --os-this|--this-os)
            assert_default_scope

            OPTION_SCOPE="os-${MULLE_UNAME}"
         ;;

         --protect-flag)
            [ $# -eq 1 ] && fail "missing argument to $1"
            shift

            OPTION_PROTECT="$1"
         ;;

         --scope)
            [ $# -eq 1 ] && fail "missing argument to $1"
            shift

            assert_default_scope
            OPTION_SCOPE="$1"
         ;;

         -*)
            env_environment_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   local cmd="${1:-list}"
   [ $# -ne 0 ] && shift


   case "${cmd}" in
      mset|remove|set)
         [ -z "${OPTION_SCOPE}" ] && env_environment_usage "Empty scope is invalid"

         if [ "${MULLE_FLAG_MAGNUM_FORCE}" != 'YES' -a "${OPTION_PROTECT}" = 'YES' ]
         then
            # shellcheck source=src/mulle-env-scope.sh
            [ -z "${MULLE_ENV_SCOPE_SH}" ] && . "${MULLE_ENV_LIBEXEC_DIR}/mulle-env-scope.sh"

            env_validate_scope_write "${OPTION_SCOPE}" "$@"
         fi
         env_environment_${cmd}_main "${OPTION_SCOPE}" "$@"
      ;;

      get|list)
         [ -z "${OPTION_SCOPE}" ] && env_environment_usage "Empty scope is invalid"

         env_environment_${cmd}_main "${OPTION_SCOPE}" "$@"
      ;;

      scope|scopes)
         # shellcheck source=src/mulle-env-scope.sh
         [ -z "${MULLE_ENV_SCOPE_SH}" ] && . "${MULLE_ENV_LIBEXEC_DIR}/mulle-env-scope.sh"

         MULLE_USAGE_NAME="${MULLE_USAGE_NAME} environment" env_scope_main "$@"
      ;;

      *)
         env_environment_usage "unknown command \"${cmd}\""
      ;;
   esac
}

