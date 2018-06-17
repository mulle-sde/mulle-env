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
MULLE_ENV_TOOL_SH="included"


env_tool_usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} tool [options] <command>

   Manage commandline tools for a -restrict or -tight environment.
   See \`${MULLE_EXECUTABLE_NAME} init\` for more information about
   environment styles.

Options:
   --required : restrict command to required tools
   --optional : restrict command to optional tools

Commands:
   add        : add a tool
   remove     : remove a tool
   list       : list either required or optional tools (default)
EOF
   exit 1
}


env_tool_remove_usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} tool remove <tool>

   Remove a tool.

EOF
   exit 1
}

env_tool_add_usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} tool add <tool>

   Add a tool to the list of tools available to the subshell.
   This doesn't install the tool, but merely symlinks it if
   the current environment style needs it.

   You can change the optionality of a tool, by re-adding it
   with the desired optionality.

   Example:
      ${MULLE_USAGE_NAME} tool --optional add ninja
EOF
   exit 1
}


env_tool_list_usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} tool list [options]

   List tools.
EOF
   exit 1
}


prepare_for_add()
{
   log_entry "prepare_for_add" "$@"

   local etctoolsfile="$1"
   local sharetoolsfile="$2"

   if [ ! -f "${etctoolsfile}" ]
   then
      mkdir_if_missing "`fast_dirname "${etctoolsfile}"`"
      if [ -f "${sharetoolsfile}" ]
      then
         exekutor cp "${sharetoolsfile}" "${etctoolsfile}"
         exekutor chmod ug+w "${etctoolsfile}"
      fi
   fi
}


prepare_for_remove()
{
   log_entry "prepare_for_remove" "$@"

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
      exekutor chmod ug+w "${etctoolsfile}"
   fi
}


chmod_share_files()
{
   local mode="$1"

   if [ -f "${MULLE_ENV_DIR}/share/optionaltool" ]
   then
      exekutor chmod "${mode}" "${MULLE_ENV_DIR}/share/optionaltool"
   fi
   if [ -f "${MULLE_ENV_DIR}/share/tool" ]
   then
      exekutor chmod "${mode}" "${MULLE_ENV_DIR}/share/tool"
   fi
}


share_protect()
{
   chmod_share_files ug-w
}


share_unprotect()
{
   chmod_share_files ug+w
}


_mulle_tool_add_file()
{
   log_entry "_mulle_tool_add_file" "$@"

   local optionality="$1"
   local tool="$2"
   local toolsfile="$3"
   local fallbacktoolsfile="$4"

   prepare_for_add "${toolsfile}" "${fallbacktoolsfile}"

   local executable

   #
   # use mudo to break out of
   # virtual environment
   #
   executable="`mudo which "${tool}" 2> /dev/null`"
   if [ -z "${executable}" ]
   then
      if [ -z "`which "mudo" 2> /dev/null`" ]
      then
         fail "\"mudo\" is not present ??? Try again outside of the environment."
      else
         case "${optionality}" in
            "optional")
               log_verbose "Optional tool \"${tool}\" not found"
               return
            ;;

            *)
               fail "Failed to find executable \"${tool}\""
            ;;
         esac
      fi
   fi

   if fgrep -q -s -x -e "${tool}" "${toolsfile}"
   then
      log_warning "\"${tool}\" is already in the list of tools, will relink"
   else
      redirect_append_exekutor "${toolsfile}" echo "${tool}"
   fi

   local style
   local flavor

   # defined in mulle_env
   __get_saved_style_flavor "${MULLE_VIRTUAL_ROOT}/.mulle-env/etc" \
                            "${MULLE_VIRTUAL_ROOT}/.mulle-env/share"

   case "${style}" in
      */wild|*-inherit)
         return
      ;;
   esac

   local bindir

   bindir="${MULLE_ENV_DIR}/bin"
   mkdir_if_missing "${bindir}"

   local dstfile

   dstfile="${bindir}/${tool}"

   exekutor chmod ug+wX "${bindir}" || return 1
   if [ -e "${dstfile}" ]
   then
      # since it's usually a symlink this won't work
      # but on mingw it's better safe than sorry
      exekutor chmod -f ug+w "${dstfile}"
   fi

   exekutor ln -sf "${executable}" "${bindir}/" || exit 1

   exekutor chmod -f ugo-w "${dstfile}"  || : # see above
   exekutor chmod ugo-w "${bindir}"
}


_mulle_tool_remove_file()
{
   log_entry "_mulle_tool_remove_file" "$@"

   local tool="$1"
   local toolsfile="$2"
   local fallbacktoolsfile="$3"

   if ! prepare_for_remove "${toolsfile}" "${fallbacktoolsfile}"
   then
      return 1
   fi

   local escaped

   escaped="`escaped_sed_pattern "${tool}"`"
   inplace_sed -e "/^${escaped}\$/d" "${toolsfile}"

   local bindir

   bindir="${MULLE_ENV_DIR}/bin"

   if [ -d "${bindir}" ]
   then
      exekutor chmod ugo+w "${bindir}" || return 1
      remove_file_if_present "${bindir}/${tool}" &&
      exekutor chmod ugo-w "${bindir}"
   fi
}


mulle_tool_add()
{
   log_entry "mulle_tool_add" "$@"

   [ -z "${MULLE_ENV_DIR}" ]   && internal_fail "MULLE_ENV_DIR not defined"
   [ ! -d "${MULLE_ENV_DIR}" ] && fail "Need to \"mulle-env init\" first before adding tools"

   local optionality="$1" ; shift
   local scope="$1" ; shift

   while :
   do
      case "$1" in
         -h*|--help|help)
            env_tool_add_usage
         ;;

         -*)
            env_tool_add_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   [ $# -eq 0 ] && env_tool_add_usage "missing tool name"

   local tool

   while [ $# -ne 0 ]
   do
      tool="$1"
      shift

      case "${scope}" in
         share)
            share_unprotect

            _mulle_tool_remove_file "${tool}" "${MULLE_ENV_DIR}/share/optionaltool"
            _mulle_tool_remove_file "${tool}" "${MULLE_ENV_DIR}/share/tool"

            if [ "${optionality}" = "optional" ]
            then
               _mulle_tool_add_file "${optionality}" \
                                    "${tool}" \
                                    "${MULLE_ENV_DIR}/share/optionaltool"
            else
               _mulle_tool_add_file "${optionality}" \
                                    "${tool}" \
                                    "${MULLE_ENV_DIR}/share/tool"
            fi

            share_protect
         ;;

         *)
            [ -z "${tool}" ] && fail "tool must not be empty"

            _mulle_tool_remove_file "${tool}" "${MULLE_ENV_DIR}/etc/optionaltool"
            _mulle_tool_remove_file "${tool}" "${MULLE_ENV_DIR}/etc/tool"

            if [ "${optionality}" = "optional" ]
            then
               _mulle_tool_add_file "${optionality}" \
                                    "${tool}" \
                                    "${MULLE_ENV_DIR}/etc/optionaltool" \
                                    "${MULLE_ENV_DIR}/share/optionaltool"
            else
               _mulle_tool_add_file "${optionality}" \
                                    "${tool}" \
                                    "${MULLE_ENV_DIR}/etc/tool" \
                                    "${MULLE_ENV_DIR}/share/tool"
            fi
         ;;
      esac
   done
}


#
# remove
#

mulle_tool_remove()
{
   log_entry "mulle_tool_remove" "$@"

   [ -z "${MULLE_ENV_DIR}" ] && internal_fail "MULLE_ENV_DIR not defined"

   local optionality="$1" ; shift
   local scope="$1" ; shift

   while :
   do
      case "$1" in
         -h*|--help|help)
            env_tool_remove_usage
         ;;

         -*)
            env_tool_remove_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   [ $# -eq 0 ] && env_tool_remove_usage "missing tool name"

   local tool

   while [ $# -ne 0 ]
   do
      tool="$1"
      shift

      case "${scope}" in
         share)
            share_unprotect

            if [ "${optionality}" != "optional" ]
            then
               _mulle_tool_remove_file "${tool}" "${MULLE_ENV_DIR}/share/tool"
            fi
            if [ "${optionality}" != "required" ]
            then
               _mulle_tool_remove_file "${tool}" "${MULLE_ENV_DIR}/share/optionaltool"
            fi

            share_protect
         ;;

         *)
            if [ "${optionality}" != "optional" ]
            then
               _mulle_tool_remove_file "${tool}" "${MULLE_ENV_DIR}/etc/tool" "${MULLE_ENV_DIR}/share/tool"
            fi
            if [ "${optionality}" != "required" ]
            then
               _mulle_tool_remove_file "${tool}" "${MULLE_ENV_DIR}/etc/optionaltool" "${MULLE_ENV_DIR}/share/optionaltool"
            fi
         ;;
      esac
   done
}

#
# list
#
_mulle_tool_list_file()
{
   log_entry "_mulle_tool_list_file" "$@"

   local title="$1"
   local toolsfile="$2"
   local fallbacktoolsfile="$3"

   if [ ! -f "${toolsfile}" ]
   then
      toolsfile="${fallbacktoolsfile}"
   fi

   if [ ! -f "${toolsfile}" ]
   then
      log_warning "No tools present."
      return 2
   fi

   log_info "${title}"

   LC_ALL=C egrep -v '^#' "${toolsfile}" | sed '/^[ ]*$/d' | LC_ALL=C sort
}


mulle_tool_list()
{
   log_entry "mulle_tool_list" "$@"

   local optionality="$1" ; shift
   local scope="$1" ; shift

   while :
   do
      case "$1" in
         -h*|--help|help)
            env_tool_list_usage
         ;;

         -*)
            env_tool_list_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   case "${scope}" in
      share)
         if [ "${optionality}" != "optional" ]
         then
            _mulle_tool_list_file "Required Tools" \
                                  "${MULLE_ENV_DIR}/share/tool"
         fi
         if [ "${optionality}" != "required" ]
         then
            _mulle_tool_list_file "Optional Tools" \
                                  "${MULLE_ENV_DIR}/share/optionaltool"
         fi
      ;;

      *)
         if [ "${optionality}" != "optional" ]
         then
            _mulle_tool_list_file "Required Tools" \
                                  "${MULLE_ENV_DIR}/etc/tool" \
                                  "${MULLE_ENV_DIR}/share/tool"
         fi
         if [ "${optionality}" != "required" ]
         then
            _mulle_tool_list_file "Optional Tools" \
                                  "${MULLE_ENV_DIR}/etc/optionaltool" \
                                  "${MULLE_ENV_DIR}/share/optionaltool"
         fi
      ;;
   esac
}


###
### parameters and environment variables
###
env_tool_main()
{
   log_entry "env_tool_main" "$@"


   [ -z "${MULLE_ENV_DIR}" ] && internal_fail "MULLE_ENV_DIR is empty"
   [ ! -d "${MULLE_ENV_DIR}" ] && fail "mulle-env init hasn't run here yet ($PWD)"

   #
   # handle options
   #
   local OPTION_OPTIONALITY="DEFAULT"
   local OPTION_SCOPE="DEFAULT"

   while :
   do
      case "$1" in
         -h*|--help|help)
            env_tool_usage
         ;;

         -o|--optional|--no-required)
            OPTION_OPTIONALITY="optional"
         ;;

         -r|--required|--no-optional)
            OPTION_OPTIONALITY="required"
         ;;

         --share)
            OPTION_SCOPE="share"
         ;;

         -*)
            env_tool_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   local cmd="$1"

   case "${cmd}" in
      add|list|remove)
         shift
         "mulle_tool_${cmd}" "${OPTION_OPTIONALITY}" "${OPTION_SCOPE}" "$@"
      ;;

      "")
         env_tool_usage
      ;;

      *)
         env_tool_usage "unknown command \"${cmd}\""
      ;;
   esac
}
