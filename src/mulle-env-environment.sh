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
SHOWN_COMMANDS="\
   list              : list environment variables
   set <key> <value> : set an environment variable
   get <key>         : get value of an environment variable
"

HIDDEN_COMMANDS="\
   hostname          : show current hostname value
   user              : show current username value
   uname             : show current uname value
"
    cat <<EOF >&2
Usage:
   ${MULLE_EXECUTABLE_NAME} environment [options] [command]*

   Manage environment variables as set by mulle-env when entering an
   environment. You general setting will be in --all, which is the
   default for *set*.

   Use list --separate to see where defintions are made.
   Use list --output-eval to see the resolved values.

Options:
   -h                : show this usage
   --all             : environment variables for all, but no specialized ones
   --hostname        : environment variables only for this host (`hostname`)
   --user            : environment variables only for this user  ($USER)
   --os              : environment variables only for this os ($MULLE_UNAME)

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

   # we don't delete the line, we comment it out (if present)
   if [ -z "${value}" ]
   then
      if [ -f "${filename}" ]
      then
         exekutor sed -i .bak -e "s/^\\( *export *${sed_escaped_key}=.*\\)/# \\1/" "${filename}"
      fi
      return
   fi

   #
   # first try inplace-replacement (comment out)
   #
   if [ -f "${filename}" ]
   then
      exekutor sed -i .bak -e "s/^[ #]*export *${sed_escaped_key}=.*/export ${sed_escaped_key}=${sed_escaped_value}/" "${filename}"
      if rexekutor egrep -q -s "^export *${sed_escaped_key}=" "${filename}"
      then
         return
      fi
   fi

   # if that fails append to end
   local text

   text="\
#
#
#
export ${key}=${value}

"
   redirect_append_exekutor "${filename}" echo "${text}"
}


env_environment_set_main()
{
   log_entry "env_environment_set_main" "$@"

   local scope="$1"; shift
   local key="$1"
   local value="$2"

   [ "$#" -ne 2 ]  && env_environment_usage "wrong number of arguments \"$*\""
   [ -z "${key}" ] && fail "empty key"

   local filename

   case "${scope}" in
      "")
         _env_environment_set "${MULLE_ENV_ETC_DIR}/environment-all.sh" "${key}" "${value}" || exit 1
         shopt -s nullglob
         for i in ${MULLE_ENV_ETC_DIR}/environment-os-*.sh \
                  ${MULLE_ENV_ETC_DIR}/environment-host-*.sh \
                  ${MULLE_ENV_ETC_DIR}/environment-user-*.sh
         do
            shopt +s nullglob
            _env_environment_set "$i" "${key}" ""
         done
         shopt +s nullglob
      ;;

      *)
         _env_environment_set "${MULLE_ENV_ETC_DIR}/environment-${scope}.sh" "${key}" "${value}"
      ;;
   esac
}


#
# Get
#
_env_environment_get()
{
   log_entry "_env_environment_get" "$@"

   local filename="$1"

   if [ -f "${filename}" ]
   then
      log_verbose "Reading ${C_RESET_BOLD}${filename}"

      rexekutor sed -n 's/^ *export *//p' "${filename}" | \
      rexekutor awk -F '=' "{ value[ \$1] = \$2 };END{ value[ \"${key}\"] }"
   else
      log_fluff "\"${filename}\" does not exist"
   fi
}


_env_environment_eval_get()
{
   log_entry "_env_environment_eval_get" "$@"

   local filename="$1"
   local key="$2"

   if [ -f "${filename}" ]
   then
      log_verbose "Reading ${C_RESET_BOLD}${filename}"

      rexekutor env -i bash -c ". '${filename}' ; echo \$${key}"
   else
      log_fluff "\"${filename}\" does not exist"
   fi
}


_env_environment_get_main()
{
   log_entry "_env_environment_get_main" "$@"

   local getter="$1"; shift
   local scope="$1"; shift
   local key="$1"

   [ "$#" -ne 1 ]  && env_environment_usage "wrong number of arguments \"$*\""
   [ -z "${key}" ] && fail "empty key"

   case "${scope}" in
      "")
         if ${getter} "${MULLE_ENV_ETC_DIR}/environment-user-${USER}.sh" "${key}"
         then
            return
         fi
         if ${getter} "${MULLE_ENV_ETC_DIR}/environment-host-`hostname`.sh" "${key}"
         then
            return
         fi
         if ${getter} "${MULLE_ENV_ETC_DIR}/environment-os-${MULLE_UNAME}.sh" "${key}"
         then
            return
         fi
         if ${getter} "${MULLE_ENV_ETC_DIR}/environment-all.sh" "${key}"
         then
            return
         fi
      ;;

      *)
         _env_environment_get "${MULLE_ENV_ETC_DIR}/environment-${scope}.sh" "${key}"
      ;;
   esac
}


env_environment_eval_get_main()
{
   log_entry "env_environment_eval_get_main" "$@"

   _env_environment_get_main "_env_environment_eval_get" "$@"
}


env_environment_get_main()
{
   log_entry "env_environment_get_main" "$@"

   _env_environment_get_main "_env_environment_get" "$@"
}


#
# List
#

__env_environment_list_text()
{
   rexekutor sed -n 's/^ *export *//p' <<< "${1}" | \
   rexekutor awk -F '=' '{ value[ $1] = $2 };END{for(i in value) print i "=" value[i]}' | \
   rexekutor sort
}

__env_environment_list()
{
   rexekutor sed -n 's/^ *export *//p' "${1}" | \
   rexekutor awk -F '=' '{ value[ $1] = $2 };END{for(i in value) print i "=" value[i]}' | \
   rexekutor sort
}

_env_environment_combined_list()
{
   log_entry "_env_environment_combined_list" "$@"

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

   __env_environment_list_text "${text}"
}


_env_environment_list()
{
   log_entry "_env_environment_list" "$@"

   while [ "$#" -ne 0 ]
   do
      if [ -f "$1" ]
      then
         log_info "${C_RESET_BOLD}`fast_basename "$1"`:"

         __env_environment_list "$1"
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

   cmdline="env -i bash -c '"
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
   reval_exekutor "${cmdline}" | rexekutor sed -e '/^PWD=/d' \
                                               -e '/^_=/d' \
                                               -e '/^SHLVL=/d'
}

_env_environment_list_main()
{
   log_entry "_env_environment_list_main" "$@"

   local lister="$1"; shift
   local scope="$1"; shift

   [ "$#" -ne 0 ] && env_environment_usage "wrong number of arguments \"$*\""

   log_info "Environment"

   case "${scope}" in
      "separate")
         "${lister}" "${MULLE_ENV_ETC_DIR}/environment-all.sh"
         "${lister}" "${MULLE_ENV_ETC_DIR}/environment-os-${MULLE_UNAME}.sh"
         "${lister}" "${MULLE_ENV_ETC_DIR}/environment-host-`hostname`.sh"
         "${lister}" "${MULLE_ENV_ETC_DIR}/environment-user-${USER}.sh"
      ;;

      *)
         "${lister}" "${MULLE_ENV_ETC_DIR}/environment-${scope}.sh"
      ;;
   esac
}


env_environment_eval_list_main()
{
   log_entry "env_environment_eval_list_main" "$@"

   _env_environment_list_main "_env_environment_eval_list" "$@"
}


env_environment_list_main()
{
   log_entry "env_environment_list_main" "$@"

   _env_environment_list_main "_env_environment_list" "$@"
}


env_environment_combined_list_main()
{
   log_entry "env_environment_combined_list_main" "$@"

   [ "$#" -ne 0 ] && env_environment_usage "wrong number of arguments \"$*\""

   log_info "Environment"

   _env_environment_combined_list "${MULLE_ENV_ETC_DIR}/environment-all.sh" \
            "${MULLE_ENV_ETC_DIR}/environment-os-${MULLE_UNAME}.sh" \
            "${MULLE_ENV_ETC_DIR}/environment-host-`hostname`.sh" \
            "${MULLE_ENV_ETC_DIR}/environment-user-${USER}.sh"
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

   local OPTION_SCOPE
   local infix="_"

   #
   # handle options
   #
   while :
   do
      case "$1" in
         -h|--help)
            sde_extension_usage
         ;;

         --all|--hostname-*|--user-*|--os-*|--separate)
            [ ! -z "${OPTION_SCOPE}" ] && log_fail "scope already specified"

            OPTION_SCOPE="${1:2}"
         ;;

         --hostname)
            [ ! -z "${OPTION_SCOPE}" ] && log_fail "scope already specified"

            OPTION_SCOPE="host-`hostname`"
         ;;

         --user)
            [ ! -z "${OPTION_SCOPE}" ] && log_fail "scope already specified"

            OPTION_SCOPE="user-${USER}"
         ;;

         --os)
            [ ! -z "${OPTION_SCOPE}" ] && log_fail "scope already specified"

            OPTION_SCOPE="os-${MULLE_UNAME}"
         ;;


         --output-eval)
            infix="_eval_"
         ;;

         -*)
            sde_extension_usage
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
         env_environment${infix}get_main "${OPTION_SCOPE}" "$@"
      ;;

      list)
         if [ -z "${OPTION_SCOPE}" ]
         then
            env_environment_combined_list_main "$@"
         else
            env_environment${infix}list_main "${OPTION_SCOPE}" "$@"
         fi
      ;;

      set)
         env_environment_set_main "${OPTION_SCOPE}" "$@"
      ;;

      "")
         env_environment_usage
      ;;

      *)
         env_environment_usage "unknown command \"${cmd}\""
      ;;
   esac
}

