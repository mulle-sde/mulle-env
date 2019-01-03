#! /usr/bin/env bash
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
MULLE_ENV_UPGRADE_SH="included"


env_move_directory()
{
   log_entry "env_move_directory" "$@"

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
      r_fast_dirname "${dstdir}"
      mkdir_if_missing "${RVAL}"
      exekutor ${MV:-mv} "${srcdir}" "${dstdir}"
   fi
}


env_straight_convert_directory_if_present()
{
   log_entry "env_straight_convert_directory_if_present" "$@"

   local directory="$1"

   local subdir
   local name

   [ ! -d "${directory}" ] && return 2

   r_fast_basename "${directory}"
   subdir="${RVAL}"

   r_fast_dirname "${directory}"
   name="${RVAL##*-}"

   env_move_directory "${directory}" ".mulle/${subdir}/${name}"
}


env_convert_directory_if_present()
{
   log_entry "env_convert_directory_if_present" "$@"

   local srcdir="$1"
   local dstdir="$2"

   [ ! -d "${srcdir}" ] && return 2

   env_move_directory "${srcdir}" "${dstdir}"
}


env_upgrade_from_v1_to_v2()
{
   log_entry "env_upgrade_from_v1_to_v2" "$@"

   if [ ! -d ".mulle-env" -a "${MULLE_FLAG_MAGNUM_FORCE}" != 'YES' ]
   then
      log_warning "There is nothing to upgrade here"
      return
   fi

   if [ -d ".mulle/share/env" ]
   then
      log_warning "This projects seems to be upgraded already"
   fi

   MV="mv"

# doesn't work reliably when files are not in git, bad idea
#   if [ -d ".git" ]
#   then
#      MV="git mv"
#   fi

   env_straight_convert_directory_if_present .mulle-sourcetree/etc
   rmdir_safer ".mulle-sourcetree"

   env_straight_convert_directory_if_present .mulle-match/share
   env_straight_convert_directory_if_present .mulle-match/env
   rmdir_safer ".mulle-match"

   env_straight_convert_directory_if_present .mulle-monitor/share
   env_straight_convert_directory_if_present .mulle-monitor/env
   rmdir_safer ".mulle-monitor"

   env_convert_directory_if_present .mulle-make .mulle/etc/craft/definition
   env_convert_directory_if_present .mulle-make.darwin .mulle/etc/craft/definition.darwin
   env_convert_directory_if_present .mulle-make.mingw .mulle/etc/craft/definition.mingw
   env_convert_directory_if_present .mulle-make.freebsd .mulle/etc/craft/definition.freebsd
   env_convert_directory_if_present .mulle-make.linux .mulle/etc/craft/definition.linux

   env_convert_directory_if_present .mulle-sde/share/libexec .mulle/share/monitor/libexec
   env_convert_directory_if_present .mulle-sde/etc/libexec .mulle/etc/monitor/libexec
   env_convert_directory_if_present .mulle-sde/share/bin .mulle/share/monitor/bin
   env_convert_directory_if_present .mulle-sde/etc/bin .mulle/etc/monitor/bin

   env_convert_directory_if_present .mulle-sde/share/match.d .mulle/share/match/match.d
   env_convert_directory_if_present .mulle-sde/etc/match.d .mulle/etc/match/match.d
   env_convert_directory_if_present .mulle-sde/share/ignore.d .mulle/share/match/ignore.d
   env_convert_directory_if_present .mulle-sde/etc/ignore.d .mulle/etc/match/ignore.d

   env_straight_convert_directory_if_present .mulle-sde/share
   env_straight_convert_directory_if_present .mulle-sde/etc
   rmdir_safer ".mulle-sde"

   local craftinfo

   shopt -s nullglob
   for craftinfo in craftinfo/*/mulle-make*
   do
      env_convert_directory_if_present "${craftinfo}" "${craftinfo//mulle-make/definition}"
   done
   shopt -u nullglob

   local i

   shopt -s nullglob
   for i in craftinfo/*/CMakeLists.txt
   do
      inplace_sed -e 's/mulle-make/definition/g' \
                  -e 's/BUILDINFO_DIRS/DEFINITION_DIRS/g' "${i}"
   done
   shopt -u nullglob

   # move mulle-project to .mulle to
   env_convert_directory_if_present "mulle-project" ".mulle/etc/project"

   env_straight_convert_directory_if_present .mulle-env/share
   env_straight_convert_directory_if_present .mulle-env/etc

   # remove some old clunckers

   remove_file_if_present .mulle-env/share/environment-aux.sh     # unused
   remove_file_if_present .mulle-env/share/environment-global.sh  # only etc!


   shopt -s nullglob
   for i in .mulle-env/share/environment*.sh .mulle-env/etc/environment*.sh
   do
      if egrep -q '^MULLE_SOURCETREE_SHARE_DIR=' "$i"
      then
         inplace_sed 's/^MULLE_SOURCETREE_SHARE_DIR=/MULLE_SOURCETREE_STASH_DIRNAME=/' "${i}"
      fi
   done
   shopt -u nullglob

   #
   # hack .gitignore for new paths, also remove some superflous stuff and
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
