# mulle-env migrate

Migrate environment configurations between different versions or formats.

## Synopsis

```bash
mulle-env migrate [options]
```

## Description

The `migrate` command handles migration of mulle-env environment configurations between different versions, formats, or system configurations. This is useful when upgrading mulle-env versions, moving between different operating systems, or updating environment configurations to new formats.

## Options

- `--dry-run`: Show what would be migrated without making changes
- `--force`: Force migration even if conflicts are detected
- `--backup`: Create backup before migration
- `--verbose`: Show detailed migration progress

## Examples

### Basic Migration

```bash
# Migrate environment to current version
mulle-env migrate

# Preview migration without changes
mulle-env migrate --dry-run

# Force migration with backup
mulle-env migrate --force --backup
```

### Version Upgrade Migration

```bash
# After upgrading mulle-env version
mulle-env migrate --verbose

# Migrate with detailed logging
mulle-env migrate --verbose --backup
```

### Cross-Platform Migration

```bash
# Migrate from Linux to macOS
mulle-env migrate --force

# Migrate from Windows to Linux
mulle-env migrate --backup --verbose
```

## Migration Types

### Version Migration
- Updates configuration format for new mulle-env versions
- Migrates deprecated settings to current format
- Updates tool configurations for compatibility

### Platform Migration
- Adapts environment for different operating systems
- Updates platform-specific tool paths
- Migrates system-specific configurations

### Configuration Migration
- Updates environment variable formats
- Migrates style configurations
- Updates tool definitions

## Behavior

- **Safe by default**: Creates backups before making changes
- **Non-destructive**: Preserves original configurations
- **Incremental**: Can be run multiple times safely
- **Recoverable**: Can restore from backups if needed

## Error Conditions

- **Version incompatibility**: Target version doesn't support migration
- **Permission denied**: Insufficient permissions for migration
- **Corrupted configuration**: Configuration files are damaged
- **Disk space**: Insufficient space for backup

## Troubleshooting

### Migration Conflicts
```bash
# Check for conflicts first
mulle-env migrate --dry-run

# Resolve conflicts manually
# Edit configuration files...

# Then migrate
mulle-env migrate --force
```

### Permission Issues
```bash
# Check file permissions
ls -la ~/.mulle-env/

# Fix permissions
chmod -R u+w ~/.mulle-env/

# Retry migration
mulle-env migrate
```

### Backup and Recovery
```bash
# Create manual backup
cp -r ~/.mulle-env ~/.mulle-env.backup

# Restore from backup
cp -r ~/.mulle-env.backup ~/.mulle-env

# Clean up backup
rm -rf ~/.mulle-env.backup
```

## Integration

### With Environment Setup
```bash
# Setup new environment
mulle-env init

# Migrate existing configurations
mulle-env migrate --backup

# Verify migration
mulle-env status
```

### With Tool Management
```bash
# Update tools after migration
mulle-env migrate
mulle-env tool update

# Reconfigure tools
mulle-env tool relink
```

### With Style Management
```bash
# Migrate and update style
mulle-env migrate
mulle-env style set developer/relax

# Verify style compatibility
mulle-env status --verbose
```

## Migration Checklist

### Pre-Migration
- [ ] Backup important configurations
- [ ] Check available disk space
- [ ] Review current environment status
- [ ] Note custom configurations

### During Migration
- [ ] Monitor progress with `--verbose`
- [ ] Check for error messages
- [ ] Verify each migration step
- [ ] Note any warnings or conflicts

### Post-Migration
- [ ] Verify environment status
- [ ] Test critical tools and configurations
- [ ] Check for missing settings
- [ ] Update documentation if needed

## Related Commands

- **[`init`](init.md)** - Initialize new environments
- **[`upgrade`](upgrade.md)** - Upgrade environment components
- **[`reset`](reset.md)** - Reset environment to clean state
- **[`status`](status.md)** - Display environment status
- **[`environment`](environment.md)** - Manage environment variables

## Notes

- Migration is typically automatic during version upgrades
- Manual migration may be needed for complex configurations
- Always backup before major migrations
- Test migrated environment thoroughly before production use
- Migration preserves user customizations when possible