# shellcheck shell=bash
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
MULLE_ENV_SCOPE_SH='included'


# Internally:
#
# scope        : scopeprefix ':' scopeid
# scopename    : keyword | scopeid
# keyword      : "DEFAULT" | "include" | "merged" | "custom"
# scopeprefix  : 'e' | 's'
# scopeid      : [A-Za-z_-][A-Za-z0-9_-]*
#
# An auxscope file looks pedantically like this:
#
# auxscope     : lines
# lines        : line | line lines
# line         : ( '#' .* | scopeline ) '\n'
# scopeline    : scopeid ';' priority
# priority     : [0-9]+
#
env::scope::usage()
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


env::scope::add_usage()
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


env::scope::get_usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} scope get [options] <scope>

   Retrieve a scope.

Options:
   --prefix   : also return the internal prefix
   --quiet    : only return the status, no output
   --aux-only : only list non-builtin scopes
EOF
   exit 1
}


env::scope::remove_usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} scope remove [options] <scope>

   Remove a scope.

Options:
   -h : show this usage
EOF
   exit 1
}


env::scope::file_usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} scope file [options] <scope>

   Print path to environment file of given scope.

Options:
   -h : show this usage
EOF
   exit 1
}


env::scope::list_usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} scope list [options]

   Show currently known scopes.

Options:
   --all                      : show all scopes
   --existing                 : list only existing/used scopes
   --output-filename          : show file for scope
   --output-existing-filename : show file for scope, only if it exists
   --[no-]aux                 : list auxiliary scopes
   --[no-]etc-aux             : list custom auxiliary scopes
   --[no-]hardcoded           : list hardcoded scopes
   --[no-]share-aux           : list predefined auxiliary scopes
   --[no-]plugin              : list plugin scopes
   --[no-]user                : list user scopes
   --sort                     : sort output

EOF
   exit 1
}


env::scope::is_scopeid()
{
   local scopeid="$1"

   if [ ! -z "${scopeid}" ]
   then
      local firstchar

      firstchar="${scopeid:0:1}"
      if [ -z "${firstchar//[A-Za-z_-]/}" -a -z "${scopeid//[A-Z0-9a-z_-]/}" ]
      then
         return 0
      fi
   fi

   return 1
}


env::scope::is_priority()
{
   local priority="$1"

   [ ! -z "${priority}" -a -z "${priority//[0-9]/}" ]
}


env::scope::is_keyword()
{
   local scopeid="$1"

   case "${scopeid}" in
      'DEFAULT'|'include'|'merged'|'custom')
         return 0
      ;;
   esac

   return 1
}


env::scope::r_read_auxscope_file()
{
   log_entry "env::scope::r_read_auxscope_file" "$@"

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

   tmp="`rexekutor grep -E -v '^#' "${auxscopefile}"`"

   local aux_scope
   local result 

   .foreachline aux_scope in ${tmp}
   .do
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

         r_add_line "${result}" "${aux_scope}"
         result="${RVAL}"
      fi
   .done

   RVAL="${result}"
}


# Typical include order is this, so let priority reflect this. But except for
# the ordering, the value is meaningless. Also the range 40-200 is hard coded
# unfortunately.
# Also make right odd tenners, and left even tenners
#
# -----|---------------------------------------|--------------------
#   1  |                                       | <hardcoded>
#  10  |                                       | environment-plugin.sh
#  15  |                                       | environment-plugin-os-\${MULLE_UNAME}.sh
#  20  | environment-project.sh                |
#  30  |                                       | environment-extension.sh
#  40  | environment-global.sh                 |
#  60  | environment-os-${MULLE_UNAME}.sh      |
#  80  | environment-host-${MULLE_HOSTNAME}.sh |
#  100 | environment-user-${MULLE_USERNAME}.sh |
#  210 |                                       | environment-post-extension.sh
# 1000 | environment-post-global.sh            |

env::scope::r_priority_for_scopeid()
{
   log_entry "env::scope::r_priority_for_scopeid" "$@"

   local scopeid="$1"

   case "${scopeid}" in
      *:*)
         _internal_fail "Need unprefixed scope"
      ;;
   esac

   case "${scopeid}" in
      'hardcoded')
         RVAL=1
         return 0
      ;;

      'plugin')
         RVAL=5
         return 0
      ;;

      'plugin-os-'*)
         RVAL=15
         return 0
      ;;

      # strictly speaking these two should not be hardcoded here
      'project')
         RVAL=20
         return 0
      ;;

      'extension')
         RVAL=30
         return 0
      ;;

      'global')
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

      'user-'*'-os-'*)
         RVAL=120
         return 0
      ;;

      'user-'*'-host-'*)
         RVAL=140
         return 0
      ;;

      'user-'*)
         RVAL=100
         return 0
      ;;

      # strictly speaking these two should not be hardcoded here
      'post-extension')
         RVAL=170
         return 0
      ;;

      'post-global')
         RVAL=180
         return 0
      ;;
   esac

   RVAL=""
   return 4 # unknown
}


env::scope::csv_field_1_by_sorting_numeric_field_2()
{
   case "${MULLE_UNAME}" in 
      netbsd)
         LC_ALL=C sort -t';' -k2n <<< "${1}" | sed -e '/^$/d' -e 's/\(.*\);.*/\1/'
      ;;

      *)
         LC_ALL=C sort -t';' -k2 -n <<< "${1}" | sed -e '/^$/d' -e 's/\(.*\);.*/\1/'
      ;;
   esac
}


env::scope::r_get_scopes()
{
   log_entry "env::scope::r_get_scopes" "$@"

   local option_plugin="${1:-YES}"
   local option_share_aux="${2:-YES}"
   local option_user="${3:-YES}"
   local option_etc_aux="${4:-YES}"
   local option_hardcoded="${5:-NO}"

   local etc_scopes
   local share_scopes
   local aux_scopes

   if [ "${option_hardcoded}" = 'YES' ]
   then
      share_scopes="h:hardcoded;1"
   fi

   if [ "${option_plugin}" = 'YES' ]
   then
      r_add_line "${share_scopes}" "s:plugin;10"
      r_add_line "${RVAL}" "s:plugin-os-${MULLE_UNAME};15"
      share_scopes="${RVAL}"
   fi

   if [ "${option_share_aux}" = 'YES' ]
   then
      env::scope::r_read_auxscope_file "${MULLE_ENV_SHARE_DIR}/auxscope" "s"
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
e:user-${MULLE_USERNAME};100
e:post-global;1000"
   fi

   if [ "${option_etc_aux}" = 'YES' ]
   then
      env::scope::r_read_auxscope_file "${MULLE_ENV_ETC_DIR}/auxscope" "e"
      r_add_line "${etc_scopes}" "${RVAL}"
      etc_scopes="${RVAL}"
   fi

   #
   # get them properly sorted
   #
   r_add_line "${share_scopes}" "${etc_scopes}"
   RVAL="`env::scope::csv_field_1_by_sorting_numeric_field_2 "${RVAL}"`"
   log_debug "scopes: ${RVAL}"
}


env::scope::is_known_scopeid()
{
   log_entry "env::scope::is_known_scopeid" "$@"

   local scopeid="$1"

   local scopes
   local scope
   local protect

   env::scope::r_get_scopes
   scopes="${RVAL}"

   .foreachline scope in ${scopes}
   .do
      if [ "${scope:2}" = "${scopeid}" ]
      then
         return 0
      fi
   .done

   return 1
}


env::scope::r_scopeprefix_for_scopeid()
{
   log_entry "env::scope::r_scopeprefix_for_scopeid" "$@"

   local scopeid="$1"

   case "${scopeid}" in
      *:*)
         _internal_fail "Need unprefixed scope"
      ;;

     host-*|os-*|user-*)
         RVAL="e"
         return
      ;;
   esac

   local scopes

   env::scope::r_get_scopes 'YES' 'YES' 'YES' 'YES' 'YES'
   scopes="${RVAL}"
   RVAL=""

   local i

   .foreachline i in ${scopes}
   .do
      if [ "${i:2}" = "${scopeid}" ]
      then
         RVAL="${i:0:1}" # continue, get last one (why ?)
      fi
   .done

   [ ! -z "${RVAL}" ]
}


env::scope::r_subdir_for_scopeid()
{
   log_entry "env::scope::r_subdir_for_scopeid" "$@"

   local scopeid="$1"

   # check OPTION_SCOPE_SUBDIRS to possibly
   log_debug "OPTION_SCOPE_SUBDIRS=${OPTION_SCOPE_SUBDIRS}"

   local line

   RVAL=
   .foreachline line in ${OPTION_SCOPE_SUBDIRS}
   .do
      case "${line}" in
         ${scopeid}=*)
            RVAL="${line#${scopeid}=}"
            log_debug "scopeid \${scopeid}\" in subdir \"${RVAL}\""
            return
         ;;
      esac
   .done
}


env::scope::r_filename_for_scopeprefix_scopeid()
{
   log_entry "env::scope::r_filename_for_scopeprefix_scopeid" "$@"

   local scopeprefix="$1"
   local scopeid="$2"

   local filepath

   case "${scopeprefix}" in
      'h'*)
         RVAL="none"
         return
      ;;

      's'*)
         filepath="${MULLE_ENV_SHARE_DIR}"
      ;;

      'e'*)
         filepath="${MULLE_ENV_ETC_DIR}"
      ;;

      *)
         _internal_fail "invalid scopeprefix \"${scopeprefix}\""
      ;;
   esac

   local subdir

   env::scope::r_subdir_for_scopeid "${scopeid}"
   subdir="${RVAL}"

   r_filepath_concat "${filepath}" "${subdir}"
   filepath="${RVAL}"

   r_filepath_concat "${filepath}" "environment-${scopeid}.sh"
}


env::scope::r_filename_for_scope()
{
   log_entry "env::scope::r_filename_for_scope" "$@"

   local scope="$1"

   case "${scope}" in
      *:*)
      ;;

      *)
         _internal_fail "Need prefixed scope"
      ;;
   esac

   env::scope::r_filename_for_scopeprefix_scopeid "${scope:0:1}" "${scope:2}"
}


env::scope::r_filename_for_scopeid()
{
   log_entry "env::scope::r_filename_for_scopeid" "$@"

   local scopeid="$1"

   if ! env::scope::r_scopeprefix_for_scopeid "${scopeid}"
   then
      return 1
   fi
   env::scope::r_filename_for_scopeprefix_scopeid "${RVAL}" "${scopeid}"
}


env::scope::r_get_existing_scope_files()
{
   log_entry "env::scope::r_get_existing_scope_files" "$@"

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

   local search_scopename

   search_scopename="$1"

   [ -z "${search_scopename}" ] && _internal_fail "empty search scope"

   local scopes

   env::scope::r_get_scopes
   scopes="${RVAL}"

   local scope
   local scopeid
   local filename
   local skipcheck
   local filenames

   filenames=""
   skipcheck='NO'

   .foreachline scope in ${scopes}
   .do
      scopeid="${scope:2}"
      if [ "${skipcheck}" = 'NO' ] && \
         [ "${search_scopename}" != "DEFAULT" -a "${scopeid}" != "${search_scopename}" ]
      then
         log_debug "\"${search_scopename}\" and  \"${scopeid}\" don't match"
         .continue
      fi
      skipcheck="${OPTION_INFERIORS}"

      env::scope::r_filename_for_scope "${scope}"
      filename="${RVAL}"

      if [ -f "${filename}" ]
      then
         log_debug "\"${filename}\" for \"${scopeid}\" exists"
         if [ "${OPTION_REVERSE}" = 'YES' ]
         then
            r_add_line "${filename}" "${filenames}"
         else
            r_add_line "${filenames}" "${filename}"
         fi
         filenames="${RVAL}"
      else
         log_fluff "\"${filename}\" for \"${scopeid}\" does not exist"
      fi
   .done

   log_debug "filenames: ${filenames}"
   RVAL="${filenames}"
}


env::scope::env_validate_scope_write()
{
   log_entry "env::scope::env_validate_scope_write" "$@"

   local scope="$1"; shift

   local scopes
   local line

   env::scope::r_get_scopes 'YES' 'YES' 'YES' 'YES' 'YES'
   scopes="${RVAL}"

   .foreachline line in ${scopes}
   .do
      case "${line:0:1}" in
         's')
            if [ "${line:2}" = "${scope}" ]
            then
               fail "Use -f to make environment variable changes, that would be lost in the next upgrade.
${C_INFO}Hint:${C_VERBOSE} Consider clobbering the value with the global scope instead."
            fi
         ;;

         'h')
            if [ "${line:2}" = "${scope}" ]
            then
               fail "Changing hardcoded values is not possible. Use a different scope to override. ($*)"
            fi
         ;;
      esac
   .done
}


env::scope::list_main()
{
   log_entry "env::scope::list_main" "$@"

   local OPTION_OUTPUT_FILENAME='NO'
   local OPTION_EXISTING='NO'
   local OPTION_USER_SCOPES='YES'
   local OPTION_SHARE_AUX_SCOPES='NO'
   local OPTION_ETC_AUX_SCOPES='YES'
   local OPTION_PLUGIN_SCOPES='NO'
   local OPTION_HARDCODED_SCOPES='NO'
   local OPTION_EXISTING_FILENAME='NO'

   local MULLE_ENV_CONTENT_SORT=cat

   while :
   do
      case "$1" in
         -h|--help|help)
            env::scope::list_usage
         ;;

         -a|--all)
            OPTION_ETC_AUX_SCOPES='YES'
            OPTION_SHARE_AUX_SCOPES='YES'
            OPTION_PLUGIN_SCOPES='YES'
            OPTION_USER_SCOPES='YES'
            OPTION_HARDCODED_SCOPES='YES'
         ;;

         --output-filename)
            OPTION_OUTPUT_FILENAME='YES'
         ;;

         --output-existing-filename)
            OPTION_EXISTING_FILENAME='YES'
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

         --existing)
            OPTION_EXISTING='YES'
         ;;

         --hardcoded)
            OPTION_HARDCODED_SCOPES='YES'
         ;;

         --no-hardcoded)
            OPTION_HARDCODED_SCOPES='NO'
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

         --sort)
            MULLE_ENV_CONTENT_SORT='sort'
         ;;

         -*)
            env::scope::list_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   [ "$#" -eq 0 ] || env::scope::list_usage "Superflous arguments \"$*\""

   [ -z "${MULLE_ENV_SHARE_DIR}" ]   && _internal_fail "MULLE_ENV_SHARE_DIR is empty"
   [ ! -d "${MULLE_ENV_SHARE_DIR}" ] && fail "mulle-env init hasn't run in $PWD yet (\"$MULLE_ENV_SHARE_DIR\" not found)"

   if [ "${OPTION_EXISTING}" = 'YES' ]
   then
      (
         shell_enable_nullglob

         rexekutor ls -1 "${MULLE_ENV_SHARE_DIR}"/environment-*.sh \
                         "${MULLE_ENV_ETC_DIR}"/environment-*.sh \
            | sed '-e s|^.*/environment-\(.*\)\.sh$|\1|'
      ) | LC_ALL=C ${MULLE_ENV_CONTENT_SORT} -u | sed -e '/^include/d'

      return 0
   fi

   local scopes

   env::scope::r_get_scopes "${OPTION_PLUGIN_SCOPES}" \
                            "${OPTION_SHARE_AUX_SCOPES}" \
                            "${OPTION_USER_SCOPES}" \
                            "${OPTION_ETC_AUX_SCOPES}" \
                            "${OPTION_HARDCODED_SCOPES}"

   scopes="${RVAL}"

   if [ -z "${scopes}" ]
   then
      fail "No scopes selected"
   fi

   if [ "${OPTION_USER_SCOPES}" = 'YES' -a \
        "${OPTION_ETC_AUX_SCOPES}" = 'YES' -a \
        "${OPTION_PLUGIN_SCOPES}" = 'NO' -a \
        "${OPTION_SHARE_AUX_SCOPES}" = 'NO' -a \
        "${OPTION_HARDCODED_SCOPES}" = 'NO' ]
   then
      log_info "User Scopes"
   else
      if [ "${OPTION_SHARE_AUX_SCOPES}" = 'YES' -a \
           "${OPTION_ETC_AUX_SCOPES}" = 'YES' -a \
           "${OPTION_PLUGIN_SCOPES}" = 'YES' -a \
           "${OPTION_USER_SCOPES}" = 'YES' -a \
           "${OPTION_HARDCODED_SCOPES}" = 'YES' ]
      then
         log_info "All Scopes"
      else
         log_info "Partial Scopes"
      fi
   fi

   local scopeid
   local scope
   local filename

   .foreachline scope in ${scopes}
   .do
      filename=
      scopeid="${scope:2}"

      if [ "${OPTION_OUTPUT_FILENAME}" = 'YES' ]
      then
         env::scope::r_filename_for_scope "${scope}"
         filename="${RVAL}"

         log_debug "scopeid  : ${scopeid}"
         log_debug "filename : ${filename}"
         log_debug "scope    : ${scope}"

         if [ "${OPTION_EXISTING_FILENAME}" = 'YES' -a ! -f "${filename}" ]
         then
            filename=""
         fi
      fi

      r_concat "${scopeid}" "${filename#"${MULLE_USER_PWD}/"}" ";"
      printf "%s\n" "${RVAL}"
   .done

   return 0
}


env::scope::get_main()
{
   log_entry "env::scope::get_main" "$@"

   local OPTION_AUX_ONLY='NO'
   local OPTION_QUIET='NO'
   local OPTION_PREFIX='NO'

   while :
   do
      case "$1" in
         -h|--help|help)
            env::scope::get_usage
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
            env::scope::get_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   local search_scopeid
   [ ! -z "$1"  ] || env::scope::get_usage "Missing scope identifier"

   search_scopeid="$1"
   shift

   [ "$#" -eq 0 ] || env::scope::get_usage "Superflous arguments \"$*\""

   local scopes
   local scope
   local scopeid
   local protect

   env::scope::r_get_scopes
   scopes="${RVAL}"

   .foreachline scope in ${scopes}
   .do
      [ -z "${scope}" ] && .continue

      scopeid="${scope:2}"
      if [ "${scopeid}" = "${search_scopeid}" ]
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

               'h:'*)
                  fail "Hardcoded values can't be read from a file"
               ;;
            esac

            r_escaped_grep_pattern "${scopeid}"
            if ! rexekutor grep -E -q -s "^${RVAL}\;"  "${filename}"
            then
               if [ "${OPTION_QUIET}" = 'NO' ]
               then
                  log_fluff "Scope ${scopeid} not part of auxscope"
               fi
               return 1
            fi
         fi

         if [ "${OPTION_QUIET}" = 'NO' ]
         then
            if [ "${OPTION_PREFIX}" = 'YES' ]
            then
               printf "%s\n" "${scope}"
            else
               printf "%s\n" "${scopeid}"
            fi
         fi
         return 0
      fi
   .done

   if [ "${OPTION_QUIET}" = 'NO' ]
   then
      log_verbose "Scope ${C_RESET_BOLD}${search_scopeid}${C_VERBOSE} is unknown"
   fi
   return 1
}


#
# the only way scopes should be generated as it checks for duplicate names
#
env::scope::add_main()
{
   log_entry "env::scope::add_main" "$@"

   local OPTION_IF_MISSING='NO'
   local OPTION_CREATE_FILE='YES'

   local priority=DEFAULT
   local protect='NO'
   local filename="${MULLE_ENV_ETC_DIR}/auxscope"

   while :
   do
      case "$1" in
         -h|--help|help)
            env::scope::add_usage
         ;;

         --create-file)
            OPTION_CREATE_FILE='YES'
         ;;

         --no-create-file)
            OPTION_CREATE_FILE='NO'
         ;;

         --etc)
            filename="${MULLE_ENV_ETC_DIR}/auxscope"
            protect='NO'
         ;;

         --if-missing)
            OPTION_IF_MISSING='YES'
         ;;

         --priority)
            [ $# -eq 1 ] && template_usage "Missing argument to \"$1\""
            shift

            if ! env::scope::is_priority "$1"
            then
               fail "priority must be a number"
            fi
            priority="$1"
         ;;

         --share)
            filename="${MULLE_ENV_SHARE_DIR}/auxscope"
            protect='YES'
         ;;

         -*)
            env::scope::add_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   local scopeid

   [ ! -z "$1"  ] || env::scope::add_usage "Missing scope name"

   scopeid="$1"
   shift

   [ "$#" -eq 0 ] || env::scope::add_usage "Superflous arguments \"$*\""

   if env::scope::get_main -q "${scopeid}"
   then
      if [ "${OPTION_IF_MISSING}" = 'YES' ]
      then
         return 0
      fi
      fail "Scope \"${scopeid}\" already exists"
   fi

   if ! env::scope::is_scopeid "${scopeid}"
   then
      fail "\"${scopeid}\" is not a valid scope identifier"
   fi

   if env::scope::is_keyword "${scopeid}"
   then
      fail "\"${scopeid}\" is a non reusable keyword"
   fi

   if [ "${priority}" = 'DEFAULT' ]
   then
      if ! env::scope::r_priority_for_scopeid "${scopeid}"
      then
         RVAL=200
      fi
      priority="${RVAL}"
   fi

   if [ "${protect}" = 'YES' ]
   then
      env::unprotect_dir_if_exists "${MULLE_ENV_SHARE_DIR}"
   fi

   r_mkdir_parent_if_missing "${filename}"
   redirect_append_exekutor "${filename}" echo "${scopeid};${priority}" || exit 1

   if [ "${OPTION_CREATE_FILE}" = 'YES' ]
   then
      if ! env::scope::r_filename_for_scopeid "${scopeid}"
      then
         fail "Unknown scopeid \"${scopeid}\""
      fi

      if [ ! -f "${RVAL}" ]
      then
         redirect_append_exekutor "${RVAL}" \
            echo "# Edit with: mulle-env environment --scope ${scopeid} set <key> <value>"
      fi
   fi

   if [ "${protect}" = 'YES' ]
   then
      env::unprotect_dir_if_exists "${MULLE_ENV_SHARE_DIR}"
   fi
}


env::scope::file_scope()
{
   log_entry "env::scope::file_scope" "$@"

   local scope="$1"
   local if_exists="$2"

   env::scope::r_filename_for_scope "${scope}"
   if [ "${if_exists}" = 'YES' ] && [ ! -f "${RVAL}" ]
   then
      return 1
   fi

   printf "%s\n" "${RVAL}"
}


env::scope::file_main()
{
   log_entry "env::scope::file_main" "$@"

   local OPTION_IS_EXISTS='NO'

   while :
   do
      case "$1" in
         -h|--help|help)
            env::scope::remove_usage
         ;;

         --if-exists)
            OPTION_IF_EXISTS='YES'
         ;;

         -*)
            env::scope::remove_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   local scopeid

   [ ! -z "$1"  ] || env::scope::remove_usage "Missing scope name"

   scopeid="$1"
   shift

   [ "$#" -eq 0 ] || env::scope::remove_usage "Superflous arguments \"$*\""

   local scopes
   local scope

   env::scope::r_get_scopes
   scopes="${RVAL}"

   .foreachline scope in ${scopes}
   .do
      if [ "${scope:2}" = "${scopeid}" ]
      then
         env::scope::file_scope "${scope}" "${OPTION_IF_EXISTS}"
         return $?
      fi
   .done
}


env::scope::remove()
{
   log_entry "env::scope::remove" "$@"

   local scope="$1"
   local remove_file="$2"

   local filename
   local protect

   case "${scope}" in
      's:'*)
         filename="${MULLE_ENV_SHARE_DIR}/auxscope"
         protect='YES'
      ;;
      'e:'*)
         filename="${MULLE_ENV_ETC_DIR}/auxscope"
         protect='NO'
      ;;

      *)
         _internal_fail "Malformed scope \"${scope}\""
      ;;
   esac

   local scopeid

   scopeid="${scope:2}"

   r_escaped_grep_pattern "${scopeid}"
   if ! rexekutor grep -E -q "^${RVAL};"  "${filename}"
   then
      fail "Scope \"${scopeid}\" is built-in and can not be deleted"
   fi

   if [ "${protect}" = 'YES' ]
   then
      env::unprotect_dir_if_exists "${MULLE_ENV_SHARE_DIR}"
   fi

   r_escaped_sed_pattern "${scopeid}"
   inplace_sed -e "/^${RVAL};/d" "${filename}" || exit 1

   if [ "${remove_file}" = 'YES' ]
   then
      env::scope::r_filename_for_scope "${scope}"
      remove_file_if_present "${RVAL}"
   fi

   if [ "${protect}" = 'YES' ]
   then
      env::unprotect_dir_if_exists "${MULLE_ENV_SHARE_DIR}"
   fi
}


env::scope::remove_main()
{
   log_entry "env::scope::remove_main" "$@"

   local OPTION_IS_EXISTS='NO'
   local OPTION_REMOVE_FILE='YES'

   while :
   do
      case "$1" in
         -h|--help|help)
            env::scope::remove_usage
         ;;

         --if-exists)
            OPTION_IF_EXISTS='YES'
         ;;

         --keep-file)
            OPTION_REMOVE_FILE='NO'
         ;;

         --remove-file)
            OPTION_REMOVE_FILE='YES'
         ;;

         -*)
            env::scope::remove_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   local scopeid

   [ ! -z "$1"  ] || env::scope::remove_usage "Missing scope name"

   scopeid="$1"
   shift

   [ "$#" -eq 0 ] || env::scope::remove_usage "Superflous arguments \"$*\""

   local scopes
   local scope
   local protect

   env::scope::r_get_scopes
   scopes="${RVAL}"

   .foreachline scope in ${scopes}
   .do
      if [ "${scope:2}" = "${scopeid}" ]
      then
         env::scope::remove "${scope}" "${OPTION_REMOVE_FILE}"
         return 0
      fi
   .done

   if [ "${OPTION_IF_EXISTS}" = 'YES' ]
   then
      return
   fi

   fail "Scope \"${scopeid}\" is unknown"
}


###
### parameters and environment variables
###
env::scope::main()
{
   log_entry "env::scope::main" "$@"

   #
   # handle options
   #
   while :
   do
      case "$1" in
         -h|--help|help)
            env::scope::usage
         ;;

         -*)
            env::scope::usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   [ -z "${MULLE_ENV_SHARE_DIR}" ]   && _internal_fail "MULLE_ENV_SHARE_DIR is empty"
   [ ! -d "${MULLE_ENV_SHARE_DIR}" ] && fail "mulle-env init hasn't run in $PWD yet (\"$MULLE_ENV_SHARE_DIR\" not found)"

   local cmd="${1:-list}"
   [ $# -ne 0 ] && shift

   case "${cmd}" in
      add|file|get|remove|list)
         env::scope::${cmd}_main "$@"
      ;;

      *)
         env::scope::usage "unknown command \"${cmd}\""
      ;;
   esac
}
