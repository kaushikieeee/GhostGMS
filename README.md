# 👻 GhostGMS

<div align="center">

![GhostGMS Banner](https://raw.githubusercontent.com/veloxineology/GhostGMS/main/docs/banner.png)

*Optimize Google Mobile Services for better battery life, privacy, and performance*

[![Version](https://img.shields.io/badge/Version-2.1-brightgreen.svg)](https://github.com/veloxineology/GhostGMS/releases)
[![Magisk](https://img.shields.io/badge/Magisk-20%2B-00B0FF.svg)](https://github.com/topjohnwu/Magisk)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

</div>

## ✨ Features

- 🔋 **Better Battery Life**: Reduce GMS wake locks and background activity
- 🔒 **Enhanced Privacy**: Disable intrusive tracking and analytics services
- ⚡ **Improved Performance**: Lower RAM usage and CPU utilization
- 📱 **Maintained Functionality**: Essential Google services remain enabled

## 📋 Optimization Categories

<details>
<summary>🛑 <b>Ads & Tracking</b></summary>
<p>Disable advertising identifiers and tracking capabilities</p>
</details>

<details>
<summary>📊 <b>Analytics & Reporting</b></summary>
<p>Reduce data collection and analytics services</p>
</details>

<details>
<summary>🔄 <b>Background & Update Services</b></summary>
<p>Limit background operations and automatic updates</p>
</details>

<details>
<summary>📍 <b>Location & Geofence</b></summary>
<p>Control location tracking and geofencing services</p>
</details>

<details>
<summary>📡 <b>Nearby & Discovery</b></summary>
<p>Manage nearby device detection and casting</p>
</details>

<details>
<summary>☁️ <b>Sync & Cloud</b></summary>
<p>Adjust account synchronization and cloud storage</p>
</details>

<details>
<summary>💰 <b>Wallet & Payment</b></summary>
<p>Toggle payment and wallet-related services</p>
</details>

<details>
<summary>⌚ <b>Wear & Fitness</b></summary>
<p>Control wearable and fitness tracking features</p>
</details>

## ⚙️ Installation

1. Download the latest release from the [Releases page](https://github.com/veloxineology/GhostGMS/releases)
2. Install via Magisk Manager
3. Follow the on-screen prompts to select your preferred optimizations
4. Reboot your device

## 🔋 Battery Impact

> ⚠️ **Important**: After installation, you may notice temporarily higher battery usage (Active/Idle drain) for the first 24-48 hours as Android adjusts to the new configuration. This is normal and will settle down after a couple of days, resulting in much better battery life.

## 🚫 What This Module Does NOT Do

- ❌ Doesn't modify kernel parameters
- ❌ Doesn't remove Google apps or break core functionality
- ❌ Doesn't change system memory management
- ❌ Doesn't affect OTA updates

## 💡 Tips for Best Results

- ✅ Enable all logging controls for maximum battery savings
- ✅ Disable only the service categories you don't actively use
- ✅ Run for at least 2-3 days to see the full benefits
- ✅ Check logs in `/data/adb/modules/GhostGMS/logs/` for troubleshooting

## 📊 Compatibility

| Android Version | Status |
|-----------------|--------|
| Android 14      | ✅ Compatible |
| Android 13      | ✅ Compatible |
| Android 12/12L  | ✅ Compatible |
| Android 11      | ✅ Compatible |
| Android 10      | ✅ Compatible |
| Android 9       | ⚠️ Limited Testing |
| Android 8.x     | ⚠️ Limited Testing |

## 🔍 Troubleshooting

<details>
<summary><b>Some Google apps show notifications about Google Play services</b></summary>
<p>This is normal and safe to ignore. The essential functionality still works.</p>
</details>

<details>
<summary><b>Battery drain seems worse initially</b></summary>
<p>Wait 24-48 hours for Android to adjust. Initial reconfiguration may temporarily increase battery usage.</p>
</details>

<details>
<summary><b>GCM push notifications delayed</b></summary>
<p>Enable the "sync" category during installation if you rely heavily on timely notifications.</p>
</details>

## 👨‍💻 Credits

- Original concept and development by **Veloxine**
- Additional improvements by **MiguVT**

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
