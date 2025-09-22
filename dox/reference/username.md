# mulle-env username - Display or Set Username

## Quick Start
Display or modify the username within the mulle-env environment.

## All Available Options

### Basic Usage
```bash
mulle-env username [options] [new-username]
```

**Arguments:**
- `new-username`: Optional new username to set

### Visible Options
- `--help`: Show usage information
- `--verbose`: Show detailed username information
- `--short`: Show only username

### Hidden Options
- `--set <username>`: Set username to specified value
- `--reset`: Reset to system default username
- `--full`: Show full name information
- Various username-specific options

## Command Behavior

### Core Functionality
- **Display**: Show current username
- **Set**: Change username for environment
- **Reset**: Return to system default
- **Full**: Show username with additional info

### Conditional Behaviors

**Username Management:**
- Environment-specific username override
- System username fallback
- User information integration
- Username validation and formatting

**Scope Control:**
- Session-specific username changes
- Global environment username settings
- Temporary vs. persistent username modifications

## Practical Examples

### Basic Username Operations
```bash
# Show current username
mulle-env username

# Show detailed username info
mulle-env username --verbose

# Set new username
mulle-env username developer

# Reset to system default
mulle-env username --reset
```

### User Information
```bash
# Show username with full info
mulle-env username --full

# Show short username only
mulle-env username --short

# Set username with validation
mulle-env username "john.doe"
```

### Environment-Specific Configuration
```bash
# Set development username
mulle-env username dev-user

# Set production username
mulle-env username prod-user

# Check username in scripts
CURRENT_USER=$(mulle-env username --short)
```

### Workflow Integration
```bash
# Configure username for project
PROJECT_NAME="myproject"
mulle-env username "${USER}-${PROJECT_NAME}"

# Username-based configuration
case "$(mulle-env username --short)" in
    "dev-"*)
        mulle-env style set developer/relax
        ;;
    "prod-"*)
        mulle-env style set production
        ;;
    "test-"*)
        mulle-env style set testing
        ;;
esac
```

## Troubleshooting

### Username Not Set
```bash
# Username not showing expected value
mulle-env username
# Shows system default instead of custom

# Solution: Set username explicitly
mulle-env username my-custom-user
```

### Permission Issues
```bash
# Cannot set username
mulle-env username newuser
# Error: Permission denied

# Solution: Check environment permissions
ls -la .mulle/etc/env/
sudo chown -R $USER .mulle/etc/env/
```

### Invalid Username
```bash
# Invalid username format
mulle-env username "invalid username"
# Error: Invalid username format

# Solution: Use valid username format
mulle-env username valid-username
```

### User Information Issues
```bash
# Full info not available
mulle-env username --full
# Shows incomplete user information

# Solution: Check system user database
getent passwd $USER
```

## Integration with Other Commands

### Environment Setup
```bash
# Set username during initialization
mulle-env init
mulle-env username "${USER}-dev"

# Username-based style selection
USER_PREFIX=$(mulle-env username --short | cut -d'-' -f1)
case "$USER_PREFIX" in
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
# Username-specific tool configuration
USERNAME=$(mulle-env username --short)
if [[ "$USERNAME" == *"admin"* ]]; then
    mulle-env tool add admin-tools
fi

# User-based tool setup
if mulle-env username --full | grep -q "Developer"; then
    mulle-env tool add development-tools
fi
```

### Status and Monitoring
```bash
# Include username in status
mulle-env status --verbose

# Username in logs and debugging
echo "Running as $(mulle-env username --full)"
```

## Technical Details

### Username Storage and Management

**Environment Storage:**
```
.mulle/etc/env/username/
├── current -> my-custom-user
├── default -> system-username
└── info -> full-user-info
```

**Username Resolution Order:**
1. Environment-specific username (highest priority)
2. User-configured username
3. System default username
4. Network-provided username

### Username Formats and Validation

**Valid Username Patterns:**
- Alphanumeric characters, dots, hyphens, underscores
- Maximum 32 characters
- Cannot start with hyphen or dot
- Case-sensitive but typically lowercase

**User Information Integration:**
- Full name and contact information
- Group membership and permissions
- Home directory and shell information
- System user database integration

### Username Persistence

**Session Persistence:**
- Username changes persist within environment session
- Survives environment reloads
- Reset on environment recreation

**Global Persistence:**
- Username settings saved to environment configuration
- Survives system reboots
- Shared across environment sessions

### User Database Integration

**System User Database:**
- Integration with /etc/passwd
- User ID and group ID information
- Home directory and shell settings
- Password and authentication data

**Extended User Information:**
- GECOS field parsing for full name
- Office and phone information
- Additional user metadata
- LDAP/Active Directory integration (when available)

## Related Commands

- **[`hostname`](hostname.md)** - Host information including username
- **[`status`](status.md)** - Environment status with username
- **[`init`](init.md)** - Initialize with username configuration
- **[`environment`](environment.md)** - Environment variables including user info