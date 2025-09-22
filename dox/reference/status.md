# mulle-env status - Show Environment Status

## Quick Start
Display the current status and configuration of the mulle-env environment.

## All Available Options

### Basic Usage
```bash
mulle-env status [options]
```

**Arguments:** None

### Visible Options
- `--help`: Show usage information
- `--verbose`: Show detailed status information
- `--quiet`: Show minimal status information

### Hidden Options
- `--json`: Output status in JSON format
- `--check`: Perform environment health check
- Various status-specific display options

## Command Behavior

### Core Functionality
- **Environment Info**: Display basic environment information
- **Tool Status**: Show configured tools and their status
- **Style Info**: Display current environment style
- **Path Info**: Show environment paths and directories
- **Health Check**: Validate environment integrity

### Conditional Behaviors

**Output Format:**
- Normal mode: Human-readable status summary
- Verbose mode: Detailed information about all components
- Quiet mode: Minimal output for scripting
- JSON mode: Structured data for programmatic use

**Environment Detection:**
- Automatically detects if running in mulle-env environment
- Shows parent environment information if applicable
- Displays environment hierarchy and inheritance

## Practical Examples

### Basic Status Check
```bash
# Show current environment status
mulle-env status

# Detailed status information
mulle-env status --verbose

# Minimal status for scripts
mulle-env status --quiet
```

### Health Checking
```bash
# Perform environment health check
mulle-env status --check

# Check specific components
mulle-env status --check tools
mulle-env status --check paths
```

### Script Integration
```bash
# Use in scripts for environment validation
if mulle-env status --quiet; then
    echo "Environment is healthy"
else
    echo "Environment has issues"
    exit 1
fi

# Get status as JSON for processing
STATUS_JSON=$(mulle-env status --json)
echo "$STATUS_JSON" | jq '.tools[] | select(.status != "ok")'
```

### Troubleshooting Workflows
```bash
# Check environment after setup
mulle-env init
mulle-env status --verbose

# Verify tool configuration
mulle-env tool add cmake
mulle-env status --check tools

# Check paths after style change
mulle-env style set developer/strict
mulle-env status --verbose
```

## Troubleshooting

### No Environment Found
```bash
# Not in a mulle-env environment
mulle-env status
# Error: No environment found

# Solution: Initialize environment first
mulle-env init
```

### Incomplete Environment
```bash
# Environment missing components
mulle-env status --check
# Warning: Missing tool configurations

# Solution: Complete environment setup
mulle-env tool add cmake git
mulle-env status --check
```

### Permission Issues
```bash
# Cannot access environment files
mulle-env status
# Error: Permission denied

# Solution: Fix permissions
chmod -R u+rw .mulle/
```

## Integration with Other Commands

### Environment Setup
```bash
# Check status after initialization
mulle-env init
mulle-env status --verbose

# Verify after configuration changes
mulle-env style set developer/relax
mulle-env status
```

### Tool Management
```bash
# Check tool status
mulle-env tool add cmake
mulle-env status --check tools

# Monitor tool health
mulle-env tool relink
mulle-env status --verbose
```

### Maintenance Workflows
```bash
# Regular environment check
mulle-env clean
mulle-env status --check

# Pre-build validation
mulle-env status --quiet || exit 1
make
```

## Technical Details

### Status Information Displayed

**Environment Basics:**
- Environment root directory
- Current style and configuration
- Platform and architecture information
- Environment version and metadata

**Tool Status:**
- Configured tools and versions
- Tool availability and paths
- Symlink status and health
- Tool compatibility with current platform

**Path Information:**
- Environment directories (.mulle/*)
- Tool binary paths
- Library and include paths
- Configuration file locations

**Health Indicators:**
- File permission checks
- Directory existence validation
- Tool availability verification
- Configuration consistency checks

### Output Formats

**Normal Mode:**
```
Environment: /path/to/project
Style: developer/relax
Platform: linux/x86_64
Tools: cmake, git, clang (3/3 ok)
Status: healthy
```

**Verbose Mode:**
```
Environment Details:
  Root: /path/to/project
  Style: developer/relax
  Platform: linux/x86_64
  Host: myhost.local
  User: developer

Tool Status:
  cmake: /usr/bin/cmake (v3.22.1) [ok]
  git: /usr/bin/git (v2.34.1) [ok]
  clang: /usr/bin/clang (v14.0.0) [ok]

Path Information:
  BIN: .mulle/var/host/user/env/bin
  LIB: .mulle/var/host/user/env/lib
  INCLUDE: .mulle/var/host/user/env/include

Health Check: PASSED
```

**JSON Mode:**
```json
{
  "environment": {
    "root": "/path/to/project",
    "style": "developer/relax",
    "platform": "linux/x86_64"
  },
  "tools": [
    {"name": "cmake", "path": "/usr/bin/cmake", "version": "3.22.1", "status": "ok"},
    {"name": "git", "path": "/usr/bin/git", "version": "2.34.1", "status": "ok"}
  ],
  "health": "passed"
}
```

### Status Validation Process
1. **Environment Detection**: Verify mulle-env environment presence
2. **File System Check**: Validate directory structure and permissions
3. **Tool Verification**: Check tool availability and versions
4. **Configuration Validation**: Ensure configuration consistency
5. **Path Resolution**: Verify path accessibility and correctness
6. **Health Assessment**: Generate overall health status

## Related Commands

- **[`init`](init.md)** - Initialize environment
- **[`tool`](tool.md)** - Manage tools checked by status
- **[`style`](style.md)** - Style information shown in status
- **[`clean`](clean.md)** - Clean operations affecting status