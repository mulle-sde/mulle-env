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
MULLE_ENV_TOOL2_SH="included"

#
# This needs a complete rewrite:
#
env_tool2_usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} tool [options] <command>

   Manage commandline tools for a 'restrict' or 'tight' style environment.
   See \`${MULLE_EXECUTABLE_NAME} init\` for more information about
   environment styles.

   You can not manage tools from the inside of a virtual environment.

Options:
   --common    : specify this command for the common toolset only
   --current   : specify this command for the current OS (default)
   --os <os>   : specify this command for the specified OS, e.g. darwin
   --plugin    : use plugin scope instead of etc for add/remove
   --extension : use extension scope instead of etc for/add remove

Commands:
   add        : add a tool
   compile    : compile tool lists into .mulle/var
   get        : check for tool existence
   link       : use compiled tool list to link commands into environment
   list       : list tools, files and specified OSs (default)
   remove     : remove a tool
   status     : check status of tool system
EOF
   exit 1
}


env_tool2_remove_usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} tool remove <tool>

   Remove a tool. See ${MULLE_USAGE_NAME} tool on how to specify the proper
   OS scope.

Example:
      ${MULLE_USAGE_NAME} tool --os darwin remove inotifywait

EOF
   exit 1
}


env_tool2_add_usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} tool add [options] <tool>

   Add a tool to the list of tools available to the subshell. This will
   install the tool on the next "link".

   You can change the optionality of a tool with options.

   Example:
      ${MULLE_USAGE_NAME} tool --os linux add --optional ninja

Options:
   --optional : it's not a fatal error if command is not available

EOF
   exit 1
}


env_tool2_list_usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} tool list [options] <domains>

   List various kind of things.
   stuff for the specified OS. The default OS is the current one which
   is ${MULLE_UNAME}.

Options:
   --no-csv   : don't output in CSV format
   --no-color : don't colorize

Domains:
   file       : list files
   tool       : list tools (default)
   os         : list specified OS

EOF
   exit 1
}


# new tool file format
# <tool>
# <tool>;optional
# <tool>;remove
#
# was wollen wir hier:
#
# Extensions installieren tools mit optional/required
# Wir wollen in den extension nichts duplizieren also
# Eine liste für alle und dann was spezielles für die einzelnen OS
#
# Eine toolliste ist nur additiv. Es gibt nur eine operation "remove"
# Die wie optional am toolnamen hängt. Ein "remove" hängt also einen
# Eintrag in eine Liste dran.
#
# Danach wird stumpf die Liste abgearbeitet und das wars.
#
# Das hier würde ein tool installieren, rauswerfen und dann wieder
# als optional installieren:
#
# <tool>
# <tool>;remove
# <tool>;optional

#
# since all mulle- tools are uniform, this is easy.
# If it's a library, we need to strip off -env from
# the toolname for the libraryname. Also libexec is versionized
# so add the version. The dstbindir/dstlibexecdir is in .mulle directly
#
env_link_mulle_tool()
{
   log_entry "env_link_mulle_tool" "$@"

   local toolname="$1"
   local dstbindir="$2"
   local dstlibexecdir="$3"
   local copystyle="${4:-tool}"
   local optional="$5"

   if [ -e "${bindir}/${toolname}" -a "${MULLE_FLAG_MAGNUM_FORCE}" != 'YES' ]
   then
      log_fluff "Mulle tool \"${toolname}\" already present"
      return
   fi

   #
   # these dependencies should be there, but just check
   #
   local exefile

   #
   # TODO: might need to modify PATH if our .mulle/bin is part of it
   #       which can happen if we are called from another environment
   #
   exefile="`command -v "${toolname}" `"
   if [ -z "${exefile}" ]
   then
      if [ "${optional}" != 'optional' ]
      then
         fail "${toolname} not in PATH"
      fi
      return 0
   fi

   # doing it like this renames "src" to $toolname

   local srclibexecdir
   local parentdir
   local srclibname

   srclibdir="`exekutor "${exefile}" libexec-dir `" || exit 1
   r_fast_dirname "${srclibdir}"
   srclibexecdir="${RVAL}"
   r_fast_basename "${srclibdir}"
   srclibname="${RVAL}"

   local dstbindir
   local dstexefile
   local dstlibname

   dstlibname="${toolname}"
   dstexefile="${dstbindir}/${toolname}"
   mkdir_if_missing "${dstbindir}"

   if [ "${copystyle}" = "library" ]
   then
      local version

      version="`"${exefile}" version `" || exit 1
      dstlibname="`sed 's/-env$//' <<< "${toolname}" `"
      dstlibdir="${dstlibexecdir}/${dstlibname}/${version}"
   else
      dstlibdir="${dstlibexecdir}/${dstlibname}"
   fi

   # remove previous symlinks or files
   remove_file_if_present "${dstexefile}"
   if [ -d "${dstlibdir}" ]
   then
      rmdir_safer "${dstlibdir}"
   else
      remove_file_if_present "${dstlibdir}"
   fi

   if [ "${OPTION_COPY_MULLE_TOOL}" = 'YES' ]
   then
      mkdir_if_missing "${dstlibdir}"

      ( cd "${srclibdir}" ; tar cf - . ) | \
      ( cd "${dstlibdir}" ; tar xf -  )

      mkdir_if_missing "${dstbindir}"

      log_fluff "Copying \"${dstexefile}\""

      exekutor cp "${exefile}" "${dstexefile}" &&
      exekutor chmod 755 "${dstexefile}"
      return $?
   fi

   mkdir_if_missing "${dstbindir}"
   mkdir_parent_if_missing "${dstlibdir}" > /dev/null

   log_fluff "Creating symlink \"${dstexefile}\""
   exekutor ln -s -f "${exefile}" "${dstexefile}"

   log_fluff "Creating symlink \"${dstlibdir}\""
   exekutor ln -s -f "${srclibexecdir}/src" "${dstlibdir}"
}


## tool_delete_list()
## {
##    # the sed works like this:
##    # expect <toolname>;<command>
##    # '/;remove$/!d' is the same as egrep
##    # 's/;remove$//' delete trailing remove command
##    # print toolname
##    # print toolname;optional
##    sed -n -e '/;remove$/!d' \
##           -e 's/;remove$//' \
##           -e p \
##           -e 's/$/;optional/' \
##           -e p
## }
##
##

r_env_tool2_oslist()
{
   log_entry "r_env_tool2_oslist" "$@"

   local name
   local filename
   local filenames

   shopt -s nullglob
   for filename in "${MULLE_ENV_SHARE_DIR}"/tool* \
                   "${MULLE_ENV_ETC_DIR}"/tool*
   do
      name="${filename##*tool.}"
      if [ "${filename}" = "${name}" ]
      then
         name="DEFAULT"
      fi

      r_add_unique_line "${filenames}" "${name}"
      filenames="${RVAL}"
   done
   shopt -u nullglob

   RVAL="${filenames}"
}


r_env_tool2_scoped_get()
{
   log_entry "r_env_tool2_scoped_get" "$@"

   local scope="$1"
   local os="$2"
   local tool="$3"

   local extension

   if [ -z "${os}" -o "${os}" = "DEFAULT" ]
   then
      extension=""
   else
      extension=".${os}"
   fi

   case "${scope}" in
      'plugin')
         if r_env_tool2_get "${tool}" \
                            "${MULLE_ENV_SHARE_DIR}/tool-plugin" \
                            "${MULLE_ENV_SHARE_DIR}/tool-plugin${extension}"
         then
            return 0
         fi
      ;;

      'extension')
         if r_env_tool2_get "${tool}" \
                            "${MULLE_ENV_SHARE_DIR}/tool-plugin" \
                            "${MULLE_ENV_SHARE_DIR}/tool-plugin${extension}" \
                            "${MULLE_ENV_SHARE_DIR}/tool-extension" \
                            "${MULLE_ENV_SHARE_DIR}/tool-extension${extension}"
         then
            return 0
         fi
      ;;

      *)
         if r_env_tool2_get "${tool}" \
                            "${MULLE_ENV_SHARE_DIR}/tool-plugin" \
                            "${MULLE_ENV_SHARE_DIR}/tool-plugin${extension}" \
                            "${MULLE_ENV_SHARE_DIR}/tool-extension" \
                            "${MULLE_ENV_SHARE_DIR}/tool-extension${extension}" \
                            "${MULLE_ENV_ETC_DIR}/tool" \
                            "${MULLE_ENV_ETC_DIR}/tool${extension}"
         then
            return 0
         fi
      ;;
   esac

   return 1
}


env_tool2_add()
{
   log_entry "env_tool2_add" "$@"

   [ -z "${MULLE_ENV_ETC_DIR}" ]   && internal_fail "MULLE_ENV_ETC_DIR not defined"
   [ -z "${MULLE_ENV_SHARE_DIR}" ] && internal_fail "MULLE_ENV_SHARE_DIR not defined"

   local scope="$1" ; shift
   local os="$1" ; shift

   local OPTION_OPTIONALITY='DEFAULT'
   local OPTION_COMPILE_LINK='DEFAULT'
   local OPTION_REMOVE='NO'
   local OPTION_CSV='NO'
   local OPTION_IF_MISSING='NO'

   while :
   do
      case "$1" in
         -h*|--help|help)
            env_tool2_add_usage
         ;;

         -o|--optional|--no-required)
            OPTION_OPTIONALITY="YES"
         ;;

         --if-missing)
            OPTION_IF_MISSING="YES"
         ;;

         --csv)
            OPTION_CSV="YES"
         ;;

         --required|--no-optional)
            OPTION_OPTIONALITY="NO"
         ;;

         --remove)
            OPTION_REMOVE='YES'
         ;;

         --compile-link)
            OPTION_COMPILE_LINK="YES"
         ;;

         --no-compile-link)
            OPTION_COMPILE_LINK="NO"
         ;;

         -*)
            env_tool2_add_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   [ $# -ne 1 ] && env_tool2_add_usage "Missing tool name"

   tool="$1"

   [ -z "${tool}" ] && env_tool2_get_usage "Empty tool name"

   local mark

   if [ "${OPTION_CSV}" = 'YES' ]
   then
      mark="${tool##*;}"
      if [ "${mark}" = "${tool}" ]
      then
         mark=""
      else
         tool="${tool%;${mark}}"
      fi
   else
      if [ "${OPTION_OPTIONALITY}" = 'YES' ]
      then
         mark="optional"
      fi

      # this overrides/ignores optional
      if [ "${OPTION_REMOVE}" = 'YES' ]
      then
         mark="remove"
      fi
   fi

   local extension

   if [ "${os}" = "DEFAULT" ]
   then
      extension=""
   else
      extension=".${os}"
   fi

   local exists

   exists='NO'

   if r_env_tool2_scoped_get "${scope}" "${os}" "${tool}"
   then
      exists='YES'
   fi

   case "${mark}" in
      remove)
         if [ "${exists}" = 'NO' ]
         then
            log_verbose "\"${tool}\" is already deinstalled"
            return 0 # no one cares or ?
         fi
      ;;

      *)
         if [ "${exists}" = 'YES' ]
         then
            if [ "${OPTION_IF_MISSING}" = 'YES' ]
            then
               return 0
            fi
            fail "\"${tool}\" is already installed"
         fi
      ;;
   esac

   if [ ! -z "${mark}" ]
   then
      tool="${tool};${mark}"
   fi

   case "${scope}" in
      plugin|extension)
         tool_filename="${MULLE_ENV_SHARE_DIR}/tool-${scope}${extension}"
         unprotect_file_if_exists "${tool_filename}"
         redirect_append_exekutor "${tool_filename}" echo "${tool}"
         protect_file "${tool_filename}"
      ;;

      *)
         mkdir_if_missing "${MULLE_ENV_ETC_DIR}"
         tool_filename="${MULLE_ENV_ETC_DIR}/tool${extension}"
         redirect_append_exekutor "${tool_filename}" echo "${tool}"
      ;;
   esac

   if [ "${OPTION_COMPILE_LINK}" != 'NO' ]
   then
      if [ "${OPTION_COMPILE_LINK}" != 'DEFAULT' -o ! -z "${MULLE_VIRTUAL_ROOT}" ]
      then
         log_debug "compile an link as : OPTION_COMPILE_LINK is \"${OPTION_COMPILE_LINK}\" and MULLE_VIRTUAL_ROOT is \"${MULLE_VIRTUAL_ROOT}\""
         env_tool2_link --compile-if-needed
      fi
   fi
}


env_tool2_compile()
{
   log_entry "env_tool2_compile" "$@"

   [ -z "${MULLE_ENV_ETC_DIR}" ]   && internal_fail "MULLE_ENV_ETC_DIR not defined"
   [ -z "${MULLE_ENV_SHARE_DIR}" ] && internal_fail "MULLE_ENV_SHARE_DIR not defined"
   [ -z "${MULLE_ENV_VAR_DIR}" ]   && internal_fail "MULLE_ENV_VAR_DIR not defined"

   local ifneeded='NO'

   local extension
   local bindir

   extension=".${MULLE_UNAME}"

   while :
   do
      case "$1" in
         -h*|--help|help)
            env_tool2_compile_usage
         ;;

         --if-needed)
            ifneeded='YES'
         ;;

         -*)
            env_tool2_compile_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   [ $# -ne 0 ] && env_tool2_compile_usage "superflous arguments \"$*\""

   if [ "${ifneeded}" = 'YES' ]
   then
      env_tool2_status "log_fluff"
      case $? in
         0)
            return 0
         ;;

         1)
         ;;

         2)
            touch "${MULLE_ENV_VAR_DIR}/tool"
            return 0
         ;;
      esac
   fi

   local _filepath

   __get_tool_filepath "${MULLE_UNAME}"


   local lines
   local result
   local file
   local name

   IFS=":"
   for file in ${_filepath}
   do
      IFS="${DEFAULT_IFS}"

      [ ! -f "${file}" ]  && continue

      log_fluff "Compiling \"${file}\""

      lines="`rexekutor egrep -v '^#' "${file}"`"

      set -f; IFS="
"
      local i

      for i in ${lines}
      do
         set +f; IFS=":"

         case "${i}" in
            *';remove')
               name="${i%;remove}"
               if find_line "${result}" "${name}"
               then
                  result="`fgrep -v -x "${name}" <<< "${result}"`"
               fi
            ;;

            *';optional')
               r_add_line "${result}" "${i}"
               result="${RVAL}"
            ;;

            *)
               # silently remove any ; crap
               r_add_line "${result}" "${i%;*}"
               result="${RVAL}"
            ;;
         esac
      done

      set +f; IFS=":"
   done
   IFS="${DEFAULT_IFS}"

   mkdir_if_missing "${MULLE_ENV_VAR_DIR}"
   redirect_exekutor "${MULLE_ENV_VAR_DIR}/tool" sort <<< "${result}"
}


r_env_tool2_get()
{
   log_entry "r_env_tool2_get" "$@"

   local tool="$1" ; shift

   local file
   local lines
   local result
   local i
   local previous
   local foundfile

   for file in "$@"
   do
      [ "${file}" = "${previous}" ] && continue
      previous="${file}"

      [ ! -f "${file}" ]  && continue

      lines="`egrep -v '^#' "${file}" | egrep "^${tool}$|^${tool};" `"
   set -f; IFS="
"
      for i in ${lines}
      do
         case "${i}" in
            *';remove')
               result=""
            ;;

            *)
               foundfile="${file}"
               result="$i"
            ;;
         esac
      done
      set IFS="${DEFAULT_IFS}"

   done

   if [ -z "${result}" ]
   then
      RVAL=
      log_debug "\"${tool}\" not found"
      return 1
   fi

   log_debug "Found \"$i\" in \"${foundfile}\""
   RVAL="${result}"
}


#
env_tool2_get()
{
   log_entry "env_tool2_get" "$@"

   [ -z "${MULLE_ENV_ETC_DIR}" ]   && internal_fail "MULLE_ENV_ETC_DIR not defined"
   [ -z "${MULLE_ENV_SHARE_DIR}" ] && internal_fail "MULLE_ENV_SHARE_DIR not defined"

   local scope="$1" ; shift
   local extension="$1" ; shift

   while :
   do
      case "$1" in
         -h*|--help|help)
            env_tool2_get_usage
         ;;

         -*)
            env_tool2_get_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   [ $# -ne 1 ] && env_tool2_get_usage "missing tool name"

   local tool

   tool="$1"

   [ -z "${tool}" ] && env_tool2_get_usage "missing tool name"

   if ! r_env_tool2_scoped_get "${scope}" "${os}" "${tool}"
   then
      return 1
   fi

   echo "${RVAL}"
}


env_tool2_link_tool()
{
   log_entry "env_tool2_link_tool" "$@"

   local toolname="$1"
   local bindir="$2"
   local isrequired="$3"

   #
   # when stepping back and forth from environments, it may be that
   # we have the proper symlink already, but we don't have the PATH anymore
   # so lets check first that a link exists
   #
   if [ -e "${bindir}/${toolname}" -a "${MULLE_FLAG_MAGNUM_FORCE}" != 'YES' ]
   then
      log_fluff "Tool \"${toolname}\" already present"
      return
   fi

   local filename

   filename="`command -v "${toolname}" `"
   case "${filename}" in
      "")
         if [ "${isrequired}" = 'YES' ]
         then
            fail "Required tool \"${toolname}\" not found"
         fi

         log_fluff "\"${toolname}\" not found, but it's optional"
         return 1
      ;;

      #
      # the idea here is to keep the mulle tools in a local state
      # until upgrade, unaffected by other projects
      #
      /*/mulle-*-*-*)
         if [ "${OPTION_COPY_MULLE_TOOL}" = 'YES' ]
         then
            log_fluff "Copying mulle script \"${bindir}/${toolname}\""

            exekutor cp -a "${filename}" "${bindir}/"
            return $?
         fi
      ;;

      /*)
      ;;

      *)
         # not absolute
         log_fluff "Skipping builtin \"${filename}\""
         return
      ;;
   esac

   log_fluff "Creating symlink \"${bindir}/${toolname}\""

   exekutor ln -sf "${filename}" "${bindir}/"
}


env_tool2_unlink_tool()
{
   log_entry "env_tool2_unlink_tool" "$@"

   local toolname="$1"
   local bindir="$2"

   log_fluff "Removing \"${bindir}/${toolname}\""

   exekutor rm -f "${bindir}/${toolname}"
}


env_tool2_link_tools()
{
   log_entry "env_tool2_link_tools" "$@"

   local toollines="$1"
   local bindir="$2"

   local toolname
   local isrequired

   local bindir
   local mark

   mkdir_if_missing "${bindir}"

   set -f ; IFS="
"
   for toolline in ${toollines}
   do
      set +f ; IFS="${DEFAULT_IFS}"

      isrequired='YES'
      operation="link"

      IFS=";" read -r toolname mark <<< "${toolline}"

      case "${mark}" in
         optional)
            isrequired='NO'
         ;;

         remove)
            operation="unlink"
         ;;
      esac

      env_tool2_${operation}_tool "${toolname}" "${bindir}" "${isrequired}"
   done

   set +f ; IFS="${DEFAULT_IFS}"

   rmdir_if_empty "${bindir}"
}


env_tool2_link()
{
   log_entry "env_tool2_link" "$@"

   local compile_if_needed='NO'
   local compile='NO'
   local compile_flags

   local bindir

   bindir="${MULLE_ENV_VAR_DIR}/bin"

   while :
   do
      case "$1" in
         -h*|--help|help)
            env_tool2_get_usage
         ;;

         --compile)
            compile='YES'
         ;;

         --compile-if-needed)
            compile_flags='--if-needed'
            compile='YES'
         ;;

         --bindir)
            [ $# -eq 1 ] && fail "missing argument to $1"
            shift

            bindir="$1"
         ;;

         -*)
            env_tool2_get_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   if [ "${compile}" = 'YES' ]
   then
      env_tool2_compile ${compile_flags}  || return 1
   fi

   local toolfile

   toolfile="${MULLE_ENV_VAR_DIR}/tool"

   [ -f "${toolfile}" ] || fail "\"${toolfile}\" is missing"

   local toollines

   toollines="`cat "${toolfile}" `"
   if [ -z "${toollines}" ]
   then
      log_warning "No tools defined in \"${toolfile}\""
   fi

   env_tool2_link_tools "${toollines}" "${bindir}"
}


_list_tool_file()
{
   local filename="$1"
   local color="$2"
   local csv="$3"
   local builtin="$4"

   local toolline
   local toolname
   local mark

   local color_start
   local color_end
   local printmark

   IFS="
"
   for toolline in `egrep -v '^#' "${filename}"`
   do
      IFS="${DEFAULT_IFS}"

      [ -z "${toolline}" ] && continue

      IFS=";" read -r toolname mark <<< "${toolline}"

      printmark=""
      if [ "${csv}" = 'YES' -a ! -z "${mark}" ]
      then
         printmark=";${mark}"
      fi

      if [ "${color}" = 'YES' ]
      then
         color_start="${C_RESET}"
         color_end="${C_RESET}"

         local filename

         if [ "${mark}" != "remove" ]
         then
            filename="`command -v "${toolname}" `"
            case "${filename}" in
               /*)
                  if [ -x "${MULLE_ENV_VAR_DIR}/bin/${toolname}" ]
                  then
                     color_start="${C_GREEN}"
                  else
                     if [ "${mark}" = "optional" ]
                     then
                        color_start="${C_YELLOW}"
                     else
                        color_start="${C_RED}${C_BOLD}"
                     fi
                  fi
               ;;

               "")
                  if [ "${mark}" = "optional" ]
                  then
                     color_start="${C_RED}"
                  else
                     color_start="${C_RED}"
                  fi
               ;;

               *)
                  color_start="${C_GREEN}${C_BOLD}"    # builtin

                  if [ "${csv}" = 'YES' -a "${builtin}" = 'YES' ]
                  then
                     if [ -z "${printmark}" ]
                     then
                        printmark=";builtin"
                     else
                        printmark=",builtin"
                     fi
                  fi
               ;;
            esac
         fi
      fi

      printf '%b%s%b%s\n' "${color_start}" "${toolname}${printmark}" "${color_end}"
   done
   IFS="${DEFAULT_IFS}"
   echo
}


_env_tool2_list()
{
   log_entry "_env_tool2_list" "$@"

   local os="$1"
   local color="$2"
   local csv="$3"
   local builtin="$4"

   local toolfiles

   r_get_existing_tool_filepath "${os}"
   toolfiles="${RVAL}"

   local file
   local directory
   local name

   IFS=":"
   for file in ${toolfiles}
   do
      IFS="${DEFAULT_IFS}"

      r_fast_dirname "${file}"
      r_fast_dirname "${RVAL}"
      r_fast_basename "${RVAL}"
      directory="${RVAL}"

      r_fast_basename "${file}"
      name="${RVAL}"

      log_info "${directory}/${name}"

      _list_tool_file "${file}" "${color}" "${csv}" "${builtin}"

   done

   IFS="${DEFAULT_IFS}"
}


env_tool2_list()
{
   log_entry "env_tool2_list" "$@"

   [ -z "${MULLE_ENV_ETC_DIR}" ]   && internal_fail "MULLE_ENV_ETC_DIR not defined"
   [ -z "${MULLE_ENV_SHARE_DIR}" ] && internal_fail "MULLE_ENV_SHARE_DIR not defined"

   local OPTION_COLOR="YES"
   local OPTION_CSV="YES"
   local OPTION_BUILTIN="YES"

   local os="$1" ; shift

   while :
   do
      case "$1" in
         -h*|--help|help)
            env_tool2_list_usage
         ;;

         --no-color)
            OPTION_COLOR='NO'
         ;;

         --csv)
            OPTION_CSV='YES'
         ;;

         --no-csv)
            OPTION_CSV='NO'
         ;;

         --no-builtin)
            OPTION_BUILTIN='NO'
         ;;

         -*)
            env_tool2_list_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   case "$1" in
      file|files)
         r_get_existing_tool_filepath "${os}"
         echo "${RVAL}"
      ;;

      os|oss)
         r_env_tool2_oslist
         sort <<< "${RVAL}"
         return 0
      ;;

      ""|tool|tools)
         _env_tool2_list "${os}" "${OPTION_COLOR}" "${OPTION_CSV}" "${OPTION_BUILTIN}"
      ;;

      *)
         env_tool2_list_usage "Unknown argument \"$1\""
      ;;
   esac
}


##
## status code is in main now
##
env_tool2_status()
{
   log_entry "env_tool2_status" "$@"

   local logger="${1:-log_info}"

   _env_tool2_status "$@"
   rval=$?

   case $rval in
      0)
         ${logger} "OK"
      ;;
      1)
         ${logger} "Compile"
      ;;
      2)
         ${logger} "Empty"
      ;;
   esac

   return $rval
}



###
### parameters and environment variables
###
env_tool2_main()
{
   log_entry "env_tool2_main" "$@"

   #
   # handle options
   #
   local OPTION_SCOPE="DEFAULT"
   local OPTION_OS="${MULLE_UNAME}"

   while :
   do
      case "$1" in
         -h*|--help|help)
            env_tool2_usage
         ;;

         --plugin|--extension)
            OPTION_SCOPE="${1:2}"
         ;;

         --common)
            OPTION_OS="DEFAULT"
         ;;

         --current)
            OPTION_OS="${MULLE_UNAME}"
         ;;

         --os)
            [ $# -eq 1 ] && fail "missing argument to $1"
            shift

            OPTION_OS="$1"
         ;;

         -*)
            env_tool2_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   local cmd="$1"

   case "${cmd}" in
      add)
         shift
         env_tool2_add "${OPTION_SCOPE}" \
                       "${OPTION_OS}" \
                       "$@"
      ;;

      compile)
         shift

         env_tool2_compile "$@"
      ;;

      get)
         shift
         env_tool2_get "${OPTION_SCOPE}"\
                       "${OPTION_OS}" \
                       "$@"
      ;;

      link)
         shift

         env_tool2_link "$@"
      ;;

      list)
         shift

         env_tool2_list "${OPTION_OS}" \
                        "$@"
      ;;

      remove)
         shift

         env_tool2_add "${OPTION_SCOPE}" \
                       "${OPTION_OS}" \
                       --remove \
                       "$@"
      ;;

      status)
         shift

         env_tool2_status "$@"
      ;;


      "")
         env_tool2_usage
      ;;

      *)
         env_tool2_usage "Unknown command \"${cmd}\""
      ;;
   esac
}
