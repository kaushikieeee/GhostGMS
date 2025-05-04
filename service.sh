#!/system/bin/sh
# GhostGMS Boot Service
MODDIR=${0%/*}

# Wait for system to fully boot
sleep 60

# Load user preferences
if [ -f "$MODDIR/config/user_prefs" ]; then
  . "$MODDIR/config/user_prefs"
else
  echo "Error: User preferences not found" > "$MODDIR/logs/boot_error.log"
  exit 1
fi

# Run initial GMS optimization service
$MODDIR/veloxine.sh boot

# Log successful boot
echo "GhostGMS service started on $(date)" >> "$MODDIR/logs/boot.log"
exit 0