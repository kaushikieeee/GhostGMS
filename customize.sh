#!/system/bin/sh
##########################################################################################
# GhostGMS Module for Magisk and KernelSU
# Authors: Kaushik, MiguVT
# Version: 3.0
##########################################################################################

# Set up environment
MODDIR="${0%/*}"
OUTFD="$2"
TIMEOUT=30

# Create directory structure
mkdir -p "$MODDIR/logs" "$MODDIR/config" "$MODDIR/system/bin"

# Enable execution
set_perm_recursive "$MODDIR" 0 0 0755 0644
set_perm_recursive "$MODDIR/system/bin" 0 0 0755 0755
for script in customize.sh service.sh veloxine.sh post-fs-data.sh; do
  [ -f "$MODDIR/$script" ] && set_perm "$MODDIR/$script" 0 0 0755
done

# UI functions
ui_print() {
  echo "$1"
}

print_banner() {
  ui_print "╭───────────────────────────────────────╮"
  ui_print "│  $1"
  ui_print "╰───────────────────────────────────────╯"
}

print_section() {
  ui_print ""
  ui_print "────────────────────────────────────────"
  ui_print "$1"
  ui_print "────────────────────────────────────────"
  ui_print ""
}

choose_option() {
  local prompt="$1"
  local default="$2"
  ui_print ""
  print_banner "$prompt"
  ui_print "🔼 = Yes | 🔽 = No  (Default/Recommended: $default)"
  ui_print "Waiting up to ${TIMEOUT}s…"
  while :; do
    event=$(timeout "$TIMEOUT" getevent -qlc 1 2>/dev/null)
    code=$?
    # Timeout returns 124 (toybox) or 143 (BusyBox)
    if [ "$code" -eq 124 ] || [ "$code" -eq 143 ]; then
      [ "$default" = "Yes" ] && return 0 || return 1
    fi
    echo "$event" | grep -q "KEY_VOLUMEUP.*DOWN"   && return 0
    echo "$event" | grep -q "KEY_VOLUMEDOWN.*DOWN" && return 1
  done
}

# Banner
print_section "📱 Welcome to GhostGMS 📱"
ui_print "💤 Optimize Google Play Services"
ui_print "🔋 Better battery"
ui_print "🔒 Enhanced privacy"

print_section "Setup Options"

ui_print "Use Volume Up for YES, Volume Down for NO."
ui_print ""

# Main feature prompts
choose_option "👻 Enable GMS Ghosting?" "Yes"
ENABLE_GHOSTED=$?
choose_option "📋 Disable GMS Logging?" "Yes"
ENABLE_LOG_DISABLE=$?
choose_option "🔧 Set GMS-optimized system properties?" "Yes"
ENABLE_SYS_PROPS=$?
choose_option "🎨 Disable UI blur effects? (Can improve performance on some ROMs)" "No"
ENABLE_BLUR_DISABLE=$?
choose_option "⚙️ Disable intrusive GMS services?" "Yes"
ENABLE_SERVICES_DISABLE=$?

# Service categories (replace associative array with a list)
GMS_CATEGORIES="ADS TRACKING ANALYTICS REPORTING BACKGROUND UPDATE LOCATION GEOFENCE NEARBY CAST DISCOVERY SYNC CLOUD AUTH WALLET PAYMENT WEAR FITNESS"
# Default values (1=Yes, 0=No)
DISABLE_ADS=1; DISABLE_TRACKING=1; DISABLE_ANALYTICS=1; DISABLE_REPORTING=1; DISABLE_BACKGROUND=1; DISABLE_UPDATE=1
DISABLE_LOCATION=0; DISABLE_GEOFENCE=0; DISABLE_NEARBY=0; DISABLE_CAST=0; DISABLE_DISCOVERY=0; DISABLE_SYNC=0
DISABLE_CLOUD=0; DISABLE_AUTH=0; DISABLE_WALLET=0; DISABLE_PAYMENT=0; DISABLE_WEAR=0; DISABLE_FITNESS=0

if [ "$ENABLE_SERVICES_DISABLE" -eq 0 ]; then
  print_section "📋 GMS Service Categories"
  ui_print "Select which GMS service types to disable:"
  for cat in $GMS_CATEGORIES; do
    case "$cat" in
      ADS|TRACKING) emoji="🛑" ;;
      ANALYTICS|REPORTING) emoji="📊" ;;
      BACKGROUND|UPDATE) emoji="🔄" ;;
      LOCATION|GEOFENCE) emoji="📍" ;;
      NEARBY|CAST|DISCOVERY) emoji="📡" ;;
      SYNC|CLOUD|AUTH) emoji="☁️" ;;
      WALLET|PAYMENT) emoji="💰" ;;
      WEAR|FITNESS) emoji="⌚️" ;;
    esac
    default="Yes"
    eval "current_value=\"\$DISABLE_$cat\""
    [ "$current_value" = "0" ] && default="No"
    choose_option "$emoji Disable $cat services?" "$default"
    eval "DISABLE_$cat=\$?"
  done
fi

choose_option "📻 Disable GMS Receivers?" "No"
ENABLE_RECEIVER_DISABLE=$?
choose_option "🏬 Disable GMS Providers?" "No"
ENABLE_PROVIDER_DISABLE=$?
choose_option "🔠 Disable GMS Activities?" "No"
ENABLE_ACTIVITY_DISABLE=$?

# Show summary before proceeding
print_section "📝 Configuration Summary"
ui_print "Ghosting:         $([ "$ENABLE_GHOSTED" -eq 0 ] && echo Yes || echo No)"
ui_print "Disable Logging:  $([ "$ENABLE_LOG_DISABLE" -eq 0 ] && echo Yes || echo No)"
ui_print "System Props:     $([ "$ENABLE_SYS_PROPS" -eq 0 ] && echo Yes || echo No)"
ui_print "Disable Blur:     $([ "$ENABLE_BLUR_DISABLE" -eq 0 ] && echo Yes || echo No)"
ui_print "Service Disable:  $([ "$ENABLE_SERVICES_DISABLE" -eq 0 ] && echo Yes || echo No)"
ui_print "Receivers:        $([ "$ENABLE_RECEIVER_DISABLE" -eq 0 ] && echo Yes || echo No)"
ui_print "Providers:        $([ "$ENABLE_PROVIDER_DISABLE" -eq 0 ] && echo Yes || echo No)"
ui_print "Activities:       $([ "$ENABLE_ACTIVITY_DISABLE" -eq 0 ] && echo Yes || echo No)"
if [ "$ENABLE_SERVICES_DISABLE" -eq 0 ]; then
  for cat in $GMS_CATEGORIES; do
    eval "value=\"\$DISABLE_$cat\""
    ui_print "$(printf '%-10s' "$cat"): $([ "$value" -eq 0 ] && echo Yes || echo No)"
  done
fi
ui_print ""
choose_option "Proceed with installation?" "Yes"
[ $? -ne 0 ] && { ui_print "Installation cancelled."; exit 1; }

# Save user preferences
mkdir -p "$MODDIR/config"
chmod 755 "$MODDIR/config"

{
  echo "ENABLE_GHOSTED=$([ "$ENABLE_GHOSTED" -eq 0 ] && echo 1 || echo 0)"
  echo "ENABLE_LOG_DISABLE=$([ "$ENABLE_LOG_DISABLE" -eq 0 ] && echo 1 || echo 0)"
  echo "ENABLE_SYS_PROPS=$([ "$ENABLE_SYS_PROPS" -eq 0 ] && echo 1 || echo 0)"
  echo "ENABLE_BLUR_DISABLE=$([ "$ENABLE_BLUR_DISABLE" -eq 0 ] && echo 1 || echo 0)"
  echo "ENABLE_SERVICES_DISABLE=$([ "$ENABLE_SERVICES_DISABLE" -eq 0 ] && echo 1 || echo 0)"
  echo "ENABLE_RECEIVER_DISABLE=$([ "$ENABLE_RECEIVER_DISABLE" -eq 0 ] && echo 1 || echo 0)"
  echo "ENABLE_PROVIDER_DISABLE=$([ "$ENABLE_PROVIDER_DISABLE" -eq 0 ] && echo 1 || echo 0)"
  echo "ENABLE_ACTIVITY_DISABLE=$([ "$ENABLE_ACTIVITY_DISABLE" -eq 0 ] && echo 1 || echo 0)"
} > "$MODDIR/config/user_prefs"
chmod 644 "$MODDIR/config/user_prefs"

{
  for cat in $GMS_CATEGORIES; do
    eval "value=\"\$DISABLE_$cat\""
    echo "DISABLE_${cat}=$value"
  done
} > "$MODDIR/config/gms_categories"
chmod 644 "$MODDIR/config/gms_categories"

# Validate config files were created
if [ ! -f "$MODDIR/config/user_prefs" ] || [ ! -f "$MODDIR/config/gms_categories" ]; then
  ui_print "⚠️ Warning: Config files may not have been created properly"
  ui_print "This may cause issues on first boot with KernelSU Next/APatch"
  ui_print "If service fails, reinstall the module or create files manually"
fi

# Completion message
print_section "✅ GhostGMS Installation Complete"
ui_print "🔄 Changes will take effect after reboot"
ui_print "🙏 Thank you for using GhostGMS!"
