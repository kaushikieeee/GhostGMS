#!/system/bin/sh

MODDIR="${0%/*}"
ENABLE_LOG_DISABLE=0
ENABLE_SYS_PROPS=0
ENABLE_BLUR_DISABLE=0

# Ensure config directory exists and load preferences with fallback
mkdir -p "$MODDIR/config" 2>/dev/null

if [ -f "$MODDIR/config/user_prefs" ]; then
  . "$MODDIR/config/user_prefs" 2>/dev/null || true
else
  # Create default config if missing (KernelSU Next/APatch fix)
  {
    echo "ENABLE_GHOSTED=1"
    echo "ENABLE_LOG_DISABLE=1"
    echo "ENABLE_SYS_PROPS=1"
    echo "ENABLE_BLUR_DISABLE=0"
    echo "ENABLE_SERVICES_DISABLE=1"
    echo "ENABLE_RECEIVER_DISABLE=0"
    echo "ENABLE_PROVIDER_DISABLE=0"
    echo "ENABLE_ACTIVITY_DISABLE=0"
  } > "$MODDIR/config/user_prefs" 2>/dev/null
  . "$MODDIR/config/user_prefs" 2>/dev/null || true
fi

# Tombstoned (only when logging disable is enabled)
if [ "${ENABLE_LOG_DISABLE:-0}" = "1" ]; then
  resetprop -n tombstoned.max_tombstone_count 0
fi

# Low Memory Killer + Dalvik runtime props
if [ "${ENABLE_SYS_PROPS:-0}" = "1" ]; then
  # Low Memory Killer
  resetprop -n ro.lmk.debug false
  resetprop -n ro.lmk.log_stats false

  # Dalvik
  resetprop -n dalvik.vm.check-dex-sum false
  resetprop -n dalvik.vm.checkjni false
  resetprop -n dalvik.vm.dex2oat-minidebuginfo false
  resetprop -n dalvik.vm.minidebuginfo false
  resetprop -n dalvik.vm.verify-bytecode false
fi

# Disable Blur (if enabled by user)
if [ "${ENABLE_BLUR_DISABLE:-0}" = "1" ]; then
  resetprop -n disableBlurs true
  resetprop -n enable_blurs_on_windows 0
  resetprop -n ro.launcher.blur.appLaunch 0
  resetprop -n ro.sf.blurs_are_expensive 0
  resetprop -n ro.surface_flinger.supports_background_blur 0
fi
