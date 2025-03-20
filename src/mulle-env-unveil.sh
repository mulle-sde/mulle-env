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
MULLE_ENV_UNVEIL_SH='included'


#
# This needs a complete rewrite:
#
env::unveil::usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} unveil [options]

   Experimental support for "unveil" style sandboxing. This commands emits
   a CSV with paths and permission for executables accessible to the
   virtual environment:

      /usr/bin;rx
      /usr/local/bin/foobar;rx

   This output will not be sufficient, as you likely will have to open access
   to directories like /lib or /etc as well.

   For a linux landlock sandbox try:
      https://github.com/marty1885/landlock-unveil

Options:
   --optimize    : remove CSV lines already allowed by directory (default)
   --no-optimize : do not optimize CSV

EOF
   exit 1
}


env::unveil::emit_symlinks()
{
   log_entry "env::unveil::emit_symlinks" "$@"

   local directory="$1"
   local permissions="$2"
   local directories="$3"

   include "file"

   local filename
   local resolved
   local link
   local skip
   local bindir

   .foreachline filename in `dir_list_files "${directory}" "*" "l"`
   .do
      link="${filename}"
      while resolved="`rexekutor readlink "${link}"`"
      do
         if ! is_absolutepath "${resolved}"
         then
            r_dirname "${link}"
            r_filepath_concat "${RVAL}" "${resolved}"
            resolved="${RVAL}"
         fi

         skip='NO'
         .foreachpath bindir in ${directories}
         .do
            if string_has_prefix "${resolved}" "${bindir%%/}/"
            then
               skip='YES'
               .break
            fi
         .done

         if [ ! -h "${resolved}" ]
         then
            if [ "${skip}" = 'NO' ]
            then
               if [ -d "${resolved}" ]
               then
                  printf "%s;%s;d\n" "${resolved%%/}" "${permissions}"
               else
                  printf "%s;%s;f\n" "${resolved%%/}" "${permissions}"
               fi
            fi
            .break
         fi

         if [ "${skip}" = 'NO' ]
         then
            printf "%s;%s;l\n" "${resolved%%/}" "${permissions}"
         fi
         link="${resolved}"
      done
   .done
}


env::unveil::emit_directory()
{
   log_entry "env::unveil::emit_directory" "$@"

   local directory="$1"
   local permissions="${2:-rx}"
   local symlinks="$3"
   local directories="$4"

   if [ -d "${directory}" ]
   then
      printf "%s;%s;d\n" "${directory%%/}" "${permissions}"
      if [ "${symlinks}" = 'YES' ]
      then
         env::unveil::emit_symlinks "${directory}" "${permissions}" "${directories}"
      fi
   fi
}


env::unveil::r_style_path()
{
   log_entry "env::unveil::r_style_path" "$@"

   local style="$1"

   case "${style}" in
      */wild|*/inherit)
         RVAL="${PATH}"
      ;;

      */relax)
         case "${MULLE_UNAME}" in
            linux)
               RVAL="/bin:/usr/bin"
            ;;

            *)
               RVAL="/bin:/usr/bin"
            ;;
         esac
      ;;

      */tight|*/restrict)
         RVAL=
      ;;

      *)
         fail "Unknown style \"${style}\""
      ;;
   esac
}


env::unveil::emit()
{
   log_entry "env::unveil::emit" "$@"

   local style="$1"
   local symlinks="$2"

   local directories
   local directory

   env::unveil::r_style_path "${style}"
   directories="${RVAL}"

   r_colon_concat "${directories}" "${MULLE_ENV_HOST_VAR_DIR}/bin"
   r_colon_concat "${RVAL}" "${MULLE_ENV_VAR_DIR}/bin"
   directories="${RVAL}"

   .foreachpath directory in ${directories}
   .do
      env::unveil::emit_directory "${directory}" "rx" "${symlinks}" "${directories}"
   .done

#   env::unveil::emit_directory "${MULLE_ENV_HOST_VAR_DIR}/bin"
   env::unveil::emit_directory "${MULLE_ENV_HOST_VAR_DIR}/lib"     ""  'NO'
   env::unveil::emit_directory "${MULLE_ENV_HOST_VAR_DIR}/share"   "r" 'NO'
   env::unveil::emit_directory "${MULLE_ENV_HOST_VAR_DIR}/libexec" ""  'YES'

#   env::unveil::emit_directory "${MULLE_ENV_VAR_DIR}/bin"
   env::unveil::emit_directory "${MULLE_ENV_VAR_DIR}/lib"     ""  'NO'
   env::unveil::emit_directory "${MULLE_ENV_VAR_DIR}/share"   "r" 'NO'
   env::unveil::emit_directory "${MULLE_ENV_VAR_DIR}/libexec" ""  'YES'
}


###
### parameters and environment variables
###
env::unveil::main()
{
   log_entry "env::unveil::main" "$@"

   local OPTION_SYMLINKS='DEFAULT'

   while [ $# -ne 0 ]
   do
      case "$1" in
         -h*|--help|help)
            env::unveil::usage
         ;;

         --symlinks)
            OPTION_SYMLINKS='YES'
         ;;

         --no-symlinks)
            OPTION_SYMLINKS='NO'
         ;;

         -*)
            env::unveil::usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   [ "${OPTION_STYLE}" != 'DEFAULT' ] && fail "You can't change the style with unveil"

   local sharedir
   local vardir

   sharedir="${MULLE_ENV_SHARE_DIR}"
   vardir="${MULLE_ENV_HOST_VAR_DIR}"

   local _style
   local _flavor

   if ! env::__get_saved_style_flavor "${vardir}" "${sharedir}"
   then
      env::fail_get_saved_style_flavor "${vardir}" "${sharedir}"
   fi

   #
   # collect directory lines
   #

   env::unveil::emit "${_style}" "${OPTION_SYMLINKS}" | sort -u
}
