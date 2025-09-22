# mulle-env upgrade - Upgrade Environment Components

## Quick Start
Upgrade mulle-env environment and its components to newer versions.

## All Available Options

### Basic Usage
```bash
mulle-env upgrade [options] [component]
```

**Arguments:**
- `component`: Optional specific component to upgrade (defaults to all)

### Visible Options
- `--help`: Show usage information
- `--dry-run`: Show what would be upgraded without making changes
- `--force`: Force upgrade even if already up-to-date

### Hidden Options
- `--all`: Upgrade all components (default)
- `--check-only`: Only check for available upgrades
- `--backup`: Create backup before upgrading
- Various upgrade-specific options

## Command Behavior

### Core Functionality
- **Version Check**: Verify current versions against available updates
- **Component Upgrade**: Update specified or all components
- **Dependency Resolution**: Handle component interdependencies
- **Configuration Migration**: Migrate settings between versions

### Conditional Behaviors

**Component Selection:**
- No component specified: Upgrade all components
- Specific component: Upgrade only that component
- Multiple components: Upgrade each specified component

**Upgrade Strategy:**
- Safe upgrade: Check compatibility before upgrading
- Force upgrade: Override compatibility checks
- Dry run: Show changes without applying them

## Practical Examples

### Basic Upgrades
```bash
# Upgrade all components
mulle-env upgrade

# Upgrade specific component
mulle-env upgrade mulle-sde

# Check what would be upgraded
mulle-env upgrade --dry-run
```

### Safe Upgrades
```bash
# Force upgrade if needed
mulle-env upgrade --force

# Create backup before upgrading
mulle-env upgrade --backup

# Check only, don't upgrade
mulle-env upgrade --check-only
```

### Component-Specific Upgrades
```bash
# Upgrade core environment
mulle-env upgrade environment

# Upgrade tools
mulle-env upgrade tools

# Upgrade styles
mulle-env upgrade styles
```

### Workflow Integration
```bash
# Regular maintenance upgrade
mulle-env upgrade --all

# After environment issues
mulle-env clean
mulle-env upgrade

# Before major development
mulle-env upgrade --dry-run
mulle-env upgrade --force
```

## Troubleshooting

### Upgrade Conflicts
```bash
# Component version conflicts
mulle-env upgrade
# Error: Version conflict detected

# Solution: Upgrade specific components
mulle-env upgrade component1
mulle-env upgrade component2
```

### Network Issues
```bash
# Cannot reach update servers
mulle-env upgrade
# Error: Network unavailable

# Solution: Check network connectivity
ping update.mulle-sde.org
```

### Permission Issues
```bash
# No permission to write updates
mulle-env upgrade
# Error: Permission denied

# Solution: Check environment permissions
sudo chown -R $USER .mulle/
```

### Failed Upgrades
```bash
# Upgrade fails midway
mulle-env upgrade
# Error: Upgrade failed

# Solution: Restore from backup
mulle-env upgrade --restore-backup
```

## Integration with Other Commands

### Version Management
```bash
# Check versions before upgrade
mulle-env version --all

# Upgrade and verify
mulle-env upgrade
mulle-env version --all
```

### Environment Maintenance
```bash
# Clean before upgrading
mulle-env clean --all
mulle-env upgrade

# Relink tools after upgrade
mulle-env upgrade tools
mulle-env tool relink
```

### Status Monitoring
```bash
# Check upgrade status
mulle-env status --verbose

# Monitor upgrade progress
mulle-env upgrade --verbose
```

## Technical Details

### Upgrade Process

**Phase 1: Assessment**
- Check current component versions
- Query available updates from repositories
- Analyze compatibility requirements
- Generate upgrade plan

**Phase 2: Preparation**
- Create backup of current state
- Download new component versions
- Verify download integrity
- Prepare rollback plan

**Phase 3: Execution**
- Stop dependent services
- Install new component versions
- Update configuration files
- Migrate user settings

**Phase 4: Verification**
- Test upgraded components
- Verify environment integrity
- Update version metadata
- Clean up temporary files

### Component Types

**Core Components:**
- mulle-env core framework
- mulle-sde build system
- Foundation libraries

**Tool Components:**
- Compiler toolchains (gcc, clang)
- Build tools (cmake, make)
- Development utilities

**Style Components:**
- Environment style definitions
- Configuration templates
- Platform-specific settings

### Backup Strategy

**Automatic Backups:**
- Configuration files backup
- Tool symlinks backup
- Environment variables backup
- User settings preservation

**Manual Restoration:**
- Rollback to previous versions
- Restore from backup archives
- Selective component restoration

### Version Compatibility

**Semantic Versioning:**
- Major version: Breaking changes
- Minor version: New features
- Patch version: Bug fixes

**Compatibility Matrix:**
- Forward compatibility: Newer versions support older configurations
- Backward compatibility: Older versions may not support newer features
- Migration paths: Automatic configuration migration

## Related Commands

- **[`version`](version.md)** - Check current versions
- **[`clean`](clean.md)** - Clean before upgrading
- **[`status`](status.md)** - Verify upgrade success
- **[`init`](init.md)** - Initialize with specific version