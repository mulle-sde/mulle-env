# mulle-env unveil

Reveal and display internal mulle-env configuration and state.

## Synopsis

```bash
mulle-env unveil [options] [component]
```

## Description

The `unveil` command reveals internal mulle-env configuration details, environment state, and debugging information that is normally hidden from users. This command is primarily used for troubleshooting, debugging, and understanding how mulle-env configures the development environment internally.

## Options

- `--verbose`: Show detailed internal information
- `--debug`: Include debug-level internal data
- `--raw`: Show raw, unprocessed configuration data
- `--all`: Reveal all available internal information
- `--component`: Focus on specific component internals

## Arguments

- `component` (optional): Specific component to unveil (environment, tools, styles, plugins, scopes)

## Examples

### General Unveiling

```bash
# Show all internal configuration
mulle-env unveil --all

# Reveal environment internals
mulle-env unveil environment

# Show tool configuration details
mulle-env unveil tools
```

### Debugging Usage

```bash
# Debug environment setup
mulle-env unveil --debug environment

# Raw configuration data
mulle-env unveil --raw styles

# Verbose plugin information
mulle-env unveil --verbose plugins
```

### Component-Specific

```bash
# Scope internals
mulle-env unveil scopes

# Style configuration details
mulle-env unveil styles

# Plugin loading information
mulle-env unveil plugins
```

## Unveiled Information

### Environment Configuration
- **Variable Resolution**: How environment variables are resolved and prioritized
- **Scope Hierarchy**: Internal scope precedence and activation order
- **Path Construction**: How PATH and other path variables are built
- **Inheritance Rules**: Variable inheritance between scopes

### Tool Management
- **Tool Discovery**: How tools are found and validated
- **Version Detection**: Internal version checking mechanisms
- **Path Resolution**: Tool executable path resolution
- **Compatibility Checks**: Internal compatibility validation

### Style System
- **Style Loading**: How styles are loaded and applied
- **Configuration Merging**: Internal style configuration merging
- **Override Rules**: How style settings override each other
- **Validation Logic**: Internal style validation mechanisms

### Plugin System
- **Plugin Loading**: Internal plugin discovery and loading process
- **Dependency Resolution**: Plugin dependency resolution
- **Integration Points**: How plugins integrate with core systems
- **Lifecycle Management**: Plugin activation and deactivation

### Scope Management
- **Scope Resolution**: Internal scope precedence and conflicts
- **Variable Isolation**: How variables are isolated between scopes
- **Activation Logic**: Internal scope activation mechanisms
- **Persistence Rules**: How scopes persist across sessions

## Debug Output

### Environment Debug
```bash
mulle-env unveil --debug environment
```
Shows:
- Variable resolution order
- Scope activation sequence
- Path construction steps
- Configuration file locations

### Tool Debug
```bash
mulle-env unveil --debug tools
```
Shows:
- Tool search paths
- Version detection methods
- Compatibility matrices
- Installation validation

### Style Debug
```bash
mulle-env unveil --debug styles
```
Shows:
- Style file parsing
- Configuration merging
- Override application
- Validation results

## Raw Data Access

### Configuration Files
```bash
# Raw environment configuration
mulle-env unveil --raw environment

# Raw style definitions
mulle-env unveil --raw styles

# Raw plugin metadata
mulle-env unveil --raw plugins
```

### Internal State
```bash
# Raw scope data
mulle-env unveil --raw scopes

# Raw tool registry
mulle-env unveil --raw tools

# Raw system state
mulle-env unveil --raw system
```

## Troubleshooting Applications

### Environment Issues
```bash
# Debug variable resolution
mulle-env unveil --debug environment | grep VARIABLE_NAME

# Check scope conflicts
mulle-env unveil scopes --conflicts

# Verify path construction
mulle-env unveil environment --paths
```

### Tool Problems
```bash
# Debug tool discovery
mulle-env unveil --debug tools | grep clang

# Check tool versions
mulle-env unveil tools --versions

# Verify tool paths
mulle-env unveil tools --paths
```

### Style Issues
```bash
# Debug style application
mulle-env unveil --debug styles

# Check style conflicts
mulle-env unveil styles --conflicts

# Verify style loading
mulle-env unveil styles --loading
```

### Plugin Issues
```bash
# Debug plugin loading
mulle-env unveil --debug plugins

# Check plugin dependencies
mulle-env unveil plugins --dependencies

# Verify plugin integration
mulle-env unveil plugins --integration
```

## Advanced Usage

### Custom Debugging
```bash
# Focus on specific component
mulle-env unveil environment --component paths

# Filter output
mulle-env unveil --all | grep "error\|warning"

# Save debug output
mulle-env unveil --debug > debug.log
```

### Integration Debugging
```bash
# Debug tool integration
mulle-env unveil tools --integration

# Debug style integration
mulle-env unveil styles --integration

# Debug plugin integration
mulle-env unveil plugins --integration
```

### Performance Analysis
```bash
# Debug loading performance
mulle-env unveil --debug --performance

# Check memory usage
mulle-env unveil --debug --memory

# Analyze startup time
mulle-env unveil --debug --timing
```

## Error Conditions

- **Access denied**: Insufficient permissions to access internal data
- **Component not found**: Specified component doesn't exist
- **Debug mode disabled**: Debug features not available in current build
- **Data corruption**: Internal configuration data is corrupted

## Troubleshooting

### Access Issues
```bash
# Check permissions
ls -la ~/.mulle-env/

# Verify debug mode
mulle-env --version | grep debug

# Check data integrity
mulle-env unveil --integrity
```

### Data Issues
```bash
# Validate configuration
mulle-env unveil --validate

# Check for corruption
mulle-env unveil --check

# Repair corrupted data
mulle-env unveil --repair
```

### Performance Issues
```bash
# Profile unveil operations
mulle-env unveil --profile

# Check resource usage
mulle-env unveil --resources

# Optimize performance
mulle-env unveil --optimize
```

## Integration

### With Development Tools
```bash
# Debug build environment
mulle-env unveil environment > build_env.log

# Check tool configuration
mulle-env unveil tools > tool_config.log

# Analyze style application
mulle-env unveil styles > style_debug.log
```

### With CI/CD Systems
```bash
# Generate debug reports
mulle-env unveil --all > ci_debug.log

# Check environment consistency
mulle-env unveil --validate > validation.log

# Monitor configuration changes
mulle-env unveil --diff > changes.log
```

### With Support Systems
```bash
# Collect diagnostic information
mulle-env unveil --diagnostic > diagnostic.tar.gz

# Generate support bundle
mulle-env unveil --support > support_bundle.tar.gz

# Create troubleshooting report
mulle-env unveil --report > troubleshooting.md
```

## Security Considerations

- **Information Disclosure**: Unveiled data may contain sensitive information
- **Debug Data**: Debug output should not be shared in production
- **Access Control**: Limit access to unveil command in production environments
- **Data Sanitization**: Sanitize output before sharing for support

## Related Commands

- **[`status`](status.md)** - Display environment status
- **[`environment`](environment.md)** - Manage environment variables
- **[`tool`](tool.md)** - Manage development tools
- **[`style`](style.md)** - Configure environment styles
- **[`plugin`](plugin.md)** - Manage plugins

## Notes

- Primarily intended for debugging and troubleshooting
- Output format may change between versions
- Some debug features may require special build configurations
- Use `--raw` option with caution as it shows unprocessed data
- Debug output should not be relied upon for automation