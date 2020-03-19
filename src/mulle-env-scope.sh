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
MULLE_ENV_SCOPE_SH="included"



#
#
#
env_scope_usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} scope [options] [command]*

   Manage environment scopes. This adds an environment file to the set of files
   you can manage with the \`environment\` command.
   You will rarely need this though.

Options:
   -h      : show this usage

Commands:
   list    : list scopes
   add     : add a scope
   remove  : remove a scope
EOF

   exit 1
}


env_scope_add_usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} scope add [options] <scope>

   A scope name must be unique. If you add a scope that is not known to any
   extensions or mulle-env itself, the respective environment file will not
   automatically read on entry to the virtual environment.

   You need to include it respective environment-<scope>.h yourself. The place to do this is in
   your environment-custom.sh file.


Options:
   --share          : make this an upgradable, not user editable scope
   --etc            : make this a user editable scope (default)
   --priority <nr>  : give this scope a priority, which can be used for sorting (200)
EOF
   exit 1
}


env_scope_get_usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} scope get [options] <scope>

   Retrieve a scope.

Options:
   --prefix         : also return the internal prefix
   --quiet          : only return the status, no output
   --aux-only       : only list non-builtin scopes
EOF
   exit 1
}


env_scope_remove_usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} scope remove [options] <scope>

   Remove a scope.

Options:
   -h               : show this usage
EOF
   exit 1
}



env_scope_list_usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} environment list [options]

   Show currently known scopes.

Options:

EOF
   exit 1
}


r_read_auxscope_file()
{
   log_entry "r_read_auxscope_file" "$@"

   local auxscopefile="$1"
   local prefix="$2"

   if [ ! -f "${auxscopefile}" ]
   then
      log_debug "No auxscope file found"
      RVAL=
      return 1
   fi

   # eval it to resolve USER and so on
   local tmp
   local aux_scope

   tmp="`rexekutor egrep -v '^#' "${auxscopefile}"`"

   RVAL=

   local aux_scope
   local order

   order=100
   set -f; IFS=$'\n'
   for aux_scope in ${tmp}
   do
      IFS="${DEFAULT_IFS}"; set +f

      if [ ! -z "${aux_scope}" ]
      then
         case "${aux_scope}" in
            *\;*)
            ;;

            *)
               fail "old style aux scope file w/o priority (need to upgrade)"
            ;;
         esac

         case "${aux_scope}" in
            *\:*)
               fail "old style scope file with prefix (need to upgrade)"
            ;;

            *)
               aux_scope="${prefix}:${aux_scope}"
            ;;
         esac

         r_add_line "${RVAL}" "${aux_scope}"
      fi
   done
   IFS="${DEFAULT_IFS}"; set +f

}


# Typical include oder is this, so let priority reflect this
# Also make rightt odd tenners, and left even tenners
#
# -----|---------------------------------------|--------------------
#  10  |                                       | environment-plugin.sh
#  15  |                                       | environment-plugin-os-\${MULLE_UNAME}.sh
#  20  | environment-project.sh                |
#  30  |                                       | environment-extension.sh
#  40  | environment-global.sh                 |
#  60  | environment-os-${MULLE_UNAME}.sh      |
#  80  | environment-host-${MULLE_HOSTNAME}.sh |
#  100 | environment-user-${USER}.sh           |
#
r_priority_for_scope()
{
   log_entry "r_priority_for_scope" "$@"

   local scope="$1"

   case "${scope}" in
      *:*)
         internal_fail "Need unprefixed scope"
      ;;
   esac

   case "${scope}" in
      'plugin')
         RVAL=10
         return 0
      ;;

      'plugin-os-'*)
         RVAL=15
         return 0
      ;;

      'global'*)
         RVAL=40
         return 0
      ;;

      'os-'*)
         RVAL=60
         return 0
      ;;

      'host-'*)
         RVAL=80
         return 0
      ;;

      'user-'*)
         RVAL=100
         return 0
      ;;
   esac

   RVAL=""
   return 4 # unknown
}


csv_field_1_by_sorting_numeric_field_2()
{
   sort -t';' -k2 -n <<< "${1}" | sed -e '/^$/d' -e 's/\(.*\);.*/\1/'
}


r_get_scopes()
{
   log_entry "r_get_scopes" "$@"

   local option_plugin="${1:-YES}"
   local option_share_aux="${2:-YES}"
   local option_user="${3:-YES}"
   local option_etc_aux="${4:-YES}"

   local etc_scopes
   local share_scopes
   local aux_scopes

   if [ "${option_plugin}" = 'YES' ]
   then
      share_scopes="s:plugin;10
s:plugin-os-${MULLE_UNAME};15"
   fi

   if [ "${option_share_aux}" = 'YES' ]
   then
      r_read_auxscope_file "${MULLE_ENV_SHARE_DIR}/auxscope" "s"
      r_add_line "${share_scopes}" "${RVAL}"
      share_scopes="${RVAL}"
   fi

   #
   # os is special and may appear in etc and share
   #
   if [ "${option_user}" = 'YES' ]
   then
      etc_scopes="e:global;40
e:os-${MULLE_UNAME};60
e:host-${MULLE_HOSTNAME};80
e:user-${USER};100"
   fi

   if [ "${option_etc_aux}" = 'YES' ]
   then
      r_read_auxscope_file "${MULLE_ENV_ETC_DIR}/auxscope" "e"
      r_add_line "${etc_scopes}" "${RVAL}"
      etc_scopes="${RVAL}"
   fi

   #
   # get them properly sorted
   #
   r_add_line "${share_scopes}" "${etc_scopes}"
   RVAL="`csv_field_1_by_sorting_numeric_field_2 "${RVAL}"`"
   log_debug "scopes: ${RVAL}"
}


r_directory_for_scopeprefix()
{
   log_entry "r_directory_for_scopeprefix" "$@"

   local prefix="$1"

   RVAL="${MULLE_ENV_ETC_DIR}"
   if [ "${prefix:0:1}" = "s" ]
   then
      RVAL="${MULLE_ENV_SHARE_DIR}"
   fi
}


r_scopeprefix_for_scope()
{
   log_entry "r_scopeprefix_for_scope" "$@"

   local scope="$1"

   local scopes

   r_get_scopes
   scopes="${RVAL}"
   RVAL=""

   local i

   set -f; IFS=$'\n'
   for i in ${scopes}
   do
      IFS="${DEFAULT_IFS}"; set +f

      if [ "${i:2}" = "${scope}" ]
      then
         RVAL="${i:0:1}" # continue, get last one (why ?)
      fi
   done
   IFS="${DEFAULT_IFS}"; set +f

   [ ! -z "${RVAL}" ]
}


r_get_existing_scope_files()
{
   log_entry "r_get_existing_scope_files" "$@"

   local OPTION_INFERIORS='NO'
   local OPTION_REVERSE='NO'

   while :
   do
      case "$1" in
         --with-inferiors)
            OPTION_INFERIORS='YES'
         ;;

         --reverse)
            OPTION_REVERSE='YES'
         ;;

         *)
            break
         ;;
      esac
      shift
   done

   local searchscope

   searchscope="$1"

   local scopes

   r_get_scopes
   scopes="${RVAL}"

   local scope
   local scopename
   local filename
   local skipcheck
   local filenames

   filenames=""
   skipcheck='NO'

   set -f; IFS=$'\n'
   for scope in ${scopes}
   do
      IFS="${DEFAULT_IFS}"; set +f

      scopename="${scope:2}"
      if [ "${skipcheck}" = 'NO' ] && \
         [ "${searchscope}" != "DEFAULT" -a "${scopename}" != "${searchscope}" ]
      then
         log_debug "\"${searchscope}\" and  \"${scopename}\" don't match"
         continue
      fi

      skipcheck="${OPTION_INFERIORS}"
      case "${scope}" in
         's:'*)
            filename="${MULLE_ENV_SHARE_DIR}/environment-${scopename}.sh"
         ;;

         'e:'*)
            filename="${MULLE_ENV_ETC_DIR}/environment-${scopename}.sh"
         ;;

         *)
            internal_fail "invalid scope \"${scope}\""
         ;;
      esac

      if [ -f "${filename}" ]
      then
         log_debug "\"${filename}\" for \"${scope}\" exists"
         if [ "${OPTION_REVERSE}" = 'YES' ]
         then
            r_add_line "${filename}" "${filenames}"
         else
            r_add_line "${filenames}" "${filename}"
         fi
         filenames="${RVAL}"
      else
         log_fluff "\"${filename}\" for \"${scope}\" does not exist"
      fi
   done
   IFS="${DEFAULT_IFS}"; set +f

   log_debug "filenames: ${filenames}"
   RVAL="${filenames}"
}


env_scope_list_main()
{
   log_entry "env_scope_list_main" "$@"

   local OPTION_OUTPUT_FILENAME='NO'
   local OPTION_EXISTING='NO'
   local OPTION_USER_SCOPES='YES'
   local OPTION_SHARE_AUX_SCOPES='NO'
   local OPTION_ETC_AUX_SCOPES='YES'
   local OPTION_PLUGIN_SCOPES='NO'
   local OPTION_EXISTING_FILENAME='NO'

   while :
   do
      case "$1" in
         -h|--help|help)
            env_scope_scope_usage
         ;;

         --all)
            OPTION_ETC_AUX_SCOPES='YES'
            OPTION_SHARE_AUX_SCOPES='YES'
            OPTION_PLUGIN_SCOPES='YES'
            OPTION_USER_SCOPES='YES'
         ;;

         --output-filename)
            OPTION_OUTPUT_FILENAME='YES'
         ;;

         --output-existing-filename)
            OPTION_EXISTING_FILENAME='YES'
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

         --etc-aux)
            OPTION_ETC_AUX_SCOPES='YES'
         ;;

         --no-etc-aux)
            OPTION_ETC_AUX_SCOPES='NO'
         ;;

         --share-aux)
            OPTION_SHARE_AUX_SCOPES='YES'
         ;;

         --no-share-aux)
            OPTION_SHARE_AUX_SCOPES='NO'
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
            env_scope_scope_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   [ "$#" -eq 0 ] || env_scope_scope_usage "Superflous arguments \"$*\""

   [ -z "${MULLE_ENV_SHARE_DIR}" ]   && internal_fail "MULLE_ENV_SHARE_DIR is empty"
   [ ! -d "${MULLE_ENV_SHARE_DIR}" ] && fail "mulle-env init hasn't run in $PWD yet (\"$MULLE_ENV_SHARE_DIR\" not found)"

   if [ "${OPTION_EXISTING}" = 'YES' ]
   then
      (
         shopt -s nullglob

         rexekutor ls -1 "${MULLE_ENV_SHARE_DIR}"/environment-*.sh \
                         "${MULLE_ENV_ETC_DIR}"/environment-*.sh \
            | sed '-e s|^.*/environment-\(.*\)\.sh$|\1|'
      ) | LC_ALL=C sort -u | sed -e '/^include/d'

      return 0
   fi

   local scopes

   r_get_scopes "${OPTION_PLUGIN_SCOPES}" \
                "${OPTION_SHARE_AUX_SCOPES}" \
                "${OPTION_USER_SCOPES}" \
                "${OPTION_ETC_AUX_SCOPES}"

   scopes="${RVAL}"

   if [ -z "${scopes}" ]
   then
      fail "No scopes selected"
   fi

   if [ "${OPTION_USER_SCOPES}" = 'YES' -a \
        "${OPTION_ETC_AUX_SCOPES}" = 'YES' -a \
        "${OPTION_PLUGIN_SCOPES}" = 'NO' -a \
        "${OPTION_SHARE_AUX_SCOPES}" = 'NO' ]
   then
      log_info "User Scopes"
   else
      if [ "${OPTION_SHARE_AUX_SCOPES}" = 'YES' -a \
           "${OPTION_ETC_AUX_SCOPES}" = 'YES' -a \
           "${OPTION_PLUGIN_SCOPES}" = 'YES' -a \
           "${OPTION_USER_SCOPES}" = 'YES' ]
      then
         log_info "All Scopes"
      else
         log_info "Partial Scopes"
      fi
   fi

   local scopename
   local scope
   local filename

   set -f
   IFS=$'\n'
   for scope in ${scopes}
   do
      IFS="${DEFAULT_IFS}"
      filename=
      scopename="${scope:2}"

      if [ "${OPTION_OUTPUT_FILENAME}" = 'YES' ]
      then
         case "${scope}" in
            'e:'*)
               filename="${MULLE_ENV_ETC_DIR}/environment-${scopename}.sh"
            ;;

            's:'*)
               filename="${MULLE_ENV_SHARE_DIR}/environment-${scopename}.sh"
            ;;
         esac

         log_debug "scopename: ${scopename}"
         log_debug "filename : ${filename}"
         log_debug "scope    : ${scope}"

         if [ "${OPTION_EXISTING_FILENAME}" = 'YES' -a ! -f "${filename}" ]
         then
            filename=""
         fi
      fi

      concat "${scopename}" "${filename#${MULLE_USER_PWD}/}" ";"
   done

   IFS="${DEFAULT_IFS}"
   set +f

   return 0
}


env_scope_get_main()
{
   log_entry "env_scope_get_main" "$@"

   local OPTION_AUX_ONLY='NO'
   local OPTION_QUIET='NO'
   local OPTION_PREFIX='NO'

   while :
   do
      case "$1" in
         -h|--help|help)
            env_scope_get_usage
         ;;

         --prefix)
            OPTION_PREFIX='YES'
         ;;

         -q|--quiet)
            OPTION_QUIET='YES'
         ;;

         --aux-only)
            OPTION_AUX_ONLY='YES'
         ;;

         -*)
            env_scope_get_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   local name
   [ ! -z "$1"  ] || env_scope_get_usage "Missing scope name"

   name="$1"
   shift

   [ "$#" -eq 0 ] || env_scope_get_usage "Superflous arguments \"$*\""

   local scopes
   local scope
   local protect

   r_get_scopes
   scopes="${RVAL}"

   set -f; IFS=$'\n'
   for scope in ${scopes}
   do
      IFS="${DEFAULT_IFS}"; set +f

      [ -z "${scope}" ] && continue

      if [ "${scope:2}" = "${name}" ]
      then
         if [ "${OPTION_AUX_ONLY}" = 'YES' ]
         then
            case "${scope}" in
               's:'*)
                  filename="${MULLE_ENV_SHARE_DIR}/auxscope"
               ;;
               'e:'*)
                  filename="${MULLE_ENV_ETC_DIR}/auxscope"
               ;;
            esac

            r_escaped_grep_pattern "${scope}"
            if ! rexekutor egrep -q -s "^${RVAL}\;"  "${filename}"
            then
               if [ "${OPTION_QUIET}" = 'NO' ]
               then
                  log_fluff "Scope ${name} not part of auxscope"
               fi
               return 1
            fi
         fi

         if [ "${OPTION_QUIET}" = 'NO' ]
         then
            if [ "${OPTION_PREFIX}" = 'YES' ]
            then
               echo "${scope}"
            else
               echo "${name}"
            fi
         fi
         return 0
      fi
   done
   IFS="${DEFAULT_IFS}"; set +f


   if [ "${OPTION_QUIET}" = 'NO' ]
   then
      log_verbose "Scope ${C_RESET_BOLD}${name}${C_VERBOSE} is unknown"
   fi
   return 1
}


#
# the only way scopes should be generated as it checks for duplicate names
#
env_scope_add_main()
{
   log_entry "env_scope_add_main" "$@"

   local OPTION_IF_MISSING='NO'

   local priority=DEFAULT
   local protect='NO'
   local filename="${MULLE_ENV_ETC_DIR}/auxscope"

   while :
   do
      case "$1" in
         -h|--help|help)
            env_scope_add_usage
         ;;

         --share)
            filename="${MULLE_ENV_SHARE_DIR}/auxscope"
            protect='YES'
         ;;

         --etc)
            filename="${MULLE_ENV_ETC_DIR}/auxscope"
            protect='NO'
         ;;

         --priority)
            [ $# -eq 1 ] && template_usage "Missing argument to \"$1\""
            shift

            priority="$1"
            if [ -z "${priority}" -o ! -z "${priority//[0-9]/}" ]
            then
               fail "priority must be a number"
            fi
         ;;

         --if-missing)
            OPTION_IF_MISSING='YES'
         ;;

         -*)
            env_scope_add_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   local name
   [ ! -z "$1"  ] || env_scope_add_usage "Missing scope name"

   name="$1"
   shift

   [ "$#" -eq 0 ] || env_scope_add_usage "Superflous arguments \"$*\""

   if env_scope_get_main -q "${name}"
   then
      if [ "${OPTION_IF_MISSING}" = 'YES' ]
      then
         return 0
      fi
      fail "Scope \"${name}\" already exists"
   fi

   r_identifier "${name}"
   if [ "${RVAL}" != "${name}" ]
   then
      fail "\"${name}\" is not a valid identifier"
   fi

   case "${name}" in
      'DEFAULT'|'include'|'merged'|'custom')
         fail "\"${name}\" is a non reusable keyword"
      ;;
   esac

   if [ "${priority}" = 'DEFAULT' ]
   then
      if ! r_priority_for_scope "${name}"
      then
         RVAL=200
      fi
      priority="${RVAL}"
   fi

   if [ "${protect}" = 'YES' ]
   then
      unprotect_dir_if_exists "${MULLE_ENV_SHARE_DIR}"
   fi

   r_mkdir_parent_if_missing "${filename}"
   redirect_append_exekutor "${filename}" echo "${name};${priority}" || exit 1

   if [ "${protect}" = 'YES' ]
   then
      unprotect_dir_if_exists "${MULLE_ENV_SHARE_DIR}"
   fi
}


scope_remove_scope()
{
   log_entry "scope_remove_scope" "$@"

   local scope="$1"

   local filename
   local protect

   case "${scope}" in
      's:'*)
         filename="${MULLE_ENV_SHARE_DIR}/auxscope"
         protect="YES"
      ;;
      'e:'*)
         filename="${MULLE_ENV_ETC_DIR}/auxscope"
         protect="NO"
      ;;

      *)
         internal_fail "Malformed scope \"${scope}\""
      ;;
   esac

   r_escaped_grep_pattern "${scope:2}"
   if ! rexekutor egrep -q "^${RVAL}\;"  "${filename}"
   then
      fail "Scope \"$name\" is built-in and can not be deleted"
   fi

   if [ "${protect}" = 'YES' ]
   then
      unprotect_dir_if_exists "${MULLE_ENV_SHARE_DIR}"
   fi

   r_escaped_sed_pattern "${scope:2}"
   inplace_sed -e "/^${RVAL}\;/d" "${filename}" || exit 1

   if [ "${protect}" = 'YES' ]
   then
      unprotect_dir_if_exists "${MULLE_ENV_SHARE_DIR}"
   fi
}


env_scope_remove_main()
{
   log_entry "env_scope_remove_main" "$@"

   local OPTION_IS_EXISTS='NO'

   while :
   do
      case "$1" in
         -h|--help|help)
            env_scope_remove_usage
         ;;


         --if-exists)
            OPTION_IF_EXISTS='YES'
         ;;

         -*)
            env_scope_remove_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   local name
   [ ! -z "$1"  ] || env_scope_remove_usage "Missing scope name"

   name="$1"
   shift

   [ "$#" -eq 0 ] || env_scope_remove_usage "Superflous arguments \"$*\""

   local scopes
   local scope
   local protect

   r_get_scopes
   scopes="${RVAL}"

   set -f; IFS=$'\n'
   for scope in ${scopes}
   do
      IFS="${DEFAULT_IFS}"; set +f

      [ -z "${scope}" ] && continue

      if [ "${scope:2}" = "${name}" ]
      then
         scope_remove_scope "${scope}"
         return 0
      fi
   done
   IFS="${DEFAULT_IFS}"; set +f

   if [ "${OPTION_IF_EXISTS}" = 'YES' ]
   then
      return
   fi


   fail "Scope \"$name\" is unknown"
}


###
### parameters and environment variables
###
env_scope_main()
{
   log_entry "env_scope_main" "$@"

   #
   # handle options
   #
   while :
   do
      case "$1" in
         -h|--help|help)
            env_scope_usage
         ;;

         -*)
            env_scope_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   [ -z "${MULLE_ENV_SHARE_DIR}" ]   && internal_fail "MULLE_ENV_SHARE_DIR is empty"
   [ ! -d "${MULLE_ENV_SHARE_DIR}" ] && fail "mulle-env init hasn't run in $PWD yet (\"$MULLE_ENV_SHARE_DIR\" not found)"

   local cmd="${1:-list}"
   [ $# -ne 0 ] && shift

   case "${cmd}" in
      add|get|remove|list)
         env_scope_${cmd}_main "$@"
      ;;

      *)
         env_scope_usage "unknown command \"${cmd}\""
      ;;
   esac
}
