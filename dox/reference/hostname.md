# mulle-env hostname - Display or Set Hostname

## Quick Start
Display or modify the system hostname within the mulle-env environment.

## All Available Options

### Basic Usage
```bash
mulle-env hostname [options] [new-hostname]
```

**Arguments:**
- `new-hostname`: Optional new hostname to set

### Visible Options
- `--help`: Show usage information
- `--verbose`: Show detailed hostname information
- `--short`: Show only hostname

### Hidden Options
- `--set <hostname>`: Set hostname to specified value
- `--reset`: Reset to system default hostname
- `--domain`: Include domain information
- Various hostname-specific options

## Command Behavior

### Core Functionality
- **Display**: Show current hostname
- **Set**: Change hostname for environment
- **Reset**: Return to system default
- **Domain**: Show hostname with domain

### Conditional Behaviors

**Hostname Management:**
- Environment-specific hostname override
- System hostname fallback
- Domain name inclusion options
- Hostname validation and formatting

**Scope Control:**
- Session-specific hostname changes
- Global environment hostname settings
- Temporary vs. persistent hostname modifications

## Practical Examples

### Basic Hostname Operations
```bash
# Show current hostname
mulle-env hostname

# Show detailed hostname info
mulle-env hostname --verbose

# Set new hostname
mulle-env hostname myproject-dev

# Reset to system default
mulle-env hostname --reset
```

### Domain and Network Information
```bash
# Show hostname with domain
mulle-env hostname --domain

# Show short hostname only
mulle-env hostname --short

# Set hostname with domain
mulle-env hostname myhost.local
```

### Environment-Specific Configuration
```bash
# Set development hostname
mulle-env hostname dev-machine

# Set production hostname
mulle-env hostname prod-server

# Check hostname in scripts
CURRENT_HOST=$(mulle-env hostname --short)
```

### Workflow Integration
```bash
# Configure hostname for project
PROJECT_NAME="myproject"
mulle-env hostname "${PROJECT_NAME}-$(mulle-env uname --short)"

# Hostname-based configuration
case "$(mulle-env hostname --short)" in
    "dev-"*)
        mulle-env style set developer/relax
        ;;
    "prod-"*)
        mulle-env style set production
        ;;
esac
```

## Troubleshooting

### Hostname Not Set
```bash
# Hostname not showing expected value
mulle-env hostname
# Shows system default instead of custom

# Solution: Set hostname explicitly
mulle-env hostname my-custom-host
```

### Permission Issues
```bash
# Cannot set hostname
mulle-env hostname newhost
# Error: Permission denied

# Solution: Check environment permissions
ls -la .mulle/etc/env/
sudo chown -R $USER .mulle/etc/env/
```

### Invalid Hostname
```bash
# Invalid hostname format
mulle-env hostname "invalid hostname"
# Error: Invalid hostname format

# Solution: Use valid hostname format
mulle-env hostname valid-hostname
```

### Domain Resolution Issues
```bash
# Domain not resolving
mulle-env hostname --domain
# Shows incomplete domain information

# Solution: Check network configuration
cat /etc/resolv.conf
```

## Integration with Other Commands

### Environment Setup
```bash
# Set hostname during initialization
mulle-env init
mulle-env hostname "project-$(date +%Y%m%d)"

# Hostname-based style selection
HOST_PREFIX=$(mulle-env hostname --short | cut -d'-' -f1)
case "$HOST_PREFIX" in
    "dev")
        mulle-env style set developer/relax
        ;;
    "test")
        mulle-env style set testing
        ;;
    "prod")
        mulle-env style set production
        ;;
esac
```

### Tool Configuration
```bash
# Hostname-specific tool configuration
HOSTNAME=$(mulle-env hostname --short)
if [[ "$HOSTNAME" == *"gpu"* ]]; then
    mulle-env tool add cuda
fi

# Network-based tool setup
if mulle-env hostname --domain | grep -q "corp.com"; then
    mulle-env tool add corporate-tools
fi
```

### Status and Monitoring
```bash
# Include hostname in status
mulle-env status --verbose

# Hostname in logs and debugging
echo "Running on $(mulle-env hostname --domain)"
```

## Technical Details

### Hostname Storage and Management

**Environment Storage:**
```
.mulle/etc/env/hostname/
├── current -> my-custom-host
├── default -> system-hostname
└── domain -> local
```

**Hostname Resolution Order:**
1. Environment-specific hostname (highest priority)
2. User-configured hostname
3. System default hostname
4. Network-provided hostname

### Hostname Formats and Validation

**Valid Hostname Patterns:**
- Alphanumeric characters and hyphens
- Maximum 63 characters
- Cannot start or end with hyphen
- Case-insensitive but typically lowercase

**Domain Name Integration:**
- Fully Qualified Domain Name (FQDN) support
- Domain suffix handling
- Network domain resolution
- DNS integration when available

### Hostname Persistence

**Session Persistence:**
- Hostname changes persist within environment session
- Survives environment reloads
- Reset on environment recreation

**Global Persistence:**
- Hostname settings saved to environment configuration
- Survives system reboots
- Shared across environment sessions

### Network Integration

**DNS Resolution:**
- Hostname to IP address resolution
- Reverse DNS lookups
- Domain name system integration
- Network configuration awareness

**Service Discovery:**
- Hostname-based service location
- Network service registration
- Multicast DNS support (when available)
- Local network hostname advertising

## Related Commands

- **[`uname`](uname.md)** - System information including hostname
- **[`status`](status.md)** - Environment status with hostname
- **[`init`](init.md)** - Initialize with hostname configuration
- **[`environment`](environment.md)** - Environment variables including hostname