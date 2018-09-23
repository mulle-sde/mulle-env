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
MULLE_ENV_PLUGINS_SH="included"


r_plugin_searchpath()
{
   r_simplified_path "${MULLE_ENV_LIBEXEC_DIR}/../share/mulle-env/plugins"
   r_colon_concat "${RVAL}" \
                  "${MULLE_ENV_LIBEXEC_DIR}/plugins"
   r_colon_concat "${MULLE_ENV_PLUGIN_PATH}" "${RVAL}"

   log_debug "plugin searchpath: ${RVAL}"
}


_env_all_plugin_names()
{
   log_entry "_env_all_plugin_names"

   [ -z "${DEFAULT_IFS}" ] && internal_fail "DEFAULT_IFS not set"
   [ -z "${MULLE_ENV_LIBEXEC_DIR}" ] && internal_fail "MULLE_ENV_LIBEXEC_DIR not set"

   local searchpath
   local RVAL

   r_plugin_searchpath
   searchpath="${RVAL}"

   local directory
   local pluginpath

   IFS=":"
   for directory in ${searchpath}
   do
      IFS="
"
      for pluginpath in `ls -1 "${directory}"/*.sh 2> /dev/null`
      do
         basename -- "${pluginpath}" .sh
      done
      IFS=":"
   done

   IFS="${DEFAULT_IFS}"
}


env_all_plugin_names()
{
   log_entry "env_all_plugin_names" "$@"

   _env_all_plugin_names "$@" | sort -u
}


env_load_plugin()
{
   log_entry "env_load_plugin" "$@"

   local flavor="$1"

   [ -z "${MULLE_ENV_LIBEXEC_DIR}" ] && \
      internal_fail "MULLE_ENV_LIBEXEC_DIR not set"

   local searchpath
   local RVAL

   r_plugin_searchpath
   searchpath="${RVAL}"

   local directory
   local pluginpath

   IFS=":"
   for directory in ${searchpath}
   do
      IFS="${DEFAULT_IFS}"

      pluginpath="${directory}/${flavor}.sh"
      if [ -f "${pluginpath}" ]
      then
         . "${pluginpath}" || exit 1

         log_fluff "Env plugin \"${flavor}\" loaded"
         return
      fi
      IFS=":"
   done
   IFS="${DEFAULT_IFS}"

   fail "No plugin \"${flavor}\" found in ${searchpath}"
}
