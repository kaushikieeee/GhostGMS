#!/system/bin/sh
##########################################################################################
# GhostGMS Service Script
# Authors: Veloxine, Migrator
# Version: 2.0
##########################################################################################

# Check for command line arguments
COMMAND=${1:-"status"}

# Set up logging
MODDIR="/data/adb/modules/GhostGMS"
LOGDIR="$MODDIR/logs"
mkdir -p $LOGDIR
LOGFILE="$LOGDIR/ghostgms_service.log"
exec >> $LOGFILE 2>&1

# Define packages
GMS_PACKAGE="com.google.android.gms"
GSF_PACKAGE="com.google.android.gsf"

# Log start time with command
echo "[$(date '+%Y-%m-%d %H:%M:%S')] GhostGMS Service started with command: $COMMAND"

# Load user preferences
if [ -f "$MODDIR/config/user_prefs" ]; then
  . "$MODDIR/config/user_prefs"
  echo "[INFO] User preferences loaded"
else
  echo "[ERROR] User preferences file not found!"
  exit 1
fi

# Load GMS categories preferences
echo "[INFO] Loading GMS categories preferences"
if [ -f "$MODDIR/config/gms_categories" ]; then
  . "$MODDIR/config/gms_categories"
  echo "[INFO] GMS categories loaded successfully"
else
  echo "[WARNING] GMS categories file not found, using defaults"
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
fi

# Function to show notification
show_notification() {
  local TITLE="GhostGMS"
  local MESSAGE="$1"
  local PRIORITY=$2
  
  # Try PowerSaver app first
  am start -a android.intent.action.MAIN -e powersaver "$MESSAGE" -n powersaver.pro/.MainActivity >/dev/null 2>&1
  
  # Fallback to basic notification if PowerSaver isn't available
  if [ $? -ne 0 ]; then
    am startservice -a android.intent.action.RUN \
      -e short "$TITLE" -e long "$MESSAGE" -e priority "$PRIORITY" \
      -n com.android.shell/.BugreportWarningService >/dev/null 2>&1
  fi
}

# Function to process service based on category
toggle_gms_service() {
  local FULL_SERVICE_NAME=$1
  local CATEGORY=$2
  local ACTION=$3
  local SHOULD_DISABLE=0
  
  # Skip if category is not set or service is not properly formatted
  if [ -z "$CATEGORY" ] || [ "$CATEGORY" = "null" ]; then
    echo "[INFO] Skipping service $FULL_SERVICE_NAME (no category)"
    return
  fi

  # Extract service name without package if it has package name
  local SERVICE_NAME
  if [[ "$FULL_SERVICE_NAME" == *"/"* ]]; then
    SERVICE_NAME=$(echo "$FULL_SERVICE_NAME" | cut -d'/' -f2)
  else
    SERVICE_NAME=$FULL_SERVICE_NAME
    FULL_SERVICE_NAME="${GMS_PACKAGE}/${SERVICE_NAME}"
  fi
  
  # If action is "enable", we enable all services
  if [ "$ACTION" = "enable" ]; then
    echo "[INFO] Enabling service $FULL_SERVICE_NAME"
    pm enable $FULL_SERVICE_NAME >/dev/null 2>&1
    return
  fi
  
  # For disable action, determine if we should disable based on category
  case $CATEGORY in
    "ads")
      SHOULD_DISABLE=$DISABLE_ADS
      ;;
    "tracking")
      SHOULD_DISABLE=$DISABLE_TRACKING
      ;;
    "analytics")
      SHOULD_DISABLE=$DISABLE_ANALYTICS
      ;;
    "reporting")
      SHOULD_DISABLE=$DISABLE_REPORTING
      ;;
    "background")
      SHOULD_DISABLE=$DISABLE_BACKGROUND
      ;;
    "update")
      SHOULD_DISABLE=$DISABLE_UPDATE
      ;;
    "location")
      SHOULD_DISABLE=$DISABLE_LOCATION
      ;;
    "geofence")
      SHOULD_DISABLE=$DISABLE_GEOFENCE
      ;;
    "nearby")
      SHOULD_DISABLE=$DISABLE_NEARBY
      ;;
    "cast")
      SHOULD_DISABLE=$DISABLE_CAST
      ;;
    "discovery")
      SHOULD_DISABLE=$DISABLE_DISCOVERY
      ;;
    "sync")
      SHOULD_DISABLE=$DISABLE_SYNC
      ;;
    "cloud")
      SHOULD_DISABLE=$DISABLE_CLOUD
      ;;
    "auth")
      SHOULD_DISABLE=$DISABLE_AUTH
      ;;
    "wallet")
      SHOULD_DISABLE=$DISABLE_WALLET
      ;;
    "payment")
      SHOULD_DISABLE=$DISABLE_PAYMENT
      ;;
    "wear")
      SHOULD_DISABLE=$DISABLE_WEAR
      ;;
    "fitness")
      SHOULD_DISABLE=$DISABLE_FITNESS
      ;;
    "core"|"essential")
      # Never disable core/essential services
      SHOULD_DISABLE=0
      ;;
    *)
      echo "[WARNING] Unknown category: $CATEGORY for service $FULL_SERVICE_NAME"
      return
      ;;
  esac
  
  # Disable service based on category preferences
  if [ "$SHOULD_DISABLE" = "1" ]; then
    echo "[INFO] Disabling service $FULL_SERVICE_NAME (category: $CATEGORY)"
    pm disable $FULL_SERVICE_NAME >/dev/null 2>&1
  else
    echo "[INFO] Keeping service $FULL_SERVICE_NAME (category: $CATEGORY)"
    pm enable $FULL_SERVICE_NAME >/dev/null 2>&1
  fi
}

# Process services from gmslist.txt
process_services() {
  local ACTION=$1
  echo "[INFO] Processing GMS services with action: $ACTION"
  
  if [ ! -f "$MODDIR/gmslist.txt" ]; then
    echo "[ERROR] gmslist.txt not found. Cannot proceed with service toggling."
    return 1
  fi
  
  # Count total services for progress tracking
  local TOTAL_SERVICES=$(grep -v "^#" "$MODDIR/gmslist.txt" | grep -v "^$" | wc -l)
  local COUNTER=0
  
  while IFS="|" read -r SERVICE CATEGORY || [ -n "$SERVICE" ]; do
    # Skip comments and empty lines
    [[ "$SERVICE" =~ ^#.*$ || -z "$SERVICE" ]] && continue
    
    # Process service
    toggle_gms_service "$SERVICE" "$CATEGORY" "$ACTION"
    
    # Update counter for progress
    COUNTER=$((COUNTER+1))
    
    # Show progress notification every 20 services
    if [ $((COUNTER % 20)) -eq 0 ]; then
      show_notification "Processing $COUNTER/$TOTAL_SERVICES services..." "low"
    fi
    
    # Add a small delay to prevent overwhelming the system
    sleep 0.01
  done < "$MODDIR/gmslist.txt"
  
  echo "[INFO] Processed $COUNTER/$TOTAL_SERVICES services"
  return 0
}

# Function to disable GMS logs
disable_gms_logs() {
  if [ "$ENABLE_LOG_DISABLE" = "1" ]; then
    echo "[INFO] Disabling GMS logging"
    settings put global gmscorestat_enabled 0
    settings put global play_store_panel_logging_enabled 0
    settings put global clearcut_events 0
    settings put global clearcut_gcm 0
    settings put global phenotype__debug_bypass_phenotype 1
    settings put global phenotype_boot_count 99
    settings put global phenotype_flags "disable_log_upload=1,disable_log_for_missing_debug_id=1"
    
    # Disable analytics and error reporting
    settings put global ga_collection_enabled 0
    settings put global clearcut_enabled 0
    settings put global analytics_enabled 0
    settings put global uploading_enabled 0
    settings put global bug_report_in_power_menu 0
    
    # Disable usage stats
    settings put global usage_stats_enabled 0
    settings put global usagestats_collection_enabled 0
  else
    echo "[INFO] GMS logging not disabled (user preference)"
  fi
}

# Main functionality based on command
case "$COMMAND" in
  "disable"|"off")
    echo "[INFO] Disabling GMS services..."
    # Apply service disabling
    if [ "$ENABLE_SERVICES_DISABLE" = "1" ] && [ -f "$MODDIR/gmslist.txt" ]; then
      process_services "disable"
    else
      echo "[INFO] Service disabling not enabled by user preference"
    fi
    
    # Apply log disabling
    disable_gms_logs
    
    # Show completion notification
    show_notification "GMS services have been DISABLED" "normal"
    ;;
    
  "enable"|"on")
    echo "[INFO] Enabling GMS services..."
    # Enable all GMS services
    if [ -f "$MODDIR/gmslist.txt" ]; then
      process_services "enable"
    else
      echo "[ERROR] gmslist.txt not found. Cannot proceed with service enabling."
    fi
    
    # Show completion notification
    show_notification "GMS services have been ENABLED" "normal"
    ;;
    
  "boot")
    echo "[INFO] Processing boot-time GMS configuration..."
    # Apply service disabling on boot
    if [ "$ENABLE_SERVICES_DISABLE" = "1" ] && [ -f "$MODDIR/gmslist.txt" ]; then
      process_services "disable"
    else
      echo "[INFO] Service disabling not enabled by user preference"
    fi
    
    # Apply log disabling
    disable_gms_logs
    ;;
    
  "status")
    echo "[INFO] Checking GMS services status"
    show_notification "GhostGMS is active" "low"
    ;;
    
  *)
    echo "[INFO] Unknown command: $COMMAND"
    echo "[INFO] Valid commands: enable, disable, boot, status"
    ;;
esac

# Log completion
echo "[$(date '+%Y-%m-%d %H:%M:%S')] GhostGMS Service completed successfully"
exit 0 