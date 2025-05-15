# Changelog

## v2.1 (Current)
- This is a major update focused on compatibility, maintainability, and an enhanced user experience.
- KernelSU Support
- Full compatibility with KernelSU alongside Magisk.
- Native Key Input Handling
- Legacy keycheck replaced with architecture-agnostic, reliable volume key detection using getevent.
- Redesigned Interactive Installer
- Sleek new wizard with clear section headers, emojis, timeout defaults, and a final confirmation screen.
- Cleaner Configuration & Storage
- User preferences and service categories saved in a structured, persistent format.
- Code Overhaul & UX Improvements
- Modular structure, clear defaults, smarter error handling, and polished user prompts throughout.
- Defaults Adjusted for Stability
- Only privacy-invading services (Ads, Tracking, Analytics, etc.) are disabled by default—everything else is opt-in to reduce breakage.
- Huge thanks to @MiguVT for helping fix the input issue via pull request!
- If you faced the volume key issue earlier, this release should fix it.
- Update now and let me know your thoughts!
And as always, join the support group: t.me/veloxineologysupport

## v2.0 
- Added advanced GMS service categorization system with granular control
- Improved volume key detection for more reliable installation choices
- Enhanced system property optimizations with focus on Android 14 compatibility
- Removed action button functionality for simpler and more stable operation
- Consolidated service management into improved veloxine.sh script
- Improved notification system with PowerSaver app support and fallback method
- Fixed compatibility issues with newer devices
- Added extensive logging options for troubleshooting

## v1.3
- Added system.prop optimizations for performance and battery
- Implemented customizable installation options
- Added action button toggle for GMS services
- Improved cache cleanup routines
- Enhanced kernel-level optimizations
- Added support for both Magisk and KernelSU
- Implemented automatic update checking

## v1.2
- Added more GMS services to disable list
- Improved logging system
- Fixed compatibility with Android 13+
- Added thermal optimization

## v1.1
- Initial public release
- Basic GMS service disabling
- Simple action button implementation 
