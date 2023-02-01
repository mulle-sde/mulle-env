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
MULLE_ENV_STYLE_SH="included"


# Internally:
#
# style        : styleprefix ':' styleid
# stylename    : keyword | styleid
# keyword      : "DEFAULT" | "include" | "merged" | "custom"
# styleprefix  : 'e' | 's'
# styleid      : [A-Za-z_-][A-Za-z0-9_-]*
#
# An auxstyle file looks pedantically like this:
#
# auxstyle     : lines
# lines        : line | line lines
# line         : ( '#' .* | styleline ) '\n'
# styleline    : styleid ';' priority
# priority     : [0-9]+
#
env::style::usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} style [options] [command]*

   Manage environment styles. You can list the current style, show what's
   available or set a different style.

   Print the style currently used by the mulle-env environment. The style
   is a pair of tool-style/env-style.

Tool-style: (built-in only, see all with \`mulle-sde style --toolstyles\`)
   none          : a fairly empty virtual environment
   minimal       : a minimal set of tools (like cd, ls)
   developer     : a common set of tools (like cd, ls, awk, man) (default)

Env-style:
   tight         : all environment variables must be user defined
   restrict      : inherit some environment (e.g. SSH_TTY) (default)
   relax         : restrict plus all /bin and /usr/bin tools.
   inherit       : relax plus all tools in PATH
   wild          : no restrictions

Options:
   -h            : show this usage

Commands:
   get           : list current style
   set           : set a style
   show          : show avaiable styles
EOF

   exit 1
}


env::style::show_usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} style show [options]

   Show available styles.

Options:
   --envstyle  : list envstyles only
   --toolstyle : list toolstyles only

EOF
   exit 1
}


env::style::set_usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} style set <style>

   Set style.

EOF
   exit 1
}


env::style::get_usage()
{
   [ $# -ne 0 ] && log_error "$1"

    cat <<EOF >&2
Usage:
   ${MULLE_USAGE_NAME} style get

   List currently set style.
EOF
   exit 1
}


env::style::set_main()
{
   log_entry "env::style::set_main" "$@"

   local _style

   case "$1" in
      -h|--help|help)
         env::style::set_usage
      ;;
   esac

   [ $# -eq 0 ]  && env::style::set_usage "Missing style argument"
   OPTION_STYLE="${1:-}"
   shift
   [ $# -ne 0 ]  && env::style::set_usage "Superflous arguments \"$*\""

   OPTION_SHELL_COMMAND=":" env::run_subshell ""
}


env::style::get_main()
{
   log_entry "env::style::get_main" "$@"

   local _style

   case "$1" in
      -h|--help|help)
         env::style::get_usage
      ;;

      "")
      ;;

      *)
         env::style::get_usage "Superflous arguments \"$*\""
      ;;
   esac

   if ! env::__get_saved_style_flavor "${MULLE_ENV_HOST_VAR_DIR}" "${MULLE_ENV_SHARE_DIR}"
   then
      env::fail_get_saved_style_flavor "${MULLE_ENV_HOST_VAR_DIR}" "${MULLE_ENV_SHARE_DIR}"
   fi
   echo "${_style}"
}


env::style::show_toolstyles()
{
   log_entry "env::style::show_toolstyles" "$@"

   include "env::plugin"

   env::plugin::all_names
   return $?
}


env::style::show_envstyles()
{
   log_entry "env::style::show_envstyles" "$@"

   echo "inherit
relax
restrict
tight
wild"
   return 0
}


env::style::show_main()
{
   log_entry "env::style::show_main" "$@"

   local toolstyles
   local envstyles

   toolstyles="`env::style::show_toolstyles`"
   envstyles="`env::style::show_envstyles`"

   case "$1" in
      --help|help|-h)
         env::style::show_usage
      ;;

      --toolstyle*)
         log_info "Toolstyle"

         echo "${toolstyles}"
         return
      ;;

      --envstyle*)
         log_info "Envstyle"

         echo "${envstyles}"
         return
      ;;

      "")
      ;;

      *)
         env::style::show_usage "Superflous arguments \"$*\""
      ;;
   esac

   local toolstyle
   local envstyle

   log_info "Style"

   .for toolstyle in ${toolstyles}
   .do
      .for envstyle in ${envstyles}
      .do
         echo "${toolstyle}/${envstyle}"
      .done
   .done
}


###
### parameters and environment variables
###
env::style::main()
{
   log_entry "env::style::main" "$@"

   #
   # handle options
   #
   while :
   do
      case "$1" in
         -h|--help|help)
            env::style::usage
         ;;

         -*)
            env::style::usage "Unknown option \"$1\""
         ;;

         *)
            break
         ;;
      esac

      shift
   done

   local cmd="${1:-get}"
   [ $# -ne 0 ] && shift

   case "${cmd}" in
      get|list|set)
         if ! env::is_help_request_commandline "$@"
         then
            env::default_setup_environment "${PWD}" "${OPTION_SEARCHMODE}" 'NO'
         fi

         env::style::${cmd/list/get}_main "$@"
      ;;

      show)
         env::style::${cmd}_main "$@"
      ;;

      *)
         env::style::usage "unknown command \"${cmd}\""
      ;;
   esac
}
