# mulle-env cd

Change to the mulle-env project directory or a subdirectory within it.

## Synopsis

```bash
mulle-env cd [subdirectory]
```

## Description

The `cd` command changes the current working directory to the mulle-env project directory or a specified subdirectory within it. This is useful for quickly navigating to the project structure for development, configuration, or maintenance tasks.

## Options

None

## Arguments

- `subdirectory` (optional): A subdirectory within the mulle-env project to change to

## Examples

### Basic Usage

```bash
# Change to the mulle-env project root directory
mulle-env cd

# Change to the source directory
mulle-env cd src

# Change to the test directory
mulle-env cd test
```

### Development Workflow

```bash
# Navigate to source for editing
mulle-env cd src
# Edit source files...

# Check test directory
mulle-env cd test
# Run tests...

# Return to project root
mulle-env cd
```

### Integration with Other Commands

```bash
# Combine with environment setup
mulle-env init
mulle-env cd src

# Use with tool management
mulle-env tool add clang
mulle-env cd bin
```

## Behavior

- If no subdirectory is specified, changes to the mulle-env project root directory
- If a subdirectory is specified, changes to that subdirectory within the project
- The command fails if the specified subdirectory doesn't exist
- Changes are persistent for the current shell session

## Error Conditions

- **Directory not found**: Specified subdirectory doesn't exist in the project
- **Permission denied**: Insufficient permissions to access the directory
- **Invalid path**: Malformed subdirectory path

## Troubleshooting

### Directory Not Found
```bash
# Check available directories
mulle-env cd
ls -la

# Verify subdirectory exists
ls src/
```

### Permission Issues
```bash
# Check permissions
ls -ld src/

# Change permissions if needed
chmod 755 src/
```

### Path Issues
```bash
# Use absolute paths
mulle-env cd /full/path/to/project/src

# Avoid special characters
mulle-env cd "sub directory"
```

## Integration

### With Development Tools
```bash
# Setup environment and navigate
mulle-env init
mulle-env style set developer/relax
mulle-env cd src

# Edit with preferred editor
$EDITOR main.c
```

### With Build Systems
```bash
# Navigate for build operations
mulle-env cd
make

# Check build artifacts
mulle-env cd build
ls -la
```

### With Version Control
```bash
# Navigate for git operations
mulle-env cd
git status

# Work with specific components
mulle-env cd src/plugins
git diff
```

## Related Commands

- **[`init`](init.md)** - Initialize new environments
- **[`status`](status.md)** - Display environment status
- **[`environment`](environment.md)** - Manage environment variables
- **[`style`](style.md)** - Configure environment styles

## Notes

- This command is primarily for interactive use during development
- Changes are local to the current shell session
- Use absolute paths for scripts to avoid dependency on current directory
- The command respects the project's directory structure conventions