#!/system/bin/sh
##########################################################################################
# GhostGMS Module for Magisk
# Authors: Veloxine, Migrator
# Version: 1.3
##########################################################################################

# Set up environment
MODDIR=${0%/*}
OUTFD=$2

# Detect SU implementation
if command -v magisk >/dev/null; then
  SU_TYPE="Magisk"
  MAGISK_VER=$(magisk -v 2>/dev/null)
  MAGISK_VER_CODE=$(magisk -V 2>/dev/null)
  ui_print "• Magisk detected: $MAGISK_VER ($MAGISK_VER_CODE)"
elif command -v ksud >/dev/null; then
  SU_TYPE="KernelSU"
  KISU_VER=$(ksud -V 2>/dev/null)
  ui_print "• KernelSU detected: $KISU_VER"
else
  SU_TYPE="Unknown SU"
  ui_print "! Warning: Could not determine SU implementation"
fi

# Create logs directory
mkdir -p $MODDIR/logs

# Check for debug mode
if [ -f "$MODDIR/debug" ]; then
  DEBUG_MODE=true
  exec 2>$MODDIR/logs/debug_log.txt
  set -x
  ui_print "• Debug mode enabled"
else
  DEBUG_MODE=false
fi

# Create a directory structure
mkdir -p $MODDIR/config
mkdir -p $MODDIR/system/bin

# Enable execution
set_perm_recursive $MODDIR 0 0 0755 0644
set_perm_recursive $MODDIR/system/bin 0 0 0755 0755
set_perm $MODDIR/customize.sh 0 0 0755
set_perm $MODDIR/service.sh 0 0 0755
set_perm $MODDIR/veloxine.sh 0 0 0755
set_perm $MODDIR/post-fs-data.sh 0 0 0755

# UI functions
ui_print() {
  echo "$1"
}

newline() {
  local count=${1:-1}
  for i in $(seq 1 $count); do
    ui_print " "
  done
}

clear_screen() {
  newline 30
}

ghost_print() {
  ui_print "╭───────────────────────────────────╮"
  ui_print "│  $1"
  ui_print "╰───────────────────────────────────╯"
}

section_header() {
  newline 1
  ui_print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  ui_print "  $1"
  ui_print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

info_print() {
  ui_print "   $1 $2"
}

# Progress indicator
show_progress() {
  local percent=$1
  local message=$2
  
  local bar_length=25
  local filled_length=$((percent * bar_length / 100))
  
  local bar=""
  for ((i=0; i<filled_length; i++)); do
    bar="${bar}━"
  done
  
  for ((i=filled_length; i<bar_length; i++)); do
    bar="${bar}┈"
  done
  
  ui_print " "
  ui_print "  [${bar}] ${percent}%"
  [ -n "$message" ] && ui_print "  $message"
}

#########################
# Volume Key Functions
#########################

# Modern method using getevent
choose_option() {
  local prompt="$1"
  local TIMEOUT="${2:-30}"  # Allow custom timeout or default to 30s
  
  [ -n "$prompt" ] && ui_print "$prompt"
  ui_print " Waiting up to ${TIMEOUT}s…"
  
  while :; do
    event=$(timeout ${TIMEOUT} getevent -qlc 1 2>/dev/null)
    code=$?
    # Timeout returns 124 (toybox) or 143 (BusyBox)
    if [ $code -eq 124 ] || [ $code -eq 143 ]; then
      return 2
    fi
    # Handle different key event formats across devices
    if echo "$event" | grep -q -E "KEY_VOLUMEUP.*DOWN|KEY_VOLUME_UP.*DOWN"; then
      return 0
    elif echo "$event" | grep -q -E "KEY_VOLUMEDOWN.*DOWN|KEY_VOLUME_DOWN.*DOWN"; then
      return 1
    fi
  done
}

# Function for detecting volume key presses
ghost_get_choice() {
  local TEXT="$1"
  local DEFAULT="$2"
  local TIMEOUT="${3:-30}"
  
  ui_print " "
  ui_print "$TEXT"
  ui_print "🔼 VOL+ → YES $([ "$DEFAULT" = "YES" ] && echo "[default]")"
  ui_print "🔽 VOL- → NO $([ "$DEFAULT" = "NO" ] && echo "[default]")"
  
  choose_option "" "$TIMEOUT"
  case $? in
    0)  
      ui_print "✅ Selected: YES"
      return 0
      ;;
    1)  
      ui_print "❌ Selected: NO"
      return 1
      ;;
    *)
      ui_print "⏱️ Timeout: using default ($DEFAULT)"
      [ "$DEFAULT" == "YES" ] && return 0 || return 1
      ;;
  esac
}

#########################
# Main Installation
#########################

# Banner
clear_screen
ghost_print "📱 Welcome to GhostGMS 📱"
newline 1
ui_print "💤 Optimize Google Play Services"
ui_print "🔋 Better battery life"
ui_print "🔒 Enhanced privacy"
ui_print "⚡ Improved performance"
newline 1

# Get settings for main features
section_header "📋 Core Settings"

ghost_get_choice "👻 Enable GMS Ghosting? (Recommended)" "YES"
ENABLE_GHOSTED=$?
[ $ENABLE_GHOSTED -eq 0 ] && ENABLE_GHOSTED=1 || ENABLE_GHOSTED=0

ghost_get_choice "📋 Disable GMS Logging? (Recommended)" "YES"
ENABLE_LOG_DISABLE=$?
[ $ENABLE_LOG_DISABLE -eq 0 ] && ENABLE_LOG_DISABLE=1 || ENABLE_LOG_DISABLE=0

ghost_get_choice "🔧 Set GMS-optimized system properties? (Recommended)" "YES"
ENABLE_SYS_PROPS=$?
[ $ENABLE_SYS_PROPS -eq 0 ] && ENABLE_SYS_PROPS=1 || ENABLE_SYS_PROPS=0

ghost_get_choice "⚙️ Disable intrusive GMS services? (Recommended)" "YES"
ENABLE_SERVICES_DISABLE=$?
[ $ENABLE_SERVICES_DISABLE -eq 0 ] && ENABLE_SERVICES_DISABLE=1 || ENABLE_SERVICES_DISABLE=0

# Default values for GMS service categories
DISABLE_ADS=1
DISABLE_TRACKING=1
DISABLE_ANALYTICS=1
DISABLE_REPORTING=1
DISABLE_BACKGROUND=1
DISABLE_UPDATE=1
DISABLE_LOCATION=0
DISABLE_GEOFENCE=0
DISABLE_NEARBY=0
DISABLE_CAST=0
DISABLE_DISCOVERY=0
DISABLE_SYNC=0
DISABLE_CLOUD=0
DISABLE_AUTH=0
DISABLE_WALLET=0
DISABLE_PAYMENT=0
DISABLE_WEAR=0
DISABLE_FITNESS=0

# If service disabling is enabled, get categories
if [ "$ENABLE_SERVICES_DISABLE" = "1" ]; then
  section_header "📋 GMS Service Categories"
  ui_print "Choose which types of GMS services to disable:"
  newline 1
  
  # Privacy-related categories
  ui_print "━ 🛡️ Privacy Related ━━━━━━━━━━━━━━━━━━"
  
  ghost_get_choice "🛑 Disable Ads services?" "YES"
  result=$?
  [ $result -eq 0 ] && DISABLE_ADS=1 || DISABLE_ADS=0
  
  ghost_get_choice "🛑 Disable Tracking services?" "YES"
  result=$?
  [ $result -eq 0 ] && DISABLE_TRACKING=1 || DISABLE_TRACKING=0
  
  ghost_get_choice "📊 Disable Analytics services?" "YES"
  result=$?
  [ $result -eq 0 ] && DISABLE_ANALYTICS=1 || DISABLE_ANALYTICS=0
  
  ghost_get_choice "📊 Disable Reporting services?" "YES"
  result=$?
  [ $result -eq 0 ] && DISABLE_REPORTING=1 || DISABLE_REPORTING=0
  
  # System-related categories
  ui_print "━ 🔄 System Related ━━━━━━━━━━━━━━━━━━"
  
  ghost_get_choice "🔄 Disable Background services?" "YES"
  result=$?
  [ $result -eq 0 ] && DISABLE_BACKGROUND=1 || DISABLE_BACKGROUND=0
  
  ghost_get_choice "🔄 Disable Update services?" "YES"
  result=$?
  [ $result -eq 0 ] && DISABLE_UPDATE=1 || DISABLE_UPDATE=0
  
  # Location-related categories
  ui_print "━ 📍 Location Related ━━━━━━━━━━━━━━━━"
  
  ghost_get_choice "📍 Disable Location services?" "NO"
  result=$?
  [ $result -eq 0 ] && DISABLE_LOCATION=1 || DISABLE_LOCATION=0
  
  ghost_get_choice "📍 Disable Geofence services?" "NO"
  result=$?
  [ $result -eq 0 ] && DISABLE_GEOFENCE=1 || DISABLE_GEOFENCE=0
  
  # Connectivity-related categories
  ui_print "━ 📡 Connectivity Related ━━━━━━━━━━━━"
  
  ghost_get_choice "📡 Disable Nearby services?" "NO"
  result=$?
  [ $result -eq 0 ] && DISABLE_NEARBY=1 || DISABLE_NEARBY=0
  
  ghost_get_choice "📡 Disable Cast services?" "NO"
  result=$?
  [ $result -eq 0 ] && DISABLE_CAST=1 || DISABLE_CAST=0
  
  ghost_get_choice "📡 Disable Discovery services?" "NO"
  result=$?
  [ $result -eq 0 ] && DISABLE_DISCOVERY=1 || DISABLE_DISCOVERY=0
  
  # Cloud-related categories
  ui_print "━ ☁️ Cloud Related ━━━━━━━━━━━━━━━━━━━"
  
  ghost_get_choice "☁️ Disable Sync services?" "NO"
  result=$?
  [ $result -eq 0 ] && DISABLE_SYNC=1 || DISABLE_SYNC=0
  
  ghost_get_choice "☁️ Disable Cloud services?" "NO"
  result=$?
  [ $result -eq 0 ] && DISABLE_CLOUD=1 || DISABLE_CLOUD=0
  
  ghost_get_choice "☁️ Disable Auth services?" "NO"
  result=$?
  [ $result -eq 0 ] && DISABLE_AUTH=1 || DISABLE_AUTH=0
  
  # Payment-related categories
  ui_print "━ 💰 Payment Related ━━━━━━━━━━━━━━━━━"
  
  ghost_get_choice "💰 Disable Wallet services?" "NO"
  result=$?
  [ $result -eq 0 ] && DISABLE_WALLET=1 || DISABLE_WALLET=0
  
  ghost_get_choice "💰 Disable Payment services?" "NO"
  result=$?
  [ $result -eq 0 ] && DISABLE_PAYMENT=1 || DISABLE_PAYMENT=0
  
  # Wearable-related categories
  ui_print "━ ⌚️ Wearable Related ━━━━━━━━━━━━━━━━"
  
  ghost_get_choice "⌚️ Disable Wear services?" "NO"
  result=$?
  [ $result -eq 0 ] && DISABLE_WEAR=1 || DISABLE_WEAR=0
  
  ghost_get_choice "⌚️ Disable Fitness services?" "NO"
  result=$?
  [ $result -eq 0 ] && DISABLE_FITNESS=1 || DISABLE_FITNESS=0
fi

section_header "🔧 Additional Options"

ghost_get_choice "📻 Disable GMS Receivers?" "NO"
ENABLE_RECEIVER_DISABLE=$?
[ $ENABLE_RECEIVER_DISABLE -eq 0 ] && ENABLE_RECEIVER_DISABLE=1 || ENABLE_RECEIVER_DISABLE=0

ghost_get_choice "🏬 Disable GMS Providers?" "NO"
ENABLE_PROVIDER_DISABLE=$?
[ $ENABLE_PROVIDER_DISABLE -eq 0 ] && ENABLE_PROVIDER_DISABLE=1 || ENABLE_PROVIDER_DISABLE=0

ghost_get_choice "🔠 Disable GMS Activities?" "NO"
ENABLE_ACTIVITY_DISABLE=$?
[ $ENABLE_ACTIVITY_DISABLE -eq 0 ] && ENABLE_ACTIVITY_DISABLE=1 || ENABLE_ACTIVITY_DISABLE=0

# Save user preferences
mkdir -p $MODDIR/config
echo "ENABLE_GHOSTED=$ENABLE_GHOSTED" > $MODDIR/config/user_prefs
echo "ENABLE_LOG_DISABLE=$ENABLE_LOG_DISABLE" >> $MODDIR/config/user_prefs
echo "ENABLE_SYS_PROPS=$ENABLE_SYS_PROPS" >> $MODDIR/config/user_prefs
echo "ENABLE_SERVICES_DISABLE=$ENABLE_SERVICES_DISABLE" >> $MODDIR/config/user_prefs
echo "ENABLE_RECEIVER_DISABLE=$ENABLE_RECEIVER_DISABLE" >> $MODDIR/config/user_prefs
echo "ENABLE_PROVIDER_DISABLE=$ENABLE_PROVIDER_DISABLE" >> $MODDIR/config/user_prefs
echo "ENABLE_ACTIVITY_DISABLE=$ENABLE_ACTIVITY_DISABLE" >> $MODDIR/config/user_prefs

show_progress 50 "Saving configuration..."

# Save GMS categories
echo "DISABLE_ADS=$DISABLE_ADS" > $MODDIR/config/gms_categories
echo "DISABLE_TRACKING=$DISABLE_TRACKING" >> $MODDIR/config/gms_categories
echo "DISABLE_ANALYTICS=$DISABLE_ANALYTICS" >> $MODDIR/config/gms_categories
echo "DISABLE_REPORTING=$DISABLE_REPORTING" >> $MODDIR/config/gms_categories
echo "DISABLE_BACKGROUND=$DISABLE_BACKGROUND" >> $MODDIR/config/gms_categories
echo "DISABLE_UPDATE=$DISABLE_UPDATE" >> $MODDIR/config/gms_categories
echo "DISABLE_LOCATION=$DISABLE_LOCATION" >> $MODDIR/config/gms_categories
echo "DISABLE_GEOFENCE=$DISABLE_GEOFENCE" >> $MODDIR/config/gms_categories
echo "DISABLE_NEARBY=$DISABLE_NEARBY" >> $MODDIR/config/gms_categories
echo "DISABLE_CAST=$DISABLE_CAST" >> $MODDIR/config/gms_categories
echo "DISABLE_DISCOVERY=$DISABLE_DISCOVERY" >> $MODDIR/config/gms_categories
echo "DISABLE_SYNC=$DISABLE_SYNC" >> $MODDIR/config/gms_categories
echo "DISABLE_CLOUD=$DISABLE_CLOUD" >> $MODDIR/config/gms_categories
echo "DISABLE_AUTH=$DISABLE_AUTH" >> $MODDIR/config/gms_categories
echo "DISABLE_WALLET=$DISABLE_WALLET" >> $MODDIR/config/gms_categories
echo "DISABLE_PAYMENT=$DISABLE_PAYMENT" >> $MODDIR/config/gms_categories
echo "DISABLE_WEAR=$DISABLE_WEAR" >> $MODDIR/config/gms_categories
echo "DISABLE_FITNESS=$DISABLE_FITNESS" >> $MODDIR/config/gms_categories

show_progress 75 "Finalizing installation..."

# Ensure scripts are executable (again, just to be safe)
chmod 0755 $MODDIR/service.sh
chmod 0755 $MODDIR/post-fs-data.sh
chmod 0755 $MODDIR/veloxine.sh
chmod 0755 $MODDIR/system/bin/notify_traceur.sh

show_progress 100 "Installation complete!"

# Completion message
newline 2
ghost_print "✅ GhostGMS Installation Complete"
newline 1
ui_print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ui_print "🔄 Changes will take effect after reboot"
ui_print "📱 Enjoy better battery life and privacy"
ui_print "👻 Thank you for using GhostGMS!"
ui_print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
newline 2