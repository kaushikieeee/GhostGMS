# Direct extraction without verify.sh
ui_print "-----------------------------------------"
ui_print "- Installing GhostGMS"
ui_print "-----------------------------------------"

# Check if module.prop exists and extract it if needed
if [ ! -f "$TMPDIR/module.prop" ]; then
  ui_print "- Extracting module.prop..."
  unzip -o "$ZIPFILE" 'module.prop' -d "$TMPDIR" >&2
  if [ ! -f "$TMPDIR/module.prop" ]; then
    ui_print "-----------------------------------------"
    ui_print "! Module files are corrupt, please re-download"
    abort    "-----------------------------------------"
  fi
fi

# Extract gmslist.txt to MODPATH
unzip -o "$ZIPFILE" 'gmslist.txt' -d "$MODPATH" >&2
if [ -f "$MODPATH/gmslist.txt" ]; then
  ui_print "- Successfully extracted gmslist.txt"
else
  ui_print "! WARNING: gmslist.txt not found in zip!"
  ui_print "! Re-attempting extraction..."
  unzip -o "$ZIPFILE" 'gmslist.txt' -d "$MODPATH" >&2
  if [ ! -f "$MODPATH/gmslist.txt" ]; then
    ui_print "! Failed to extract gmslist.txt. GMS services won't be toggled."
  else
    ui_print "- Successfully extracted gmslist.txt"
  fi
fi

# Variables
MODNAME=`grep_prop name $TMPDIR/module.prop`
MODVER=`grep_prop version $TMPDIR/module.prop`
DV=`grep_prop author $TMPDIR/module.prop`
Device=`getprop ro.product.device`
Model=`getprop ro.product.model`
Brand=`getprop ro.product.brand` 
Architecture=`getprop ro.product.cpu.abi`
SDK=`getprop ro.system.build.version.sdk`
Android=`getprop ro.system.build.version.release`
Type=`getprop ro.system.build.type`
Built=`getprop ro.system.build.date`
Time=$(date "+%d, %b - %H:%M %Z")

# Define functions with new names
ghost_print_message() {
  local message="$1"
  local delay="${2:-0.3}"
  local type="$3"
  local padding_length=5
  local line_length=$((${#message} + 2 * padding_length))
  if [ "$type" == "boxed" ]; then
    ui_print ""
    printf '%*s\n' "$line_length" | tr ' ' '-'
    printf "%-${padding_length}s%s%${padding_length}s\n" "" "$message" ""
    printf '%*s\n' "$line_length" | tr ' ' '-'
    ui_print ""
  else
    ui_print "$message"
  fi
  sleep "$delay"
}

# Add ghost_display_message function to replace Dikhao
ghost_display_message() {
  local message="$1"
  local delay="${2:-0.3}"
  local type="$3"
  ui_print "$message"
  sleep "$delay"
}

# Create a temporary file for events
EVENTS="$TMPDIR/events"
rm -f $EVENTS 2>/dev/null
touch $EVENTS

# Function to test if volume keys can be detected
keytest() {
  ui_print "- Testing volume key detection -"
  ui_print "   Press any Volume key..."
  timeout 5 sh -c '/system/bin/getevent -lc 1 2>&1 | grep VOLUME | grep "DOWN" > $1' -- "$EVENTS" || return 1
  if [ -s "$EVENTS" ]; then
    ui_print "   Volume key detected!"
    return 0
  else
    return 1
  fi
}

# Modern volume key detection function
choose_modern() {
  # Clear previous events
  rm -f $EVENTS 2>/dev/null
  touch $EVENTS

  ui_print " "
  ui_print "   Press Volume Up for YES"
  ui_print "   Press Volume Down for NO"
  ui_print "   (You have 15 seconds to make a choice)"
  ui_print " "

  # Wait for volume key press with timeout
  timeout 15 sh -c 'while true; do
    /system/bin/getevent -lc 1 2>&1 | grep VOLUME | grep "DOWN" > $1
    if [ -s "$1" ]; then
      break
    fi
    sleep 0.2
  done' -- "$EVENTS" || { ui_print "   Timeout reached, defaulting to YES"; return 0; }

  # Check which key was pressed
  if grep -q "VOLUMEUP" $EVENTS || grep -q "Volume Up" $EVENTS || grep -q "KEY_VOLUMEUP" $EVENTS; then
    ui_print "   → YES selected"
    return 0
  else
    ui_print "   → NO selected"
    return 1
  fi
}

# Legacy volume key detection function
choose_legacy() {
  ui_print " "
  ui_print "   Press Volume Up for YES"
  ui_print "   Press Volume Down for NO"
  ui_print "   (Using property method for older devices)"
  ui_print " "
  
  # Use getprop to get volume key input (recovery mode)
  local start_time=$(date +%s)
  local timeout=15
  
  while true; do
    local current_time=$(date +%s)
    if [ $((current_time - start_time)) -gt $timeout ]; then
      ui_print "   Timeout reached, defaulting to YES"
      return 0
    fi
    
    local choice=$(getprop "recovery.make_choice")
    if [ "$choice" = "0" ]; then
      ui_print "   → NO selected"
      return 1
    elif [ "$choice" = "1" ]; then
      ui_print "   → YES selected"
      return 0
    fi
    
    sleep 0.5
  done
}

# Determine which volume key function to use
if keytest; then
  ui_print "   Using modern volume key detection"
  ghost_get_choice() {
    choose_modern
  }
else
  ui_print "   Using legacy volume key detection (for older devices)"
  ghost_get_choice() {
    choose_legacy
  }
fi

# Set default values for optimizations
ENABLE_KERNEL_TWEAKS=true
ENABLE_LOG_DISABLE=true
ENABLE_PROP_CHANGES=true
ENABLE_SYS_PROPS=true

# Installation Begins
ghost_print_message "Fetching module info..." 0.5 "boxed"
ghost_print_message "- Author: $DV"
ghost_print_message "- Module: $MODNAME"
ghost_print_message "- Version: $MODVER"
echo -e "- Provider: \c"
if [ "$BOOTMODE" ] && [ "$KSU" ]; then
  ui_print "KernelSU"
  sed -i '/^description=/c\description=[🦄 KernelSU Mode] Nukes cache, Disables 200+ GMS services, Disables 95% logs, Applies Kernel Tweaks for Battery and much more. Run Action button to Toggle GMS Services and Cleanup.' "$MODPATH/module.prop"
  ui_print "- KernelSU: $KSU_KERNEL_VER_CODE (kernel) + $KSU_VER_CODE (ksud)"
  if [ "$(which magisk)" ]; then
    ui_print "-----------------------------------------------------------"
    ui_print "! Multiple root implementation is NOT supported!"
    abort    "-----------------------------------------------------------"
  fi
elif [ "$BOOTMODE" ] && [ "$MAGISK_VER_CODE" ]; then
  ui_print "Magisk"
  sed -i '/^description=/c\description=[🪷 Magisk Mode] Nukes cache, Disables 200+ GMS services, Disables 95% logs, Applies Kernel Tweaks for Battery and much more. Run Action button to Toggle GMS Services and Cleanup.' "$MODPATH/module.prop"
else
  ui_print "--------------------------------------------------------"
  ui_print "Installation from recovery is not supported"
  ui_print "Please install from KernelSU or Magisk app"
  abort "----------------------------------------------------------"
fi

ghost_print_message "Fetching your device info..." 0.5 "boxed"
ghost_print_message "- Brand: $Brand"
ghost_print_message "- Device: $Device"
ghost_print_message "- Model: $Model"
ghost_print_message "- RAM: $(free | grep Mem | awk '{print $2}')"
ghost_print_message "Fetching your ROM information..." 0.3 "boxed"
ghost_print_message "- Android: $Android"
ghost_print_message "- Kernel: $(uname -r)"
ghost_print_message "- CPU: $Architecture"
ghost_print_message "- SDK: $SDK"
ghost_print_message "- Build Date: $Built"
ghost_print_message "- Build Type: $Type"

ui_print "---------------------------------------------"
ui_print "- Running $MODNAME"
ui_print "- Flashing started at $Time"
ui_print "---------------------------------------------"
ui_print " ⚡"
ui_print " 🔋 "
sleep 1

# Interactive menu for optimization choices
ghost_print_message "CUSTOMIZATION OPTIONS" 0.3 "boxed"

ui_print "• Enable kernel-level tweaks for battery?"
ui_print "  This optimizes kernel settings for better battery life"
if ghost_get_choice; then
  ENABLE_KERNEL_TWEAKS=true
else
  ENABLE_KERNEL_TWEAKS=false
fi

ui_print "• Disable system logs and debug messages?"
ui_print "  This reduces battery drain from logging processes"
if ghost_get_choice; then
  ENABLE_LOG_DISABLE=true
else
  ENABLE_LOG_DISABLE=false
fi

ui_print "• Apply system property changes?"
ui_print "  This disables various system features for better performance"
if ghost_get_choice; then
  ENABLE_PROP_CHANGES=true
else
  ENABLE_PROP_CHANGES=false
fi

ui_print "• Apply all system.prop optimizations?"
ui_print "  This applies additional system-wide optimizations"
if ghost_get_choice; then
  ENABLE_SYS_PROPS=true
else
  ENABLE_SYS_PROPS=false
  # If system.prop is disabled, create an empty one
  echo "# Optimizations disabled by user" > "$MODPATH/system.prop"
fi

# Print Preview GMS results (will be applied after reboot)
ghost_print_message "KILLING GMS SERVICES, PLEASE WAIT" 0.3 "boxed"
ghost_print_message "✦ Disabled advertising and tracking in Google Play services."
ghost_print_message "✦ Restricted Google's data collection on your device."
ghost_print_message "✦ Disabled the battery-draining HardwareArProviderService."
ghost_print_message "✦ Disabled bug reporting in Google Play services."
ghost_print_message "✦ Disabled Google Cast services."
ghost_print_message "✦ Disabled debugging services in Google Play Services."
ghost_print_message "✦ Disabled component discovery services in Google Play and Firebase."
ghost_print_message "✦ Disabled location and time zone services."
ghost_print_message "✦ Disabled key authentication services in Google Play."
ghost_print_message "✦ Disabled various background update services."
ghost_print_message "✦ Disabled services for smartwatches and wearables."
ghost_print_message "✦ Disabled Trusted Agents / Find My Device services."
ghost_print_message "✦ Disabled enpromo-related services."
ghost_print_message "✦ Disabled emergency features and child safety services."
ghost_print_message "✦ Disabled Google Fit health tracking services."
ghost_print_message "✦ Disabled Google Nearby services."
ghost_print_message "✦ Disabled logging and data collection services."
ghost_print_message "✦ Disabled security and app verification services."
ghost_print_message "✦ Disabled Google Pay and Wallet services."
ghost_print_message "✦ Disabled location services."
ghost_print_message "✦ Disabled Google Play Games-related services."
ghost_print_message "✦ Disabled Google Instant Apps services."

# Remove modules that conflicts with power saver (if available)
rm -rf /data/adb/modules/AdvanceCleaner
rm -rf /data/adb/modules/Energy_Saver
sleep 1

# Print Preview System Prop Results
if [ "$ENABLE_LOG_DISABLE" = true ]; then
  ghost_display_message "DISABLING LOGS & COMPONENTS" 0.2 "sar"
  ghost_display_message "✦ Disabled Real-Time Transport Protocol (RTP) logging"
  ghost_display_message "✦ Disabled JNI (Java Native Interface) checks, reducing logging related to native code interaction."
  ghost_display_message "✦ Stopped logging slow database queries."
  ghost_display_message "✦ Disabled debugging logs related to Qualcomm's Sensor Network Services (SNS)."
  ghost_display_message "✦ Disabled profiling logs for the EGL graphics API."
  ghost_display_message "✦ Disabled logging related to gamed and Wayland."
  ghost_display_message "✦ Disabled logging related to the Hardware Composer (HWC) and SurfaceFlinger components."
  ghost_display_message "✦ Disabled logging related to SurfaceFlinger's backpressure mechanism."
  ghost_display_message "✦ Disabled logging related to surface re-computations."
  ghost_display_message "✦ Disabled logging of Application Not Responding (ANR) events."
  ghost_display_message "✦ Disabled GPU-based pixel buffers, impacting rendering."
  ghost_display_message "✦ Disabled real-time logcat output and streaming."
  ghost_display_message "✦ Disabled TCP metrics logging."
  ghost_display_message "✦ Disabled logging related to the Stagefright media framework."
  ghost_display_message "✦ Disabled various profiling tools."
  ghost_display_message "✦ Disabled StrictMode, which checks for potential performance and security issues."
  ghost_display_message "✦ Changed behavior related to EGL context destruction."
  ghost_display_message "✦ Disabled support for Kernel Samepage Merging (KSM), a memory optimization technique."
  ghost_display_message "✦ Disabled \"checkin\" logging that sends system information to Google."
  ghost_display_message "✦ Disabled debugging capabilities for the device."
  ghost_display_message "✦ Setting the log buffer size to zero, effectively disable the log system."
  ghost_display_message "✦ Disabled the default compression cache."
  ghost_display_message "✦ Disabled JNI checks and QEMU-related logging."
  ghost_display_message "✦ Disabled battery-related logging."
  ghost_display_message "✦ Disabled multiple simultaneous call ringtones."
  ghost_display_message "✦ Disabled the RW logger, used for debugging network interactions."
  ghost_display_message "✦ Disabled IMS (IP Multimedia Subsystem) debug logs."
  ghost_display_message "✦ Disabled debugging related to Wi-Fi Direct (WFD)."
  ghost_display_message "✦ Disabled AAC support for Bluetooth A2DP."
  ghost_display_message "✦ Disabled QMI (Qualcomm MSM Interface) logging for ADB."
  ghost_display_message "✦ Disabled debug logging for the sensors HAL (Hardware Abstraction Layer)."
  ghost_display_message "✦ Disabled logging and crash reports related to Broadcom components."
  ghost_display_message "✦ Disabled an override for USB tethering."
  ghost_display_message "✦ Disabled an OEM socket for the radio."
  ghost_display_message "✦ Disabled virtual WFD capabilities."
  ghost_display_message "✦ Disabled various IMS logging and functionality."
  ghost_display_message "✦ Enabled offline logging for the kernel and logcat."
  ghost_display_message "✦ Disabled OEM-specific dumps"
  ghost_display_message "✦ Enabled the system's sleep mode."
  ghost_display_message "✦ Force disabled error reports and ulog."
  ghost_display_message "✦ Disabled debugging related to display management."
  ghost_display_message "✦ Enabled profiling for game tools."
  ghost_display_message "✦ Disabled GPU performance mode."
  ghost_display_message "✦ Disabled concurrent A2DP connections for FM radio."
  ghost_display_message "✦ Disabled B-frame encoding for the video decoder."
  ghost_display_message "✦ Disabled video decoder debugging."
  ghost_display_message "✦ Disabled Ultra Buffer With Cache (UBWC) for video."
  ghost_display_message "✦ Setting the systems composition type to GPU-based."
  ghost_display_message "✦ Disabled various SurfaceFlinger display options."
  ghost_display_message "✦ Disabled specific tags for the \"atrace\" profiling tool."
  ghost_display_message "✦ Disabled a mechanism for killing tasks that are allocating memory excessively."
  ghost_display_message "✦ Disabled logging for specific services."
  ghost_display_message "✦ Disabled redirecting standard input/output to the log system."
  ghost_display_message "✦ Disabled additional profiling features."
  ghost_display_message "✦ Disabled StrictMode, which checks for potential performance and security issues."
  ghost_display_message "✦ Disabled bytecode verification for the Dalvik VM, impacting security."
  ghost_display_message "✦ Disabled debug logging for memory allocation."
  ghost_display_message "✦ Disabled persistent caching for the A/V system."
  ghost_display_message "✦ Disabled RAM dumps for the SSR (System Server Recovery) service."
  ghost_display_message "✦ Disabled various log outputs related to the systems core functionality, including media playback, rendering, and audio output."
  ghost_display_message "✦ Disabled debug-specific logging and testing"
  ghost_display_message "✦ Disabled Memory Dump"
  ghost_display_message "✦ Disabled CRC"
  ghost_display_message "✦ Disabled IOSTATS"
  ghost_display_message "✦ Disabled Tombstoned"
  ghost_display_message "✦ Disabled Low Memory Killer"
  ghost_display_message "✦ Disabled Dalvik"
  ghost_display_message "✦ Disabled Blur"
  ghost_display_message "✦ Disabled Timer Migration"
else
  ghost_display_message "LOG DISABLING SKIPPED (USER CHOICE)" 0.5 "sar"
fi

# Create post-fs-data.sh based on user choice
if [ "$ENABLE_PROP_CHANGES" = false ]; then
  # Create an empty post-fs-data.sh if user disabled prop changes
  echo "#!/system/bin/sh" > "$MODPATH/post-fs-data.sh"
  echo "# Property changes disabled by user" >> "$MODPATH/post-fs-data.sh"
  chmod 755 "$MODPATH/post-fs-data.sh"
fi

# Apply kernel-level tweaks if selected
if [ "$ENABLE_KERNEL_TWEAKS" = true ]; then
  # Stop/Delete Logs & Cache
  ghost_print_message "DISABLING KERNEL LOGS" 1 "boxed"
  sysctl -w kernel.panic=0
  sysctl -w vm.panic_on_oom=0
  sysctl -w kernel.panic_on_oops=0
  sysctl -w vm.oom_dump_tasks=0
  sysctl -w vm.oom_kill_allocating_task=0
  echo "0 0 0 0" > /proc/sys/kernel/printk
  echo "off" > /proc/sys/kernel/printk_devkmsg
  echo "0" > /proc/sys/debug/exception-trace
else
  ghost_print_message "KERNEL TWEAKS SKIPPED (USER CHOICE)" 0.5 "boxed"
fi

ghost_print_message "OPTIMIZING STORAGE PERFORMANCE" 0.5 "boxed"
fstrim -v /cache
fstrim -v /system
fstrim -v /vendor
fstrim -v /data
fstrim -v /persist

if [ "$ENABLE_KERNEL_TWEAKS" = true ]; then
  ghost_print_message "APPLYING KERNEL LEVEL TWEAKS FOR BATTERY BACKUP" 1 "boxed"
else
  ghost_print_message "KERNEL LEVEL TWEAKS SKIPPED (USER CHOICE)" 0.5 "boxed"
fi

# Store user preferences
mkdir -p "$MODPATH/config"
echo "ENABLE_KERNEL_TWEAKS=$ENABLE_KERNEL_TWEAKS" > "$MODPATH/config/user_prefs"
echo "ENABLE_LOG_DISABLE=$ENABLE_LOG_DISABLE" >> "$MODPATH/config/user_prefs"
echo "ENABLE_PROP_CHANGES=$ENABLE_PROP_CHANGES" >> "$MODPATH/config/user_prefs"
echo "ENABLE_SYS_PROPS=$ENABLE_SYS_PROPS" >> "$MODPATH/config/user_prefs"

# Action Button
setprop veloxine-install rukho
cat > "$MODPATH/action.sh" << 'EOF'
#!/bin/sh
MODDIR="${0%/*}"
chmod +x "$MODDIR/veloxine.sh"
. "$MODDIR/veloxine.sh"
EOF

# Log script
touch "/data/local/tmp/DisabledAllGoogleServices"
cat > "$MODPATH/veloxine.sh" << 'EOF'
#!/system/bin/sh
# Log file path
log_file="/sdcard/veloxineology.log"

# Function to write to the log file
ghost_log() {
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "$timestamp: $1" >> "$log_file" 2>&1
}

# Create log file if it doesn't exist.
if [ ! -f $log_file ]; then
  touch $log_file
fi

# Wait for some time before toggling services and cleaning again
if [ "$(getprop veloxine-action)" == "bro, wait." ]; then
echo "----------------------------------------------------------"
echo "WAIT FOR IT TO INITIALIZE, DO NOT SPAM THE BUTTON."
echo "----------------------------------------------------------"
am start -a android.intent.action.MAIN -e powersaver "PLEASE WAIT, DO NOT INTERRUPT." -n powersaver.pro/.MainActivity
sleep 3
exit
fi

# Nuke Logs & Cache
ghost_log " ⚡ Switching GMS mode × Starting CACHE and LOG deletion "
echo "----------------------------------------------------------"
echo "STARTING TO CLEAN & TOGGLE GMS"
echo "----------------------------------------------------------"
echo " "
sleep 0.3

echo "✦ Deleting Package Cache"
rm -rf /data/package_cache || ghost_log "Error deleting /data/package_cache: $?"
sleep 0.3

echo "✦ Deleting Dalvik Cache"
rm -rf /data/dalvik-cache || ghost_log "Error deleting /data/dalvik-cache: $?"
sleep 0.3

echo "✦ Deleting Cached Data"
rm -rf /data/cache || ghost_log "Error deleting /data/cache: $?"
sleep 0.3

echo "✦ Deleting WLAN Logs"
rm -rf /data/vendor/wlan_logs || ghost_log "Error deleting /data/vendor/wlan_logs: $?"
sleep 0.3

echo "✦ Deleting System Logs"
rm -rf /dev/log/* || ghost_log "Error deleting /dev/log/*: $?"
sleep 0.3

echo "✦ Deleting System Package Cache"
rm -rf /data/system/package_cache || ghost_log "Error deleting /data/system/package_cache: $?"
sleep 0.3

echo "✦ Deleting Thumbnail Cache"
rm -rf /data/media/0/DCIM/.thumbnails || ghost_log "Error deleting /data/media/0/DCIM/.thumbnails: $?"
rm -rf /data/media/0/Pictures/.thumbnails || ghost_log "Error deleting /data/media/0/Pictures/.thumbnails: $?"
rm -rf /data/media/0/Music/.thumbnails || ghost_log "Error deleting /data/media/0/Music/.thumbnails: $?"
rm -rf /data/media/0/Movies/.thumbnails || ghost_log "Error deleting /data/media/0/Movies/.thumbnails: $?"
sleep 0.3

echo "✦ Deleting Thermal Logs"
rm -rf /data/vendor/thermal/thermal.dump || ghost_log "Error deleting /data/vendor/thermal/thermal.dump: $?"
rm -rf /data/vendor/thermal/last_thermal.dump || ghost_log "Error deleting /data/vendor/thermal/last_thermal.dump: $?"
rm -rf /data/vendor/thermal/thermal_history.dump || ghost_log "Error deleting /data/vendor/thermal/thermal_history.dump: $?"
rm -rf /data/vendor/thermal/thermal_history_last.dump || ghost_log "Error deleting /data/vendor/thermal/thermal_history_last.dump: $?"
sleep 0.3

echo "✦ Deleting ANR Logs"
rm -rf /data/anr/* || ghost_log "Error deleting /data/anr/*: $?"
sleep 0.3

echo "✦ Deleting Dev Logs"
rm -rf /dev/log/* || ghost_log "Error deleting /dev/log/*: $?"
sleep 0.3

# Toggle Services
ghost_status="/data/local/tmp/DisabledAllGoogleServices"
if [ -f "$ghost_status" ]; then
am start -a android.intent.action.MAIN -e powersaver "GMS SHIT HAS BEEN FREEZED 🥶" -n powersaver.pro/.MainActivity
 TOGGLE_CMD="pm disable"
 echo "--------------------------------------------------"
 echo "✦ Disabled All Unnecessary Google Services"
 sleep 0.5
 echo "|| This may break some features depends on Google. ||"
 echo "[Run action button again to Disable Safe Services]"
 sleep 1.5
 rm "$ghost_status"
 echo "--------------------------------------------------"
 sleep 0.3
else
am start -a android.intent.action.MAIN -e powersaver "GMS SHIT HAS BEEN ENABLED 🥵" -n powersaver.pro/.MainActivity
 TOGGLE_CMD="pm enable"
 echo "--------------------------------------------------"
 echo "✦ Enabled Safe Google Services"
 sleep 0.3
 echo "|| This will not break any features depends on Google. ||"
 echo "[Run action button again to Disable All Google Services]"
 sleep 1.5
 echo "--------------------------------------------------"
 touch "$ghost_status"
 sleep 0.3
fi
(
until [ "$(getprop veloxine-action)" == "finished" -o "$(getprop veloxine-install)" == "finished" ]; do
  sleep 1
done

# Read and toggle services from the gmslist.txt file
MODDIR="${0%/*}"
GMSLIST="$MODDIR/gmslist.txt"
if [ -f "$GMSLIST" ]; then
  ghost_log "Reading services from $GMSLIST"
  echo "Reading services list from gmslist.txt"
  while IFS= read -r line || [ -n "$line" ]; do
    # Skip empty lines and comments
    if [ -z "$line" ] || [[ "$line" == \#* ]]; then
      continue
    fi
    # Apply the enable/disable command to the package
    $TOGGLE_CMD "$line"
    # Add small delay to prevent overwhelming the system
    sleep 0.01
  done < "$GMSLIST"
  ghost_log "Successfully processed services from gmslist.txt"
else
  ghost_log "Error: gmslist.txt not found at: $GMSLIST"
  echo "Error: gmslist.txt not found at: $GMSLIST. Services not toggled."
fi

sleep 30
setprop veloxine-action hold
) &

if [ ! "$(getprop veloxine-install)" == "hold" ]; then
  echo "✦ Optimizing storage performance"
  fstrim -v /cache || ghost_log "Error running fstrim on /cache: $?"
  fstrim -v /system || ghost_log "Error running fstrim on /system: $?"
  fstrim -v /vendor || ghost_log "Error running fstrim on /vendor: $?"
  fstrim -v /data || ghost_log "Error running fstrim on /data: $?"
  fstrim -v /persist || ghost_log "Error running fstrim on /persist: $?"
  
  sleep 0.3
  echo "✦ Deleting Logcat Buffer"
  echo "⌛ Please wait, this may take a while..."
  logcat -c > /dev/null 2>&1 || ghost_log "Error clearing Logcat buffer: $?"
  echo " "
  dmesg -c > /dev/null 2>&1 || ghost_log "Error clearing Dmesg logs: $?"

sleep 1
echo " "
echo "-----------------------------------------------------"
echo "✦✦ ACTION COMPLETED SUCCESSFULLY ✦✦"
echo "-----------------------------------------------------"
echo " "
echo " "
sleep 3
ghost_log "👾 GMS MODE CHANGE SUCCESSFUL"
setprop veloxine-action complete
exit 0
fi
EOF

# Make executable and Execute veloxine script
chmod +x "$MODPATH/action.sh"
chmod +x "$MODPATH/veloxine.sh"
. "$MODPATH/veloxine.sh"

ui_print "- !! Note: Magisk may crash after a few seconds"
ui_print "  but the installation will complete successfully."
sleep 3
ui_print "- Finalizing installation and redirecting"
ui_print "  to the release source in"
sleep 0.3
ui_print "- 3s "
sleep 1
ui_print "- 2s "
sleep 1
ui_print "- 1s "
sleep 1

# Redirect to Veloxineology Chat Support and Finish Installation
am start -a android.intent.action.VIEW -d https://t.me/veloxineologysupport >/dev/null 2>&1
nohup sh -c "(
  sleep 6
  setprop veloxine-install complete
)" &
