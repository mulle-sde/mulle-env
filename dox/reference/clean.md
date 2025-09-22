# mulle-env clean - Clean Environment Artifacts

## Quick Start
Remove cached artifacts and temporary files from the mulle-env environment.

## All Available Options

### Basic Usage
```bash
mulle-env clean [options]
```

**Arguments:** None

### Visible Options
- `--help`: Show usage information

### Hidden Options
- Various domain-specific cleaning options

## Command Behavior

### Core Functionality
- **Removes**: Tool caches and temporary files
- **Cleans**: Environment variable caches
- **Resets**: Tool relinking triggers
- **Preserves**: Configuration files and user settings

### Conditional Behaviors

**Environment Context:**
- Works only within initialized mulle-env environments
- Requires write permissions to environment directories
- Safe to run multiple times

**Selective Cleaning:**
- Without options: Cleans all artifacts

## Practical Examples

### Basic Cleaning
```bash
# Clean all environment artifacts
mulle-env clean
```

### Development Workflow
```bash
# After changing tool versions
mulle-env tool upgrade cmake
mulle-env clean  # Clear old tool caches

# Before debugging issues
mulle-env clean
mulle-env tool relink

# Regular maintenance
mulle-env clean  # Weekly cleanup
```

### Selective Cleaning
```bash
# Clean all artifacts (no selective options available)
mulle-env clean
```

## Troubleshooting

### Permission Issues
```bash
# No write permission to environment directories
mulle-env clean
# Error: Permission denied

# Solution: Check directory ownership
ls -la .mulle/var/
sudo chown -R $USER .mulle/var/
```

### Environment Not Found
```bash
# Not in a mulle-env environment
mulle-env clean
# Error: No environment found

# Solution: Initialize environment first
mulle-env init
```

### Files Still in Use
```bash
# Some files locked by running processes
mulle-env clean
# Warning: Some files could not be removed

# Solution: Close running applications
pkill -f "mulle-env"
mulle-env clean
```

## Integration with Other Commands

### Tool Management
```bash
# Clean before tool operations
mulle-env clean
mulle-env tool add gcc
mulle-env tool relink
```

### Environment Reset
```bash
# Clean environment state
mulle-env clean
mulle-env reset
mulle-env init
```

### Debugging Workflows
```bash
# Clean for debugging
mulle-env clean
mulle-env tool relink --force
mulle-env -- bash -x script.sh
```

## Technical Details

### Files and Directories Cleaned

**Cache Files:**
- `.mulle/var/*/env/cache/` - Environment variable caches
- `.mulle/var/*/env/tool/` - Tool-specific caches
- `.mulle/var/*/env/style/` - Style configuration caches

**Temporary Files:**
- `.mulle/var/*/env/tmp/` - Temporary working files
- `.mulle/var/*/env/log/` - Log files older than retention period
- Build artifacts in temporary directories

**Tool Artifacts:**
- Symlinked tool executables (marked for relinking)
- Tool configuration caches
- Platform-specific tool caches

### Cleaning Process
1. **Discovery**: Scan environment directories for cleanable files
2. **Filtering**: Apply cleaning options and safety checks
3. **Removal**: Delete files safely with error handling
4. **Verification**: Check for successful cleanup
5. **Relinking**: Mark tools for relinking if necessary

### Safety Features
- **Preservation**: Never deletes configuration files
- **Backup**: Creates backup of critical files before removal
- **Verification**: Checks file ownership before deletion
- **Recovery**: Provides rollback options for accidental deletion

## Related Commands

- **[`init`](init.md)** - Initialize new environment
- **[`reset`](reset.md)** - Reset environment to clean state
- **[`tool`](tool.md)** - Manage environment tools
- **[`upgrade`](upgrade.md)** - Upgrade environment version