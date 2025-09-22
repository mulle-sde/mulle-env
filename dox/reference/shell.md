# mulle-env shell

Start an interactive shell with mulle-env environment.

## Synopsis

```bash
mulle-env shell [options] [command]
```

## Description

The `shell` command starts an interactive shell session with the mulle-env environment fully configured. This provides an isolated development environment where all tools, paths, and variables are set up according to your mulle-env configuration. The shell inherits all environment settings from active scopes and styles.

## Options

- `--preserve-env`: Preserve existing environment variables
- `--clean-env`: Start with clean environment (minimal setup)
- `--inherit-env`: Inherit all current environment variables
- `--login-shell`: Start as login shell
- `--interactive`: Force interactive mode
- `--command`: Execute command and exit

## Arguments

- `command` (optional): Command to execute in the shell environment

## Examples

### Basic Usage

```bash
# Start interactive shell
mulle-env shell

# Execute command in mulle-env environment
mulle-env shell make

# Run multiple commands
mulle-env shell "make clean && make"
```

### Environment Control

```bash
# Start with clean environment
mulle-env shell --clean-env

# Preserve existing environment
mulle-env shell --preserve-env

# Inherit all current variables
mulle-env shell --inherit-env
```

### Advanced Usage

```bash
# Start login shell
mulle-env shell --login-shell

# Execute with specific shell
mulle-env shell --shell /bin/zsh

# Run in background
mulle-env shell --detach make test
```

## Shell Behavior

### Environment Setup
- **Tool Paths**: All configured tools are in PATH
- **Variables**: Environment variables from active scopes
- **Styles**: Applied coding styles and preferences
- **Plugins**: Active plugins and their configurations

### Session Management
- **Persistent**: Environment persists for shell session
- **Isolated**: Changes don't affect parent environment
- **Clean Exit**: Environment cleaned up on exit
- **Signal Handling**: Proper cleanup on interruption

## Environment Variables

### Automatically Set

**Tool Variables**
```bash
CC=clang
CXX=clang++
MAKE=make
CMAKE=cmake
```

**Path Variables**
```bash
PATH=/opt/mulle/bin:$PATH
LD_LIBRARY_PATH=/opt/mulle/lib:$LD_LIBRARY_PATH
PKG_CONFIG_PATH=/opt/mulle/lib/pkgconfig:$PKG_CONFIG_PATH
```

**Build Variables**
```bash
CFLAGS="-O2 -Wall"
CXXFLAGS="-O2 -Wall -std=c++17"
LDFLAGS="-L/opt/mulle/lib"
```

### Scope Variables
- Variables from active scopes are available
- Project-specific variables take precedence
- User preferences override system defaults

## Integration Examples

### Development Workflow
```bash
# Setup development environment
mulle-env init
mulle-env style set developer/relax
mulle-env tool add clang gdb cmake

# Start development shell
mulle-env shell

# Inside shell: all tools configured
which clang    # /opt/mulle/bin/clang
echo $CC       # clang
make           # uses configured make
```

### Build Automation
```bash
# Automated build in mulle-env shell
mulle-env shell --command "make clean && make && make test"

# Multi-stage build
mulle-env shell << 'EOF'
./configure --prefix=/opt/project
make -j$(nproc)
make install
make test
EOF
```

### CI/CD Integration
```bash
# CI build script
#!/bin/bash
mulle-env shell --clean-env --command "
  cmake -B build -S .
  cmake --build build
  ctest --test-dir build
"
```

### Testing Environment
```bash
# Setup test environment
mulle-env shell --command "
  export TEST_MODE=1
  export COVERAGE=1
  make test
"
```

## Shell Types

### Interactive Shell
```bash
mulle-env shell
```
- Full interactive environment
- Command history and completion
- Job control and signals
- Custom prompt with mulle-env info

### Non-Interactive Shell
```bash
mulle-env shell --command "make"
```
- Executes command and exits
- No interactive features
- Suitable for scripts and automation
- Minimal overhead

### Login Shell
```bash
mulle-env shell --login-shell
```
- Processes profile scripts
- Sets up complete environment
- Suitable for development sessions
- Includes login-specific configurations

## Error Conditions

- **Shell not found**: Specified shell doesn't exist
- **Permission denied**: Cannot execute shell or command
- **Environment setup failed**: Configuration errors
- **Command failed**: Executed command returns error

## Troubleshooting

### Shell Startup Issues
```bash
# Check shell availability
which bash
which zsh

# Verify permissions
ls -la /bin/bash

# Check environment setup
mulle-env status
```

### Environment Problems
```bash
# Debug environment variables
mulle-env shell --command "env | grep -i mulle"

# Check tool availability
mulle-env shell --command "which clang"

# Verify paths
mulle-env shell --command "echo \$PATH"
```

### Command Execution Issues
```bash
# Test command manually
mulle-env shell --command "ls -la"

# Check command syntax
mulle-env shell --command "make --help"

# Debug with verbose output
mulle-env shell --verbose --command "make"
```

## Advanced Features

### Custom Shell Configuration
```bash
# Use custom shell
export SHELL=/usr/local/bin/zsh
mulle-env shell

# Custom prompt
mulle-env shell --command "
  export PS1='[mulle-env] \u@\h:\w\$ '
  bash
"
```

### Environment Persistence
```bash
# Save shell environment
mulle-env shell --command "
  # Modify environment...
  mulle-env environment save my-session
"

# Restore later
mulle-env environment load my-session
mulle-env shell
```

### Remote Development
```bash
# SSH with mulle-env
ssh remote-host "mulle-env shell --command 'make'"

# Sync environment
rsync -av ~/.mulle-env/ remote-host:~/.mulle-env/
```

## Related Commands

- **[`init`](init.md)** - Initialize mulle-env environment
- **[`environment`](environment.md)** - Manage environment variables
- **[`tool`](tool.md)** - Manage development tools
- **[`style`](style.md)** - Configure environment styles
- **[`status`](status.md)** - Display environment status

## Notes

- Shell sessions are isolated from parent environment
- All mulle-env configurations are active in the shell
- Changes made in shell don't persist unless saved
- Use `--clean-env` for reproducible builds
- Shell inherits user's shell preferences and configurations