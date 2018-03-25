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
MULLE_ENV_CD_SH="included"


function _env_escapes_environment()
{
   if [ -z "${MULLE_VIRTUAL_ROOT}" ]
   then
      return 1
   fi

   local physdir

   physdir="`( builtin cd "$@" 2> /dev/null && pwd -P )`"
   if [ -z "${physdir}" ]
   then
      return 1
   fi

   while [ ! -z "${physdir}" ]
   do
      if [ "${physdir}" = "${MULLE_VIRTUAL_ROOT}" ]
      then
         return 1
      fi
      physdir="${physdir%/*}"
   done

   return 0
}


function cd()
{
   local directory="$*"

   while [ "$#" -ne 0 ]
   do
      case "$1" in
         -f)
            shift
            builtin cd "${directory}"
            return $?
         ;;
      esac
      break
   done

   #
   # warn once when stepping out
   #
   if ! _env_escapes_environment "$@" ||
        _env_escapes_environment "${PWD}"
   then
      builtin cd "$@"
      return $?
   fi

   local C_RESET
   local C_RED
   local C_BOLD

   C_RESET="\033[0m"
   C_RED="\033[0;31m"
   C_BOLD="\033[1m"

   if [ ! -d "${directory}/.mulle-env" ]
   then
      printf "${C_RED}${C_BOLD}%b${C_RESET}\n" "Directory \"${directory}\" is \
outside of the virtual environment. Leave the shell or override with:
   ${C_RESET}${C_BOLD}cd -f $1"
      return 1
   fi

   #
   # We inherit environment variables from our environment if the destination
   # style is "wild",which can be catastrophic.
   #
   local nextstyle

   nextstyle="`mulle-env style "${directory}"`"
   case "${nextstyle}" in
      "")
         printf "${C_RED}${C_BOLD}%b${C_RESET}\n" "Can not figure out
the environment style of \"${directory}\". Chickening out."
         return 1
      ;;

      */wild)
         printf "${C_RED}${C_BOLD}%b${C_RESET}\n" "Directory \"${directory}\" \
is a \"${nextstyle}\" environment. Can't switch to wild ones safely."
         return 1
      ;;
   esac

   printf "${C_RED}${C_BOLD}%b${C_RESET}\n" "Switching environment to \"${directory}\""

   MULLE_VIRTUAL_ROOT="" exec mulle-env "${directory}"
}

