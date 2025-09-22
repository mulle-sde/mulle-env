# mulle-env plugin

Manage mulle-env plugins and extensions.

## Synopsis

```bash
mulle-env plugin [command] [options] [plugin-name]
```

## Description

The `plugin` command manages mulle-env plugins and extensions. Plugins extend mulle-env functionality with additional tools, styles, and capabilities. This command allows installing, removing, updating, and managing plugins from various sources.

## Commands

- `list`: List installed and available plugins
- `install`: Install a plugin from repository or local path
- `remove`: Remove an installed plugin
- `update`: Update installed plugins
- `info`: Show detailed information about a plugin
- `search`: Search for plugins in repositories

## Options

- `--global`: Operate on global plugins (system-wide)
- `--local`: Operate on local plugins (project-specific)
- `--force`: Force operation even if conflicts exist
- `--verbose`: Show detailed operation information

## Examples

### Plugin Management

```bash
# List all available plugins
mulle-env plugin list

# Install a plugin
mulle-env plugin install clang-tools

# Install from specific repository
mulle-env plugin install https://github.com/example/mulle-env-plugin.git

# Remove a plugin
mulle-env plugin remove clang-tools

# Update all plugins
mulle-env plugin update
```

### Plugin Information

```bash
# Get detailed plugin information
mulle-env plugin info clang-tools

# Search for plugins
mulle-env plugin search "test"

# List installed plugins
mulle-env plugin list --local
```

### Advanced Usage

```bash
# Install plugin globally
mulle-env plugin install --global cmake-tools

# Force update all plugins
mulle-env plugin update --force

# Install from local path
mulle-env plugin install /path/to/local/plugin
```

## Plugin Types

### Tool Plugins
- Provide additional development tools
- Extend tool management capabilities
- Add platform-specific tools

### Style Plugins
- Define new environment styles
- Customize development workflows
- Add organization-specific configurations

### Integration Plugins
- Connect with external systems
- Add CI/CD integration
- Provide cloud service integration

### Utility Plugins
- Add helper commands
- Provide development utilities
- Extend environment management

## Plugin Sources

### Official Repository
- Curated plugins from mulle-env project
- Tested and maintained by core team
- Available through default plugin commands

### Community Repository
- User-contributed plugins
- Community maintained and tested
- Available through plugin search

### Local Plugins
- Custom plugins developed locally
- Organization-specific extensions
- Private or proprietary plugins

### Git Repositories
- Direct installation from git URLs
- Development versions of plugins
- Custom or forked plugins

## Installation Methods

### Repository Installation
```bash
# Install from official repository
mulle-env plugin install plugin-name

# Install from community repository
mulle-env plugin install community/plugin-name
```

### Direct URL Installation
```bash
# Install from git repository
mulle-env plugin install https://github.com/user/plugin-repo.git

# Install from specific branch
mulle-env plugin install https://github.com/user/plugin-repo.git --branch develop
```

### Local Installation
```bash
# Install from local directory
mulle-env plugin install /path/to/plugin/directory

# Install with custom name
mulle-env plugin install /path/to/plugin --name custom-plugin
```

## Plugin Lifecycle

### Discovery
- Search plugin repositories
- Browse available plugins
- Review plugin documentation

### Installation
- Download plugin files
- Install dependencies
- Configure plugin settings
- Update environment

### Configuration
- Set plugin options
- Configure plugin behavior
- Integrate with existing tools
- Test plugin functionality

### Maintenance
- Update to latest versions
- Monitor for compatibility
- Backup plugin configurations
- Remove unused plugins

## Error Conditions

- **Plugin not found**: Specified plugin doesn't exist in repositories
- **Dependency conflict**: Plugin conflicts with existing tools
- **Permission denied**: Insufficient permissions for installation
- **Network error**: Cannot download plugin from repository

## Troubleshooting

### Installation Issues
```bash
# Check plugin availability
mulle-env plugin search plugin-name

# Verify repository access
curl -I https://github.com/user/plugin-repo.git

# Check disk space
df -h
```

### Plugin Conflicts
```bash
# List conflicting plugins
mulle-env plugin list --conflicts

# Remove conflicting plugin
mulle-env plugin remove conflicting-plugin

# Reinstall after resolution
mulle-env plugin install desired-plugin
```

### Permission Issues
```bash
# Check installation permissions
ls -ld ~/.mulle-env/plugins/

# Fix permissions
chmod -R u+w ~/.mulle-env/plugins/

# Retry installation
mulle-env plugin install plugin-name
```

## Integration

### With Environment Setup
```bash
# Setup environment with plugins
mulle-env init
mulle-env plugin install essential-tools
mulle-env plugin install project-style

# Configure plugins
mulle-env style set custom
mulle-env tool add clang gdb
```

### With Tool Management
```bash
# Install tool plugins
mulle-env plugin install clang-tools
mulle-env plugin install build-tools

# Update tools through plugins
mulle-env tool update --all

# Use plugin-provided tools
mulle-env tool run clang-format
```

### With Style Management
```bash
# Install style plugins
mulle-env plugin install coding-styles
mulle-env plugin install team-config

# Apply plugin styles
mulle-env style set team/coding-standard

# Customize with plugin options
mulle-env style configure indentation 4
```

## Plugin Development

### Creating Plugins
```bash
# Plugin structure
plugin-name/
├── mulle-env-plugin.json    # Plugin metadata
├── bin/                     # Executables
├── lib/                     # Libraries
├── share/                   # Shared files
└── README.md               # Documentation
```

### Plugin Metadata
```json
{
  "name": "example-plugin",
  "version": "1.0.0",
  "description": "Example mulle-env plugin",
  "author": "Developer Name",
  "dependencies": ["tool1", "tool2"],
  "provides": ["feature1", "feature2"]
}
```

## Related Commands

- **[`tool`](tool.md)** - Manage development tools
- **[`style`](style.md)** - Configure environment styles
- **[`environment`](environment.md)** - Manage environment variables
- **[`init`](init.md)** - Initialize new environments

## Notes

- Plugins extend mulle-env without modifying core functionality
- Always review plugin permissions and security implications
- Test plugins in development environment before production use
- Keep plugins updated for security and compatibility
- Document custom plugins for team knowledge sharing