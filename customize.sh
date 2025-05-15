#!/system/bin/sh
##########################################################################################
# GhostGMS Module for Magisk
# Authors: Veloxine, Migrator
# Version: 1.3
##########################################################################################

# Set up environment
MODDIR=${0%/*}
OUTFD=$2

# Create a directory structure
mkdir -p $MODDIR/logs
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

clear_screen() {
  for i in $(seq 1 30); do
    ui_print " "
  done
}

ghost_print() {
  ui_print "╭───────────────────────────────────╮"
  ui_print "│  $1"
  ui_print "╰───────────────────────────────────╯"
}

info_print() {
  ui_print "   $1 $2"
}

#########################
# Volume Key Functions
#########################

# Modern keycheck method
check_keycheck() {
  # Get device architecture
  ARCH=$(getprop ro.product.cpu.abi)
  
  # Set $ARCH32 based on $ARCH
  if [ "$ARCH" == "arm64-v8a" ] || [ "$ARCH" == "armeabi-v7a" ]; then
    ARCH32="arm"
  elif [ "$ARCH" == "x86_64" ] || [ "$ARCH" == "x86" ]; then
    ARCH32="x86"
  else
    ARCH32="arm"
  fi
  
  # Check if keycheck binary exists for the architecture
  if [ -f "$MODDIR/tools/$ARCH32/keycheck" ]; then
    # Make keycheck executable
    chmod 0755 "$MODDIR/tools/$ARCH32/keycheck"
    return 0
  else
    return 1
  fi
}

# Function for detecting volume key presses
ghost_get_choice() {
  local TIMEOUT=30
  local TEXT="$1"
  local DEFAULT="$2"
  local COUNT=0
  
  ui_print " "
  ui_print "$TEXT"
  ui_print "Press Volume + for YES, Volume - for NO"
  ui_print "Default option in $TIMEOUT seconds: $DEFAULT"
  
  # Check if we have keycheck
  if check_keycheck; then
    # Keycheck method
    ui_print "Using volume keys for selection..."
    
    # Consume existing input and wait for a new key press
    timeout -t 0 $MODDIR/tools/$ARCH32/keycheck
    timeout -t $TIMEOUT $MODDIR/tools/$ARCH32/keycheck
    local SEL=$?

    if [ $SEL -eq 42 ]; then
      ui_print "Selected: YES"
      return 0
    elif [ $SEL -eq 41 ]; then
      ui_print "Selected: NO"
      return 1
    else
      ui_print "Timeout or no input detected. Using default: $DEFAULT"
      [ "$DEFAULT" == "YES" ] && return 0 || return 1
    fi
  else
    # Fallback to timeout with default
    ui_print "Volume keys not available. Using timeout method..."
    ui_print "Default option will be selected in $TIMEOUT seconds."
    sleep $TIMEOUT
    ui_print "Default selected: $DEFAULT"
    [ "$DEFAULT" == "YES" ] && return 0 || return 1
  fi
}

#########################
# Main Installation
#########################

# Banner
clear_screen
ghost_print "📱 Welcome to GhostGMS 📱"
ui_print " "
ui_print "💤 Optimize Google Play Services"
ui_print "🔋 Better battery"
ui_print "🔒 Privacy enhancement"
ui_print " "

# Get settings for main features
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
  ui_print " "
  ghost_print "📋 GMS Service Categories"
  ui_print " "
  ui_print "Choose which types of GMS services to disable:"
  
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
  
  ghost_get_choice "🔄 Disable Background services?" "YES"
  result=$?
  [ $result -eq 0 ] && DISABLE_BACKGROUND=1 || DISABLE_BACKGROUND=0
  
  ghost_get_choice "🔄 Disable Update services?" "YES"
  result=$?
  [ $result -eq 0 ] && DISABLE_UPDATE=1 || DISABLE_UPDATE=0
  
  ghost_get_choice "📍 Disable Location services?" "NO"
  result=$?
  [ $result -eq 0 ] && DISABLE_LOCATION=1 || DISABLE_LOCATION=0
  
  ghost_get_choice "📍 Disable Geofence services?" "NO"
  result=$?
  [ $result -eq 0 ] && DISABLE_GEOFENCE=1 || DISABLE_GEOFENCE=0
  
  ghost_get_choice "📡 Disable Nearby services?" "NO"
  result=$?
  [ $result -eq 0 ] && DISABLE_NEARBY=1 || DISABLE_NEARBY=0
  
  ghost_get_choice "📡 Disable Cast services?" "NO"
  result=$?
  [ $result -eq 0 ] && DISABLE_CAST=1 || DISABLE_CAST=0
  
  ghost_get_choice "📡 Disable Discovery services?" "NO"
  result=$?
  [ $result -eq 0 ] && DISABLE_DISCOVERY=1 || DISABLE_DISCOVERY=0
  
  ghost_get_choice "☁️ Disable Sync services?" "NO"
  result=$?
  [ $result -eq 0 ] && DISABLE_SYNC=1 || DISABLE_SYNC=0
  
  ghost_get_choice "☁️ Disable Cloud services?" "NO"
  result=$?
  [ $result -eq 0 ] && DISABLE_CLOUD=1 || DISABLE_CLOUD=0
  
  ghost_get_choice "☁️ Disable Auth services?" "NO"
  result=$?
  [ $result -eq 0 ] && DISABLE_AUTH=1 || DISABLE_AUTH=0
  
  ghost_get_choice "💰 Disable Wallet services?" "NO"
  result=$?
  [ $result -eq 0 ] && DISABLE_WALLET=1 || DISABLE_WALLET=0
  
  ghost_get_choice "💰 Disable Payment services?" "NO"
  result=$?
  [ $result -eq 0 ] && DISABLE_PAYMENT=1 || DISABLE_PAYMENT=0
  
  ghost_get_choice "⌚️ Disable Wear services?" "NO"
  result=$?
  [ $result -eq 0 ] && DISABLE_WEAR=1 || DISABLE_WEAR=0
  
  ghost_get_choice "⌚️ Disable Fitness services?" "NO"
  result=$?
  [ $result -eq 0 ] && DISABLE_FITNESS=1 || DISABLE_FITNESS=0
fi

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

# Completion message
ui_print " "
ghost_print "✅ GhostGMS Installation Complete"
ui_print " "
ui_print "🔄 Changes will take effect after reboot"
ui_print " "
ui_print "Thank you for using GhostGMS!"
ui_print " "