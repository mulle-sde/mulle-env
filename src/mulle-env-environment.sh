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
   scopes            : list available scopes
"

HIDDEN_COMMANDS="\
   host              : show current host value
   user              : show current user value
   uname             : show current operating system value
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
   --host            : narrow scope to this host only ($MULLE_HOSTNAME)
   --os              : narrow scope to this operating system only ($MULLE_UNAME)
   --scope <name>    : use an arbitrarily named scope
   --user            : narrow scope to this user only ($USER)

Commands:
EOF

   (
      echo "${SHOWN_COMMANDS}"
      if [ "${MULLE_FLAG_LOG_VERBOSE}" = 'YES' ]
      then
         echo "${HIDDEN_COMMANDS}"
      fi
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

Options:
   --output-eval : resolve value with other environment variables
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
   --add              : add value to existing values (using seperator :)
   --separator <sep>  : sepecify custom separator for --add
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
   more information about scopes.

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
   contents of all existing environment scopes with definitions.

   The scopes are listed in increasing order of precedence. An entry in
   the user setting will override a setting in host, os, global etc.

Scopes:
   plugin             : only used by mulle-env plugins
   project            : set by mulle-sde on init
   extension          : set by mulle-sde extensions
   global             : global settings (user defined)
   os-<platform>      : platform specific settings (user defined)
   host-<hostname>    : host specific settings (user defined)
   user-<username>    : user specific settings (user defined)

Options:
   --all              : show also plugin, project and extension scopes
   --filename         : emit filename of the scope file
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

   IFS="
"
   while read -r line
   do
      IFS="${DEFAULT_IFS}"

      if [ -z "${line}" ]
      then
         continue
      fi

      key="${line%%=*}"
      value="${line#${key}=}"

      # scope is a cheat!!
      echo "${MULLE_USAGE_NAME} environment set ${key} '${value}'"
   done
   IFS="${DEFAULT_IFS}"
}


key_values_to_sed()
{
   local line

   local key
   local value
   local escaped_value
   local escaped_key
   local RVAL

   IFS="
"
   while read -r line
   do
      IFS="${DEFAULT_IFS}"

      if [ -z "${line}" ]
      then
         continue
      fi

      key="${line%%=*}"
      value="${line#${key}=}"

      r_escaped_sed_pattern "${OPTION_SED_KEY_PREFIX}${key}${OPTION_SED_KEY_SUFFIX}"
      escaped_key="${RVAL}"
      r_escaped_sed_pattern "${value}"
      escaped_value="${RVAL}"

      # escape quotes for "eval line"
      # i really don't see why i need 6 backquotes here, but...
      escaped_key="`sed -e "s/'/'\\\\\\''/g" <<< "${escaped_key}"`"
      escaped_value="`sed -e "s/'/'\\\\\\''/g" <<< "${escaped_value}"`"

      echo "-e 's/${escaped_key}/${escaped_value}/g'"
   done
   IFS="${DEFAULT_IFS}"
}


#
# Set
#
escaped_doublequotes()
{
   sed 's/"/\\"/g' <<< "${1}"
}


_env_environment_set()
{
   log_entry "_env_environment_set" "$@"

   local filename="$1"
   local key="$2"
   local value="$3"
   local comment="$4"

   # put quotes around it if needed
   case "${value}" in
      ""|\"\")
         value=""
      ;;

      \"*\")
      ;;

      *)
         escaped_value="`escaped_doublequotes "${value}"`"
         value="\"${escaped_value}\""
      ;;
   esac

   local escaped_value
   local sed_escaped_value
   local sed_escaped_key
   local RVAL

   r_escaped_sed_pattern "${key}"
   sed_escaped_key="${RVAL}"
   r_escaped_sed_pattern "${value}"
   sed_escaped_value="${RVAL}"

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
         return 1
      fi

      if ! _env_file_defines_key "${filename}" "${key}"
      then
         log_fluff "${key} does not exist in ${filename}"
         return 1
      fi

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
         inplace_sed -e "s/^[ #]*export *${sed_escaped_key}=.*/\
export ${sed_escaped_key}=${sed_escaped_value}/" "${filename}"
         return $?
      fi
   fi

   if [ -z "${comment}" ]
   then
      comment="#
#
#"
   fi

   if [ -z "${value}" -a "${OPTION_ADD_EMPTY}" = 'NO' ]
   then
      return
   fi

   local text

   text="\
${comment}
export ${key}=${value}

"
   r_mkdir_parent_if_missing "${filename}"
   redirect_append_exekutor "${filename}" echo "${text}"
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

   shopt -s nullglob
   for i in ${MULLE_ENV_ETC_DIR}/environment-os-*.sh \
            ${MULLE_ENV_ETC_DIR}/environment-host-*.sh \
            ${MULLE_ENV_ETC_DIR}/environment-user-*.sh
   do
      shopt -u nullglob
      _env_environment_remove "$i" "${key}"
   done
   shopt -u nullglob
}


# todo: set i still too hacky
#       and doesn't respect r_get_scopes information

env_environment_set_main()
{
   log_entry "env_environment_set_main" "$@"

   local scope="$1"; shift
   local OPTION_COMMENT_OUT_EMPTY='NO'
   local OPTION_ADD_EMPTY='YES'
   local OPTION_ADD='NO'
   local OPTION_SEPARATOR=":"  # convenient for PATH like behaviour

   while :
   do
      case "$1" in
         -h|--help|help)
            env_environment_set_usage
         ;;

         --no-add-empty)
            OPTION_ADD_EMPTY='NO'
         ;;

         -a|--add)
            OPTION_ADD='YES'
         ;;

         -c|--comment-out-empty)
            OPTION_COMMENT_OUT_EMPTY='YES'
         ;;

         -s|--separator)
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

   local key="$1"
   local value="$2"
   local comment="$3"

   [ -z "${key}" ] && env_environment_set_usage "empty key"

   assert_valid_environment_key "${key}"

   if [ "${OPTION_ADD}" = 'YES' ]
   then
      local prev
      local oldvalue

      prev="`env_environment_get_main "${scope}" "${key}"`"
      log_debug "Previous value is \"${prev}\""

      case "${value}" in
         *:*)
            fail "${value} contains :, which is not possible for addition \
(can not be escaped either)"
         ;;
      esac

      set -f; IFS="${OPTION_SEPARATOR}"

      for oldvalue in ${prev}
      do
         set +f; IFS="${DEFAULT_IFS}"
         if [ "${oldvalue}" = "${value}" ]
         then
            log_fluff "\"${value}\" already set"
            return
         fi
      done

      set +f; IFS="${DEFAULT_IFS}"

      r_concat "${prev}" "${value}" "${OPTION_SEPARATOR}"
      value="${RVAL}"
   fi

   local filename

#   log_verbose "Use \`mulle-env-reload\` to get the actual value in your shell"

   log_debug "Environment scope \"${scope}\" set $key=\"${value}\""

   if [ "${scope}" = 'DEFAULT' ]
   then
      filename="${MULLE_ENV_ETC_DIR}/environment-global.sh"
      _env_environment_set "${filename}" "${key}" "${value}" "${comment}" &&
      env_environment_remove_from_global_subscopes "${key}"
      return $?
   fi

   local scopeprefix
   local rval

   if ! r_scopeprefix_for_scope "${scope}"
   then
      if [ "${MULLE_FLAG_MAGNUM_FORCE}" = 'YES' ]
      then
         log_warning "Adding unknown scope \"${scope}\" to auxscopes"

         filename="${MULLE_ENV_DIR}/share/auxscopes"
         if [ -f "${filename}" ]
         then
            exekutor chmod ug+w "${filename}" 2> /dev/null
         fi
         redirect_append_exekutor "${MULLE_ENV_DIR}/share/auxscopes" echo "${scope}"
         exekutor chmod a-w "${filename}"

         RVAL="s" # auxscopes are always share
      else
         fail "Unknown scope \"${scope}\""
      fi
   fi
   scopeprefix="${RVAL}"

   r_directory_for_scopeprefix "${scopeprefix}"
   filename="${RVAL}/environment-${scope}.sh"

   if [ "${scopeprefix}" = "s" ]
   then
      if [ -f "${filename}" ]
      then
         exekutor chmod ug+w "${filename}"
      fi
   fi

   _env_environment_set "${filename}" "${key}" "${value}" "${comment}"
   rval="$?"

   if [ "${MULLE_FLAG_LOG_SETTINGS}" = 'YES' ]
   then
      log_trace2 "filename : ${filename}"
      cat "${filename}" >&2
   fi

   if [ "${scopeprefix}" = "s" ]
   then
      if [ -f "${filename}" ]
      then
         exekutor chmod a-w "${filename}"
      fi
   fi

   return $rval
}


#
# interface for mulle-sde
#
env_environment_mset_main()
{
   log_entry "env_environment_mset_main" "$@"

   local scope="$1"; shift

   local key
   local value
   local comment
   local option

   while [ $# -ne 0 ]
   do
      case "$1" in
         *+=\"*\"*)
            key="${1%%+=*}"
            value="${1#${key}+=}"
            option="--add"
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
         comment="`sed 's/\\\n/\n/g' <<< "${comment}"`"
         comment="`sed -e 's/^/# /' <<< "${comment}"`"
      fi

      env_environment_set_main "${scope}" ${option} "${key}" "${value}" "${comment}"

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
   log_verbose "Reading ${C_RESET_BOLD}${filename}"

   assert_valid_environment_key "${key}"

   local sedcmd

   r_escaped_sed_pattern "${key}"
   sedcmd="s/^ *export *${RVAL} *= *\"\\(.*\\)\$/\\1/p"

   value="`rexekutor sed -n -e "${sedcmd}" "${filename}" `"
   value="`rexekutor sed 's/\(.*\)\".*/\1/' <<< "${value}"`"

   if [ -z "${value}" ]
   then
      _env_file_defines_key "${filename}" "${key}"
      return $?
   fi

   log_fluff "Found \"${key}\" with value \"${value}\" in \"${filename}\""

   case "${value}" in
      \"*\")
         value="${value%?}"
         echo "${value:1}"
      ;;

      *)
         echo "${value}"
      ;;
   esac
}


_env_file_defines_key()
{
   log_entry "_env_file_defines_key" "$@"

   local filename="$1"
   local key="$2"

   local grep_escaped_pattern

   r_escaped_grep_pattern "${key}"
   grep_escaped_pattern="${RVAL}"
   rexekutor egrep -q -s "^ *export *${grep_escaped_pattern}=" "${filename}"
}


_env_environment_eval_get()
{
   log_entry "_env_environment_eval_get" "$@"

   local filename="$1"
   local key="$2"

   [ -z "${MULLE_VIRTUAL_ROOT}" ] && internal_fail "MULLE_VIRTUAL_ROOT not set up"
   [ -z "${MULLE_UNAME}" ] && internal_fail "MULLE_UNAME not set up"

   if [ ! -f "${filename}" ]
   then
      log_fluff "\"${filename}\" does not exist"
      return 1
   fi

   log_verbose "Reading ${C_RESET_BOLD}${filename}"

   local  value

   value="`rexekutor env -i MULLE_VIRTUAL_ROOT="${MULLE_VIRTUAL_ROOT}" \
                            MULLE_UNAME="${MULLE_UNAME}" \
                            "${BASH}" -c ". '${filename}' ; echo \\\$${key}"`"
   if [ -z "${value}" ]
   then
      _env_file_defines_key "${filename}" "${key}"
      return $?
   fi
   echo "$value"
}


_env_environment_sed_get()
{
   log_entry "_env_environment_sed_get" "$@"

   local filename="$1"
   local key="$2"

   [ -z "${MULLE_VIRTUAL_ROOT}" ] && internal_fail "MULLE_VIRTUAL_ROOT not set up"
   [ -z "${MULLE_UNAME}" ] && internal_fail "MULLE_UNAME not set up"

   local value

   if [ ! -f "${filename}" ]
   then
      log_fluff "\"${filename}\" does not exist"
      return 1
   fi

   log_verbose "Reading ${C_RESET_BOLD}${filename}"

   value="`rexekutor env -i MULLE_VIRTUAL_ROOT="${MULLE_VIRTUAL_ROOT}" \
                            MULLE_UNAME="${MULLE_UNAME}" \
                            "${BASH}" -c ". '${filename}' ; echo \\\$${key}"`"
   if [ -z "${value}" ]
   then
      _env_file_defines_key "${filename}" "${key}"
      return $?
   fi

   local escaped_key
   local escaped_value

   r_escaped_sed_pattern "${OPTION_SED_KEY_PREFIX}${key}${OPTION_SED_KEY_SUFFIX}"
   escaped_key="${RVAL}"
   r_escaped_sed_pattern "${value}"
   escaped_value="${RVAL}"

   # escape quotes for "eval line"
   escaped_key="`sed -e "s/'/'\\\\\\''/g" <<< "${escaped_key}"`"
   escaped_value="`sed -e "s/'/'\\\\\\''/g" <<< "${escaped_value}"`"

   echo "-e 's/${escaped_key}/${escaped_value}/g'"
}


r_get_auxscopes()
{
   log_entry "r_get_scopes" "$@"

   local auxscopesfile

   auxscopesfile="${MULLE_ENV_DIR}/share/auxscopes"
   if [ ! -f "${auxscopesfile}" ]
   then
      log_debug "No auxscopes found"
      return 1
   fi
   # eval it to resolve USER and so on
   local tmp
   local aux_scope

   tmp="`rexekutor egrep -v '^#' "${auxscopesfile}"`"
   log_debug "aux_scopes: ${tmp}"

   RVAL=

   set -f; IFS="
"
   for aux_scope in ${tmp}
   do
      IFS="${DEFAULT_IFS}"; set +f

      if [ ! -z "${aux_scope}" ]
      then
         aux_scope="`eval echo "${aux_scope}" | sed 's/^/s:/'`"
         r_add_line "${RVAL}" "${aux_scope}"
      fi
   done
   IFS="${DEFAULT_IFS}"; set +f

   log_debug "aux_scopes: ${RVAL}"
}


r_get_scopes()
{
   log_entry "r_get_scopes" "$@"

   local option_plugin="${1:-YES}"
   local option_aux="${2:-YES}"
   local option_user="${3:-YES}"

   local user_scopes
   local env_scopes
   local aux_scopes

   if [ "${option_plugin}" = 'YES' ]
   then
      env_scopes="s:plugin
s:plugin-os-${MULLE_UNAME}"
   fi

   if [ "${option_aux}" = 'YES' ]
   then
      r_get_auxscopes
      aux_scopes="${RVAL}"
   fi

   #
   # os is special and may appear in etc and share
   #
   if [ "${option_user}" = 'YES' ]
   then
      user_scopes="e:global
e:os-${MULLE_UNAME}
e:host-${MULLE_HOSTNAME}
e:user-${USER}"
   fi

   r_add_line "${env_scopes}" "${aux_scopes}"
   r_add_line "${RVAL}" "${user_scopes}"
}


r_directory_for_scopeprefix()
{
   log_entry "r_directory_for_scopeprefix" "$@"

   local prefix="$1"

   RVAL="${MULLE_ENV_ETC_DIR}"
   if [ "${prefix:0:1}" = "s" ]
   then
      RVAL="${MULLE_ENV_DIR}/share"
   fi
}


r_scopeprefix_for_scope()
{
   log_entry "r_scopeprefix_for_scope" "$@"

   local scope="$1"

   r_get_scopes

   local scopes

   scopes="${RVAL}"
   RVAL=""

   local i

   set -f; IFS="
"
   for i in ${scopes}
   do
      IFS="${DEFAULT_IFS}"; set +f

      if [ "${i:2}" = "${scope}" ]
      then
         RVAL="${i:0:1}"
      fi
   done
   IFS="${DEFAULT_IFS}"; set +f

   [ ! -z "${RVAL}" ]
}


r_get_existing_scope_files()
{
   log_entry "r_existing_scope_files" "$@"

   local OPTION_INFERIORS='NO'

   while :
   do
      case "$1" in
         --with-inferiors)
            OPTION_INFERIORS='YES'
         ;;

         *)
            break
         ;;
      esac
      shift
   done

   local scope="$1"

   local scopes

   r_get_scopes
   scopes="${RVAL}"

   RVAL=""

   local i
   local scopename
   local filename
   local skipcheck

   skipcheck='NO'

   set -f; IFS="
"
   for i in ${scopes}
   do
      IFS="${DEFAULT_IFS}"; set +f

      scopename="${i:2}"
      if [ "${skipcheck}" = 'NO' -a \
           "${scope}" != "DEFAULT" -a \
           "${scopename}" != "${scope}" ]
      then
         continue
      fi

      skipcheck="${OPTION_INFERIORS}"
      case "${i}" in
         'e:'*)
            filename="${MULLE_ENV_ETC_DIR}/environment-${scopename}.sh"
            if [ -f "${filename}" ]
            then
               r_add_line "${RVAL}" "${filename}"
            fi
         ;;

         's:'*)
            filename="${MULLE_ENV_DIR}/share/environment-${scopename}.sh"
            if [ -f "${filename}" ]
            then
               r_add_line "${RVAL}" "${filename}"
            fi
         ;;
      esac
   done
   IFS="${DEFAULT_IFS}"; set +f
}


env_environment_get_main()
{
   log_entry "env_environment_get_main" "$@"

   local scope="$1"; shift

   local infix="_"
   local getter

   getter="_env_environment_get"

   while :
   do
      case "$1" in
         -h|--help|help)
            env_environment_get_usage
         ;;

         --output-eval)
            getter="_env_environment_eval_get"
         ;;

         --output-sed)
            getter="_env_environment_sed_get"
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
   [ -z "${key}" ] && fail "empty key"

   local filename
   local filenames
   local RVAL

   case "${scope}" in
      include)
         ${getter} "${MULLE_ENV_DIR}/share/include-environment.sh" "${key}"
      ;;

      *)
         r_get_existing_scope_files "${scope}"
         filenames="${RVAL}"

         set -f ; IFS="
"
         for filename in ${filenames}
         do
            set +f; IFS="${DEFAULT_IFS}"
            if ${getter} "${filename}" "${key}"
            then
               return
            fi
         done
         set +f; IFS="${DEFAULT_IFS}"

         return 1
      ;;
   esac
}


remove_environmentfile_if_empty()
{
   log_entry "remove_environmentfile_if_empty" "$@"

   local filename="$1"

   local contents

   contents="`egrep -v '^#' "${filename}"   | sed '/^[ ]*$/d'`"
   if [ -z "${contents}" ]
   then
      remove_file_if_present "${filename}"
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
   inplace_sed -e "s/^\\( *export *${sed_escaped_key}=.*\\)//" "${filename}"

   if [ "${OPTION_REMOVE}" != 'NO' ]
   then
      remove_environmentfile_if_empty "${filename}"
   fi
}


env_environment_remove_main()
{
   log_entry "env_environment_remove_main" "$@"

   local scope="$1"; shift

   local OPTION_REMOVE='DEFAULT'

   while :
   do
      case "$1" in
         -h|--help|help)
            env_environment_remove_usage
         ;;

         --no-remove)
            OPTION_REMOVE='YES'
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

   local key="$1"

   [ -z "${key}" ] && fail "empty key"

   local filename
   local filenames
   local RVAL

   if [ "${scope}" = "DEFAULT" ]
   then
      r_get_existing_scope_files "--with-inferiors" "global"
   else
      r_get_existing_scope_files "${scope}"
   fi

   filenames="${RVAL}"

   local rval

   rval=1
   set -f ; IFS="
"
   for filename in ${filenames}
   do
      set +f; IFS="${DEFAULT_IFS}"

      if _env_file_defines_key "${filename}" "${key}"
      then
         _env_environment_remove "${filename}" "${key}"
         rval=0
      fi
  done
   set +f; IFS="${DEFAULT_IFS}"

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

   awkcode='{ left=substr( $0, 0, index( $0, "=") - 1); \
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
   local RVAL

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
   local RVAL


   r_get_existing_scope_files "DEFAULT"
   filenames="${RVAL}"

   set -f ; IFS="
"
   for filename in ${filenames}
   do
      set +f; IFS="${DEFAULT_IFS}"

      r_concat "${cmdline}" "'${filename}'"
      cmdline="${RVAL}"
   done
   set +f; IFS="${DEFAULT_IFS}"

   eval "${cmdline}"
}


_env_environment_list()
{
   log_entry "_env_environment_list" "$@"

   local scope
   local RVAL

   while [ "$#" -ne 0 ]
   do
      if [ -f "$1" ]
      then
      	r_fast_basename "$1"

         scope="${RVAL}"
         scope="${scope%.sh}"
         scope="${scope#environment-}"

         log_info "${C_MAGENTA}${C_BOLD}${scope}"

         merge_environment_file "$1"
      else
         log_fluff "\"$1\" does not exist"
      fi
      shift
   done
}


_env_environment_eval_list()
{
   log_entry "_env_environment_eval_list" "$@"

   local cmdline

   [ -z "${MULLE_VIRTUAL_ROOT}" ] && internal_fail "MULLE_VIRTUAL_ROOT not set up"
   [ -z "${MULLE_UNAME}" ] && internal_fail "MULLE_UNAME not set up"

   cmdline="env -i MULLE_VIRTUAL_ROOT=\"${MULLE_VIRTUAL_ROOT}\" \
MULLE_UNAME=\"${MULLE_UNAME}\" \
MULLE_HOSTNAME=\"${MULLE_HOSTNAME}\" \
USER=\"${USER}\" \
\"${BASH}\" -c '"

   [ "$#" -eq 0 ] && internal_fail "No environment files specified"

   local files
   local RVAL

   while [ "$#" -ne 0 ]
   do
      if [ -f "$1" ]
      then
         log_verbose "${C_RESET_BOLD}`fast_basename "$1"`:"

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
   reval_exekutor "${cmdline}" | rexekutor sed -e '/^PWD=/d' \
                                               -e '/^_=/d' \
                                               -e '/^SHLVL=/d' \
                                               -e '/^MULLE_UNAME=/d' \
                                               -e '/^MULLE_HOSTNAME=/d' \
                                               -e '/^USER=/d' \
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

   local scope="$1"; shift

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
            if [ "${scope}" = "DEFAULT" ]
            then
               scope="include"
            fi
         ;;

         --output-sed)
            lister="_env_environment_sed_list"
            if [ "${scope}" = "DEFAULT" ]
            then
               scope="include"
            fi
         ;;

         --output-command)
            lister="_env_environment_command_list"
            if [ "${scope}" = "DEFAULT" ]
            then
               scope="include"
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

   log_info "Environment"

   BASH="`command -v "bash"`"
   BASH="${BASH:-/usr/bin/bash}"  # panic fallback

   log_debug "scope: \"${scope}\""

   case "${scope}" in
      "merged")
         _env_environment_combined_list_main "merge_environment_text" "$@"
      ;;

      include)
         "${lister}" "${MULLE_ENV_DIR}/share/include-environment.sh"
      ;;

      *)
         r_get_scopes
         scopes="${RVAL}"

         local i
         local scopename

         set -f; IFS="
"
         for i in ${scopes}
         do
            IFS="${DEFAULT_IFS}"; set +f

            scopename="${i:2}"
            if [ "${scope}" != "DEFAULT" -a "${scopename}" != "${scope}" ]
            then
               continue
            fi

            case "${i}" in
               'e:'*)
                  "${lister}" "${MULLE_ENV_ETC_DIR}/environment-${scopename}.sh"
               ;;

               's:'*)
                 "${lister}" "${MULLE_ENV_DIR}/share/environment-${scopename}.sh"
               ;;
            esac
         done
         IFS="${DEFAULT_IFS}"; set +f
      ;;

   esac
}



env_environment_scope_main()
{
   log_entry "env_environment_scope_main" "$@"

   local OPTION_FILENAME='NO'
   local OPTION_EXISTING='NO'
   local OPTION_USER_SCOPES='YES'
   local OPTION_AUX_SCOPES='NO'
   local OPTION_PLUGIN_SCOPES='NO'

   while :
   do
      case "$1" in
         -h|--help|help)
            env_environment_scope_usage
         ;;

         --all)
            OPTION_AUX_SCOPES='YES'
            OPTION_PLUGIN_SCOPES='YES'
            OPTION_USER_SCOPES='YES'
         ;;

         --filename)
            OPTION_FILENAME='YES'
         ;;

         --no-directory)
            OPTION_FILENAME='NO'
         ;;

         --aux)
            OPTION_AUX_SCOPES='YES'
         ;;

         --no-aux)
            OPTION_AUX_SCOPES='NO'
         ;;

         --plugin)
            OPTION_PLUGIN_SCOPES='YES'
         ;;

         --no-plugin)
            OPTION_PLUGIN_SCOPES='NO'
         ;;

         --user)
            OPTION_USER_SCOPES='YES'
         ;;

         --no-user)
            OPTION_USER_SCOPES='NO'
         ;;

         --existing)
            OPTION_EXISTING='YES'
         ;;

         -*)
            env_environment_scope_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   [ "$#" -ne 0 ]  && env_environment_scope_usage "Superflous arguments \"$*\""

   if [ "${OPTION_EXISTING}" = 'YES' ]
   then
      (
         shopt -s nullglob

         rexekutor ls -1 "${MULLE_ENV_DIR}/share"/environment-*.sh \
                         "${MULLE_ENV_ETC_DIR}"/environment-*.sh \
            | sed '-e s|^.*/environment-\(.*\)\.sh$|\1|'
      ) | LC_ALL=C sort -u | sed -e '/^include/d'

      return 0
   fi

   local scopes

   r_get_scopes "${OPTION_PLUGIN_SCOPES}" \
                "${OPTION_AUX_SCOPES}" \
                "${OPTION_USER_SCOPES}"
   scopes="${RVAL}"

   if [ -z "${scopes}" ]
   then
      fail "No scopes selected"
   fi

   local scope
   local filename

   if [ "${OPTION_USER_SCOPES}" = 'YES' -a \
        "${OPTION_AUX_SCOPES}" = 'NO' -a \
        "${OPTION_PLUGIN_SCOPES}" = 'NO' ]
   then
      log_info "User Scopes"
   else
      if [ "${OPTION_AUX_SCOPES}" = 'YES' -a \
           "${OPTION_PLUGIN_SCOPES}" = 'YES' -a \
           "${OPTION_USER_SCOPES}" = 'YES' ]
      then
         log_info "All Scopes"
      else
         log_info "Partial Scopes"
      fi
   fi

   local etcdir
   local sharedir

   etcdir="${MULLE_ENV_ETC_DIR#${PWD}/}"
   sharedir="${MULLE_ENV_DIR#${PWD}/}/share"

   local scopename
   set -f
   IFS="
"
   for scope in ${scopes}
   do
      IFS="${DEFAULT_IFS}"
      filename=

      scopename="${scope:2}"
      if [ "${OPTION_FILENAME}" = 'YES' ]
      then
         case "${scope}" in
            'e:'*)
               if [ -f "${etcdir}/environment-${scopename}.sh" ]
               then
                  filename="(${etcdir}/environment-${scopename}.sh)"
               fi
            ;;

            's:'*)
               if [ -f "${sharedir}/environment-${scopename}.sh" ]
               then
                  filename="(${sharedir}/environment-${scopename}.sh)"
               fi
            ;;
         esac
      fi
      echo "${scopename}" "${filename}"
   done

   IFS="${DEFAULT_IFS}"
   set +f
}


assert_default_scope()
{
   [ "${OPTION_SCOPE}" = "DEFAULT" ] || \
      log_fail "scope has already \been specified as \"${OPTION_SCOPE}\""
}


###
### parameters and environment variables
###
env_environment_main()
{
   log_entry "env_environment_main" "$@"

   [ -z "${MULLE_ENV_DIR}" ] && internal_fail "MULLE_ENV_DIR is empty"
   [ ! -d "${MULLE_ENV_DIR}" ] && fail "mulle-env init hasn't run here yet ($PWD)"

   MULLE_ENV_ETC_DIR="${MULLE_ENV_ETC_DIR:-${MULLE_ENV_DIR}/etc}"

   local OPTION_SCOPE="DEFAULT"
   local infix="_"
   local OPTION_SED_KEY_PREFIX
   local OPTION_SED_KEY_SUFFIX

   #
   # handle options
   #
   while :
   do
      case "$1" in
         -h|--help|help)
            env_environment_usage
         ;;

         --global|--host-*|--os-*|--user-*)
            assert_default_scope

            OPTION_SCOPE="${1:2}"
         ;;

         --hostname-*)
            OPTION_SCOPE="host-${1:11}"
         ;;

         --hostname|--host)
            assert_default_scope

            OPTION_SCOPE="host-${MULLE_HOSTNAME}"
         ;;

         --user)
            assert_default_scope

            [ -z "${USER}" ] && fail "USER environment variable not set"

            OPTION_SCOPE="user-${USER}"
         ;;

         --os)
            assert_default_scope

            OPTION_SCOPE="os-${MULLE_UNAME}"
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

   [ -z "${OPTION_SCOPE}" ] && env_environment_usage "Empty scope is invalid"

   case "${cmd}" in
      host|hostname)
         hostname
      ;;

      user)
         echo "${USER}"
      ;;

      os|uname)
         echo "${MULLE_UNAME}"
      ;;

      get|list|mset|remove|set)
         env_environment_${cmd}_main "${OPTION_SCOPE}" "$@"
      ;;

      scope|scopes)
         env_environment_scope_main "$@"
      ;;

      upgrade)
         . "${MULLE_ENV_LIBEXEC_DIR}/mulle-env-init.sh" || exit 1

         local style
         local flavor

         __get_saved_style_flavor "${MULLE_VIRTUAL_ROOT:-.}/.mulle-env/etc" \
                                  "${MULLE_VIRTUAL_ROOT:-.}/.mulle-env/share"

         env_init_main --upgrade --style "${style}"
      ;;

      "")
         env_environment_usage
      ;;

      *)
         env_environment_usage "unknown command \"${cmd}\""
      ;;
   esac
}

