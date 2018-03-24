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
MULLE_ENV_INIT_SH="included"


env_init_options()
{
    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} [flags] init [options]

   Initialize the working directory for mulle-env.

Options:
   -d <dir>             : specify directory
   --style <tool:path>  : specify environment style

EOF

   cat <<EOF >&2

Tool-style:
   none                 : no additions
   mulle                : additionally support mulle-build (default)

Path-style:
   none                 : all tools must be specified in .mulle-env/etc/tools
   inherit              : inherit PATH, don't use tools links
   restrict             : /bin and /usr/bin are inherited. All other tools must
                          be specified.
   wild                 : inherit PATH and inherit environment
EOF
   exit 1
}



env_init_main()
{
   log_entry "env_init_main" "$@"

   local OPTION_NINJA="DEFAULT"
   local OPTION_CMAKE="DEFAULT"
   local OPTION_SVN="DEFAULT"
   local OPTION_AUTOCONF="DEFAULT"
   local OPTION_OTHER_TOOLS=
   local OPTION_BLURB="DEFAULT"

   local directory

   directory="${PWD}"

   while [ $# -ne 0 ]
   do
      case "$1" in
         -h*|--help|help)
            usage
         ;;

         -d|--directory)
            [ $# -eq 1 ] && fail "Missing argument to $1"
            shift

            directory="$1"
         ;;

         --autoconf)
            OPTION_AUTOCONF="YES"
         ;;

         --no-autoconf)
            OPTION_AUTOCONF="NO"
         ;;

         --blurb)
            OPTION_BLURB="YES"
         ;;

         --no-blurb)
            OPTION_BLURB="NO"
         ;;

         --cmake)
            OPTION_CMAKE="YES"
         ;;

         --no-cmake)
            OPTION_CMAKE="NO"
         ;;

         --ninja)
            OPTION_NINJA="YES"
         ;;

         --no-ninja)
            OPTION_NINJA="NO"
         ;;

         --svn)
            OPTION_SVN="YES"
         ;;

         --no-svn)
            OPTION_SVN="NO"
         ;;

         -s|--style)
            [ $# -eq 1 ] && fail "missing argument to $1"
            shift

            OPTION_STYLE="$1"
         ;;

         -t|--tool)
            [ $# -eq 1 ] && fail "missing argument to $1"
            shift

            OPTION_OTHER_TOOLS="`add_line "${OPTION_OTHER_TOOLS}" "$1" `"
         ;;

         -*)
            fail "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   [ "$#" -eq 0 ] || fail "Superflous arguments $*"

   local envfile
   local envincludefile
   local toolsfile
   local stylefile
   local versionfile
   local sharedir
   local optional_toolsfile
   local completionfile

   MULLE_ENV_DIR="${directory}/.mulle-env"

   sharedir="${MULLE_ENV_DIR}/share"

   envfile="${sharedir}/environment.sh"
   envincludefile="${sharedir}/environment-include.sh"

   # user editable stuff in etc
   auxfile="${sharedir}/environment-global.sh"
   darwinauxfile="${sharedir}/environment-os-darwin.sh"
   completionfile="${sharedir}/libexec/mulle-env-bash-completion.sh"

   toolsfile="${sharedir}/tool"
   optional_toolsfile="${sharedir}/optionaltool"
   versionfile="${sharedir}/version"

   stylefile="${sharedir}/style"

   if [ "${OPTION_MAGNUM_FORCE}" = "YES" ]
   then
      rmdir_safer ".mulle-env/bin"
      rmdir_safer ".mulle-env/libexec"
      rmdir_safer ".mulle-env/var"
      # don't throw away share though

      # remove some known trouble makers...
      remove_file_if_present   ".mulle-env/etc/style"
   else
      if [ -f "${envfile}" ]
      then
         log_warning "\"${envfile}\" already exists"
         return 2
      fi
   fi

   mkdir_if_missing "${sharedir}"
   find "${sharedir}" -type f -exec chmod ug+w {} \;

   # indicate a fresh init by removing a possibly old versionfile
   remove_file_if_present "${versionfile}"

   local style
   local flavor

   __get_user_style_flavor "${OPTION_STYLE}"
   __load_flavor_plugin "${flavor}"

   case "${style}" in
      */inherit|*/relax|*/restrict|*/tight|*/wild)
      ;;

      *)
         fail "unknown style \"${style}\""
      ;;
   esac

   log_verbose "Creating \"${envfile}\""

   local text

   if ! text="`print_${flavor}_startup_sh "${style}" `"
   then
      return 1
   fi
   redirect_exekutor "${envfile}" echo "${text}"

   local text

   log_verbose "Creating \"${envincludefile}\""
   if ! text="`print_${flavor}_include_sh "${style}" `"
   then
      return 1
   fi
   redirect_exekutor "${envincludefile}" echo "${text}"

   log_verbose "Creating \"${auxfile}\""
   if ! text="`print_${flavor}_environment_global_sh "${style}" `"
   then
      return 1
   fi
   redirect_exekutor "${auxfile}" echo "${text}"

   # add more os flavors later
   callback="print_${flavor}_environment_os_darwin_sh"
   if [ "`type -t "${callback}"`" = "function" ]
   then
      log_verbose "Creating \"${darwinauxfile}\""
      if ! text="`${callback} "${style}" `"
      then
         return 1
      fi
      redirect_exekutor "${darwinauxfile}" echo "${text}"
   fi

   log_verbose "Creating \"${toolsfile}\""
   if ! text="`print_${flavor}_tools_sh "${style}" `"
   then
      return 1
   fi
   redirect_exekutor "${toolsfile}" echo "${text}"

   log_verbose "Creating \"${optional_toolsfile}\""
   if ! text="`print_${flavor}_optional_tools_sh "${style}" `"
   then
      return 1
   fi
   redirect_exekutor "${optional_toolsfile}" echo "${text}"

   mkdir_if_missing "${sharedir}/libexec"
   log_verbose "Installing \"${completionfile}\""
   exekutor cp "${MULLE_ENV_LIBEXEC_DIR}/mulle-env-bash-completion.sh" \
          ${completionfile}

   log_verbose "Creating \"${stylefile}\""
   redirect_exekutor "${stylefile}" echo "${style}"

   # we create this last, if its present than the init ran through
   log_verbose "Creating \"${versionfile}\""
   redirect_exekutor "${versionfile}" echo "${MULLE_ENV_VERSION}"

   # chowning the directory is bad for git
   find "${sharedir}" -type f -exec chmod a-w {} \;

   if [ "${OPTION_BLURB}" != "NO" ]
   then
      log_info "Enter the environment:
   ${C_RESET_BOLD}${MULLE_EXECUTABLE_NAME} \"${directory}\"${C_INFO}"
   fi
}
