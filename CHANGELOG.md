# Changelog

## v3.0 (Latest)
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