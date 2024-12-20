# shellcheck shell=bash
#
#   Copyright (c) 2018 Nat! - Mulle kybernetiK
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
MULLE_ENV_MIGRATE_SH='included'


env::migrate::move_directory()
{
   log_entry "env::migrate::move_directory" "$@"

   local srcdir="$1"
   local dstdir="$2"

   rmdir_if_empty "${srcdir}"
   if [ ! -d "${srcdir}" ]
   then
      return
   fi

   if [ -d "${dstdir}" ]
   then
      # move over contents
      exekutor ${MV:-mv} "${srcdir}"/* "${dstdir}/"
   else
      r_dirname "${dstdir}"
      mkdir_if_missing "${RVAL}"
      exekutor ${MV:-mv} "${srcdir}" "${dstdir}" || exit 1
   fi

   #
   # When we migrate unprotect the files for future edits
   # at the end the protection is re-done by init
   #
   exekutor chmod -R ug+wX "${dstdir}"
}


env::migrate::straight_convert_directory_if_present()
{
   log_entry "env::migrate::straight_convert_directory_if_present" "$@"

   local directory="$1"

   local subdir
   local name

   [ ! -d "${directory}" ] && return 4

   r_basename "${directory}"
   subdir="${RVAL}"

   r_dirname "${directory}"
   name="${RVAL##*-}"

   env::migrate::move_directory "${directory}" ".mulle/${subdir}/${name}"
}


env::migrate::convert_directory_if_present()
{
   log_entry "env::migrate::convert_directory_if_present" "$@"

   local srcdir="$1"
   local dstdir="$2"

   [ ! -d "${srcdir}" ] && return 4

   env::migrate::move_directory "${srcdir}" "${dstdir}"
}


env::migrate::rename_file_if_present()
{
   log_entry "env::migrate::rename_file_if_present" "$@"

   local srcfile="$1"
   local dstfile="$2"

   [ ! -f "${srcfile}" ] && return 4

   r_mkdir_parent_if_missing "${dstfile}"
   exekutor mv -f "${srcfile}" "${dstfile}"
}


env::migrate::migrate_from_v1_to_v2()
{
   log_entry "env::migrate::migrate_from_v1_to_v2" "$@"

   log_info "Migrating to mulle-env v2"

   if [ ! -d ".mulle-env" -a "${MULLE_FLAG_MAGNUM_FORCE}" != 'YES' ]
   then
      log_warning "There is nothing to migrate here"
      return
   fi

   if [ -d ".mulle/share/env" ]
   then
      log_warning "This project seems to have been migrated already"
   fi

   MV="mv"

# doesn't work reliably when files are not in git, bad idea
#   if [ -d ".git" ]
#   then
#      MV="git mv"
#   fi

   env::migrate::straight_convert_directory_if_present .mulle-sourcetree/etc
   rmdir_safer ".mulle-sourcetree"

   env::migrate::straight_convert_directory_if_present .mulle-match/share
   env::migrate::straight_convert_directory_if_present .mulle-match/env
   rmdir_safer ".mulle-match"

   env::migrate::straight_convert_directory_if_present .mulle-monitor/share
   env::migrate::straight_convert_directory_if_present .mulle-monitor/env
   rmdir_safer ".mulle-monitor"

   env::migrate::convert_directory_if_present .mulle-make .mulle/etc/craft/definition
   env::migrate::convert_directory_if_present .mulle-make.darwin .mulle/etc/craft/definition.darwin
   env::migrate::convert_directory_if_present .mulle-make.mingw .mulle/etc/craft/definition.mingw
   env::migrate::convert_directory_if_present .mulle-make.freebsd .mulle/etc/craft/definition.freebsd
   env::migrate::convert_directory_if_present .mulle-make.linux .mulle/etc/craft/definition.linux

   env::migrate::convert_directory_if_present .mulle-sde/share/libexec .mulle/share/monitor/libexec
   env::migrate::convert_directory_if_present .mulle-sde/etc/libexec .mulle/etc/monitor/libexec
   env::migrate::convert_directory_if_present .mulle-sde/share/bin .mulle/share/monitor/bin
   env::migrate::convert_directory_if_present .mulle-sde/etc/bin .mulle/etc/monitor/bin

   env::migrate::convert_directory_if_present .mulle-sde/share/match.d .mulle/share/match/match.d
   env::migrate::convert_directory_if_present .mulle-sde/etc/match.d .mulle/etc/match/match.d
   env::migrate::convert_directory_if_present .mulle-sde/share/ignore.d .mulle/share/match/ignore.d
   env::migrate::convert_directory_if_present .mulle-sde/etc/ignore.d .mulle/etc/match/ignore.d

   env::migrate::straight_convert_directory_if_present .mulle-sde/share
   env::migrate::straight_convert_directory_if_present .mulle-sde/etc

   rmdir_safer ".mulle-sde"

   local craftinfo

   .foreachfile craftinfo in craftinfo/*/mulle-make*
   .do
      env::migrate::convert_directory_if_present "${craftinfo}" "${craftinfo//mulle-make/definition}"
   .done

   local i

   .foreachfile i in craftinfo/*/CMakeLists.txt
   .do
      inplace_sed -e 's/mulle-make/definition/g' \
                  -e 's/BUILDINFO_DIRS/DEFINITION_DIRS/g' "${i}"
   .done

   # move mulle-project to .mulle to
   env::migrate::convert_directory_if_present "mulle-project" ".mulle/etc/project"

   env::migrate::straight_convert_directory_if_present .mulle-env/share
   env::migrate::straight_convert_directory_if_present .mulle-env/etc

   # remove some old clunckers

   remove_file_if_present .mulle-env/share/environment-aux.sh     # unused
   remove_file_if_present .mulle-env/share/environment-global.sh  # only etc!

   .foreachfile i in .mulle-env/share/environment*.sh .mulle-env/etc/environment*.sh
   .do
      if grep -E -q '^MULLE_SOURCETREE_SHARE_DIR=' "$i"
      then
         inplace_sed 's/^MULLE_SOURCETREE_SHARE_DIR=/MULLE_SOURCETREE_STASH_DIRNAME=/' "${i}"
      fi
   .done

   #
   # hack .gitignore for new paths, also remove some superfluous stuff and
   # correct typos
   #
   if [ -f ".gitignore" ]
   then
      local escaped_1

      r_escaped_sed_pattern ".mulle-*/var"
      escaped_1="${RVAL}"

      inplace_sed -e "s|${escaped_1}|.mulle/var|" \
                  -e "s|\.mulle-env/bin|.mulle/bin|" \
                  -e "s|\.mulle-env/libexec|.mulle/libexec|" \
                  -e "s|var and directories|var directories|" \
                  -e "/\.mulle-sourcetree\ is\ generally/d" \
                  -e "/\.mulle-sde\ is\ generally/d" \
                  -e "/\.mulle-sourcetree\/var/d" \
                  -e "s|\.mulle-env/etc|.mulle/etc/env|" \
                  -e "s|mulle-project/|.mulle/etc/project/|" .gitignore
   fi

   rmdir_safer ".mulle-env"
}


env::migrate::migrate_from_v2_0_to_v2_2()
{
   log_entry "env::migrate::migrate_from_v2_0_to_v2_2" "$@"

   log_info "Migrating to mulle-env v2.2"

   remove_file_if_present ".mulle/share/env/tool"
   remove_file_if_present ".mulle/share/env/tool.darwin"
   remove_file_if_present ".mulle/share/env/tool.freebsd"
   remove_file_if_present ".mulle/share/env/tool.linux"
   remove_file_if_present ".mulle/share/env/optionaltool"
   remove_file_if_present ".mulle/share/env/optionaltool.darwin"
   remove_file_if_present ".mulle/share/env/optionaltool.freebsd"
   remove_file_if_present ".mulle/share/env/optionaltool.linux"

   env::migrate::rename_file_if_present .mulle/share/env/auxscopes .mulle/share/env/auxscope
}


env::migrate::migrate_from_v2_2_to_v3()
{
   log_entry "env::migrate::migrate_from_v2_2_to_v3" "$@"

   local lines
   local scope

   local etc_lines
   local share_lines
   local order
   local priority

   log_info "Migrating to mulle-env 3"

   # shellcheck source=src/mulle-env-scope.sh
   [ -z "${MULLE_ENV_SCOPE_SH}" ] && . "${MULLE_ENV_LIBEXEC_DIR}/mulle-env-scope.sh"

   order=200
   #
   # auxscopes have changed
   #
   lines="`rexekutor grep -E -v '^#' ".mulle/share/env/auxscope" 2> /dev/null`"

   .foreachline scope in ${lines}
   .do
      case "${scope}" in
         extension|s:extension)
            env::scope::r_priority_for_scopeid 'extension'
            r_add_unique_line "${share_lines}" 'extension;${RVAL}'
            share_lines="${RVAL}"
         ;;

         # should be done by a mulle-sde extension upgrade really
         project|s:project)
            r_add_unique_line "${etc_lines}" 'project;20'
            etc_lines="${RVAL}"
         ;;

         'e:'*)
            if ! env::scope::r_priority_for_scopeid "${scope:2}"
            then
               RVAL="${order}"
               order=$(( order + 10 ))
            fi
            r_add_unique_line "${etc_lines}" "${scope:2};${RVAL}"
            etc_lines="${RVAL}"
         ;;

         's:'*)
            if ! env::scope::r_priority_for_scopeid "${scope:2}"
            then
               RVAL="${order}"
               order=$(( order + 10 ))
            fi
            r_add_unique_line "${share_lines}" "${scope:2};${RVAL}"
            share_lines="${RVAL}"
         ;;

         *)
            r_add_unique_line "${share_lines}" "${scope};${order}"
            share_lines="${RVAL}"
            order=$(( order + 10 ))
         ;;
      esac
   .done

   order=100
   lines="`rexekutor grep -E -v '^#' ".mulle/etc/env/auxscope" 2> /dev/null`"

   .foreachline scope in ${lines}
   .do
      case "${scope}" in
         'e:'*)
            if ! env::scope::r_priority_for_scopeid "${scope:2}"
            then
               RVAL="${order}"
               order=$(( order + 10 ))
            fi
            r_add_unique_line "${etc_lines}" "${scope:2};${RVAL}"
            etc_lines="${RVAL}"
         ;;

         's:'*)
            if ! env::scope::r_priority_for_scopeid "${scope:2}"
            then
               RVAL="${order}"
               order=$(( order + 10 ))
            fi
            r_add_unique_line "${share_lines}" "${scope:2};${RVAL}"
            share_lines="${RVAL}"
         ;;

         *) # difference
            r_add_unique_line "${etc_lines}" "${scope};${order}"
            etc_lines="${RVAL}"
            order=$(( order + 10 ))
         ;;
      esac
   .done

   if [ ! -z "${etc_lines}" ]
   then
      r_mkdir_parent_if_missing ".mulle/etc/env/auxscope" &&
      redirect_exekutor ".mulle/etc/env/auxscope" echo "${etc_lines}"
   fi

   if [ ! -z "${share_lines}" ]
   then
      r_mkdir_parent_if_missing ".mulle/etc/env/auxscope" &&
      redirect_exekutor ".mulle/share/env/auxscope" echo "${share_lines}"
   fi

   if [ ! -f ".mulle/etc/env/environment-project.sh" -a \
          -f ".mulle/share/env/environment-project.sh" ]
   then
      exekutor mv  ".mulle/share/env/environment-project.sh" ".mulle/etc/env/"
   fi
}


env::migrate::main()
{
   log_entry "env::migrate::main" "$@"

   local oldversion="$1"
   local version="$2"
   local flavor="$3"

   local oldmajor
   local oldminor

   oldmajor="${oldversion%%.*}"
   oldminor="${oldversion#*.}"
   oldminor="${oldminor%%.*}"

   local major
   local minor

   major="${version%%.*}"
   minor="${minor#*.}"
   minor="${minor%%.*}"

   if [ "${oldmajor}" -lt 2 ]
   then
      env::migrate::migrate_from_v1_to_v2
      oldmajor=2
      oldminor=0
   fi

   if [ "${oldmajor}" -eq 2 -a "${major}" -eq 2 -a "${oldminor}" -lt 2 ]
   then
      env::migrate::migrate_from_v2_0_to_v2_2
      oldmajor=2
      oldminor=2
   fi

   if [ "${oldmajor}" -lt 3 ]
   then
      env::migrate::migrate_from_v2_2_to_v3
      oldmajor=3
      oldminor=0
   fi

   env::plugin::upgrade "${flavor}" "${oldversion}" "${version}"
}
