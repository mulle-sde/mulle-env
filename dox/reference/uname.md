# mulle-env uname - Display System Information

## Quick Start
Display system and platform information for the mulle-env environment.

## All Available Options

### Basic Usage
```bash
mulle-env uname [options]
```

**Arguments:** None

### Visible Options
- `--help`: Show usage information
- `--verbose`: Show detailed system information
- `--short`: Show only essential information

### Hidden Options
- `--all`: Show all available system information
- `--platform`: Show platform-specific details
- `--hardware`: Show hardware information
- Various uname-specific display options

## Command Behavior

### Core Functionality
- **System Name**: Display operating system name
- **Platform Info**: Show platform and architecture
- **Host Details**: Display hostname and domain
- **Environment Context**: Show mulle-env specific information

### Conditional Behaviors

**Output Format:**
- Normal mode: Standard uname-style output
- Verbose mode: Detailed system and environment information
- Short mode: Minimal essential information
- All mode: Comprehensive system report

**Environment Integration:**
- Shows mulle-env environment context
- Displays platform compatibility information
- Includes environment-specific system details

## Practical Examples

### Basic System Information
```bash
# Show basic system information
mulle-env uname

# Detailed system information
mulle-env uname --verbose

# Short system info
mulle-env uname --short
```

### Platform-Specific Information
```bash
# Show platform details
mulle-env uname --platform

# Hardware information
mulle-env uname --hardware

# All system information
mulle-env uname --all
```

### Environment Context
```bash
# System info with environment context
mulle-env uname --verbose

# Check platform compatibility
mulle-env uname --platform
```

### Script Integration
```bash
# Get OS name for scripts
OS_NAME=$(mulle-env uname | cut -d' ' -f1)

# Check architecture
ARCH=$(mulle-env uname --short | cut -d' ' -f2)

# Platform-specific logic
case "$(mulle-env uname --platform)" in
    "linux")
        echo "Linux-specific setup"
        ;;
    "darwin")
        echo "macOS-specific setup"
        ;;
    "mingw")
        echo "Windows-specific setup"
        ;;
esac
```

## Troubleshooting

### Incomplete Information
```bash
# uname shows limited information
mulle-env uname
# Missing expected details

# Solution: Use verbose mode
mulle-env uname --verbose
```

### Environment Context Missing
```bash
# Not showing mulle-env context
mulle-env uname
# No environment information

# Solution: Ensure in mulle-env environment
mulle-env init
mulle-env uname --verbose
```

### Platform Detection Issues
```bash
# Incorrect platform detection
mulle-env uname --platform
# Shows wrong platform

# Solution: Check system configuration
uname -a
mulle-env uname --all
```

## Integration with Other Commands

### Environment Setup
```bash
# Check system before initialization
mulle-env uname --verbose
mulle-env init

# Platform-specific initialization
case "$(mulle-env uname --platform)" in
    "linux")
        mulle-env init --style developer/linux
        ;;
    "darwin")
        mulle-env init --style developer/macos
        ;;
esac
```

### Tool Configuration
```bash
# Configure tools based on platform
PLATFORM=$(mulle-env uname --platform)
case "$PLATFORM" in
    "linux")
        mulle-env tool add gcc
        ;;
    "darwin")
        mulle-env tool add clang
        ;;
    "mingw")
        mulle-env tool add mingw-gcc
        ;;
esac
```

### Style Selection
```bash
# Choose style based on system
SYS_INFO=$(mulle-env uname --all)
if echo "$SYS_INFO" | grep -q "minimal"; then
    mulle-env style set minimal
else
    mulle-env style set developer/relax
fi
```

## Technical Details

### System Information Sources

**Operating System:**
- OS name and version from system files
- Distribution information (Linux)
- Kernel version and build details

**Platform Information:**
- Architecture (x86_64, arm64, etc.)
- Platform type (linux, darwin, mingw)
- System type and variant

**Host Information:**
- Hostname and domain name
- Network configuration
- System identifiers

**Environment Context:**
- mulle-env environment status
- Platform compatibility flags
- Environment-specific system details

### Output Formats

**Standard Output:**
```
Linux x86_64 myhost.local
```

**Verbose Output:**
```
System: Linux
Architecture: x86_64
Platform: linux
Hostname: myhost.local
Domain: local
Kernel: 5.15.0-89-generic
Distribution: Ubuntu 22.04.3 LTS
Environment: mulle-env active
Platform Support: full
```

**Short Output:**
```
Linux x86_64
```

**All Output:**
```
Operating System: Linux
Kernel Version: 5.15.0-89-generic
Architecture: x86_64
Platform: linux
Hostname: myhost.local
Domain: local
Distribution: Ubuntu 22.04.3 LTS
Environment: mulle-env v1.2.3
Platform Compatibility: full
Hardware: Intel(R) Core(TM) i7-9750H CPU @ 2.60GHz
Memory: 16GB
Disk: 512GB SSD
```

### Information Gathering Process
1. **System Detection**: Query system files and commands
2. **Platform Analysis**: Determine platform type and capabilities
3. **Environment Check**: Verify mulle-env environment status
4. **Hardware Probing**: Gather hardware information when available
5. **Compatibility Assessment**: Evaluate platform compatibility

### Platform Support Matrix

**Fully Supported Platforms:**
- Linux (x86_64, arm64)
- macOS (x86_64, arm64)
- Windows (MinGW, x86_64)

**Limited Support Platforms:**
- BSD variants (FreeBSD, OpenBSD)
- Solaris/SunOS
- Other Unix-like systems

**Unsupported Platforms:**
- Legacy architectures (i386, ppc)
- Embedded systems without full POSIX compliance

## Related Commands

- **[`init`](init.md)** - Initialize based on system info
- **[`style`](style.md)** - Choose style based on platform
- **[`tool`](tool.md)** - Configure tools for platform
- **[`status`](status.md)** - Status including system info