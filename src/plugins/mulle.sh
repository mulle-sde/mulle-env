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
MULLE_ENV_MULLE_PLUGIN_SH="included"

print_mulle_startup_body_sh()
{
   log_entry "print_mulle_startup_body_sh" "$@"

   cat <<EOF
#
# Globally appropriate definitions
#
case "\${MULLE_UNAME}" in
   darwin)
      MULLE_FETCH_MIRROR_DIR="~/Library/Caches/mulle-fetch/git-mirrors"
      MULLE_FETCH_ARCHIVE_DIR="~/Library/Caches/mulle-fetch/archives"
   ;;

   *)
      MULLE_FETCH_MIRROR_DIR="~/.cache/mulle-fetch/git-mirrors"
      MULLE_FETCH_ARCHIVE_DIR="~/.cache/mulle-fetch/archives"
   ;;
esac

MULLE_FETCH_SEARCH_PATH="${MULLE_VIRTUAL_ROOT}/..`"
MULLE_SYMLINK="YES"

#
# PATH to search for git repositories locally
#
export MULLE_FETCH_SEARCH_PATH

#
# Prefer symlinks to local git repositories found via MULLE_FETCH_SEARCH_PATH
#
export MULLE_SYMLINK

#
# Git mirror and Zip/TGZ cache to conserve bandwidth
#
export MULLE_FETCH_MIRROR_DIR
export MULLE_FETCH_ARCHIVE_DIR

#
# Use common folder for sharable projects
#
MULLE_SOURCETREE_SHARE_DIR="\${MULLE_VIRTUAL_ROOT}/stashes"
export MULLE_SOURCETREE_SHARE_DIR

#
# Use common build directory
#
BUILD_DIR="\${MULLE_VIRTUAL_ROOT}/build"
export BUILD_DIR


#
# Share dependencies directory (absolute for ease of use)
#
DEPENDENCIES_DIR="\${MULLE_VIRTUAL_ROOT}/dependencies"
export DEPENDENCIES_DIR

EOF

}


#
# since all mulle- tools are uniform, this is easy.
# If it's a library, we need to strip off -env from
# the toolname for the libraryname. Also libexec is versionized
# so add the version
#
env_copy_mulle_tool()
{
   log_entry "env_copy_mulle_tool" "$@"

   local toolname="$1"
   local directory="$2"
   local copystyle="${3:-tool}"

   #
   # these dependencies should be there, but just check
   #
   local exefile

   exefile="`command -v "${toolname}" `"
   if [ -z "${exefile}" ]
   then
      fail "${toolname} not in PATH"
   fi

   # doing it like this renames "src" to $toolname

   local srclibexecdir
   local parentdir
   local srclibname

   srclibdir="`exekutor "${exefile}" libexec-path `" || exit 1
   srclibexecdir="`dirname -- "${srclibdir}" `"
   srclibname="`basename -- "${srclibdir}" `"

   local dstlibexecdir
   local dstbindir
   local dstexefile
   local dstlibname

   dstlibname="${toolname}"
   dstbindir="${directory}/bin"
   dstexefile="${dstbindir}/${toolname}"
   mkdir_if_missing "${dstbindir}"

   dstlibexecdir="${directory}/libexec"

   if [ "${copystyle}" = "library" ]
   then
      local version

      version="`"${exefile}" version `" || exit 1
      dstlibname="`sed 's/-env$//' <<< "${toolname}" `"
      dstlibdir="${dstlibexecdir}/${dstlibname}/${version}"
   else
      dstlibdir="${directory}/libexec/${dstlibname}"
   fi

   #
   # Developer option, since I don't want to edit copies. Doesn't work
   # on mingw, but shucks
   #
   if [ "${srclibname}" = "src" -a "${MULLE_ENV_DEVELOPER}" != "NO" ]
   then
      mkdir_if_missing "${dstbindir}"
      mkdir_parent_if_missing "${dstlibdir}" > /dev/null

      log_fluff "Creating symlink \"${dstexefile}\""

      exekutor ln -s -f "${exefile}" "${dstexefile}"
      exekutor ln -s -f "${srclibexecdir}/src" "${dstlibdir}"
   else
      mkdir_if_missing "${dstlibdir}"

      ( cd "${srclibdir}" ; tar cf - . ) | \
      ( cd "${dstlibdir}" ; tar xf -  )

      mkdir_if_missing "${dstbindir}"

      log_fluff "Copying \"${dstexefile}\""

      exekutor cp "${exefile}" "${dstexefile}" &&
      exekutor chmod 755 "${dstexefile}"
   fi
}


##
## CALLBACKS
##

print_mulle_tools_sh()
{
   log_entry "print_mulle_tools_sh" "$@"

   print_none_tools_sh "$@"

   #
   # set of "minimal" commands for use in development
   # many or most are required by the mulle scripts
   #
   cat <<EOF
curl
git
uuidgen
EOF

   # optional, default yes

   if [ "${OPTION_NINJA}" != "NO" ]
   then
      echo "ninja"
   fi

   if [ "${OPTION_CMAKE}" != "NO" ]
   then
      echo "cmake"
   fi

   # optional, default no
   if [ "${OPTION_SVN}" = "YES" ]
   then
      echo "svn"
   fi

   if [ "${OPTION_AUTOCONF}" = "YES" ]
   then
      echo "autoconf"
      echo "autoreconf"
   fi

   if [ ! -z "${OPTION_OTHER_TOOLS}" ]
   then
      echo "${OPTION_OTHER_TOOLS}"
   fi
}



## callback
print_mulle_startup_sh()
{
   log_entry "print_mulle_startup_sh" "$@"

   print_none_startup_header_sh "$@"
   print_mulle_startup_body_sh "$@"
   print_none_startup_footer_sh "$@"
}



## callback
env_setup_mulle_tools()
{
   log_entry "env_setup_mulle_tools" "$@"

   local directory="$1"

   [ -z "${directory}" ] && internal_fail "directory is empty"

   #
   # Since the PATH is restricted, we need a basic set of tools
   # in directory/bin to get things going
   # (We'd also need in PATH: git, tar, sed, tr, gzip, zip. But that's not
   # checked yet)
   #
   (
      env_copy_mulle_tool "mulle-bashfunctions-env" "${directory}" "library" &&
      env_copy_mulle_tool "mulle-fetch"      "${directory}" &&
      env_copy_mulle_tool "mulle-make"       "${directory}" &&
      env_copy_mulle_tool "mulle-dispense"   "${directory}" &&
      env_copy_mulle_tool "mulle-sourcetree" "${directory}" &&
      env_copy_mulle_tool "mulle-build"      "${directory}"
   ) || return 1
}

## callback
env_mulle_tools_need_update()
{
   log_entry "env_mulle_tools_need_update" "$@"

   local directory="$1"

   if [ -z "`command -v mulle-build`" ]
   then
      fail "Style \"mulle\" needs mulle-build to be in PATH.

Use \"--style none\", if you don't need mulle-build"
   fi

   if [ "${OPTION_MAGNUM_FORCE}" = "YES" ] || \
      [ ! -d "${directory}/bin/mulle-fetch" ]
   then
      return 0
   fi

   return 1
}


## callback
env_mulle_enter_subshell()
{
   log_entry "env_mulle_enter_subshell" "$@"

   local directory="$1"

   if [ "${OPTION_BOOTSTRAP}" = "YES" ] && \
      [ -f "${directory}/.mulle-sourcetree"  ] && \
      [ ! -d "${MULLE_VIRTUAL_ROOT}/dependencies" ]
   then
      local exepath

      if [ $? -eq 0 ]
      then
         exepath="`command -v mulle-build`"
         log_fluff "Running mulle-build in \"${directory}\"..."
         (
            cd "${directory}" ;
            "${MULLE_ENV_LIBEXEC_DIR}/mulle-env-shell" \
               "${MULLE_VIRTUAL_ROOT}" \
               "${PATH}" \
               "SCRIPT" \
               "${exepath}" "--share"
         )
      fi
   fi
}

## callback
env_mulle_add_runpath()
{
   log_entry "env_mulle_add_runpath" "$@"

   local directory="$1"
   local runpath="$2"

   # since we prepend, prepend in reversr order, so dependencies is first
   runpath="`colon_concat "${runpath}" "${directory}/addictions/bin" "${runpath}"`"
   colon_concat  "${directory}/dependencies/bin" "${runpath}"
}


env_mulle_initialize()
{
   env_load_plugin "none"
}


env_mulle_initialize
