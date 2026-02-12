#!/system/bin/sh
# GhostGMS Boot Service
MODDIR=${0%/*}

# Wait for system to fully boot
sleep 60

# Persistent fallback directory
PERSISTENT_CONFIG="/data/local/tmp/ghostgms_config"
mkdir -p "$PERSISTENT_CONFIG" 2>/dev/null

# Ensure config and logs directories exist (KernelSU Next/APatch fix)
mkdir -p "$MODDIR/config" 2>/dev/null
mkdir -p "$MODDIR/logs" 2>/dev/null

# Determine which log file to use (module if writable, otherwise persistent)
if [ -d "$MODDIR/logs" ] && [ -w "$MODDIR/logs" ]; then
  BOOT_LOG="$MODDIR/logs/boot.log"
  ERROR_LOG="$MODDIR/logs/boot_error.log"
else
  # Fallback to persistent location if module logs not writable
  mkdir -p "$PERSISTENT_CONFIG/logs" 2>/dev/null
  BOOT_LOG="$PERSISTENT_CONFIG/logs/boot.log"
  ERROR_LOG="$PERSISTENT_CONFIG/logs/boot_error.log"
fi

# Load user preferences with fallback to persistent location
if [ -f "$MODDIR/config/user_prefs" ]; then
  . "$MODDIR/config/user_prefs"
elif [ -f "$PERSISTENT_CONFIG/user_prefs" ]; then
  # Found in persistent fallback - copy back to module directory
  echo "Info: Config found in persistent fallback, copying to module directory" >> "$BOOT_LOG"
  cp "$PERSISTENT_CONFIG/user_prefs" "$MODDIR/config/user_prefs" 2>/dev/null
  chmod 644 "$MODDIR/config/user_prefs" 2>/dev/null
  . "$MODDIR/config/user_prefs"
else
  # Config file missing - create with safe defaults
  echo "Warning: User preferences not found, creating defaults" > "$ERROR_LOG"
  echo "This can happen on first boot with KernelSU Next/APatch" >> "$ERROR_LOG"
  
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
  } > "$MODDIR/config/user_prefs" 2>>"$ERROR_LOG"
  
  # Set permissions
  chmod 644 "$MODDIR/config/user_prefs" 2>/dev/null
  
  # Also save to persistent fallback
  cp "$MODDIR/config/user_prefs" "$PERSISTENT_CONFIG/user_prefs" 2>/dev/null
  chmod 644 "$PERSISTENT_CONFIG/user_prefs" 2>/dev/null
  
  # Load the defaults we just created
  if [ -f "$MODDIR/config/user_prefs" ]; then
    . "$MODDIR/config/user_prefs"
  else
    echo "Fatal: Could not create or load config at $MODDIR/config/user_prefs" >> "$ERROR_LOG"
    exit 1
  fi
fi

# Create default gms_categories if missing
if [ ! -f "$MODDIR/config/gms_categories" ]; then
  # Check persistent fallback first
  if [ -f "$PERSISTENT_CONFIG/gms_categories" ]; then
    cp "$PERSISTENT_CONFIG/gms_categories" "$MODDIR/config/gms_categories" 2>/dev/null
    chmod 644 "$MODDIR/config/gms_categories" 2>/dev/null
  else
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
    } > "$MODDIR/config/gms_categories" 2>>"$ERROR_LOG"
    
    # Set permissions
    chmod 644 "$MODDIR/config/gms_categories" 2>/dev/null
    
    # Also save to persistent fallback
    cp "$MODDIR/config/gms_categories" "$PERSISTENT_CONFIG/gms_categories" 2>/dev/null
    chmod 644 "$PERSISTENT_CONFIG/gms_categories" 2>/dev/null
  fi
fi

# Run initial GMS optimization service
$MODDIR/veloxine.sh boot

# Log successful boot
echo "GhostGMS service started on $(date)" >> "$BOOT_LOG"
exit 0