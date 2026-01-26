#!/system/bin/sh
# GhostGMS Boot Service
MODDIR=${0%/*}

# Wait for system to fully boot
sleep 60

# Ensure config directory exists (KernelSU Next/APatch fix)
mkdir -p "$MODDIR/config" 2>/dev/null

# Load user preferences with fallback defaults
if [ -f "$MODDIR/config/user_prefs" ]; then
  . "$MODDIR/config/user_prefs"
else
  # Config file missing - create with safe defaults
  echo "Warning: User preferences not found, creating defaults" > "$MODDIR/logs/boot_error.log"
  echo "This can happen on first boot with KernelSU Next/APatch" >> "$MODDIR/logs/boot_error.log"
  
  # Create default config
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
  
  # Load the defaults we just created
  . "$MODDIR/config/user_prefs" 2>/dev/null || {
    echo "Fatal: Could not create or load config" >> "$MODDIR/logs/boot_error.log"
    exit 1
  }
fi

# Create default gms_categories if missing
if [ ! -f "$MODDIR/config/gms_categories" ]; then
  {
    echo "DISABLE_ADS=1"
    echo "DISABLE_TRACKING=1"
    echo "DISABLE_ANALYTICS=1"
    echo "DISABLE_REPORTING=1"
    echo "DISABLE_BACKGROUND=1"
    echo "DISABLE_UPDATE=1"
    echo "DISABLE_LOCATION=0"
    echo "DISABLE_GEOFENCE=0"
    echo "DISABLE_NEARBY=0"
    echo "DISABLE_CAST=0"
    echo "DISABLE_DISCOVERY=0"
    echo "DISABLE_SYNC=0"
    echo "DISABLE_CLOUD=0"
    echo "DISABLE_AUTH=0"
    echo "DISABLE_WALLET=0"
    echo "DISABLE_PAYMENT=0"
    echo "DISABLE_WEAR=0"
    echo "DISABLE_FITNESS=0"
  } > "$MODDIR/config/gms_categories" 2>/dev/null
fi

# Run initial GMS optimization service
$MODDIR/veloxine.sh boot

# Log successful boot
echo "GhostGMS service started on $(date)" >> "$MODDIR/logs/boot.log"
exit 0