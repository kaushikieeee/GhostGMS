#!/system/bin/sh
##########################################################################################
# GhostGMS Module - Magisk/KernelSU Compatible
# Authors: Veloxine, Migrator
# Version: 1.2
##########################################################################################

# Environment setup
MODDIR=${0%/*}
OUTFD=$2
LOG_DIR="$MODDIR/logs"
CONFIG_DIR="$MODDIR/config"

# POSIX-compliant UI functions
ui_print() {
  echo "ui_print $1" > /proc/self/fd/"$OUTFD"
  echo "ui_print " > /proc/self/fd/"$OUTFD"
}

clear_screen() {
  ui_print "$(printf '\033[2J\033[H')"
}

ghost_print() {
  ui_print "╭───────────────────────────────────╮"
  ui_print "│  $1"
  ui_print "╰───────────────────────────────────╯"
}

# Universal input handler
choose_option() {
  prompt="$1"
  TIMEOUT="${2:-30}"
  [ -n "$prompt" ] && ui_print "$prompt"
  ui_print " Waiting up to ${TIMEOUT}s…"
  
  while true; do
    event=$(timeout "$TIMEOUT" getevent -qlc 1 2>/dev/null)
    code=$?
    # POSIX-compliant status check
    if [ "$code" -eq 124 ] || [ "$code" -eq 143 ]; then
      return 2
    fi
    # Universal key pattern matching
    if echo "$event" | grep -qE "KEY_VOLUMEUP.*DOWN|KEY_VOLUME_UP.*DOWN"; then
      return 0
    elif echo "$event" | grep -qE "KEY_VOLUMEDOWN.*DOWN|KEY_VOLUME_DOWN.*DOWN"; then
      return 1
    fi
  done
}

# Configuration handler
ghost_get_choice() {
  prompt="$1"
  default="$2"
  timeout=30
  ui_print "\n$prompt"
  ui_print "Press Volume + for YES, Volume - for NO"
  ui_print "Default option in $timeout seconds: $default"

  choose_option "$prompt" "$timeout"
  sel=$?

  case $sel in
    0) ui_print "Selected: YES"; return 0 ;;
    1) ui_print "Selected: NO"; return 1 ;;
    2)
      ui_print "Timeout. Using default: $default"
      [ "$default" = "YES" ] && return 0 || return 1
      ;;
  esac
}

# Installation setup
initialize_dirs() {
  mkdir -p "$LOG_DIR" "$CONFIG_DIR" "$MODDIR/system/bin"
  set_perm_recursive "$MODDIR" 0 0 0755 0644
  set_perm_recursive "$MODDIR/system/bin" 0 0 0755 0755
  find "$MODDIR" -maxdepth 1 -type f -name "*.sh" -exec chmod 0755 {} \;
}

# Main configuration flow
apply_configuration() {
  clear_screen
  ghost_print "📱 GhostGMS Universal Edition 📱"
  ui_print "\n💤 Optimize Google Play Services\n🔋 Battery optimization\n🔒 Privacy enhancement\n"

  # POSIX-compliant configuration setup
  ghost_get_choice "👻 Enable GMS Ghosting? (Recommended)" "YES"
  ENABLE_GHOSTED=$?

  ghost_get_choice "📋 Disable GMS Logging? (Recommended)" "YES"
  ENABLE_LOG_DISABLE=$?

  ghost_get_choice "🔧 Set optimized system properties? (Recommended)" "YES"
  ENABLE_SYS_PROPS=$?

  ghost_get_choice "⚙️ Disable intrusive GMS services? (Recommended)" "YES"
  ENABLE_SERVICES_DISABLE=$?

  configure_service_categories
  save_configuration
}

# Service configuration
configure_service_categories() {
  [ "$ENABLE_SERVICES_DISABLE" -eq 1 ] || return 0

  # POSIX-compliant service configuration
  for entry in \
    "DISABLE_ADS:🛑 Disable Ads services?:YES" \
    "DISABLE_TRACKING:🛑 Disable Tracking services?:YES" \
    "DISABLE_ANALYTICS:📊 Disable Analytics services?:YES" \
    "DISABLE_REPORTING:📊 Disable Reporting services?:YES" \
    "DISABLE_BACKGROUND:🔄 Disable Background services?:YES" \
    "DISABLE_UPDATE:🔄 Disable Update services?:YES" \
    "DISABLE_LOCATION:📍 Disable Location services?:NO" \
    "DISABLE_GEOFENCE:📍 Disable Geofence services?:NO" \
    "DISABLE_NEARBY:📡 Disable Nearby services?:NO" \
    "DISABLE_CAST:📡 Disable Cast services?:NO" \
    "DISABLE_DISCOVERY:📡 Disable Discovery services?:NO" \
    "DISABLE_SYNC:☁️ Disable Sync services?:NO" \
    "DISABLE_CLOUD:☁️ Disable Cloud services?:NO" \
    "DISABLE_AUTH:☁️ Disable Auth services?:NO" \
    "DISABLE_WALLET:💰 Disable Wallet services?:NO" \
    "DISABLE_PAYMENT:💰 Disable Payment services?:NO" \
    "DISABLE_WEAR:⌚️ Disable Wear services?:NO" \
    "DISABLE_FITNESS:⌚️ Disable Fitness services?:NO"
  do
    IFS=':' read -r var prompt default <<EOF
$entry
EOF
    ghost_get_choice "$prompt" "$default"
    eval "$var=$?"
  done
}

# Configuration saver
save_configuration() {
  {
    echo "# User Preferences"
    echo "ENABLE_GHOSTED=$ENABLE_GHOSTED"
    echo "ENABLE_LOG_DISABLE=$ENABLE_LOG_DISABLE"
    echo "ENABLE_SYS_PROPS=$ENABLE_SYS_PROPS"
    echo "ENABLE_SERVICES_DISABLE=$ENABLE_SERVICES_DISABLE"
    # Add other variables as needed
  } > "$CONFIG_DIR/ghost_config"
}

# Execution flow
initialize_dirs
apply_configuration

# Completion
ghost_print "✅ Installation Complete"
ui_print "\n🔄 Reboot to apply changes\n"
ui_print "Thank you for choosing GhostGMS!"
