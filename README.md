# 👻 GhostGMS

<div align="center">
  
*Optimize Google Mobile Services for better battery life, privacy, and performance*

[![Version](https://img.shields.io/badge/Version-3.1-brightgreen.svg)](https://github.com/kaushikieeee/GhostGMS/releases)
[![Magisk](https://img.shields.io/badge/Magisk-20%2B-00B0FF.svg)](https://github.com/topjohnwu/Magisk)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

</div>

---

## ✨ Overview

GhostGMS has now reached a **saturation point**: after months of refinements and optimizations, the module has been fully developed to maximize battery life, privacy, and performance for Google Mobile Services (GMS) **without breaking Android functionality**.  

While development continues, this release may represent the **final major feature expansion**. Future releases will focus mainly on stability, minor improvements, or compatibility updates rather than adding new optimization features.

---

##  What's New in v3.1

### 🔧 Critical Fix: Comprehensive Uninstall Script

Version 3.1 addresses a **major oversight** in previous versions where the uninstall script didn't fully reverse all module changes:

**What's Fixed:**
- ✅ **System Settings Restoration** - Now properly restores analytics, logging, bug reporting, and usage stats settings
- ✅ **Runtime Properties** - Removes all `resetprop` changes (tombstone, LMK, Dalvik, blur settings)
- ✅ **Complete Service Re-enabling** - Re-enables ALL disabled GMS services including location, auth, backup, and crash reporting
- ✅ **Uninstall Logging** - Added logging to `/data/local/tmp/ghostgms_uninstall.log` for debugging
- ✅ **Both Versions Updated** - Core 3.1 and Legacy 1.3.1 now include comprehensive uninstall

**Before v3.1:** Uninstalling only re-enabled GMS services but left system settings and properties modified  
**After v3.1:** Module is now **fully reversible** - uninstalling returns your device to its exact pre-installation state

> 💡 **Recommendation:** If you're on v3.0 or earlier, update to v3.1 for proper uninstall functionality.

---

## 🆕 Version 3.0 – Dual Modules

Starting with **v3.0**, the release includes **two separate modules** under the same release:

| Module | Description | Key Differences |
|--------|-------------|----------------|
| **GhostGMS 3.0 (Core)** | Optimized for maximum safety and compatibility | Focuses on GMS optimizations without kernel modifications |
| **GhostGMS 2.0 (Legacy)** | Includes previous kernel tweaks and deeper system-level tweaks | May provide additional performance gains but could affect device stability if misused |

Users can choose whichever module works best for their device and needs.

---

## ⚙️ Features

- 🔋 **Better Battery Life**: Reduce GMS wake locks and background activity  
- 🔒 **Enhanced Privacy**: Disable intrusive tracking and analytics services  
- ⚡ **Improved Performance**: Lower RAM usage and CPU utilization  
- 📱 **Maintained Functionality**: Essential Google services remain fully functional  

> ⚠️ GhostGMS has reached the **maximum safe optimization level**. Adding further tweaks risks breaking Android or critical Google services.

---

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

---

## ⚙️ Installation

1. Download the latest release from the [Releases page](https://github.com/kaushikieeee/GhostGMS/releases)  
2. Install via Magisk Manager  
3. Choose the preferred module (3.0 Core or 2.0 Legacy)  
4. Follow the on-screen prompts to select your optimizations  
5. Reboot your device  

---

## 🔋 Battery Impact

> ⚠️ **Important**: After installation, you may notice temporarily higher battery usage (Active/Idle drain) for the first 24–48 hours as Android adjusts to the new configuration. This is normal and will settle down after a couple of days, resulting in better battery life.  

---

## 🚫 What This Module Does NOT Do

- ❌ Doesn't modify Android kernel (3.0 Core)  
- ❌ Doesn't remove Google apps or break core functionality  
- ❌ Doesn't change system memory management  
- ❌ Doesn't affect OTA updates  

> The **Legacy 2.0 module** may include kernel tweaks, but users should proceed with caution.

---

## 💡 Tips for Best Results

- ✅ Enable all logging controls for maximum battery savings  
- ✅ Disable only service categories you don’t actively use  
- ✅ Run for at least 2–3 days to see the full benefits  
- ✅ Check logs in `/data/adb/modules/GhostGMS/logs/` for troubleshooting  
- ✅ Compare performance between 3.0 Core and 2.0 Legacy if desired  

---

## 📊 Compatibility

| Android Version | Status |
|-----------------|--------|
| Android 16      | ✅ Compatible |
| Android 15      | ✅ Compatible |
| Android 14      | ✅ Compatible |
| Android 13      | ✅ Compatible |
| Android 12/12L  | ✅ Compatible |
| Android 11      | ✅ Compatible |
| Android 10      | ✅ Compatible |
| Android 9       | ⚠️ Limited Testing |
| Android 8.x     | ⚠️ Limited Testing |

---

## 🔍 Troubleshooting

<details>
<summary><b>Some Google apps show notifications about Google Play services</b></summary>
<p>This is normal and safe to ignore. Essential functionality still works.</p>
</details>

<details>
<summary><b>Battery drain seems worse initially</b></summary>
<p>Wait 24–48 hours for Android to adjust. Initial reconfiguration may temporarily increase battery usage.</p>
</details>

<details>
<summary><b>GCM push notifications delayed</b></summary>
<p>Enable the "Sync" category during installation if you rely heavily on timely notifications.</p>
</details>

---

## 👨‍💻 Credits

- Original concept and development by **Kaushik S**  
- Additional improvements by **MiguVT**  

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📝 Note from the Developer

GhostGMS has reached the **final stage of safe optimization**. While there may be minor improvements in the future, **v3.1 is likely the last major feature release**.  

Two modules are now provided so users can choose between **maximum safety (3.1 Core)** and **legacy tweaks (1.3 Legacy)** based on their needs.
