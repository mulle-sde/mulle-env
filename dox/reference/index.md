# mulle-env Command Reference

## Overview

**mulle-env** is a cross-platform environment manager for development tools and project configurations. This reference documents all available commands organized by category.

## Command Categories

### Environment Management
- **[`init`](init.md)** - Initialize new environments with various styles
- **[`reset`](reset.md)** - Reset environment to clean state
- **[`upgrade`](upgrade.md)** - Upgrade environment components
- **[`clean`](clean.md)** - Clean environment artifacts

### Configuration
- **[`environment`](environment.md)** - Manage environment variables
- **[`style`](style.md)** - Configure environment styles
- **[`tool`](tool.md)** - Manage development tools
- **[`status`](status.md)** - Display environment status

### System Information
- **[`uname`](uname.md)** - Display system information
- **[`hostname`](hostname.md)** - Display or set hostname
- **[`username`](username.md)** - Display or set username
- **[`version`](version.md)** - Display version information

## Quick Start Examples

### New Environment Setup
```bash
# Initialize new environment
mulle-env init

# Set development style
mulle-env style set developer/relax

# Add essential tools
mulle-env tool add clang cmake git
```

### Development Workflow
```bash
# Check environment status
mulle-env status

# Set environment variables
mulle-env environment set CC clang

# Upgrade environment
mulle-env upgrade
```

### Tool Management
```bash
# Add development tools
mulle-env tool add gdb valgrind

# List available tools
mulle-env tool list

# Remove unused tools
mulle-env tool remove old-tool
```

### Environment Configuration
```bash
# Set custom environment variables
mulle-env environment set MY_PROJECT_PATH /path/to/project

# Configure build settings
mulle-env environment set CMAKE_BUILD_TYPE Debug

# Check current configuration
mulle-env status --verbose
```

## Command Reference Table

| Command | Category | Description |
|---------|----------|-------------|
| `init` | Environment | Initialize new environments |
| `reset` | Environment | Reset to clean state |
| `upgrade` | Environment | Upgrade components |
| `clean` | Environment | Clean artifacts |
| `environment` | Configuration | Manage variables |
| `style` | Configuration | Configure styles |
| `tool` | Configuration | Manage tools |
| `status` | Configuration | Show status |
| `uname` | System | System information |
| `hostname` | System | Hostname management |
| `username` | System | Username management |
| `version` | System | Version information |

## Getting Help

### Command Help
```bash
# Get help for specific command
mulle-env <command> --help

# Get detailed help
mulle-env <command> --help --verbose

# List all commands
mulle-env --help
```

### Documentation
- Each command has a dedicated documentation file in this reference
- Use `--help` for quick command usage
- Check `mulle-env status` for environment-specific information

## Common Workflows

### Environment Setup
1. **Initialize** environment: `mulle-env init`
2. **Configure** style: `mulle-env style set <style>`
3. **Setup** tools: `mulle-env tool add <tools>`
4. **Configure** environment: `mulle-env environment set <vars>`

### Daily Development
1. **Check** status: `mulle-env status`
2. **Set** environment variables: `mulle-env environment set <vars>`
3. **Add** tools as needed: `mulle-env tool add <tools>`
4. **Upgrade** when available: `mulle-env upgrade`

### Troubleshooting
1. **Check** status: `mulle-env status --verbose`
2. **Reset** if needed: `mulle-env reset`
3. **Clean** environment: `mulle-env clean`
4. **Reinitialize**: `mulle-env init`

## Advanced Usage

### Custom Environment Variables
```bash
# Project-specific variables
mulle-env environment set PROJECT_ROOT /path/to/project
mulle-env environment set BUILD_DIR ${PROJECT_ROOT}/build

# Tool-specific configuration
mulle-env environment set CC clang
mulle-env environment set CXX clang++
mulle-env environment set CFLAGS "-O2 -g"
```

### Style Customization
```bash
# Choose development style
mulle-env style set developer/relax

# List available styles
mulle-env style list

# Custom style configuration
mulle-env style set custom
```

### Tool Management
```bash
# Add multiple tools
mulle-env tool add clang cmake git gdb

# Set tool versions
mulle-env tool set clang --version 14

# Remove tools
mulle-env tool remove old-tool
```

### Environment Persistence
```bash
# Environment changes persist across sessions
mulle-env environment set MY_VAR value
# MY_VAR will be available in future sessions

# Reset environment
mulle-env reset
# Removes all customizations
```

## Troubleshooting

### Environment Issues
```bash
# Check environment status
mulle-env status --verbose

# Reset corrupted environment
mulle-env reset

# Clean and reinitialize
mulle-env clean
mulle-env init
```

### Tool Problems
```bash
# Relink tools
mulle-env tool relink

# Check tool status
mulle-env tool list

# Remove problematic tools
mulle-env tool remove bad-tool
mulle-env tool add good-tool
```

### Configuration Issues
```bash
# Check current configuration
mulle-env status

# Reset environment variables
mulle-env environment clear

# Reset to default style
mulle-env style set default
```

## Integration with Other Tools

### Build Systems
```bash
# Set build variables
mulle-env environment set CMAKE_GENERATOR "Unix Makefiles"
mulle-env environment set CMAKE_BUILD_TYPE Debug

# Configure compiler
mulle-env environment set CC gcc
mulle-env environment set CXX g++
```

### Development Tools
```bash
# Configure editor
mulle-env environment set EDITOR vim

# Set language settings
mulle-env environment set LANG en_US.UTF-8

# Configure paths
mulle-env environment set PATH "${HOME}/bin:${PATH}"
```

### Version Control
```bash
# Set git configuration
mulle-env environment set GIT_AUTHOR_NAME "Your Name"
mulle-env environment set GIT_AUTHOR_EMAIL "your.email@example.com"

# Configure SSH
mulle-env environment set SSH_KEY_PATH "${HOME}/.ssh/id_rsa"
```

## Related Documentation

- **[README.md](../../README.md)** - Project overview and installation
- **[mulle-sde](../mulle-sde/)** - Build system integration
- **[Environment Variables](./environment.md)** - Detailed variable management
- **[Tool Management](./tool.md)** - Advanced tool configuration