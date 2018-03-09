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
"

HIDDEN_COMMANDS="\
   hostname          : show current hostname value
   user              : show current username value
   uname             : show current operating system value
"
    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} environment [options] [command]*

   Manage environment variables as set by mulle-env when entering an
   environment. You general settings will be in scope "global". There
   other scopes based on the login user, the current host and the
   current platform (os).

Options:
   -h                : show this usage
   --global          : scope for general environments variables
   --hostname        : narrow scope to this host only (`hostname`)
   --user            : narrow scope to this user only ($USER)
   --os              : narrow scope to this operating system only ($MULLE_UNAME)

Commands:
EOF

   (
      echo "${SHOWN_COMMANDS}"
      if [ "${MULLE_FLAG_LOG_VERBOSE}" = "YES" ]
      then
         echo "${HIDDEN_COMMANDS}"
      fi
   ) | sed '/^$/d' | sort >&2

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

   Get the value of an environment variable.

Options:
   --output-eval : resolve value
EOF
   exit 1
}

env_environment_set_usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} environment set [options] <key> [value] [comment]

   Set the value of an environment variable. Specify the scope of your
   environment variable with the `${MULLE_USAGE_NAME} environment`
   options.

   Set by default will save into the user scope!

   Use the alias \`mulle-env-reload\` to update your shell environment
   variables after edits.

   Example:
      ${MULLE_USAGE_NAME} environment --global set FOO "A value"

Options:
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
   environment options.

      ${MULLE_USAGE_NAME} environment --global list


Options:
   --separate    : list all files where environment variables are defined
   --output-eval : resolve values
EOF
   exit 1
}


key_values_to_sed()
{
   local line

   local key
   local value
   local sed_escaped_value
   local sed_escaped_key

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

      sed_escaped_key="`escaped_sed_pattern "${OPTION_SED_KEY_PREFIX}${key}${OPTION_SED_KEY_SUFFIX}"`"
      sed_escaped_value="`escaped_sed_pattern "${value}"`"

      echo "-e 's/${sed_escaped_key}/${sed_escaped_value}/g'"
   done
   IFS="${DEFAULT_IFS}"
}


env_prepare_for_add()
{
   log_entry "env_prepare_for_add" "$@"

   local etctoolsfile="$1"
   local sharetoolsfile="$2"

   mkdir_if_missing "`fast_dirname "${etctoolsfile}"`"
   if [ ! -f "${etctoolsfile}" ]
   then
      if [ -f "${sharetoolsfile}" ]
      then
         exekutor cp "${sharetoolsfile}" "${etctoolsfile}"
         exekutor chmod ug+w "${etctoolsfile}"
      fi
   fi
}

env_prepare_for_remove()
{
   log_entry "env_prepare_for_remove" "$@"

   local etctoolsfile="$1"
   local sharetoolsfile="$2"

   if [ ! -f "${etctoolsfile}" ]
   then
      if [ ! -f "${sharetoolsfile}" ]
      then
         return 1
      fi
      mkdir_if_missing "`fast_dirname "${etctoolsfile}"`"
      exekutor cp "${sharetoolsfile}" "${etctoolsfile}"
   fi
}


#
# Get
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

   sed_escaped_key="`escaped_sed_pattern "${key}"`"
   sed_escaped_value="`escaped_sed_pattern "${value}"`"

   # on request, we comment it out
   if [ "${OPTION_COMMENT_OUT_EMPTY}" = "YES" -a -z "${value}" ]
   then
      if [ -f "${filename}" ]
      then
         inplace_sed -e "s/^\\( *export *${sed_escaped_key}=.*\\)/\
# \\1/" "${filename}"
      fi
      return
   fi

   #
   # first try inplace-replacement
   #
   if [ -f "${filename}" ]
   then
      inplace_sed -e "s/^[ #]*export *${sed_escaped_key}=.*/\
export ${sed_escaped_key}=${sed_escaped_value}/" "${filename}"
      if rexekutor egrep -q -s "^export *${sed_escaped_key}=" "${filename}"
      then
         return
      fi
   fi

   if [ -z "${comment}" ]
   then
      comment="#
#
#"
   fi

   #
   # If that fails append to end, except if empty
   #
   if [  -z "${value}" -a "${OPTION_ADD_EMPTY}" = "NO"  ]
   then
      return
   fi

   local text

   text="\
${comment}
export ${key}=${value}

"
   redirect_append_exekutor "${filename}" echo "${text}"
}


env_environment_set_main()
{
   log_entry "env_environment_set_main" "$@"

   local scope="$1"; shift
   local OPTION_COMMENT_OUT_EMPTY="NO"
   local OPTION_ADD_EMPTY="NO"

   while :
   do
      case "$1" in
         -h|--help|help)
            env_environment_set_usage
         ;;

         --comment-out-empty)
            OPTION_COMMENT_OUT_EMPTY="YES"
         ;;

         --add-empty)
            OPTION_ADD_EMPTY="YES"
         ;;

         -*)
            env_environment_set_usage "unknown option \"$1\""
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

   local identifier

   identifier="`printf "%s" "${key}" | tr -c 'a-zA-Z0-9' '_' | tr 'a-z' 'A-Z'`"

   if [ "${key}" != "${identifier}" ]
   then
      fail "\"${key}\" is not a valid environment identifier ([_A-Z][0-9A-Z_])"
   fi

   case "${identifier}" in
      [0-9]*)
         fail "\"${key}\" is not a valid environment identifier ([_A-Z][0-9A-Z_])"
      ;;
   esac

   local filename

   log_verbose "Use \`mulle-env-reload\' to get the actual value in your shell"

   case "${scope}" in
      "")
         env_prepare_for_add "${filename}" "${MULLE_ENV_DIR}/share/environment-global.sh"

         filename="${MULLE_ENV_ETC_DIR}/environment-global.sh"
         _env_environment_set "${filename}" "${key}" "${value}" "${comment}" || exit 1

         shopt -s nullglob
         for i in ${MULLE_ENV_ETC_DIR}/environment-os-*.sh \
                  ${MULLE_ENV_ETC_DIR}/environment-host-*.sh \
                  ${MULLE_ENV_ETC_DIR}/environment-user-*.sh
         do
            shopt -u nullglob
            _env_environment_set "$i" "${key}" ""
         done
         shopt -u nullglob
      ;;

      share)
         local rval

         filename="${MULLE_ENV_DIR}/share/environment-global.sh"

         exekutor chmod ug+w "${filename}" 2> /dev/null
         exekutor chmod ug+wX "${MULLE_ENV_DIR}/share" 2> /dev/null

         _env_environment_set "${filename}" "${key}" "${value}" "${comment}"
         rval="$?"

         exekutor chmod a-w "${filename}" 2> /dev/null
         exekutor chmod a-w "${MULLE_ENV_DIR}/share" 2> /dev/null

         return $rval
      ;;

      *)
         filename="${MULLE_ENV_ETC_DIR}/environment-${scope}.sh"
         env_prepare_for_add "${filename}" "${MULLE_ENV_DIR}/share/environment-${scope}.sh"

         _env_environment_set "${filename}" "${key}" "${value}" "${comment}"
      ;;
   esac
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

   while [ $# -ne 0 ]
   do
      key="${1%%=*}"
      value="${1#${key}=}"
      comment="${value##*##}"
      value="${value%##*}"

      if [ ! -z "${comment}" ]
      then
         comment="`sed 's/\\\n/\n/g' <<< "${comment}"`"
         comment="`sed -e 's/^/# /' <<< "${comment}"`"
      fi

      env_environment_set_main "${scope}" "${key}" "${value}" "${comment}"

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

   value="`rexekutor sed -n 's/^ *export *//p' "${filename}" | \
           rexekutor awk -F '=' "{ value[ \\\$1] = \\\$2 };END{ print value[ \\\"${key}\\\"] }"`"
   if [ -z "${value}" ]
   then
      return 1
   fi

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
                            bash -c ". '${filename}' ; echo \\\$${key}"`"
   if [ -z "${value}" ]
   then
      return 1
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
                            bash -c ". '${filename}' ; echo \\\$${key}"`"
   if [ -z "${value}" ]
   then
      return 1
   fi

   local escaped_key
   local escaped_value

   escaped_key="`escaped_sed_pattern "${OPTION_SED_KEY_PREFIX}${key}${OPTION_SED_KEY_SUFFIX}"`"
   escaped_value="`escaped_sed_pattern "${value}"`"
   echo "-e 's/${escaped_key}/${escaped_value}/g'"
}


env_environment_get_main()
{
   log_entry "_env_environment_get_main" "$@"

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
            env_environment_get_usage "unknown option \"$1\""
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

   case "${scope}" in
      "")
         filename="${MULLE_ENV_ETC_DIR}/environment-user-${USER}.sh"
         if ${getter} "${filename}" "${key}"
         then
            return
         fi
         filename="${MULLE_ENV_ETC_DIR}/environment-host-`hostname`.sh"
         if ${getter} "${filename}" "${key}"
         then
            return
         fi

         filename="${MULLE_ENV_ETC_DIR}/environment-os-${MULLE_UNAME}.sh"
         if [ ! -f "${filename}" ]
         then
            filename="${MULLE_ENV_DIR}/share/environment-os-${MULLE_UNAME}.sh"
         fi
         if ${getter} "${filename}" "${key}"
         then
            return
         fi
         filename="${MULLE_ENV_ETC_DIR}/environment-global.sh"
         if [ ! -f "${filename}" ]
         then
            filename="${MULLE_ENV_DIR}/share/environment-global.sh"
         fi
         if ${getter} "${filename}" "${key}"
         then
            return
         fi
      ;;

      include)
         ${getter} "${MULLE_ENV_DIR}/share/environment-include.sh" "${key}"
      ;;

      share)
         ${getter} "${MULLE_ENV_DIR}/share/environment-global.sh" "${key}"
      ;;

      *)
         filename="${MULLE_ENV_ETC_DIR}/environment-${scope}.sh"
         if [ ! -f "${filename}" ]
         then
            filename="${MULLE_ENV_DIR}/share/environment-${scope}.sh"
         fi
         ${getter} "${filename}" "${key}"
      ;;
   esac
}

#
# List
#

merge_environment_text()
{
   rexekutor sed -n 's/^ *export *//p' <<< "${1}" | \
   rexekutor awk -F '=' '{ value[ $1] = $2 };END{for(i in value) print i "=" value[i]}' | \
   rexekutor sort
}


merge_environment_file()
{
   rexekutor sed -n 's/^ *export *//p' "${1}" | \
   rexekutor awk -F '=' '{ value[ $1] = $2 };END{for(i in value) print i "=" value[i]}' | \
   rexekutor sort
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
            text="`add_line "${text}" "${contents}"`"
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
   local filename

   cmdline="_env_environment_combined_list '${text_lister}'"
   filename="${MULLE_ENV_DIR}/etc/environment-global.sh"
   if [ -f "${filename}" ]
   then
      cmdline="`concat "${cmdline}" "'${filename}'"`"
   else
      filename="${MULLE_ENV_DIR}/share/environment-global.sh"
      cmdline="`concat "${cmdline}" "'${filename}'"`"
   fi

   filename="${MULLE_ENV_DIR}/etc/environment-os-${MULLE_UNAME}.sh"
   if [ -f "${filename}" ]
   then
      cmdline="`concat "${cmdline}" "'${filename}'"`"
   else
      filename="${MULLE_ENV_DIR}/share/environment-os-${MULLE_UNAME}.sh"
      cmdline="`concat "${cmdline}" "'${filename}'"`"
   fi

   filename="'${MULLE_ENV_ETC_DIR}/environment-host-`hostname`.sh'"
   cmdline="`concat "${cmdline}" "${filename}" `"

   filename="'${MULLE_ENV_ETC_DIR}/environment-user-${USER}.sh'"
   cmdline="`concat "${cmdline}" "${filename}" `"

   eval "${cmdline}"
}


_env_environment_list()
{
   log_entry "_env_environment_list" "$@"

   local scope

   while [ "$#" -ne 0 ]
   do
      if [ -f "$1" ]
      then
         scope="`fast_basename "$1"`"
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
MULLE_UNAME=\"${MULLE_UNAME}\" bash -c '"

   while [ "$#" -ne 0 ]
   do
      if [ -f "$1" ]
      then
         log_info "${C_RESET_BOLD}`fast_basename "$1"`:"

         cmdline="`concat "${cmdline}" ". \"$1\" ; "`"
      else
         log_fluff "\"$1\" does not exist"
      fi
      shift
   done
   cmdline="`concat "${cmdline}" "env | sort '"`"

   #
   # remove a couple of builtins clumsily.
   # Properly: do `env -i bash -c env` and then remove
   # those lines
   #
    \
   MULLE_UNAME="${MULLE_UNAME}" \
      reval_exekutor "${cmdline}" | rexekutor sed -e '/^PWD=/d' \
                                                  -e '/^_=/d' \
                                                  -e '/^SHLVL=/d' \
                                                  -e '/MULLE_UNAME=/d' \
                                                  -e '/MULLE_VIRTUAL_ROOT=/d'
}

_env_environment_sed_list()
{
   log_entry "_env_environment_sed_list" "$@"

   _env_environment_eval_list "$@" | key_values_to_sed
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
            env_environment_list_usage "unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   [ "$#" -ne 0 ] && env_environment_list_usage "wrong number of arguments \"$*\""

   log_info "Environment"

   local filename

   case "${scope}" in
      "separate")
         filename="${MULLE_ENV_ETC_DIR}/environment-global.sh"
         if [ ! -f "${filename}" ]
         then
            filename="${MULLE_ENV_DIR}/share/environment-global.sh"
         fi
         "${lister}" "${filename}"

         filename="${MULLE_ENV_ETC_DIR}/environment-os-${MULLE_UNAME}.sh"
         if [ ! -f "${filename}" ]
         then
            filename="${MULLE_ENV_DIR}/share/environment-os-${MULLE_UNAME}.sh"
         fi
         "${lister}" "${filename}"

         "${lister}" "${MULLE_ENV_ETC_DIR}/environment-host-`hostname`.sh"
         "${lister}" "${MULLE_ENV_ETC_DIR}/environment-user-${USER}.sh"
      ;;

      include)
         "${lister}" "${MULLE_ENV_DIR}/share/environment-include.sh"
      ;;

      share)
         "${lister}" "${MULLE_ENV_DIR}/share/environment-default.sh"
      ;;

      "DEFAULT")
         _env_environment_combined_list_main "merge_environment_text" "$@"
      ;;

      *)
         filename="${MULLE_ENV_ETC_DIR}/environment-${scope}.sh"
         if [ ! -f "${filename}" ]
         then
            filename="${MULLE_ENV_DIR}/share/environment-${scope}.sh"
         fi
      ;;
   esac
}

###
### parameters and environment variables
###
env_environment_main()
{
   log_entry "env_environment_main" "$@"

   [ -z "${MULLE_ENV_DIR}" ] && internal_fail "MULLE_ENV_DIR is empty"
   [ ! -d "${MULLE_ENV_DIR}" ] && fail "mulle-env init hasn't run here yet"

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

         --global|--hostname-*|--user-*|--os-*|--share)
            [ "${OPTION_SCOPE}" = "DEFAULT" ] || log_fail "scope has already been specified as \"${OPTION_SCOPE}\""

            OPTION_SCOPE="${1:2}"
         ;;

         --hostname)
            [ "${OPTION_SCOPE}" = "DEFAULT" ] || log_fail "scope has already been specified as \"${OPTION_SCOPE}\""

            OPTION_SCOPE="host-`hostname`"
         ;;

         --user)
            [ "${OPTION_SCOPE}" = "DEFAULT" ] || log_fail "scope has already been specified as \"${OPTION_SCOPE}\""

            OPTION_SCOPE="user-${USER}"
         ;;

         --os)
            [ "${OPTION_SCOPE}" = "DEFAULT" ] || log_fail "scope has already been specified as \"${OPTION_SCOPE}\""

            OPTION_SCOPE="os-${MULLE_UNAME}"
         ;;

         -*)
            env_environment_usage "unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   local cmd="$1"
   [ $# -ne 0 ] && shift

   case "${cmd}" in
      hostname)
         hostname
      ;;

      user)
         echo "${USER}"
      ;;

      os|uname)
         echo "${MULLE_UNAME}"
      ;;

      get)
         if [ "${OPTION_SCOPE}" = "DEFAULT" ]
         then
            OPTION_SCOPE=""
         fi
         env_environment_get_main "${OPTION_SCOPE}" "$@"
      ;;

      list)
         env_environment_list_main "${OPTION_SCOPE}" "$@"
      ;;

      set)
         if [ "${OPTION_SCOPE}" = "DEFAULT" ]
         then
            OPTION_SCOPE="${MULLE_ENV_DEFAULT_SET_SCOPE:-user-${USER}}"
         fi
         env_environment_set_main "${OPTION_SCOPE}" "$@"
      ;;

      mset)
         if [ "${OPTION_SCOPE}" = "DEFAULT" ]
         then
            OPTION_SCOPE="all"      # mset to be used by init only
         fi
         env_environment_mset_main "${OPTION_SCOPE}" "$@"
      ;;

      "")
         env_environment_usage
      ;;

      *)
         env_environment_usage "unknown command \"${cmd}\""
      ;;
   esac
}

