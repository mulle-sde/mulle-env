# mulle-env init - Initialize Environment

## Quick Start
Initialize a new mulle-env environment in the current directory.

## All Available Options

### Basic Usage
```bash
mulle-env init [options] [directory]
```

**Arguments:**
- `directory`: Optional directory to initialize (defaults to current directory)

### Visible Options
- `--style <style>`: Set the environment style (default: developer/relax)
- `--help`: Show usage information

### Hidden Options
- `--upgrade`: Perform upgrade instead of initialization
- Various internal options for environment setup

## Command Behavior

### Core Functionality
- **Creates**: `.mulle/etc/env/` and `.mulle/share/env/` directories
- **Generates**: `environment.sh` file with default settings
- **Sets up**: Tool and style configurations
- **Initializes**: Version tracking and environment metadata

### Conditional Behaviors

**Directory Context:**
- If no directory specified, uses current working directory
- Creates directory if it doesn't exist
- Fails if directory exists and is not empty (unless forced)

**Environment Detection:**
- Searches for existing environments in parent directories
- Inherits settings from superior environments when appropriate
- Creates isolated environment if no parent found

## Practical Examples

### Basic Initialization
```bash
# Initialize in current directory
mulle-env init

# Initialize in specific directory
mulle-env init my-project

# Initialize with custom style
mulle-env init --style developer/wild
```

### Project Setup Workflow
```bash
# Create and enter project directory
mkdir my-c-project
cd my-c-project

# Initialize mulle-env environment
mulle-env init

# The environment is now ready for use
mulle-env -c 'echo "Environment initialized"'
```

### Style Selection
```bash
# Developer-friendly (default)
mulle-env init --style developer/relax

# Minimal restrictions
mulle-env init --style developer/wild

# Strict security
mulle-env init --style developer/strict

# Custom style
mulle-env init --style mycompany/standard
```

## Troubleshooting

### Directory Issues
```bash
# Directory already exists and is not empty
mulle-env init existing-project
# Error: Directory exists and is not empty

# Solution: Use a new directory or check contents
ls existing-project/
mulle-env init new-project
```

### Permission Issues
```bash
# No write permission in directory
mulle-env init /readonly/directory
# Error: Permission denied

# Solution: Change to writable location
cd ~/projects
mulle-env init my-project
```

### Existing Environment
```bash
# Environment already exists
mulle-env init
# Error: Environment already initialized

# Check existing environment
mulle-env environment list

# Use reset if needed
mulle-env reset
```

## Integration with Other Commands

### Environment Management
```bash
# After initialization, manage environment
mulle-env init
mulle-env environment list
mulle-env environment set CC clang
```

### Tool Setup
```bash
# Initialize and configure tools
mulle-env init
mulle-env tool add cmake
mulle-env tool add git
```

### Style Configuration
```bash
# Initialize with specific style
mulle-env init --style developer/relax
mulle-env style list
mulle-env style set developer/strict
```

## Technical Details

### Directory Structure Created
```
.mulle/
├── etc/env/
│   ├── environment.sh     # Main environment configuration
│   └── style/            # Style-specific settings
└── share/env/
    ├── environment.sh    # Shared environment settings
    ├── tool/            # Tool configurations
    └── version          # Version information
```

### Environment Variables Set
- `MULLE_VIRTUAL_ROOT`: Root directory of the environment
- `MULLE_ENV_ETC_DIR`: Configuration directory
- `MULLE_ENV_SHARE_DIR`: Shared settings directory
- `MULLE_UNAME`: Operating system identifier
- `MULLE_HOSTNAME`: System hostname

### File Permissions
- Configuration files: Readable by owner
- Tool directories: Executable permissions for tools
- Environment files: Sourced by shell (execute permission)

## Related Commands

- **[`reset`](reset.md)** - Reset environment to clean state
- **[`reset`](reset.md)** - Reset environment to clean state
- **[`clean`](clean.md)** - Clean environment artifacts
- **[`upgrade`](upgrade.md)** - Upgrade environment version
- **[`status`](status.md)** - Show environment status