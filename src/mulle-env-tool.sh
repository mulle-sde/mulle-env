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
    cat <<EOF >&2
Usage:
   ${MULLE_EXECUTABLE_NAME} tool [options] [command]

   Add and remove commandline tool from the environment. This is only
   of interest, if you are using the :restricted or :none path style.
   See \`${MULLE_EXECUTABLE_NAME} init\` for more information about path styles.

Options:
   -h            : show this usage
   -r            : tool is required
   -o            : tool is optional

Commands:
   add <tool>    : add a tool
   remove <tool> : remove a tool
   list          : list either required or optional tools (default)
EOF
   exit 1
}


_mulle_tool_add()
{
   log_entry "_mulle_tool_add" "$@"

   local toolsfile="$1" ; shift

   local tool="$1"

   [ -z "${tool}" ] && internal_fail "tool must not be empty"
   [ -z "${MULLE_ENV_DIR}" ] && internal_fail "MULLE_ENV_DIR not defined"

   if [ ! -d "${MULLE_ENV_DIR}" ]
   then
      fail "Need to \"mulle-env init\" first before adding tools"
   fi

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
         fail "Failed to find executable \"${tool}\""
      fi
   fi

   if fgrep -q -s -x "${tool}" "${toolsfile}"
   then
      log_warning "\"${tool}\" is already in the list of tools, will relink"
   else
      redirect_append_exekutor "${toolsfile}" echo "${tool}"
   fi

   local bindir

   bindir="${MULLE_ENV_DIR}/bin"
   mkdir_if_missing "${bindir}"

   local dstfile

   dstfile="${bindir}/${tool}"

   exekutor chmod ugo+w "${bindir}" || return 1
   if [ -e "${dstfile}" ]
   then
      # since it's usually a symlink this won't work
      # but on mingw it's better safe than sorry
      exekutor chmod ugo+w "${dstfile}" 2> /dev/null
   fi

   exekutor ln -sf "${executable}" "${bindir}/" || exit 1

   exekutor chmod ugo-w "${dstfile}" 2> /dev/null || : # see above
   exekutor chmod ugo-w "${bindir}"
}


_mulle_tool_remove()
{
   log_entry "_mulle_tool_remove" "$@"

   local toolsfile="$1" ; shift

   local tool="$1"

   [ -z "${tool}" ] && internal_fail "tool must not be empty"
   [ -z "${MULLE_ENV_DIR}" ] && internal_fail "MULLE_ENV_DIR not defined"

   if [ ! -f "${toolsfile}" ]
   then
      log_warning "No tools present. Check your PATH."
      return 2
   fi

   local escaped

   escaped="`escaped_sed_pattern "${tool}"`"
   exekutor sed -i'.bak' "/^${escaped}\$/d" "${toolsfile}"

   local bindir

   bindir="${MULLE_ENV_DIR}/bin"

   exekutor chmod ugo+w "${bindir}" || return 1
   remove_file_if_present "${bindir}/${tool}" &&
   exekutor chmod ugo-w "${bindir}"
}


_mulle_tool_list()
{
   log_entry "_mulle_tool_list" "$@"

   local toolsfile="$1" ; shift

   if [ ! -f "${toolsfile}" ]
   then
      log_warning "No tools present."
      return 2
   fi

   log_info "Tools"

   LC_ALL=C egrep -v '^#' | sed '/^[ ]*$/d' | sort
}



###
### parameters and environment variables
###
env_tool_main()
{
   log_entry "env_tool_main" "$@"

   local TOOLSFILE

   [ -z "${MULLE_ENV_DIR}" ] && internal_fail "MULLE_ENV_DIR is empty"
   [ ! -d "${MULLE_ENV_DIR}" ] && fail "mulle-env init hasn't run here yet"

   #
   # handle options
   #
   TOOLSFILE="tools"

   while :
   do
      case "$1" in
         -*)
            env_tool_usage
         ;;

         -o|--optional|--no-required)
            TOOLSFILE="optional-tools"
         ;;

         -r|--required|--no-optional)
            TOOLSFILE="tools"
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
      add|list|remove)
         _mulle_tool_${cmd} "${MULLE_ENV_DIR}/etc/${TOOLSFILE}" "$@"
      ;;

      *)
         env_tool_usage
      ;;
   esac
}
