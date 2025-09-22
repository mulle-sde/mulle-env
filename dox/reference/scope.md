# mulle-env scope

Manage environment variable scopes and isolation.

## Synopsis

```bash
mulle-env scope [command] [options] [scope-name]
```

## Description

The `scope` command manages environment variable scopes and isolation in mulle-env. Scopes allow different parts of your development environment to have isolated or shared environment variables. This is useful for managing different project configurations, user preferences, and system-wide settings.

## Commands

- `list`: List all available scopes
- `create`: Create a new scope
- `delete`: Delete an existing scope
- `activate`: Activate a scope
- `deactivate`: Deactivate current scope
- `show`: Show variables in a scope
- `set`: Set variable in a scope
- `unset`: Remove variable from a scope

## Options

- `--global`: Operate on global scope
- `--local`: Operate on local/project scope
- `--user`: Operate on user scope
- `--system`: Operate on system scope
- `--temporary`: Create temporary scope
- `--persistent`: Make scope persistent across sessions

## Examples

### Scope Management

```bash
# List all scopes
mulle-env scope list

# Create a new project scope
mulle-env scope create project-alpha

# Activate a scope
mulle-env scope activate project-alpha

# Show current scope variables
mulle-env scope show

# Deactivate current scope
mulle-env scope deactivate
```

### Variable Management in Scopes

```bash
# Set variable in current scope
mulle-env scope set CC clang

# Set variable in specific scope
mulle-env scope set --scope project-alpha CXX g++

# Unset variable from scope
mulle-env scope unset CC

# Show variables in specific scope
mulle-env scope show project-alpha
```

### Scope Types

```bash
# Create user-level scope
mulle-env scope create --user my-tools

# Create system-wide scope
mulle-env scope create --system development

# Create temporary scope
mulle-env scope create --temporary temp-config
```

## Scope Hierarchy

### System Scope
- Lowest priority
- System-wide environment variables
- Available to all users and projects
- Modified by system administrators

### User Scope
- User-specific variables
- Available to all projects for this user
- Higher priority than system scope
- Personal development preferences

### Project Scope
- Project-specific variables
- Available only within project directory
- Highest priority for project-specific settings
- Team-shared configurations

### Temporary Scope
- Session-only variables
- Lost when shell exits
- Highest priority for overrides
- Useful for testing configurations

## Scope Resolution

### Variable Lookup Order
1. **Temporary Scope** (highest priority)
2. **Project Scope**
3. **User Scope**
4. **System Scope** (lowest priority)
5. **Shell Environment**

### Scope Isolation
- Variables in higher scopes override lower scopes
- Scopes can be activated/deactivated independently
- Multiple scopes can be active simultaneously
- Conflicts resolved by priority order

## Variable Management

### Setting Variables

```bash
# Simple variable
mulle-env scope set EDITOR vim

# Path variable
mulle-env scope set PATH "$PATH:/opt/local/bin"

# Complex value
mulle-env scope set CFLAGS "-O2 -Wall -Wextra"
```

### Variable Types

**Simple Variables**
```bash
mulle-env scope set PROJECT_NAME "My Project"
mulle-env scope set VERSION "1.0.0"
```

**Path Variables**
```bash
mulle-env scope set PATH "$PATH:/usr/local/bin"
mulle-env scope set LD_LIBRARY_PATH "/opt/lib:$LD_LIBRARY_PATH"
```

**Compiler Flags**
```bash
mulle-env scope set CFLAGS "-std=c11 -O2"
mulle-env scope set CXXFLAGS "-std=c++17 -O2"
```

**Tool Configuration**
```bash
mulle-env scope set CMAKE_GENERATOR "Ninja"
mulle-env scope set MAKEFLAGS "-j8"
```

## Scope Operations

### Creating Scopes

```bash
# Basic scope creation
mulle-env scope create development

# Scope with description
mulle-env scope create --description "Development environment" dev-env

# Temporary scope
mulle-env scope create --temporary test-config
```

### Activating Scopes

```bash
# Activate single scope
mulle-env scope activate development

# Activate multiple scopes
mulle-env scope activate dev-env tools

# Activate with priority
mulle-env scope activate --priority 10 custom
```

### Scope Information

```bash
# Show all scopes
mulle-env scope list

# Show active scopes
mulle-env scope list --active

# Show scope details
mulle-env scope info development

# Show scope variables
mulle-env scope show development
```

## Error Conditions

- **Scope not found**: Specified scope doesn't exist
- **Permission denied**: Insufficient permissions to modify scope
- **Variable conflict**: Variable already defined in higher-priority scope
- **Scope locked**: Scope is locked and cannot be modified

## Troubleshooting

### Scope Conflicts
```bash
# Check for conflicting variables
mulle-env scope show --conflicts

# Resolve conflicts by changing priority
mulle-env scope activate --priority 5 project-scope

# Override conflicting variable
mulle-env scope set --force VARIABLE new-value
```

### Permission Issues
```bash
# Check scope ownership
mulle-env scope info scope-name

# Change scope ownership
mulle-env scope chown user scope-name

# Fix permissions
mulle-env scope chmod 755 scope-name
```

### Variable Resolution
```bash
# Debug variable lookup
mulle-env scope show --debug VARIABLE

# Check scope precedence
mulle-env scope list --priority

# Verify variable value
echo $VARIABLE
```

## Integration

### With Environment Setup
```bash
# Setup project with scopes
mulle-env init
mulle-env scope create project-config
mulle-env scope activate project-config

# Configure project variables
mulle-env scope set BUILD_TYPE Release
mulle-env scope set INSTALL_PREFIX /opt/project
```

### With Tool Management
```bash
# Setup tool-specific scope
mulle-env scope create clang-tools
mulle-env scope activate clang-tools

# Configure tool variables
mulle-env scope set CC clang
mulle-env scope set CXX clang++
mulle-env tool add clang lld
```

### With Style Management
```bash
# Create style scope
mulle-env scope create coding-style
mulle-env scope activate coding-style

# Set style variables
mulle-env scope set INDENT_SIZE 4
mulle-env scope set LINE_LENGTH 100
mulle-env style set team/coding-standard
```

## Advanced Usage

### Scope Inheritance
```bash
# Create child scope
mulle-env scope create --parent development mobile-dev

# Inherit and override
mulle-env scope activate mobile-dev
mulle-env scope set PLATFORM ios
```

### Scope Templates
```bash
# Create from template
mulle-env scope create --template c-development clang-dev

# Apply template variables
mulle-env scope template apply clang-dev
```

### Scope Export/Import
```bash
# Export scope configuration
mulle-env scope export development > dev-config.env

# Import scope configuration
mulle-env scope import < dev-config.env
```

## Related Commands

- **[`environment`](environment.md)** - Manage environment variables
- **[`style`](style.md)** - Configure environment styles
- **[`tool`](tool.md)** - Manage development tools
- **[`status`](status.md)** - Display environment status

## Notes

- Scopes provide isolation between different development contexts
- Higher-priority scopes override lower-priority ones
- Temporary scopes are lost when shell exits
- Use descriptive names for scopes to avoid confusion
- Regularly review and clean up unused scopes