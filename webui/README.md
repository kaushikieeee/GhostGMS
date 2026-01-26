# GhostGMS WebUI

A modern web-based control panel for managing GhostGMS configuration.

## Features

- 🎨 Modern, responsive UI with gradient design
- 💾 Real-time configuration management
- 📊 Visual status indicators
- 🔄 One-click reboot with config save
- 📱 Mobile-friendly interface
- ⚡ Fast and lightweight

## Requirements

- **Termux** (install from F-Droid)
- **Python** (install in Termux: `pkg install python`)
- **Root access** (Magisk/KernelSU/APatch)

## Installation

The WebUI files are included with GhostGMS v3.1+. No separate installation needed.

## Usage

### Start WebUI Server

```bash
# In Termux
su
cd /data/adb/modules/GhostGMS/webui
./webui.sh start
```

### Access WebUI

Open your browser and navigate to:
```
http://localhost:9999
```

### Control Commands

```bash
# Start server
./webui.sh start

# Stop server
./webui.sh stop

# Restart server
./webui.sh restart

# Check status
./webui.sh status
```

## Features Overview

### Core Features
- **👻 GMS Ghosting** - Optimize Google Play Services
- **📋 Disable GMS Logging** - Reduce log generation and improve battery
- **🔧 System Properties** - Apply GMS-optimized system properties
- **🎨 Disable UI Blur** - Can improve performance on some ROMs
- **⚙️ Disable Intrusive Services** - Disable tracking, ads, and analytics

### Advanced Options
- **📻 Disable Receivers** - May affect some GMS functionality
- **🏬 Disable Providers** - Advanced users only
- **🔠 Disable Activities** - Advanced users only

## Screenshots

![GhostGMS WebUI](screenshot.png)

## Controls

- **💾 Save Configuration** - Saves settings to config file
- **🔄 Save & Reboot** - Saves and immediately reboots device to apply changes

## Technical Details

- **Port**: 9999
- **Server**: Python HTTP Server
- **Config Path**: `/data/adb/modules/GhostGMS/config/user_prefs`
- **Log Path**: `/data/adb/modules/GhostGMS/logs/webui.log`
- **PID File**: `/data/adb/modules/GhostGMS/webui.pid`

## Troubleshooting

### Server won't start
- Ensure Python is installed: `python3 --version`
- Check logs: `cat /data/adb/modules/GhostGMS/logs/webui.log`
- Verify port 9999 is not in use: `netstat -an | grep 9999`

### Can't access WebUI
- Ensure server is running: `./webui.sh status`
- Try accessing via IP: `http://127.0.0.1:9999`
- Check firewall settings

### Changes not saving
- Verify permissions: Config files should be writable
- Check logs for errors
- Ensure sufficient storage space

## Security Notes

⚠️ **Important**: The WebUI server runs on localhost only and requires root access. However:

- Only run the server when needed
- Stop the server when not in use: `./webui.sh stop`
- Do not expose port 9999 to external networks
- The server has no authentication - localhost access only

## Auto-Start (Optional)

To start WebUI automatically on boot, add to `service.sh`:

```bash
# Start WebUI server
$MODDIR/webui/webui.sh start
```

## Uninstallation

The WebUI is part of GhostGMS. If you uninstall the module, WebUI is removed automatically.

To manually stop the server:
```bash
su
cd /data/adb/modules/GhostGMS/webui
./webui.sh stop
```

## Credits

- **Design**: Modern gradient UI with smooth animations
- **Backend**: Python HTTP server with JSON API
- **Authors**: Kaushik, MiguVT

## Support

For issues or questions:
- GitHub Issues: [kaushikieeee/GhostGMS](https://github.com/kaushikieeee/GhostGMS/issues)
- Telegram: Contact via GitHub

## Changelog

### v3.1 (26 January 2026)
- Initial WebUI release
- Real-time config management
- Modern responsive design
- One-click reboot functionality
- Status indicators
- Python-based HTTP server

## License

Part of GhostGMS - Licensed under GPL v3
