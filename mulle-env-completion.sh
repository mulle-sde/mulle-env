# bash completion for mulle-env

# Helper: join array into words for compgen -W
_mulle_env__join_words() {
  local IFS=$'\n'
  printf "%s" "$*"
}

# Helper: filter list by prefix in $cur
_mulle_env__filter_prefix() {
  local cur="$1"; shift
  local out=()
  local w
  for w in "$@"; do
    [[ "$w" == "$cur"* ]] && out+=("$w")
  done
  COMPREPLY=( "${out[@]}" )
}

# Helper: add to COMPREPLY preserving existing
_mulle_env__append_compreply() {
  local add=("$@")
  COMPREPLY+=( "${add[@]}" )
}

# Helper: unique COMPREPLY
_mulle_env__unique_compreply() {
  local -A seen=()
  local out=()
  local x
  for x in "${COMPREPLY[@]}"; do
    [[ -n "$x" ]] || continue
    if [[ -z "${seen[$x]}" ]]; then
      out+=("$x")
      seen["$x"]=1
    fi
  done
  COMPREPLY=( "${out[@]}" )
}

# Top-level global options (flags)
_mulle_env__global_flags() {
  printf "%s\n" \
    -h --help help \
    -C -c -d -D -ef -aef \
    --defines --pre-defines --post-defines \
    --search-here --search-none --search-nearest -N --search-parent -P --search-superior -S --search-default --search-as-is \
    --style \
    -f --force --freeze \
    -e --environment-override \
    --shell --echo-args \
    --keep-tmp --no-motd \
    --protect --no-protect \
    --scope-subdir \
    --uppercase-only \
    --
}

# Top-level commands (static fallback)
_mulle_env__top_commands_fallback() {
  printf "%s\n" \
    clean commands env environment get set list \
    hostname init install-dir invoke local mulle-tool-env \
    project-dir reinit reset scope scopes searchpath style styles \
    subenv tool tweak uname osname unveil username untweak \
    upgrade libexec-dir mulle-bin-dir mulle-libexec-dir version
}

# Try to get command list dynamically
_mulle_env__top_commands() {
  if command -v mulle-env >/dev/null 2>&1; then
    local out
    out="$(mulle-env commands 2>/dev/null)"
    if [[ -n "$out" ]]; then
      printf "%s\n" $out
      return
    fi
  fi
  _mulle_env__top_commands_fallback
}

# Environment (env) subcommands
_mulle_env__environment_subcommands() {
  printf "%s\n" list set get remove scope scopes clobber mset
}

# Environment global options (before env subcommand)
_mulle_env__environment_global_opts() {
  printf "%s\n" \
    -h --help help \
    --host --os --scope --user \
    --this-host --this-os --this-user --this-user-os --this-os-user \
    --scope-subdir \
    --cat --sort
}

# Environment get options
_mulle_env__environment_get_opts() {
  printf "%s\n" \
    -h --help help \
    --lenient --notfound-rc --output-eval --output-sed \
    --sed-key-prefix --sed-key-suffix
}

# Environment set options
_mulle_env__environment_set_opts() {
  printf "%s\n" \
    -h --help help \
    --no-add-empty -a --add --append -c --comment-out-empty \
    --concat --concat0 -p --prepend --remove \
    --separator
}

# Environment remove options
_mulle_env__environment_remove_opts() {
  printf "%s\n" \
    -h --help help \
    --no-remove-file
}

# Environment list options
_mulle_env__environment_list_opts() {
  printf "%s\n" \
    -h --help help \
    --output-eval --output-sed --output-command \
    --sed-key-prefix --sed-key-suffix
}

# Scope subcommands
_mulle_env__scope_subcommands() {
  printf "%s\n" add file get remove list
}

# Scope list options
_mulle_env__scope_list_opts() {
  printf "%s\n" \
    -h --help help \
    -a --all \
    --existing \
    --output-filename --output-existing-filename \
    --aux --no-aux --etc-aux --no-etc-aux \
    --hardcoded --no-hardcoded \
    --share-aux --no-share-aux \
    --plugin --no-plugin \
    --user --no-user \
    --sort
}

# Scope add options
_mulle_env__scope_add_opts() {
  printf "%s\n" \
    -h --help help \
    --share --etc --priority --create-file --no-create-file --if-missing
}

# Scope get options
_mulle_env__scope_get_opts() {
  printf "%s\n" \
    -h --help help \
    --prefix --quiet -q --aux-only
}

# Scope remove options
_mulle_env__scope_remove_opts() {
  printf "%s\n" \
    -h --help help \
    --if-exists --keep-file --remove-file
}

# Scope file options
_mulle_env__scope_file_opts() {
  printf "%s\n" \
    -h --help help \
    --if-exists
}

# Style subcommands
_mulle_env__style_subcommands() {
  printf "%s\n" get set show list
}

# Style show options
_mulle_env__style_show_opts() {
  printf "%s\n" -h --help help --envstyle --toolstyle
}

# Tool subcommands
_mulle_env__tool_subcommands() {
  printf "%s\n" add compile doctor get link list remove status bin-dir libexec-dir
}

# Tool global options (before tool subcommand)
_mulle_env__tool_global_opts() {
  printf "%s\n" \
    -h --help help \
    --plugin --extension \
    --global --common \
    --current \
    --os
}

# Tool add options
_mulle_env__tool_add_opts() {
  printf "%s\n" \
    -h --help help \
    --optional --no-required --required --no-optional \
    --remove \
    --compile-link --no-compile-link \
    --csv \
    --resolve --no-resolve \
    --script --no-script \
    --if-missing
}

# Tool list options
_mulle_env__tool_list_opts() {
  printf "%s\n" \
    -h --help help \
    --no-color --csv --no-csv --no-builtin
}

# Tool link options
_mulle_env__tool_link_opts() {
  printf "%s\n" \
    -h --help help \
    --no-delete --compile --compile-if-needed --bindir
}

# Tool compile options
_mulle_env__tool_compile_opts() {
  printf "%s\n" \
    -h --help help \
    --if-needed
}

# Unveil options
_mulle_env__unveil_opts() {
  printf "%s\n" \
    -h --help help \
    --symlinks --no-symlinks
}

# Init options
_mulle_env__init_opts() {
  printf "%s\n" \
    -h --help help \
    -d --directory \
    --blurb --no-blurb \
    --style \
    -t --tool \
    --reinit --upgrade
}

# Upgrade may accept init-like args
_mulle_env__upgrade_opts() {
  printf "%s\n" \
    -h --help help \
    --style \
    --blurb --no-blurb \
    -t --tool
}

# OS names for tool --os
_mulle_env__os_names() {
  printf "%s\n" darwin freebsd openbsd netbsd linux mingw msys windows sunos dragonfly DEFAULT
}

# Generate style list "tool/env"
_mulle_env__style_values() {
  local tools envs
  if tools="$(mulle-env style show --toolstyle 2>/dev/null)"; then
    :
  else
    tools="none minimal developer"
  fi
  if envs="$(mulle-env style show --envstyle 2>/dev/null)"; then
    :
  else
    envs="inherit relax restrict tight wild"
  fi
  local t e
  for t in $tools; do
    for e in $envs; do
      printf "%s/%s\n" "$t" "$e"
    done
  done
}

# Determine if $1 is an option that takes a value at global level
_mulle_env__global_opt_requires_value() {
  case "$1" in
    -C|-c|-d|-ef|-aef|--style|--scope-subdir|--defines|--pre-defines|--post-defines) return 0 ;;
  esac
  return 1
}

# Determine index of first non-option top-level token (the command), considering options that take values
_mulle_env__find_command_index() {
  local i=1
  while (( i < COMP_CWORD )); do
    local w="${COMP_WORDS[i]}"
    case "$w" in
      --)
        echo $((i+1))
        return
      ;;
      -*)
        if _mulle_env__global_opt_requires_value "$w"; then
          i=$((i+2))
          continue
        fi
      ;;
      *)
        echo $i
        return
      ;;
    esac
    i=$((i+1))
  done
  # If current word is command candidate
  echo $i
}

# Complete directories
_mulle_env__complete_dirs() {
  compopt -o dirnames
  COMPREPLY=( $(compgen -d -- "$1") )
}

# Complete files
_mulle_env__complete_files() {
  compopt -o filenames
  COMPREPLY=( $(compgen -f -- "$1") )
}

# Complete commands from PATH
_mulle_env__complete_commands() {
  COMPREPLY=( $(compgen -c -- "$1") )
}

# Complete tweak names by listing files in .mulle/etc/env/tweak
_mulle_env__complete_tweaks() {
  local dir=".mulle/etc/env/tweak"
  if [[ -d "$dir" ]]; then
    local names
    names=$(cd "$dir" && printf "%s\n" *)
    COMPREPLY=( $(compgen -W "$names" -- "$1") )
  else
    COMPREPLY=()
  fi
}

_mulle_env_complete() {
  local cur prev words cword
  words=("${COMP_WORDS[@]}")
  cword=$COMP_CWORD
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  # If completing value for a global option that takes a value
  if _mulle_env__global_opt_requires_value "$prev"; then
    case "$prev" in
      -d|--directory)
        _mulle_env__complete_dirs "$cur"
        return
      ;;
      -ef|--environment-file|-aef|--aux-environment-file)
        _mulle_env__complete_files "$cur"
        return
      ;;
      --style)
        COMPREPLY=( $(compgen -W "$(_mulle_env__style_values)" -- "$cur") )
        return
      ;;
      -C|-c|--defines|--pre-defines|--post-defines)
        COMPREPLY=()
        return
      ;;
      --scope-subdir)
        COMPREPLY=()
        return
      ;;
    esac
  fi

  # Determine command index and command
  local cmd_index cmd
  cmd_index="$(_mulle_env__find_command_index)"
  if (( cmd_index >= cword )); then
    # We're still before the command: suggest global flags and commands and dirs
    if [[ "$cur" == -* ]]; then
      COMPREPLY=( $(compgen -W "$(_mulle_env__global_flags)" -- "$cur") )
      return
    fi
    local cmds="$(_mulle_env__top_commands)"
    COMPREPLY=( $(compgen -W "$cmds" -- "$cur") )
#    # Also suggest directories for path-or-url
#    local dircomp
#    dircomp=$(compgen -d -- "$cur")
#    if [[ -n "$dircomp" ]]; then
#      _mulle_env__append_compreply $dircomp
#      _mulle_env__unique_compreply
#    fi
    return
  fi

  cmd="${COMP_WORDS[cmd_index]}"

  # Aliases normalization for routing
  local cmd_norm="$cmd"
  case "$cmd" in
    env|environment|get|set|list) cmd_norm="environment" ;;
    scopes) cmd_norm="scope" ;;
    styles) cmd_norm="style" ;;
    osname) cmd_norm="uname" ;;
  esac

  # Subdispatch based on command
  case "$cmd_norm" in
    clean|commands|hostname|install-dir|'local'|mulle-bin-dir|mulle-libexec-dir|project-dir|reinit|reset|searchpath|uname|unveil|username|upgrade|libexec-dir|version|invoke|init|subenv|tool|style|scope|environment|tweak|untweak)
      ;;
    *)
      # Unknown command yet; complete command names
      if [[ "$cur" == -* ]]; then
        COMPREPLY=( $(compgen -W "$(_mulle_env__global_flags)" -- "$cur") )
      else
        COMPREPLY=( $(compgen -W "$(_mulle_env__top_commands)" -- "$cur") )
      fi
      return
      ;;
  esac

  # Per-command completion
  case "$cmd_norm" in
    # environment / env / get / set / list
    environment)
      # Find env subcommand position (first non-option after 'environment')
      local i=$((cmd_index+1))
      local sub=""
      while (( i < cword )); do
        local w="${COMP_WORDS[i]}"
        case "$w" in
          -*)
            # env options that take values
            case "$w" in
              --host|--os|--scope|--user|--scope-subdir)
                i=$((i+2))
                continue
              ;;
            esac
          ;;
          *)
            sub="$w"
            break
          ;;
        esac
        i=$((i+1))
      done

      # Check for option values that need completion
      if [[ "$prev" == "--scope" ]]; then
        local scopes
        scopes="$(mulle-env scope list 2>/dev/null | sed -n 's/^[a-z]:\(.*\)/\1/p' | sed 's/;.*//' | tr '\n' ' ')"
        if [[ -z "$scopes" ]]; then
          scopes="global project user-${USER:-$(id -un)} host-${HOSTNAME:-localhost} os-${OSTYPE%%-*}"
        fi
        COMPREPLY=( $(compgen -W "$scopes" -- "$cur") )
        return
      fi

      # If currently completing the subcommand itself
      if [[ -z "$sub" || $i -ge $cword ]]; then
        if [[ "$cur" == -* ]]; then
          COMPREPLY=( $(compgen -W "$(_mulle_env__environment_global_opts)" -- "$cur") )
        else
          COMPREPLY=( $(compgen -W "$(_mulle_env__environment_subcommands)" -- "$cur") )
        fi
        return
      fi

      # Now handle specific env subcommands
      case "$sub" in
        get)
          # Complete options and key
          if [[ "$cur" == -* ]]; then
            COMPREPLY=( $(compgen -W "$(_mulle_env__environment_get_opts)" -- "$cur") )
          else
            COMPREPLY=()
          fi
        ;;
        set)
          if [[ "$cur" == -* ]]; then
            COMPREPLY=( $(compgen -W "$(_mulle_env__environment_set_opts)" -- "$cur") )
          else
            COMPREPLY=()
          fi
        ;;
        remove|rm|unset)
          if [[ "$cur" == -* ]]; then
            COMPREPLY=( $(compgen -W "$(_mulle_env__environment_remove_opts)" -- "$cur") )
          else
            COMPREPLY=()
          fi
        ;;
        list)
          if [[ "$cur" == -* ]]; then
            COMPREPLY=( $(compgen -W "$(_mulle_env__environment_list_opts)" -- "$cur") )
          else
            COMPREPLY=()
          fi
        ;;
        scope|scopes)
          # Next token after 'scope' subcommand
          local j=$((i+1))
          local ssub=""
          while (( j < cword )); do
            local w="${COMP_WORDS[j]}"
            if [[ "$w" != -* ]]; then ssub="$w"; break; fi
            j=$((j+1))
          done
          if [[ -z "$ssub" || $j -ge $cword ]]; then
            if [[ "$cur" == -* ]]; then
              COMPREPLY=( $(compgen -W "$(_mulle_env__scope_list_opts)" -- "$cur") )
            else
              COMPREPLY=( $(compgen -W "$(_mulle_env__scope_subcommands)" -- "$cur") )
            fi
            return
          fi
          case "$ssub" in
            list)
              if [[ "$cur" == -* ]]; then
                COMPREPLY=( $(compgen -W "$(_mulle_env__scope_list_opts)" -- "$cur") )
              else
                COMPREPLY=()
              fi
            ;;
            add)
              if [[ "$cur" == -* ]]; then
                COMPREPLY=( $(compgen -W "$(_mulle_env__scope_add_opts)" -- "$cur") )
              else
                COMPREPLY=()
              fi
            ;;
            get)
              if [[ "$cur" == -* ]]; then
                COMPREPLY=( $(compgen -W "$(_mulle_env__scope_get_opts)" -- "$cur") )
              else
                COMPREPLY=()
              fi
            ;;
            remove)
              if [[ "$cur" == -* ]]; then
                COMPREPLY=( $(compgen -W "$(_mulle_env__scope_remove_opts)" -- "$cur") )
              else
                COMPREPLY=()
              fi
            ;;
            file)
              if [[ "$cur" == -* ]]; then
                COMPREPLY=( $(compgen -W "$(_mulle_env__scope_file_opts)" -- "$cur") )
              else
                COMPREPLY=()
              fi
            ;;
            *)
              COMPREPLY=( $(compgen -W "$(_mulle_env__scope_subcommands)" -- "$cur") )
            ;;
          esac
        ;;
        *)
          COMPREPLY=( $(compgen -W "$(_mulle_env__environment_subcommands)" -- "$cur") )
        ;;
      esac
      return
    ;;

    style)
      # Find style subcommand
      local i=$((cmd_index+1))
      local ssub=""
      while (( i < cword )); do
        local w="${COMP_WORDS[i]}"
        if [[ "$w" != -* ]]; then ssub="$w"; break; fi
        i=$((i+1))
      done

      if [[ -z "$ssub" || $i -ge $cword ]]; then
        COMPREPLY=( $(compgen -W "$(_mulle_env__style_subcommands)" -- "$cur") )
        return
      fi

      case "$ssub" in
        get|list)
          COMPREPLY=()
        ;;
        set)
          if [[ "$cur" == -* ]]; then
            COMPREPLY=()
          else
            COMPREPLY=( $(compgen -W "$(_mulle_env__style_values)" -- "$cur") )
          fi
        ;;
        show)
          if [[ "$cur" == -* ]]; then
            COMPREPLY=( $(compgen -W "$(_mulle_env__style_show_opts)" -- "$cur") )
          else
            COMPREPLY=()
          fi
        ;;
        *)
          COMPREPLY=( $(compgen -W "$(_mulle_env__style_subcommands)" -- "$cur") )
        ;;
      esac
      return
    ;;

    tool)
      # Global tool options before subcommand
      local i=$((cmd_index+1))
      local w
      while (( i < cword )); do
        w="${COMP_WORDS[i]}"
        case "$w" in
          --os) i=$((i+2)); continue ;;
          -*)
            i=$((i+1)); continue
          ;;
          *)
            break
          ;;
        esac
      done
      local tsub=""
      if (( i < cword )); then
        tsub="${COMP_WORDS[i]}"
      fi
      if [[ -z "$tsub" || $i -ge $cword ]]; then
        if [[ "$cur" == -* ]]; then
          COMPREPLY=( $(compgen -W "$(_mulle_env__tool_global_opts)" -- "$cur") )
        else
          COMPREPLY=( $(compgen -W "$(_mulle_env__tool_subcommands)" -- "$cur") )
        fi
        return
      fi
      case "$tsub" in
        add|remove)
          if [[ "$cur" == -* ]]; then
            COMPREPLY=( $(compgen -W "$(_mulle_env__tool_add_opts)" -- "$cur") )
          else
            _mulle_env__complete_commands "$cur"
          fi
        ;;
        get)
          if [[ "$cur" == -* ]]; then
            COMPREPLY=( $(compgen -W "--csv -h --help help" -- "$cur") )
          else
            _mulle_env__complete_commands "$cur"
          fi
        ;;
        list)
          if [[ "$cur" == -* ]]; then
            COMPREPLY=( $(compgen -W "$(_mulle_env__tool_list_opts)" -- "$cur") )
          else
            COMPREPLY=( $(compgen -W "tool tools file files os oss compiled" -- "$cur") )
          fi
        ;;
        link)
          if [[ "$cur" == -* ]]; then
            COMPREPLY=( $(compgen -W "$(_mulle_env__tool_link_opts)" -- "$cur") )
          else
            COMPREPLY=()
          fi
        ;;
        compile)
          if [[ "$cur" == -* ]]; then
            COMPREPLY=( $(compgen -W "$(_mulle_env__tool_compile_opts)" -- "$cur") )
          else
            COMPREPLY=()
          fi
        ;;
        doctor|status|bin-dir|libexec-dir)
          COMPREPLY=()
        ;;
        *)
          COMPREPLY=( $(compgen -W "$(_mulle_env__tool_subcommands)" -- "$cur") )
        ;;
      esac
      return
    ;;

    init)
      if [[ "$cur" == -* ]]; then
        COMPREPLY=( $(compgen -W "$(_mulle_env__init_opts)" -- "$cur") )
        return
      fi
      # Values for options
      case "$prev" in
        -d|--directory)
          _mulle_env__complete_dirs "$cur"; return ;;
        --style)
          COMPREPLY=( $(compgen -W "$(_mulle_env__style_values)" -- "$cur") ); return ;;
        -t|--tool)
          _mulle_env__complete_commands "$cur"; return ;;
      esac
      COMPREPLY=()
      return
    ;;

    upgrade)
      if [[ "$cur" == -* ]]; then
        COMPREPLY=( $(compgen -W "$(_mulle_env__upgrade_opts)" -- "$cur") )
        return
      fi
      case "$prev" in
        --style)
          COMPREPLY=( $(compgen -W "$(_mulle_env__style_values)" -- "$cur") ); return ;;
        -t|--tool)
          _mulle_env__complete_commands "$cur"; return ;;
      esac
      COMPREPLY=()
      return
    ;;

    invoke)
      # complete commands after 'invoke'
      _mulle_env__complete_commands "$cur"
      return
    ;;

    subenv)
      _mulle_env__complete_dirs "$cur"
      return
    ;;

    project-dir)
      _mulle_env__complete_dirs "$cur"
      return
    ;;

    tweak|untweak)
      _mulle_env__complete_tweaks "$cur"
      return
    ;;

    unveil)
      if [[ "$cur" == -* ]]; then
        COMPREPLY=( $(compgen -W "$(_mulle_env__unveil_opts)" -- "$cur") )
      else
        COMPREPLY=()
      fi
      return
    ;;

    scope)
      # Find scope subcommand
      local i=$((cmd_index+1))
      local ssub=""
      while (( i < cword )); do
        local w="${COMP_WORDS[i]}"
        if [[ "$w" != -* ]]; then ssub="$w"; break; fi
        i=$((i+1))
      done
      if [[ -z "$ssub" || $i -ge $cword ]]; then
        COMPREPLY=( $(compgen -W "$(_mulle_env__scope_subcommands)" -- "$cur") )
        return
      fi
      case "$ssub" in
        list)
          if [[ "$cur" == -* ]]; then
            COMPREPLY=( $(compgen -W "$(_mulle_env__scope_list_opts)" -- "$cur") )
          else
            COMPREPLY=()
          fi
        ;;
        add)
          if [[ "$cur" == -* ]]; then
            COMPREPLY=( $(compgen -W "$(_mulle_env__scope_add_opts)" -- "$cur") )
          else
            COMPREPLY=()
          fi
        ;;
        get)
          if [[ "$cur" == -* ]]; then
            COMPREPLY=( $(compgen -W "$(_mulle_env__scope_get_opts)" -- "$cur") )
          else
            COMPREPLY=()
          fi
        ;;
        remove)
          if [[ "$cur" == -* ]]; then
            COMPREPLY=( $(compgen -W "$(_mulle_env__scope_remove_opts)" -- "$cur") )
          else
            COMPREPLY=()
          fi
        ;;
        file)
          if [[ "$cur" == -* ]]; then
            COMPREPLY=( $(compgen -W "$(_mulle_env__scope_file_opts)" -- "$cur") )
          else
            COMPREPLY=()
          fi
        ;;
        *)
          COMPREPLY=( $(compgen -W "$(_mulle_env__scope_subcommands)" -- "$cur") )
        ;;
      esac
      return
    ;;

    clean|commands|hostname|install-dir|local|mulle-bin-dir|mulle-libexec-dir|reinit|reset|searchpath|uname|username|libexec-dir|version)
      COMPREPLY=()
      return
    ;;
  esac

  # Fallback: no suggestions
  COMPREPLY=()
}

# Option argument completers for global level
_mulle_env__handle_global_prev_arg() {
  local cur="$1" prev="$2"
  case "$prev" in
    -d|--directory)
      _mulle_env__complete_dirs "$cur"; return 0 ;;
    -ef|--environment-file|-aef|--aux-environment-file)
      _mulle_env__complete_files "$cur"; return 0 ;;
    --style)
      COMPREPLY=( $(compgen -W "$(_mulle_env__style_values)" -- "$cur") ); return 0 ;;
  esac
  return 1
}

# Provide OS names when previous is --os (tool global)
_mulle_env__handle_tool_os_prev() {
  local cur="$1" prev="$2"
  if [[ "$prev" == "--os" ]]; then
    COMPREPLY=( $(compgen -W "$(_mulle_env__os_names)" -- "$cur") )
    return 0
  fi
  return 1
}

# Hook: enhance completion for certain prevs at any phase
complete -F _mulle_env_complete mulle-env

# vi: ft=sh ts=2 sw=2 et
