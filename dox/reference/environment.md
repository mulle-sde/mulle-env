# mulle-env environment / env - Manage Environment Variables

## Quick Start
Manage environment variables within the mulle-env environment.

## All Available Options

### Basic Usage
```bash
mulle-env environment <subcommand> [options] [variable[=value]]
# or
mulle-env env <subcommand> [options] [variable[=value]]
```

**Arguments:**
- `subcommand`: Environment variable operation (get, set, list, etc.)
- `variable`: Environment variable name
- `value`: Value to assign (for set operations)

### Visible Options
- `--help`: Show usage information
- `--global`: Operate on global environment (not session-specific)
- `--export`: Export variables for use in scripts

### Hidden Options
- `--force`: Force operation without confirmation
- `--inherit`: Inherit from parent environment
- Various environment-specific configuration options

## Command Behavior

### Core Functionality
- **Get**: Retrieve environment variable values
- **Set**: Define or modify environment variables
- **List**: Display all environment variables
- **Unset**: Remove environment variables
- **Export**: Generate shell export statements

### Conditional Behaviors

**Scope Management:**
- Session-specific variables (default)
- Global environment variables (--global)
- Inherited variables from parent environments
- Platform-specific variable handling

**Variable Resolution:**
- Searches current environment first
- Falls back to parent environments
- Resolves platform-specific variables
- Handles variable dependencies

## Practical Examples

### Basic Variable Management
```bash
# Get a specific variable
mulle-env env get CC

# Set a variable
mulle-env env set CC clang

# List all variables
mulle-env env list

# Unset a variable
mulle-env env unset CC
```

### Development Setup
```bash
# Configure compiler settings
mulle-env env set CC clang
mulle-env env set CXX clang++
mulle-env env set CFLAGS "-O2 -Wall"

# Set library paths
mulle-env env set LD_LIBRARY_PATH "/usr/local/lib:$LD_LIBRARY_PATH"

# Configure build settings
mulle-env env set CMAKE_BUILD_TYPE Release
```

### Script Integration
```bash
# Export variables for scripts
mulle-env env export > environment.sh
source environment.sh

# Check variable values
echo "CC=$CC"
echo "CFLAGS=$CFLAGS"
```

### Cross-Platform Configuration
```bash
# Platform-specific settings
case "$(mulle-env uname)" in
    "linux")
        mulle-env env set CC gcc
        ;;
    "darwin")
        mulle-env env set CC clang
        ;;
    "mingw")
        mulle-env env set CC x86_64-w64-mingw32-gcc
        ;;
esac
```

## Troubleshooting

### Variable Not Found
```bash
# Variable doesn't exist
mulle-env env get NONEXISTENT_VAR
# Returns empty or error

# Solution: Check available variables
mulle-env env list | grep VAR
```

### Permission Issues
```bash
# No permission to set variables
mulle-env env set CC clang
# Error: Permission denied

# Solution: Check environment ownership
ls -la .mulle/etc/env/
sudo chown -R $USER .mulle/etc/env/
```

### Variable Conflicts
```bash
# Conflicting variable definitions
mulle-env env set PATH "/new/path:$PATH"
# May cause path conflicts

# Solution: Use careful path construction
mulle-env env get PATH
mulle-env env set PATH "/new/path:$(mulle-env env get PATH)"
```

## Integration with Other Commands

### Tool Configuration
```bash
# Environment affects tool behavior
mulle-env env set CC clang
mulle-env tool add cmake  # Uses CC from environment

# Tool-specific variables
mulle-env env set CMAKE_GENERATOR "Unix Makefiles"
mulle-env env set MAKEFLAGS "-j$(nproc)"
```

### Style Integration
```bash
# Style affects environment variables
mulle-env style set developer/strict
mulle-env env list  # Shows style-imposed variables

# Custom style variables
mulle-env env set CUSTOM_VAR value
mulle-env style set custom-style  # May include CUSTOM_VAR
```

### Script Execution
```bash
# Environment for command execution
mulle-env env set DEBUG 1
mulle-env -- bash -c 'echo "Debug mode: $DEBUG"'

# Export for external scripts
mulle-env env export > build.env
# Use build.env in CI/CD pipelines
```

## Technical Details

### Variable Storage Structure
```
.mulle/etc/env/environment/
├── session/          # Session-specific variables
│   ├── CC=clang
│   └── CFLAGS=-O2
├── global/           # Global environment variables
│   ├── PATH
│   └── LD_LIBRARY_PATH
└── inherited/        # Variables from parent environments
```

### Variable Types
- **Session Variables**: Temporary, session-specific settings
- **Global Variables**: Persistent across sessions
- **Inherited Variables**: From parent mulle-env environments
- **Platform Variables**: OS-specific configurations
- **Tool Variables**: Tool-specific environment settings

### Variable Resolution Order
1. **Session Variables**: Highest priority, current session
2. **Global Variables**: Persistent user settings
3. **Inherited Variables**: From parent environments
4. **System Variables**: Fallback to system defaults
5. **Platform Defaults**: OS-specific fallbacks

### Variable Expansion
- **Recursive Expansion**: Variables can reference other variables
- **Path Expansion**: Automatic path normalization
- **Platform Adaptation**: Platform-specific path separators
- **Security Filtering**: Safe variable content validation

## Related Commands

- **[`style`](style.md)** - Environment styles affecting variables
- **[`tool`](tool.md)** - Tools using environment variables
- **[`init`](init.md)** - Initialize environment with variables
- **[`clean`](clean.md)** - Clean environment variable caches