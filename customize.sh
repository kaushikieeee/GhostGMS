#!/system/bin/sh
##########################################################################################
# GhostGMS Module for Magisk and KernelSU
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

# Modern key detection method
choose_option() {
  local prompt="$1"
  ui_print "$prompt"
  ui_print " "
  ui_print "🔼 = Yes | 🔽 = No"
  ui_print " "
  ui_print " Waiting up to ${TIMEOUT}s…"
  while :; do
    event=$(timeout ${TIMEOUT} getevent -qlc 1 2>/dev/null)
    code=$?
    # Timeout returns 124 (toybox) or 143 (BusyBox)
    if [ $code -eq 124 ] || [ $code -eq 143 ]; then
      return 2
    fi
    echo "$event" | grep -q "KEY_VOLUMEUP.*DOWN"    && return 0
    echo "$event" | grep -q "KEY_VOLUMEDOWN.*DOWN"  && return 1
  done
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

ui_print "Press Volume Up for YES, Volume Down for NO."
ui_print " "

# Get settings for main features
TIMEOUT=30
choose_option "👻 Enable GMS Ghosting? (Recommended)"
ENABLE_GHOSTED=$?
[ $ENABLE_GHOSTED -eq 0 ] && ENABLE_GHOSTED=1 || ENABLE_GHOSTED=0

choose_option "📋 Disable GMS Logging? (Recommended)"
ENABLE_LOG_DISABLE=$?
[ $ENABLE_LOG_DISABLE -eq 0 ] && ENABLE_LOG_DISABLE=1 || ENABLE_LOG_DISABLE=0

choose_option "🔧 Set GMS-optimized system properties? (Recommended)"
ENABLE_SYS_PROPS=$?
[ $ENABLE_SYS_PROPS -eq 0 ] && ENABLE_SYS_PROPS=1 || ENABLE_SYS_PROPS=0

choose_option "⚙️ Disable intrusive GMS services? (Recommended)"
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
  
  choose_option "🛑 Disable Ads services?" 
  DISABLE_ADS=$?
  
  choose_option "🛑 Disable Tracking services?" 
  DISABLE_TRACKING=$?
  
  choose_option "📊 Disable Analytics services?" 
  DISABLE_ANALYTICS=$?
  
  choose_option "📊 Disable Reporting services?" 
  DISABLE_REPORTING=$?
  
  choose_option "🔄 Disable Background services?" 
  DISABLE_BACKGROUND=$?
  
  choose_option "🔄 Disable Update services?" 
  DISABLE_UPDATE=$?
  
  choose_option "📍 Disable Location services?" 
  DISABLE_LOCATION=$?
  
  choose_option "📍 Disable Geofence services?" 
  DISABLE_GEOFENCE=$?
  
  choose_option "📡 Disable Nearby services?" 
  DISABLE_NEARBY=$?
  
  choose_option "📡 Disable Cast services?" 
  DISABLE_CAST=$?
  
  choose_option "📡 Disable Discovery services?" 
  DISABLE_DISCOVERY=$?
  
  choose_option "☁️ Disable Sync services?" 
  DISABLE_SYNC=$?
  
  choose_option "☁️ Disable Cloud services?" 
  DISABLE_CLOUD=$?
  
  choose_option "☁️ Disable Auth services?" 
  DISABLE_AUTH=$?
  
  choose_option "💰 Disable Wallet services?" 
  DISABLE_WALLET=$?
  
  choose_option "💰 Disable Payment services?" 
  DISABLE_PAYMENT=$?
  
  choose_option "⌚️ Disable Wear services?" 
  DISABLE_WEAR=$?
  
  choose_option "⌚️ Disable Fitness services?" 
  DISABLE_FITNESS=$?
fi

choose_option "📻 Disable GMS Receivers?" 
ENABLE_RECEIVER_DISABLE=$?
[ $ENABLE_RECEIVER_DISABLE -eq 0 ] && ENABLE_RECEIVER_DISABLE=1 || ENABLE_RECEIVER_DISABLE=0

choose_option "🏬 Disable GMS Providers?" 
ENABLE_PROVIDER_DISABLE=$?
[ $ENABLE_PROVIDER_DISABLE -eq 0 ] && ENABLE_PROVIDER_DISABLE=1 || ENABLE_PROVIDER_DISABLE=0

choose_option "🔠 Disable GMS Activities?" 
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