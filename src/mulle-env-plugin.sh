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
MULLE_ENV_PLUGIN_SH="included"


#
# the main problem is brew, as brew symlinks to the folder
# but we need to get the source of the symlinks folder
#
env::plugin::r_installdir()
{
#   log_entry "env::plugin::r_installdir"

   local dev="${1:-YES}"

   # dev support
   if [ "${dev}" = 'YES' ]
   then
      case "${MULLE_ENV_LIBEXEC_DIR}" in
         */src)
            RVAL="/tmp/share/mulle-env/plugins"
            return
         ;;
      esac
   fi

   r_resolve_symlinks "$0"
   r_simplified_path "${RVAL}/../../share/mulle-env/plugins"
#   log_debug "plugin install directory: ${RVAL}"
}


env::plugin::r_searchpath()
{
#   log_entry "env::plugin::r_searchpath"

   if [ ${_ENV_PLUGIN_SEARCHPATH+x} ]
   then
      RVAL="${_ENV_PLUGIN_SEARCHPATH}"
   fi

	local searchpath

	searchpath="${MULLE_ENV_PLUGIN_PATH:-}"

	#
	# add wherever we are that share directory
	# i.e.  /usr/libexec/mulle-env -> /usr/share/mulle-env
	#
   env::plugin::r_installdir
   r_colon_concat "${searchpath}" "${RVAL}"
   searchpath="${RVAL}"

   r_colon_concat "${searchpath}" "${MULLE_SDE_EXTENSION_BASE_PATH:-}"
   searchpath="${RVAL}"

   r_colon_concat "${searchpath}" "/usr/local/share/mulle-env/plugins"
   searchpath="${RVAL}"

   r_colon_concat "${searchpath}" "/usr/share/mulle-env/plugins"
   searchpath="${RVAL}"

   # builtin plugins last
   r_simplified_path "${MULLE_ENV_LIBEXEC_DIR}/plugins"
   r_colon_concat "${searchpath}" "${RVAL}"
   searchpath="${RVAL}"

#   log_debug "plugin searchpath: ${searchpath}"
   RVAL="${searchpath}"
}


env::plugin::_all_names()
{
   log_entry "env::plugin::_all_names"

   local searchpath

   env::plugin::r_searchpath
   searchpath="${RVAL}"

   local directory
   local pluginpath

   .foreachpath  directory in ${searchpath}
   .do
      .foreachline pluginpath in `ls -1 "${directory}"/*.sh 2> /dev/null`
      .do
         basename -- "${pluginpath}" .sh
      .done
   .done
}


env::plugin::all_names()
{
   log_entry "env::plugin::all_names" "$@"

   env::plugin::_all_names "$@" | sort -u
}


env::plugin::do_load()
{
   log_entry "env::plugin::do_load" "$@"

   local flavor="$1"
   local searchpath="$2"

   [ -z "${MULLE_ENV_LIBEXEC_DIR}" ] && \
      _internal_fail "MULLE_ENV_LIBEXEC_DIR not set"

   local directory
   local pluginpath

   .foreachpath directory in ${searchpath}
   .do
      r_filepath_concat "${directory}" "${flavor}.sh"
      pluginpath="${RVAL}"

      if [ -f "${pluginpath}" ]
      then
         log_verbose "Loading env plugin ${pluginpath#"${MULLE_USER_PWD}/"}"
         . "${pluginpath}" || exit 1

         return 0
      else
         log_debug "No plugin found at ${pluginpath#"${MULLE_USER_PWD}/"}"
      fi
   .done

   log_fluff "No plugin found"
   return 1
}


env::plugin::load()
{
   log_entry "env::plugin::load" "$@"

   local flavor="$1"

   local searchpath

   env::plugin::r_searchpath
   searchpath="${RVAL}"

   if env::plugin::do_load "${flavor}" "${searchpath}"
   then
      log_debug "Env plugin \"${flavor}\" loaded"
      return
   fi

   fail "No plugin \"${flavor}\" found in \"${searchpath}\""
}


#
# assumes plugin has already been loaded
#
env::plugin::upgrade()
{
   log_entry "env::plugin::upgrade" "$@"

   local flavor="$1"
   local oldversion="$2"
   local version="$3"

   local functionname

   functionname="env::plugin::${flavor}::migrate"
   if shell_is_function "${functionname}"
   then
      log_fluff "Migrating ${flavor} plugin"
      rexekutor "${functionname}" "${oldversion}" "${version}"
   fi
}


# cache this PATH
env::plugin::initialize()
{
   env::plugin::r_searchpath

   _ENV_PLUGIN_SEARCHPATH="${RVAL}"
}

env::plugin::initialize

: