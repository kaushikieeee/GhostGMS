# Changelog

## v3.1 (Latest) - 26 January 2026

### 🔧 Critical Fixes

#### ✅ Comprehensive Uninstall Script
- **Fixed:** Uninstall script now properly reverses **ALL** changes made by the module  
- **System Settings:** Correctly restores analytics, logging, bug reporting, and usage stats  
- **Runtime Properties:** Properly removes all resetprop changes (tombstone, LMK, Dalvik, blur settings)  
- **GMS Services:** Re-enables all disabled services including location, auth, backup, and crash reporting  
- **Logging:** Added uninstall logging to `/data/local/tmp/ghostgms_uninstall.log` for debugging  
- **Impact:** Module now provides complete reversibility - uninstalling returns device to exact pre-installation state  
- **Previous Behavior:** Only re-enabled services but left settings/properties modified

#### ✅ KernelSU Next / APatch Compatibility (Issue #8)
- **Fixed:** Module now works properly with KernelSU Next and APatch root managers  
- **Core Module:** Added proper permissions (`chmod 755`/`644`) for config files  
- **Core Module:** Added validation and warning if config creation fails during installation  
- **Core Module:** Auto-creates config files with safe defaults if missing on boot  
- **Legacy Module:** FIXED critical bug - config files were never created during installation!  
- **Legacy Module:** Now creates `user_prefs` and `gms_categories` with default values  
- **Fallback Logic:** Both versions now auto-generate config files on boot if missing  
- **Error Logging:** Detailed logging to `boot_error.log` for troubleshooting  
- **Impact:** No more "User preferences not found" error on first boot  
- **Tested On:** Magisk, KernelSU, KernelSU Next v1.0.7+, APatch

### ✨ New Features

#### 🎨 Interactive Blur Disable Option
- **Added:** Volume button prompt during installation to optionally disable UI blur effects  
- **Default:** Blur stays enabled (safe for most ROMs)  
- **User Choice:** Users can now choose whether to disable blur based on their ROM  
- **Compatibility Fix:** Prevents transparent popups and unreadable notifications on OxygenOS/AOSP ROMs  
- **Configuration:** Preference saved and applied conditionally on boot  
- **Impact:** Better ROM compatibility without forcing blur changes on all users

### 🔄 Updates

- **Repository:** Updated GitHub username from `veloxineology` to `kaushikieeee`  
- **Links:** Updated all repository URLs, documentation, and workflow files  
- **Both Versions:** Core (3.1) and Legacy (1.3.1) both updated with all fixes  
- **Compatibility:** Confirmed working on Android 8-15, Magisk 20+, KernelSU, KernelSU Next, APatch

### 📝 Summary

This release focuses on **stability and compatibility** across all root managers. Major issues with KernelSU Next/APatch are now resolved, and the module provides full reversibility on uninstall. The interactive blur option improves ROM compatibility without breaking existing functionality.

**Upgrade Recommended:** If you're on v3.0 or earlier, especially with KernelSU Next/APatch, update to v3.1 immediately.

---

## v3.0
- **Reached Saturation Point:** GhostGMS is now fully optimized; adding more tweaks risks breaking Android or critical Google functionality.  
- **Dual Module Release:**  
  - **3.0 Core:** Safe optimizations with no kernel modifications; focuses on maximum battery, privacy, and performance while maintaining full stability.  
  - **2.0 Legacy:** Includes previous kernel tweaks and deeper system-level optimizations; may offer extra performance gains but could affect stability on some devices.  
- **Compatibility Updates:** Confirmed support for Android 10–14, with limited testing for Android 8–9.  
- **Final Major Feature Release:** Future updates will focus on bug fixes and minor refinements only.  

---

## v2.1
- Major update focused on compatibility, maintainability, and enhanced user experience.  
- **KernelSU Support:** Full compatibility with KernelSU alongside Magisk.  
- **Native Key Input Handling:** Legacy keycheck replaced with architecture-agnostic, reliable volume key detection using getevent.  
- **Redesigned Interactive Installer:** Sleek new wizard with clear section headers, emojis, timeout defaults, and a final confirmation screen.  
- **Cleaner Configuration & Storage:** User preferences and service categories saved in a structured, persistent format.  
- **Code Overhaul & UX Improvements:** Modular structure, clear defaults, smarter error handling, and polished user prompts throughout.  
- **Defaults Adjusted for Stability:** Only privacy-invading services (Ads, Tracking, Analytics, etc.) are disabled by default—everything else is opt-in to reduce breakage.  
- Huge thanks to @MiguVT for helping fix the input issue via pull request!  
- If you faced the volume key issue earlier, this release should fix it.  
- Join the support group: t.me/veloxineologysupport  

---

## v2.0
- Added advanced GMS service categorization system with granular control  
- Improved volume key detection for more reliable installation choices  
- Enhanced system property optimizations with focus on Android 14 compatibility  
- Removed action button functionality for simpler and more stable operation  
- Consolidated service management into improved veloxine.sh script  
- Improved notification system with PowerSaver app support and fallback method  
- Fixed compatibility issues with newer devices  
- Added extensive logging options for troubleshooting  

---

## v1.3
- Added system.prop optimizations for performance and battery  
- Implemented customizable installation options  
- Added action button toggle for GMS services  
- Improved cache cleanup routines  
- Enhanced kernel-level optimizations  
- Added support for both Magisk and KernelSU  
- Implemented automatic update checking  

---

## v1.2
- Added more GMS services to disable list  
- Improved logging system  
- Fixed compatibility with Android 13+  
- Added thermal optimization  

---

## v1.1
- Initial public release  
- Basic GMS service disabling  
- Simple action button implementation