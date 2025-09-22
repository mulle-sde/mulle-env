# mulle-env reset - Reset Environment to Clean State

## Quick Start
Reset the mulle-env environment to a clean, default state.

## All Available Options

### Basic Usage
```bash
mulle-env reset [options]
```

**Arguments:** None

### Visible Options
- `--help`: Show usage information
- `--force`: Force reset without confirmation
- `--keep-config`: Preserve user configuration files

### Hidden Options
- `--hard`: Perform complete reset including all caches
- `--soft`: Reset only runtime state
- `--backup`: Create backup before reset
- Various reset-specific options

## Command Behavior

### Core Functionality
- **State Reset**: Return environment to initial state
- **Cache Clearing**: Remove all cached data and artifacts
- **Configuration Reset**: Restore default configuration
- **Tool Relinking**: Refresh all tool symlinks

### Conditional Behaviors

**Reset Scope:**
- Default reset: Preserve user configuration, reset runtime state
- Hard reset: Complete environment reset including configuration
- Soft reset: Reset only temporary state and caches

**Safety Features:**
- Confirmation required unless --force is used
- Backup creation when requested
- Selective preservation of user data

## Practical Examples

### Basic Reset
```bash
# Reset environment to clean state
mulle-env reset

# Force reset without confirmation
mulle-env reset --force

# Reset but keep user configuration
mulle-env reset --keep-config
```

### Advanced Reset Options
```bash
# Complete hard reset
mulle-env reset --hard

# Soft reset (preserve more state)
mulle-env reset --soft

# Reset with backup
mulle-env reset --backup
```

### Recovery Scenarios
```bash
# After environment corruption
mulle-env reset --hard
mulle-env init

# After tool configuration issues
mulle-env reset --soft
mulle-env tool relink

# Clean start for new project phase
mulle-env reset --keep-config
```

### Workflow Integration
```bash
# Reset before clean build
mulle-env reset
mulle-env init --style developer/relax

# Reset after testing
mulle-env reset --soft
mulle-env status
```

## Troubleshooting

### Reset Failures
```bash
# Reset fails due to locked files
mulle-env reset
# Error: Files locked by running processes

# Solution: Stop processes first
pkill -f "mulle-env"
mulle-env reset
```

### Permission Issues
```bash
# No permission to reset environment
mulle-env reset
# Error: Permission denied

# Solution: Check ownership
sudo chown -R $USER .mulle/
```

### Data Loss Concerns
```bash
# Accidental reset without backup
mulle-env reset --hard
# Warning: No backup created

# Solution: Use --backup next time
mulle-env reset --hard --backup
```

### Incomplete Reset
```bash
# Reset doesn't clean everything
mulle-env reset
mulle-env status  # Still shows old state

# Solution: Use hard reset
mulle-env reset --hard
```

## Integration with Other Commands

### Environment Management
```bash
# Reset and reinitialize
mulle-env reset --hard
mulle-env init --style developer/strict

# Reset for style change
mulle-env reset --keep-config
mulle-env style set developer/minimal
```

### Tool Management
```bash
# Reset tool configurations
mulle-env reset --soft
mulle-env tool add cmake git clang

# Clean tool environment
mulle-env reset
mulle-env tool relink --force
```

### Maintenance Workflows
```bash
# Weekly environment maintenance
mulle-env reset --soft
mulle-env clean
mulle-env upgrade

# Troubleshooting workflow
mulle-env reset --backup
mulle-env status --verbose
```

## Technical Details

### Reset Process

**Phase 1: Assessment**
- Analyze current environment state
- Identify files and configurations to reset
- Check for running processes that may interfere
- Generate reset plan

**Phase 2: Preparation**
- Create backup if requested
- Stop dependent services and processes
- Prepare rollback information
- Validate reset safety

**Phase 3: Execution**
- Remove cache files and temporary data
- Reset configuration to defaults
- Clear tool symlinks and caches
- Restore clean environment structure

**Phase 4: Verification**
- Verify environment integrity
- Test basic functionality
- Update metadata and timestamps
- Provide status report

### Reset Types

**Soft Reset:**
- Clears runtime caches and temporary files
- Preserves user configuration and settings
- Maintains tool configurations
- Quick operation with minimal disruption

**Hard Reset:**
- Complete environment reset
- Removes all user configurations
- Clears all caches and temporary files
- Returns to clean installation state

**Configuration-Preserving Reset:**
- Resets runtime state but keeps user preferences
- Maintains style and tool selections
- Preserves custom environment variables
- Balances cleanliness with user convenience

### Backup and Recovery

**Automatic Backups:**
- Configuration files backup
- User settings preservation
- Tool configuration archive
- Environment state snapshot

**Recovery Options:**
- Rollback to previous state
- Selective restoration of components
- Configuration migration
- Incremental recovery

### Safety Mechanisms

**Confirmation Requirements:**
- User confirmation for destructive operations
- Clear warnings about data loss
- Option to create backups automatically
- Force option for automated scripts

**Data Preservation:**
- Identification of user-critical data
- Selective preservation during reset
- Backup creation and management
- Recovery procedures documentation

## Related Commands

- **[`init`](init.md)** - Initialize fresh environment
- **[`clean`](clean.md)** - Clean artifacts without full reset
- **[`upgrade`](upgrade.md)** - Upgrade rather than reset
- **[`status`](status.md)** - Check environment state after reset