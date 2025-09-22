# mulle-env style / styles - Manage Environment Styles

## Quick Start
Manage environment style settings and configurations.

## All Available Options

### Basic Usage
```bash
mulle-env style <subcommand> [options] [style-name]
# or
mulle-env styles <subcommand> [options] [style-name]
```

**Arguments:**
- `subcommand`: Style management operation (list, set, get, etc.)
- `style-name`: Name of the style to manage

### Visible Options
- `--help`: Show usage information
- `--verbose`: Show detailed style information

### Hidden Options
- `--force`: Force style change without confirmation
- `--reset`: Reset to default style
- Various style-specific configuration options

## Command Behavior

### Core Functionality
- **List**: Display available and current styles
- **Set**: Change active environment style
- **Get**: Show current style configuration
- **Info**: Display detailed style information
- **Reset**: Return to default style

### Conditional Behaviors

**Style Discovery:**
- Searches for available styles in environment
- Validates style compatibility with current setup
- Checks for platform-specific style requirements

**Configuration Management:**
- Applies style-specific environment variables
- Updates tool configurations based on style
- Maintains style consistency across sessions

## Practical Examples

### Basic Style Management
```bash
# List available styles
mulle-env style list

# Show current style
mulle-env style get

# Set a specific style
mulle-env style set developer/relax

# Get detailed style information
mulle-env style info developer/strict
```

### Development Workflows
```bash
# Relaxed development style
mulle-env style set developer/relax
# Allows more flexibility in tool usage

# Strict development style
mulle-env style set developer/strict
# Enforces stricter tool and environment rules

# Minimal style
mulle-env style set minimal
# Reduces environment overhead
```

### Style Information
```bash
# Show all style details
mulle-env style list --verbose

# Compare styles
mulle-env style info developer/relax
mulle-env style info developer/strict

# Check style compatibility
mulle-env style list --platform linux
```

## Troubleshooting

### Style Not Found
```bash
# Style doesn't exist
mulle-env style set nonexistent-style
# Error: Style not found

# Solution: List available styles first
mulle-env style list
mulle-env style set developer/relax
```

### Permission Issues
```bash
# No permission to change style
mulle-env style set developer/strict
# Error: Permission denied

# Solution: Check environment ownership
ls -la .mulle/etc/env/
sudo chown -R $USER .mulle/etc/env/
```

### Incompatible Style
```bash
# Style incompatible with current setup
mulle-env style set windows-style
# Error: Style incompatible with platform

# Solution: Use platform-appropriate style
mulle-env style set developer/relax
```

## Integration with Other Commands

### Environment Setup
```bash
# Initialize with specific style
mulle-env init --style developer/relax

# Change style after initialization
mulle-env style set developer/strict
mulle-env tool relink  # Update tools for new style
```

### Tool Management
```bash
# Style affects tool configurations
mulle-env style set developer/strict
mulle-env tool list  # Shows tools allowed by style

# Style-specific tool behavior
mulle-env style set minimal
mulle-env tool add cmake  # May have different behavior
```

### Clean Operations
```bash
# Clean style-related caches
mulle-env clean --cache
mulle-env style reset  # Reset to default style
```

## Technical Details

### Style Storage Structure
```
.mulle/etc/env/style/
├── available/        # Available style definitions
│   ├── developer/
│   │   ├── relax/
│   │   └── strict/
│   └── minimal/
├── current -> developer/relax  # Current style symlink
└── config/           # Style-specific configurations
```

### Style Components
- **Environment Variables**: Style-specific variable settings
- **Tool Policies**: Which tools are allowed/restricted
- **Path Configurations**: Style-specific PATH modifications
- **Security Settings**: Permission and access controls
- **Platform Settings**: Platform-specific configurations

### Style Types
- **Developer Styles**: Various development environments
  - `developer/relax`: Flexible development environment
  - `developer/strict`: Strict development rules
  - `developer/wild`: Minimal restrictions
- **System Styles**: Platform-specific configurations
- **Custom Styles**: User-defined configurations

### Style Application Process
1. **Validation**: Check style compatibility
2. **Backup**: Save current configuration
3. **Application**: Apply new style settings
4. **Tool Update**: Refresh tool configurations
5. **Verification**: Confirm style application

## Related Commands

- **[`init`](init.md)** - Initialize environment with style
- **[`tool`](tool.md)** - Manage tools affected by style
- **[`clean`](clean.md)** - Clean style-related caches
- **[`environment`](env.md)** - Environment variables affected by style