# mulle-env version - Show Version Information

## Quick Start
Display version information for mulle-env and its components.

## All Available Options

### Basic Usage
```bash
mulle-env version [options]
```

**Arguments:** None

### Visible Options
- `--help`: Show usage information
- `--verbose`: Show detailed version information
- `--short`: Show only version number

### Hidden Options
- `--all`: Show versions of all components
- `--check-updates`: Check for available updates
- Various version-specific display options

## Command Behavior

### Core Functionality
- **Version Display**: Show mulle-env version
- **Component Versions**: Display versions of key components
- **Build Information**: Show build date and platform
- **Update Check**: Verify if updates are available

### Conditional Behaviors

**Output Format:**
- Normal mode: Standard version information
- Verbose mode: Detailed component information
- Short mode: Minimal version string only
- All mode: Comprehensive version listing

**Update Checking:**
- Online mode: Check for updates when network available
- Offline mode: Use cached version information
- Force check: Override cache and check remotely

## Practical Examples

### Basic Version Check
```bash
# Show current version
mulle-env version

# Detailed version information
mulle-env version --verbose

# Short version string
mulle-env version --short
```

### Update Checking
```bash
# Check for updates
mulle-env version --check-updates

# Force update check
mulle-env version --check-updates --force
```

### Component Versions
```bash
# Show all component versions
mulle-env version --all

# Check specific component
mulle-env version --component mulle-sde
```

### Script Integration
```bash
# Get version for scripts
VERSION=$(mulle-env version --short)
echo "Using mulle-env $VERSION"

# Version comparison
if mulle-env version --check-updates | grep -q "update available"; then
    echo "Update recommended"
fi
```

## Troubleshooting

### Network Issues
```bash
# Update check fails due to network
mulle-env version --check-updates
# Error: Network unavailable

# Solution: Use cached information
mulle-env version --verbose
```

### Version Mismatch
```bash
# Components have different versions
mulle-env version --all
# Warning: Version mismatch detected

# Solution: Update components
mulle-env upgrade
```

### Permission Issues
```bash
# Cannot access version files
mulle-env version
# Error: Permission denied

# Solution: Check file permissions
ls -la .mulle/etc/env/version
```

## Integration with Other Commands

### Environment Setup
```bash
# Check version after initialization
mulle-env init
mulle-env version --verbose

# Verify version compatibility
mulle-env version --check-updates
```

### Upgrade Workflows
```bash
# Check current version
mulle-env version

# Check for updates
mulle-env version --check-updates

# Perform upgrade if needed
mulle-env upgrade
```

### Tool Management
```bash
# Check tool versions
mulle-env tool list --versions

# Compare with mulle-env version
mulle-env version --all
```

## Technical Details

### Version Information Sources

**Core Version:**
- Version number from package metadata
- Build date and time
- Git commit hash (if available)
- Platform and architecture

**Component Versions:**
- mulle-sde core components
- Tool versions and compatibility
- Style definitions and versions
- Extension versions

**Build Information:**
- Compiler version used for build
- Build platform and architecture
- Linked libraries and versions
- Configuration options

### Version Format

**Standard Output:**
```
mulle-env 1.2.3 (2024-01-15)
Platform: linux/x86_64
Build: gcc-11.3.0
```

**Verbose Output:**
```
Version: 1.2.3
Build Date: 2024-01-15 14:30:22 UTC
Git Commit: abc123def456
Platform: linux/x86_64
Compiler: gcc 11.3.0
Architecture: x86_64
Linked Libraries:
  - mulle-sde: 2.1.0
  - foundation: 0.20.0
```

**Short Output:**
```
1.2.3
```

### Update Checking Process
1. **Version Retrieval**: Get current installed version
2. **Remote Check**: Query version repository for latest
3. **Comparison**: Compare versions using semantic versioning
4. **Notification**: Report available updates and changes
5. **Caching**: Cache results for performance

### Version Components
- **Major Version**: Breaking changes and major features
- **Minor Version**: New features, backward compatible
- **Patch Version**: Bug fixes and small improvements
- **Build Metadata**: Additional build information

## Related Commands

- **[`upgrade`](upgrade.md)** - Upgrade to newer version
- **[`init`](init.md)** - Initialize with specific version
- **[`status`](status.md)** - Status including version info
- **[`clean`](clean.md)** - Clean version-related caches