# mulle-env tool - Manage Environment Tools

## Quick Start
Manage tools and executables within the mulle-env environment.

## All Available Options

### Basic Usage
```bash
mulle-env tool <subcommand> [options] [tool-name]
```

**Arguments:**
- `subcommand`: Tool management operation (add, remove, list, etc.)
- `tool-name`: Name of the tool to manage

### Visible Options
- `--help`: Show usage information
- `--version`: Show tool version information

### Hidden Options
- `--force`: Force operation without confirmation
- `--all`: Apply to all tools
- `--platform <platform>`: Target specific platform
- Various tool-specific options

## Command Behavior

### Core Functionality
- **Add**: Install and configure tools in environment
- **Remove**: Uninstall tools from environment
- **List**: Display configured tools
- **Relink**: Refresh tool symlinks and paths
- **Upgrade**: Update tools to newer versions

### Conditional Behaviors

**Tool Discovery:**
- Searches system PATH for available tools
- Validates tool compatibility with environment
- Checks for platform-specific requirements

**Dependency Management:**
- Resolves tool dependencies automatically
- Handles conflicting tool versions
- Maintains tool isolation between environments

## Practical Examples

### Basic Tool Management
```bash
# List available tools
mulle-env tool list

# Add a specific tool
mulle-env tool add cmake

# Remove a tool
mulle-env tool remove gcc

# Upgrade all tools
mulle-env tool upgrade
```

### Development Setup
```bash
# Set up development environment
mulle-env tool add cmake
mulle-env tool add git
mulle-env tool add clang

# Check tool status
mulle-env tool list --verbose

# Relink after system changes
mulle-env tool relink
```

### Cross-Platform Development
```bash
# Add platform-specific tools
mulle-env tool add --platform linux cmake
mulle-env tool add --platform darwin clang

# List tools for specific platform
mulle-env tool list --platform darwin
```

## Troubleshooting

### Tool Not Found
```bash
# Tool not in system PATH
mulle-env tool add nonexistent-tool
# Error: Tool not found in PATH

# Solution: Install tool first
sudo apt install cmake
mulle-env tool add cmake
```

### Permission Issues
```bash
# No permission to create symlinks
mulle-env tool add cmake
# Error: Permission denied

# Solution: Check environment permissions
ls -la .mulle/var/
chmod u+w .mulle/var/
```

### Conflicting Versions
```bash
# Multiple tool versions available
mulle-env tool add gcc
# Warning: Multiple versions found

# Solution: Specify version
mulle-env tool add gcc-9
```

## Integration with Other Commands

### Environment Setup
```bash
# Initialize and configure tools
mulle-env init
mulle-env tool add cmake git clang
mulle-env tool relink
```

### Style Configuration
```bash
# Tools affected by style settings
mulle-env style set developer/strict
mulle-env tool relink  # Refresh with new style
```

### Clean Operations
```bash
# Clean tool caches
mulle-env clean --cache
mulle-env tool relink  # Rebuild tool links
```

## Technical Details

### Tool Storage Structure
```
.mulle/var/<host>/<user>/env/tool/
├── bin/           # Tool executables
├── lib/           # Tool libraries
├── include/       # Tool headers
└── share/         # Tool data files
```

### Tool Discovery Process
1. **PATH Scanning**: Search system PATH for tool executables
2. **Version Detection**: Identify tool versions and capabilities
3. **Dependency Analysis**: Check for required libraries and tools
4. **Platform Validation**: Ensure tool compatibility with target platform
5. **Symlink Creation**: Create environment-specific symlinks

### Tool Types Supported
- **Compilers**: gcc, clang, msvc
- **Build Tools**: cmake, make, ninja
- **Version Control**: git, svn, hg
- **Development Tools**: gdb, valgrind, clang-format
- **Package Managers**: apt, brew, vcpkg

### Symlink Management
- **Isolation**: Tools isolated per environment
- **Versioning**: Multiple tool versions supported
- **Platform**: Platform-specific tool variants
- **Caching**: Tool discovery results cached for performance

## Related Commands

- **[`init`](init.md)** - Initialize environment
- **[`clean`](clean.md)** - Clean environment artifacts
- **[`style`](style.md)** - Manage environment styles
- **[`mulle-tool-env`](mulle-tool-env.md)** - Generate tool environment variables