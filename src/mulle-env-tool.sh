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
MULLE_ENV_TOOL_SH='included'

#
# This needs a complete rewrite:
#
env::tool::usage()
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
   --global    : specify this command for the global toolset only
   --current   : specify this command for the current OS (default)
   --os <os>   : specify this command for the specified OS, e.g. darwin
   --plugin    : use plugin scope instead of etc for add/remove
   --extension : use extension scope instead of etc for/add remove

Commands:
   add        : add tools
   compile    : compile tool lists into .mulle/var
   doctor     : check links of linked tools
   get        : check for tool existence
   link       : use compiled tool list to link commands into environment
   list       : list tools, files and specified OSs (default)
   remove     : remove a tool
   status     : quick check status of tool system
EOF
   exit 1
}


env::tool::remove_usage()
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


env::tool::add_usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} tool add [options] <tool> ...

   Add a tool or multiple tools to the list of tools available to the subshell.
   The additions will be available on the next "link".

   You can change the optionality of a tool with options.

Examples:
   ${MULLE_USAGE_NAME} tool --os linux add --optional ninja

   ${MULLE_USAGE_NAME} tool --global add cmake

Options:
   --no-resolve : do not deeply resolve symlinks
   --optional   : it's not a fatal error if command is not available
   --required   : it's a fatal error
   --script     : force use of a script instead of a symlink

EOF
   exit 1
}


env::tool::list_usage()
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
   compiled   : show the compiled tools list for this host
   tool       : list tools (default)
   os         : list specified OS

EOF
   exit 1
}


env::tool::compile_usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} tool compile

   Compile tool list from recent changes. Run "link" to make these changes
   become apparent.

EOF
   exit 1
}


env::tool::link_usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} tool link

   Relink tools. Useful, if tools were recently installed.

EOF
   exit 1
}


env::tool::get_usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} tool get <name>

   Check if named tool is linked and available.

EOF
   exit 1
}


env::tool::doctor_usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} tool doctor

   Check if the tools linked are still available.

EOF
   exit 1
}



# new tool file format:
# since mulle-bashfunctions 6.0.0 the default is optional
#
# <tool>
# <tool>;required
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
# Die wie optional am toolnamen hängt. Ein "remove" command hängt also einen
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
env::tool::link_mulle_tool()
{
   log_entry "env::tool::link_mulle_tool" "$@"

   local toolname="$1"
   local dstbindir="$2"
   local dstlibexecdir="$3"
   local copystyle="${4:-tool}"
   local optional="$5"

   if [ -e "${dstbindir}/${toolname}" -a "${MULLE_FLAG_MAGNUM_FORCE}" != 'YES' ]
   then
      log_fluff "Mulle tool \"${toolname}\" already present"
      return 0
   fi

   #
   # these dependencies should be there, but just check
   #
   local exefile

   #
   # TODO: might need to modify PATH if our .mulle/bin is part of it
   #       which can happen if we are called from another environment
   #
   if ! exefile="`command -v "${toolname}" `"
   then
      if [ "${optional}" = 'required' ]
      then
         fail "${toolname} not in PATH"
      fi
      return 0
   fi

   # doing it like this renames "src" to $toolname

   local srclibexecdir
   local srclibdir

   if [ ! -z "${dstlibexecdir}" ]
   then
      srclibdir="`exekutor "${exefile}" libexec-dir `" || exit 1
      r_dirname "${srclibdir}"
      srclibexecdir="${RVAL}"

      local dstlibname

      dstlibname="${toolname}"

      if [ "${copystyle}" = "library" ]
      then
         local version

         version="`"${exefile}" version `" || exit 1
         dstlibname="${toolname%-env}"
         dstlibdir="${dstlibexecdir}/${dstlibname}/${version}"
      else
         dstlibdir="${dstlibexecdir}/${dstlibname}"
      fi

      if [ -d "${dstlibdir}" ]
      then
         rmdir_safer "${dstlibdir}"
      else
         remove_file_if_present "${dstlibdir}"
      fi
   fi

   local dstexefile

   dstexefile="${dstbindir}/${toolname}"
   # remove previous symlinks or files
   remove_file_if_present "${dstexefile}"
   mkdir_if_missing "${dstbindir}"

   #
   # copy
   #
   if [ "${OPTION_COPY_MULLE_TOOL}" = 'YES' ]
   then
      log_debug "Copying \"${dstexefile}\""

      exekutor cp "${exefile}" "${dstexefile}" &&
      exekutor chmod 755 "${dstexefile}"

      if [ ! -z "${dstlibexecdir}" ]
      then
         log_debug "Copying \"${dstlibdir}\""

         mkdir_if_missing "${dstlibdir}"

         ( cd "${srclibdir}" ; tar cf - . ) | \
         ( cd "${dstlibdir}" ; tar xf -  ) || exit 1
      fi
      return
   fi

   #
   # symlinks
   #
   log_debug "Creating symlink \"${dstexefile}\""
   exekutor ln -s -f "${exefile}" "${dstexefile}" || exit 1

   if [ ! -z "${dstlibexecdir}" ]
   then
      r_mkdir_parent_if_missing "${dstlibdir}"

      log_debug "Creating symlink \"${dstlibdir}\""
      exekutor ln -s -f "${srclibexecdir}/src" "${dstlibdir}" || exit 1
   fi
}



## tool_delete_list()
## {
##    # the sed works like this:
##    # expect <toolname>;<command>
##    # '/;remove$/!d' is the same as grep -E
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

env::tool::r_oslist()
{
   log_entry "env::tool::r_oslist" "$@"

   local name
   local filename
   local filenames

   .foreachfile filename in "${MULLE_ENV_SHARE_DIR}"/tool* \
                            "${MULLE_ENV_ETC_DIR}"/tool*
   .do
      name="${filename##*tool.}"
      if [ "${filename}" = "${name}" ]
      then
         name="DEFAULT"
      fi

      r_add_unique_line "${filenames}" "${name}"
      filenames="${RVAL}"
   .done

   RVAL="${filenames}"
}


env::tool::r_scoped_get()
{
   log_entry "env::tool::r_scoped_get" "$@"

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
         if env::tool::r_get "${tool}" \
                             "${MULLE_ENV_SHARE_DIR}/tool-plugin" \
                             "${MULLE_ENV_SHARE_DIR}/tool-plugin${extension}"
         then
            return 0
         fi
      ;;

      'extension')
         if env::tool::r_get "${tool}" \
                             "${MULLE_ENV_SHARE_DIR}/tool-plugin" \
                             "${MULLE_ENV_SHARE_DIR}/tool-plugin${extension}" \
                             "${MULLE_ENV_SHARE_DIR}/tool-extension" \
                             "${MULLE_ENV_SHARE_DIR}/tool-extension${extension}"
         then
            return 0
         fi
      ;;

      *)
         if env::tool::r_get "${tool}" \
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


env::tool::add()
{
   log_entry "env::tool::add" "$@"

   local scope="$1" ; shift
   local os="$1" ; shift

   local OPTION_OPTIONALITY='DEFAULT'
   local OPTION_COMPILE_LINK='DEFAULT'
   local OPTION_REMOVE='NO'
   local OPTION_CSV='NO'
   local OPTION_RESOLVE='YES'
   local OPTION_IF_MISSING='NO'
   local OPTION_SCRIPT='NO'

   while [ $# -ne 0 ]
   do
      case "$1" in
         -h*|--help|help)
            env::tool::add_usage
         ;;

         -o|--optional|--no-required)
            OPTION_OPTIONALITY='YES'
         ;;

         --if-missing)
            OPTION_IF_MISSING='YES'
         ;;

         --csv)
            OPTION_CSV='YES'
         ;;

         --resolve)
            OPTION_RESOLVE='YES'
         ;;

         --no-resolve)
            OPTION_RESOLVE='NO'
         ;;

         --script)
            OPTION_SCRIPT='YES'
         ;;

         --no-script)
            OPTION_SCRIPT='NO'
         ;;

         --required|--no-optional)
            OPTION_OPTIONALITY='NO'
         ;;

         --remove)
            OPTION_REMOVE='YES'
         ;;

         --compile-link)
            OPTION_COMPILE_LINK='YES'
         ;;

         --no-compile-link)
            OPTION_COMPILE_LINK='NO'
         ;;

         -*)
            env::tool::add_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   [ $# -lt 1 ] && env::tool::add_usage "Missing tool name"

   local tool

   [ -z "${MULLE_ENV_ETC_DIR}" ]   && _internal_fail "MULLE_ENV_ETC_DIR not defined"
   [ -z "${MULLE_ENV_SHARE_DIR}" ] && _internal_fail "MULLE_ENV_SHARE_DIR not defined"

   local lockingdir
   local protecingdir

   case "${scope}" in
      plugin|extension)
         lockingdir="${MULLE_ENV_SHARE_DIR}"
         protectingdir="${MULLE_ENV_SHARE_DIR}"
      ;;

      *)
         lockingdir="${MULLE_ENV_ETC_DIR}"
         protectingdir=""
      ;;
   esac

   mkdir_if_missing "${lockingdir}"
   env::lock_existing_directory "${lockingdir}"
   case $? in
      0|2)
      ;;

      3)
         log_warning "Overriding stale lock"
      ;;

      1)
         fail "Unable to lock \"${lockingdir}\", competing process is stuck ?"
      ;;
   esac

   if [ ! -z "${protectingdir}" ]
   then
      env::unprotect_dir_if_exists "${protectingdir}"
   fi


   # zsh no like in loop locals
   local extension
   local doesexist
   local mark
   local rval

   # run in subshell to protect cleanly afterwards
   (
      while [ $# -ne 0 ]
      do
         tool="$1"
         shift

         [ -z "${tool}" ] && env::tool::add_usage "Empty tool name"

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
            if [ "${OPTION_OPTIONALITY}" = 'NO' ]
            then
               mark="required"
            fi

            # this overrides/ignores optional
            if [ "${OPTION_REMOVE}" = 'YES' ]
            then
               mark="remove"
            fi
         fi

         if [ "${OPTION_RESOLVE}" = 'NO' ]
         then
            r_comma_concat "${mark}" "no-resolve"
            mark="${RVAL}"
         fi

         if [ "${OPTION_SCRIPT}" = 'YES' ]
         then
            r_comma_concat "${mark}" "script"
            mark="${RVAL}"
         fi

         if [ "${os}" = "DEFAULT" ]
         then
            extension=""
         else
            extension=".${os}"
         fi

         doesexist='NO'
         if env::tool::r_scoped_get "${scope}" "${os}" "${tool}"
         then
            doesexist='YES'
         fi

         case "${mark}" in
            remove)
               if [ "${doesexist}" = 'NO' ]
               then
                  log_verbose "\"${tool}\" is already deinstalled"
                  continue
               fi
            ;;

            *)
               if [ "${doesexist}" = 'YES' ]
               then
                  if [ "${OPTION_IF_MISSING}" = 'YES' ]
                  then
                     continue
                  fi
                  fail "\"${tool}\" is already installed"
               fi
            ;;
         esac

         if [ ! -z "${mark}" ]
         then
            tool="${tool};${mark}"
         fi

         rval=0

         case "${scope}" in
            plugin|extension)
               tool_filename="${MULLE_ENV_SHARE_DIR}/tool-${scope}${extension}"
               redirect_append_exekutor "${tool_filename}" printf "%s\n" "${tool}"
               rval=$?
            ;;

            *)
               mkdir_if_missing "${MULLE_ENV_ETC_DIR}"
               tool_filename="${MULLE_ENV_ETC_DIR}/tool${extension}"
               redirect_append_exekutor "${tool_filename}" printf "%s\n" "${tool}"
               rval=$?
            ;;
         esac

         if [ $rval -ne 0 ]
         then
            exit 1
         fi

         if [ "${OPTION_REMOVE}" != 'YES' ]
         then
            case "${os}" in
               'DEFAULT')
                  _log_info "Tool ${C_MAGENTA}${C_BOLD}${tool}${C_INFO} added.
Use ${C_RESET_BOLD}--os <os> add${C_INFO} to restrict tool to a certain OS."
               ;;

               *)
                  _log_info "Tool ${C_MAGENTA}${C_BOLD}${tool}${C_INFO} added for ${C_MAGENTA}${C_BOLD}${os}${C_INFO}.
Use ${C_RESET_BOLD}--global add${C_VERBOSE} to make tool available on all platforms."
               ;;
            esac
         fi
      done
   )
   rval=$?

   if [ ! -z "${protectingdir}" ]
   then
      env::protect_dir_if_exists "${protectingdir}"
   fi
   env::unlock_existing_directory "${lockingdir}"

   if [ $rval -ne 0 ]
   then
      exit 1
   fi

   if [ "${OPTION_COMPILE_LINK}" != 'NO' ]
   then
      if [ "${OPTION_COMPILE_LINK}" != 'DEFAULT' -o ! -z "${MULLE_VIRTUAL_ROOT}" ]
      then
         log_debug "compile and link as : OPTION_COMPILE_LINK is \"${OPTION_COMPILE_LINK}\" and MULLE_VIRTUAL_ROOT is \"${MULLE_VIRTUAL_ROOT}\""
         env::tool::link --compile-if-needed
      fi
   fi
}

env::tool::sort()
{
   # reverse, sort
   # 'abc;123;first
   # def;456;old
   # abc;789;second
   # abc;999;last
   # def;111;newest
   # xyz;333;solo'
   #
   # produces:
   #
   # abc;999;last
   # def;111;newest
   # xyz;333;solo

   sed '1!G;h;$!d' \
   | sort -t';' -k1,1 -u
}

env::tool::compile()
{
   log_entry "env::tool::compile" "$@"

   [ -z "${MULLE_ENV_ETC_DIR}" ]      && _internal_fail "MULLE_ENV_ETC_DIR not defined"
   [ -z "${MULLE_ENV_SHARE_DIR}" ]    && _internal_fail "MULLE_ENV_SHARE_DIR not defined"
   [ -z "${MULLE_ENV_VAR_DIR}" ]      && _internal_fail "MULLE_ENV_VAR_DIR not defined"
   [ -z "${MULLE_ENV_HOST_VAR_DIR}" ] && _internal_fail "MULLE_ENV_HOST_VAR_DIR not defined"

   local ifneeded='NO'

   local extension
   local bindir

   extension=".${MULLE_UNAME}"

   while [ $# -ne 0 ]
   do
      case "$1" in
         -h*|--help|help)
            env::tool::compile_usage
         ;;

         --if-needed)
            ifneeded='YES'
         ;;

         -*)
            env::tool::compile_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   [ $# -ne 0 ] && env::tool::compile_usage "superfluous arguments \"$*\""

   if [ "${ifneeded}" = 'YES' ]
   then
      env::tool::status "_log_fluff"
      case $? in
         0)
            return 0
         ;;

         1)
         ;;

         4)
            touch "${MULLE_ENV_HOST_VAR_DIR}/tool"
            return 0
         ;;
      esac
   fi

   local _filepath

   env::__get_tool_filepath "${MULLE_UNAME}"

   local lines
   local result
   local file
   local name
   local i

   .foreachpath file in ${_filepath}
   .do
      [ ! -f "${file}" ]  && .continue

      log_fluff "Compiling \"${file}\""

      lines="`rexekutor grep -E -v '^#' "${file}"`"

      .foreachline i in ${lines}
      .do
         case "${i}" in
            *';'*'remove'*)
               name="${i%;remove}"
               r_escaped_grep_pattern "${name}"
               result="`grep -E -v -x "^${RVAL}$|^${RVAL};.*$" <<< "${result}"`"
            ;;

            *)
               r_add_line "${result}" "${i}"
               result="${RVAL}"
            ;;
         esac
      .done
   .done

   mkdir_if_missing "${MULLE_ENV_HOST_VAR_DIR}"
   redirect_exekutor "${MULLE_ENV_HOST_VAR_DIR}/tool" env::tool::sort <<< "${result}" || exit 1
}


env::tool::r_get()
{
   log_entry "env::tool::r_get" "$@"

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

      lines="`grep -E -v '^#' "${file}" | grep -E "^${tool}$|^${tool};" `"

      .foreachline i in ${lines}
      .do
         case "${i}" in
            *';remove')
               result=""
            ;;

            *)
               foundfile="${file}"
               result="$i"
            ;;
         esac
      .done
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
env::tool::get()
{
   log_entry "env::tool::get" "$@"

   [ -z "${MULLE_ENV_ETC_DIR}" ]   && _internal_fail "MULLE_ENV_ETC_DIR not defined"
   [ -z "${MULLE_ENV_SHARE_DIR}" ] && _internal_fail "MULLE_ENV_SHARE_DIR not defined"

   local scope="$1" ; shift
   local os="$1" ; shift

   local OPTION_CSV='NO'

   while [ $# -ne 0 ]
   do
      case "$1" in
         -h*|--help|help)
            env::tool::get_usage
         ;;

         --csv)
            OPTION_CSV='YES'
         ;;

         -*)
            env::tool::get_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   [ $# -ne 1 ] && env::tool::get_usage "missing tool name"

   local tool

   tool="$1"

   [ -z "${tool}" ] && env::tool::get_usage "missing tool name"

   if ! env::tool::r_scoped_get "${scope}" "${os}" "${tool}"
   then
      return 1
   fi

   if [ "${OPTION_CSV}" = 'YES' ]
   then
      case "${RVAL}" in
         *\;*)
            printf "%s\n" "${RVAL}"
         ;;

         *)
            printf "%s;optional\n" "${RVAL}"
         ;;
      esac
   else
      printf "%s\n" "${RVAL%%;*}"
   fi
}


env::tool::link_tool()
{
   log_entry "env::tool::link_tool" "$@"

   local toolname="$1"
   local bindir="$2"
   local isrequired="$3"
   local resolve="$4"
   local script="$5"

   #
   # when stepping back and forth from environments, it may be that
   # we have the proper symlink already, but we don't have the PATH anymore
   # so lets check first that a link exists
   #
   if [ -e "${bindir}/${toolname}" -a "${MULLE_FLAG_MAGNUM_FORCE}" != 'YES' ]
   then
      log_fluff "Tool \"${toolname}\" already present"
      return 0
   fi

   local filename

   if [ -z "${script}" ]
   then
      case "${MULLE_UNAME}" in
         'mingw'|'msys')
            script='YES'
         ;;

         'windows')
            script='MAYBE'
         ;;

         *)
            script='NO'
         ;;
      esac
   fi

   local searchpath

   searchpath="${MULLE_OLDPATH}"
   if [ -z "${searchpath}" ]
   then
      searchpath="${PATH}"
      log_debug "MULLE_OLDPATH is empty (searching for \"$toolname\")"
   fi

   log_setting "MULLE_OLDPATH : ${searchpath}"
   log_setting "PATH          : ${searchpath}"

   filename="`PATH="${searchpath}" command -v "${toolname}" `"

   case "${filename}" in
      "")
         if [ "${isrequired}" = 'YES' ]
         then
            local text

            text="Required tool \"${toolname}\" not found (${PWD#"${MULLE_USER_PWD}/"}) not found in PATH:
${C_RESET}${searchpath}"
            if [ "${MULLE_FLAG_MAGNUM_FORCE}" = 'YES' ]
            then
               log_warning "${text}"
            else
               fail "${text}"
            fi
         else
            log_fluff "Tool \"${toolname}\" not found, but it's optional (${PWD#"${MULLE_USER_PWD}/"})"
         fi
         return 0
      ;;

      *.exe)
         if [ "${script}" = 'MAYBE' ]
         then
            script='YES'
         fi
      ;;

      #
      # the idea here is to keep the mulle tools in a local state
      # until upgrade, unaffected by other projects
      #
      /*/mulle-*-*-*)
         if [ "${OPTION_COPY_MULLE_TOOL}" = 'YES' ]
         then
            log_fluff "Copying mulle script \"${bindir}/${toolname}\""

            exekutor cp -p "${filename}" "${bindir}/" || exit 1
            return 0
         fi
      ;;

      /*)
      ;;

      *)
         # not absolute
         log_debug "Skipping builtin \"${filename}\""
         return
      ;;
   esac

   if [ "${script}" = 'YES' ]
   then
      log_debug "Creating script \"${bindir}/${toolname}\""

      local script_text

      script_text="#! /bin/sh

exec '${filename}' \"\$@\""
      redirect_exekutor "${bindir}/${toolname}" printf "%s\n" "${script_text}" || exit 1
      exekutor chmod 755 "${bindir}/${toolname}"  || exit 1
      return
   fi

   log_debug "Creating symlink \"${bindir}/${toolname}\""

   if [ "${resolve}" = 'YES' ]
   then
      if ! r_resolve_symlinks "${filename}"
      then
         fail "Broken symlink chain \"${filename}\""
      fi
      filename="${RVAL}"
   fi

   # memo: filename can change during "resolve" e.g awk -> gawk
   #       so keep toolname
   exekutor ln -sf "${filename}" "${bindir}/${toolname}" || exit 1
}


env::tool::unlink_tool()
{
   log_entry "env::tool::unlink_tool" "$@"

   local toolname="$1"
   local bindir="$2"

   log_debug "Removing \"${bindir}/${toolname}\""

   exekutor rm -f "${bindir}/${toolname}" || exit 1
}


env::tool::link_tools()
{
   log_entry "env::tool::link_tools" "$@"

   local toollines="$1"
   local bindir="$2"

   local toolname
   local isrequired
   local mark
   local resolve
   local script

   mkdir_if_missing "${bindir}"

   .foreachline toolline in ${toollines}
   .do
      isrequired='NO'
      resolve='YES'
      operation="link"
      script=""

      IFS=";" read -r toolname mark <<< "${toolline}"

      case ",${mark}," in
         *,remove,*)
            operation="unlink"
         ;;
      esac

      case ",${mark}," in
         *,required,*)
            isrequired='YES'
         ;;
      esac

      case ",${mark}," in
         *,no-resolve,*)
            resolve='NO'
         ;;
      esac

      case ",${mark}," in
         *,no-script,*)
            script='NO'
         ;;
      esac

      case ",${mark}," in
         *,script,*)
            script='YES'
         ;;
      esac

      env::tool::${operation}_tool "${toolname}"   \
                                   "${bindir}"     \
                                   "${isrequired}" \
                                   "${resolve}"    \
                                   "${script}"
   .done

   rmdir_if_empty "${bindir}"
}


env::tool::link()
{
   log_entry "env::tool::link" "$@"

   local compile_if_needed='NO'
   local compile='NO'
   local compile_flags
   local OPTION_DELETE='YES'
   local bindir

   bindir="${MULLE_ENV_HOST_VAR_DIR}/bin"

   if [ "${MULLE_FLAG_MAGNUM_FORCE}" = 'YES' ]
   then
      compile='YES'
   fi

   while [ $# -ne 0 ]
   do
      case "$1" in
         -h*|--help|help)
            env::tool::link_usage
         ;;

         --no-delete)
            OPTION_DELETE='NO'
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
            env::tool::link_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   if [ "${compile}" = 'YES' ]
   then
      env::tool::compile ${compile_flags}
   fi

   if [ "${OPTION_DELETE}" = 'YES' ]
   then
      rmdir_safer "${bindir}"
      if [ ${ZSH_VERSION+x} ]
      then
         rehash # ensure that we don't do old commands
      else
         hash -r
      fi
      exekutor mkdir "${bindir}"
   fi

   local toolfile
   local toollines

   toolfile="${MULLE_ENV_HOST_VAR_DIR}/tool"

   toollines="`grep -E -v '^#' "${toolfile}" 2> /dev/null`"
   if [ -z "${toollines}" ]
   then
      log_info "No tools defined in \"${toolfile}\""
      return
   fi

   env::tool::link_tools "${toollines}" "${bindir}"
}


env::tool::doctor()
{
   log_entry "env::tool::doctor" "$@"

   local bindir="$1"
   local toolfile="$2"

   local symlink
   local rval
   local found 
   local any
   local cmd

   .foreachline cmd in `grep -E -v '^#' "${toolfile}" 2>/dev/null`
   .do
      if shell_is_builtin_command "${cmd}"
      then
         .continue
      fi

      if [ ! -e "${bindir}/${cmd}" ]
      then
         if mudo -f which "${cmd}" 2> /dev/null
         then
            _log_warning "Tool ${C_RESET_BOLD}${cmd}${C_WARNING} has recently been installed
${C_INFO}Refresh your custom environment with
${C_RESET_BOLD}   ${MULLE_USAGE_NAME} tool link"
         fi
      fi
   .done

   rval=0
   any='NO'

   .foreachfile symlink in "${bindir}"/*
   .do
      any='YES'
      #https://stackoverflow.com/questions/8049132/how-can-i-detect-whether-a-symlink-is-broken-in-bash
      if [ ! -e "${symlink}" ]
      then
         rval=1

         r_basename "${symlink}"

         found="`mudo -f which "${RVAL}" `"
         if [ ! -z "${found}" ]
         then
            _log_error "Tool ${C_RESET_BOLD}${RVAL}${C_ERROR} is in a different place
${C_INFO}You can probably fix this with
${C_RESET_BOLD}   ${MULLE_USAGE_NAME} tool link"
         else
            log_error "Tool ${C_RESET_BOLD}${RVAL}${C_ERROR} is not available"
         fi
      fi
   .done

   if [ ${rval} -eq 0 ]
   then
      if [ "${any}" = 'NO' ]
      then
         log_warning "No tools found"
      else
         log_info "No link problems found"
      fi
   fi

   return $rval
}


env::tool::_list_file()
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
   local toolfilename

   .foreachline toolline in `grep -E -v '^#' "${filename}"`
   .do
      [ -z "${toolline}" ] && .continue

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

         if [ "${mark}" != "remove" ]
         then
            toolfilename="`command -v "${toolname}" `"
            case "${toolfilename}" in
               /*)
                  if [ -x "${MULLE_ENV_HOST_VAR_DIR}/bin/${toolname}" ]
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
                        printmark="${printmark},builtin"
                     fi
                  fi
               ;;
            esac
         fi
      fi

      printf '%b%s%b%s\n' "${color_start}" "${toolname}${printmark}" "${color_end}"
   .done

   echo
}


env::tool::_list()
{
   log_entry "env::tool::_list" "$@"

   local os="$1"
   local color="$2"
   local csv="$3"
   local builtin="$4"

   local toolfiles

   env::r_get_existing_tool_filepath "${os}"
   toolfiles="${RVAL}"

   local file
   local directory
   local name

   IFS=':'
   for file in ${toolfiles}
   do
      IFS="${DEFAULT_IFS}"

      r_dirname "${file}"
      r_dirname "${RVAL}"
      r_basename "${RVAL}"
      directory="${RVAL}"

      r_basename "${file}"
      name="${RVAL}"

      log_info "${directory}/${name}"

      env::tool::_list_file "${file}" "${color}" "${csv}" "${builtin}"
   done

   IFS="${DEFAULT_IFS}"
}


env::tool::list()
{
   log_entry "env::tool::list" "$@"

   [ -z "${MULLE_ENV_ETC_DIR}" ]   && _internal_fail "MULLE_ENV_ETC_DIR not defined"
   [ -z "${MULLE_ENV_SHARE_DIR}" ] && _internal_fail "MULLE_ENV_SHARE_DIR not defined"

   local OPTION_COLOR='YES'
   local OPTION_CSV='YES'
   local OPTION_BUILTIN='YES'

   local os="$1" ; shift

   while [ $# -ne 0 ]
   do
      case "$1" in
         -h*|--help|help)
            env::tool::list_usage
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
            env::tool::list_usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   case "$1" in
      file|files)
         env::r_get_existing_tool_filepath "${os}"
         printf "%s\n" "${RVAL}"
      ;;

      os|oss)
         env::tool::r_oslist
         sort <<< "${RVAL}"
         return 0
      ;;

      compiled)
         if [ ! -f "${MULLE_ENV_HOST_VAR_DIR}/tool" ]
         then
            fail "No compiled tool list available yet (compile to make one)"
         fi
         rexekutor cat "${MULLE_ENV_HOST_VAR_DIR}/tool"
      ;;

      ""|tool|tools)
         env::tool::_list "${os}" "${OPTION_COLOR}" "${OPTION_CSV}" "${OPTION_BUILTIN}"
      ;;

      *)
         env::tool::list_usage "Unknown argument \"$1\""
      ;;
   esac
}


##
## status code is in main now
##
env::tool::status()
{
   log_entry "env::tool::status" "$@"

   local logger="${1:-_log_info}"

   env::get_tool_status "$@"
   rval=$?

   case $rval in
      0)
         ${logger} "OK"
      ;;
      1)
         ${logger} "Compile"
      ;;
      4)
         ${logger} "Empty"
      ;;
   esac

   return $rval
}



###
### parameters and environment variables
###
env::tool::main()
{
   log_entry "env::tool::main" "$@"

 
   #
   # handle options
   #
   local OPTION_SCOPE="DEFAULT"
   local OPTION_OS="${MULLE_UNAME}"

   while [ $# -ne 0 ]
   do
      case "$1" in
         -h*|--help|help)
            env::tool::usage
         ;;

         --plugin|--extension)
            OPTION_SCOPE="${1:2}"
         ;;

         --global|--common)
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
            env::tool::usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   local cmd="$1"
   if [ ! -z "${cmd}" ]
   then
      shift
   fi


   local rval
   local bindir
   local libexecdir

   [ -z "${MULLE_ENV_HOST_VAR_DIR}" ] && _internal_fail "MULLE_ENV_HOST_VAR_DIR not defined"

   bindir="${MULLE_ENV_HOST_VAR_DIR}/bin"
   libexecdir="${MULLE_ENV_HOST_VAR_DIR}/libexec"

   case "${cmd:-list}" in
      add)
         mkdir_if_missing "${MULLE_ENV_HOST_VAR_DIR}"
         env::lock_existing_directory "${MULLE_ENV_HOST_VAR_DIR}"
         case $? in
            0|2)
            ;;

            3)
               log_warning "Overriding stale lock"
            ;;

            1)
               # if we a locked after a timeout, assume another process set it
               # up already, so don't do it again
               fail "Unable to lock \"${MULLE_ENV_HOST_VAR_DIR}\", competing process is stuck ?"
            ;;
         esac

         env::unprotect_dir_if_exists "${bindir}"
         env::unprotect_dir_if_exists "${libexecdir}"
         (
            env::tool::add "${OPTION_SCOPE}" \
                           "${OPTION_OS}" \
                           "$@"
         )
         rval=$?
         env::protect_dir_if_exists "${bindir}"
         env::protect_dir_if_exists "${libexecdir}"
         env::unlock_existing_directory "${MULLE_ENV_HOST_VAR_DIR}"
         return $rval
      ;;

      bin-dir)
         printf "%s\n" "${bindir}"
      ;;

      libexec-dir)
         printf "%s\n" "${libexecdir}"
      ;;

      doctor)
         env::tool::doctor "${bindir}" "${MULLE_ENV_HOST_VAR_DIR}/tool"
      ;;

      compile)
         env::tool::compile "$@"
      ;;

      get)
         env::tool::get "${OPTION_SCOPE}" \
                       "${OPTION_OS}" \
                       "$@"
      ;;

      link)
         mkdir_if_missing "${MULLE_ENV_HOST_VAR_DIR}"
         env::lock_existing_directory "${MULLE_ENV_HOST_VAR_DIR}"
         case $? in
            0|2)
            ;;

            3)
               log_warning "Overriding stale lock"
            ;;


            1)
               # if we a locked after a timeout, assume another process set it
               # up already, so don't do it again
               fail "Unable to lock \"${MULLE_ENV_HOST_VAR_DIR}\", competing process is stuck ?"
            ;;
         esac

         env::unprotect_dir_if_exists "${bindir}"
         env::unprotect_dir_if_exists "${libexecdir}"
         (
            env::tool::link "$@"
         )
         rval=$?
         env::protect_dir_if_exists "${bindir}"
         env::protect_dir_if_exists "${libexecdir}"
         env::unlock_existing_directory "${MULLE_ENV_HOST_VAR_DIR}"
         return $rval
      ;;

      list)
         env::tool::list "${OPTION_OS}" \
                         "$@"
      ;;

      remove)
         mkdir_if_missing "${MULLE_ENV_HOST_VAR_DIR}"
         env::lock_existing_directory "${MULLE_ENV_HOST_VAR_DIR}"
         case $? in
            0|2)
            ;;

            3)
               log_warning "Overriding stale lock"
            ;;


            1)
               # if we a locked after a timeout, assume another process set it
               # up already, so don't do it again
               fail "Unable to lock \"${MULLE_ENV_HOST_VAR_DIR}\", competing process is stuck ?"
            ;;
         esac

         env::unprotect_dir_if_exists "${bindir}"
         env::unprotect_dir_if_exists "${libexecdir}"
         (
            env::tool::add "${OPTION_SCOPE}" \
                          "${OPTION_OS}" \
                          --remove \
                          "$@"
         )
         rval=$?
         env::protect_dir_if_exists "${bindir}"
         env::protect_dir_if_exists "${libexecdir}"
         env::unlock_existing_directory "${MULLE_ENV_HOST_VAR_DIR}"
         return $rval
      ;;

      status)
         env::tool::status "$@"
      ;;

      *)
         env::tool::usage "Unknown command \"${cmd}\""
      ;;
   esac
}
