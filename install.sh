#!/sbin/sh

##########################################################################################
# GhostGMS Installer
##########################################################################################

SKIPMOUNT=false
PROPFILE=true
POSTFSDATA=false
LATESTARTSERVICE=true

REPLACE="
"

print_modname() {
  ui_print "*******************************"
  ui_print "        GhostGMS v1.3         "
  ui_print "   Performance & Battery Mod   "
  ui_print "*******************************"
}

on_install() {
  # Make required directories
  mkdir -p $MODPATH/config

  # Set permissions
  set_perm_recursive $MODPATH 0 0 0755 0644
  set_perm $MODPATH/action.sh 0 0 0755
  
  # Create user preferences file
  CONFIG_FILE="$MODPATH/config/user_prefs"
  
  # Get user input for optimizations
  ui_print " "
  ui_print "===== Optimization Settings ====="
  ui_print " "
  
  ui_print "Enable system log disabling?"
  ui_print "This will disable most system logs"
  ui_print "for better battery life and privacy."
  ui_print " "
  ui_print "1. Yes"
  ui_print "2. No"
  LOG_DISABLE=1
  if $BOOTMODE; then
    LOG_DISABLE=$(get_choose)
  fi
  ui_print " "
  
  ui_print "Enable system property changes?"
  ui_print "This will disable debugging and"
  ui_print "optimize battery consumption."
  ui_print " "
  ui_print "1. Yes"
  ui_print "2. No"
  PROP_CHANGES=1
  if $BOOTMODE; then
    PROP_CHANGES=$(get_choose)
  fi
  ui_print " "
  
  ui_print "Enable system properties in system.prop?"
  ui_print "This will apply all optimizations in"
  ui_print "the system.prop file."
  ui_print " "
  ui_print "1. Yes"
  ui_print "2. No"
  SYS_PROPS=1
  if $BOOTMODE; then
    SYS_PROPS=$(get_choose)
  fi
  ui_print " "
  
  ui_print "Enable kernel tweaks?"
  ui_print "This will optimize kernel parameters"
  ui_print "for better performance and battery life."
  ui_print " "
  ui_print "1. Yes"
  ui_print "2. No"
  KERNEL_TWEAKS=1
  if $BOOTMODE; then
    KERNEL_TWEAKS=$(get_choose)
  fi
  ui_print " "
  
  # Convert user choices to enable/disable values (1 or 0)
  [ "$LOG_DISABLE" = "1" ] && LOG_DISABLE_VAL=1 || LOG_DISABLE_VAL=0
  [ "$PROP_CHANGES" = "1" ] && PROP_CHANGES_VAL=1 || PROP_CHANGES_VAL=0
  [ "$SYS_PROPS" = "1" ] && SYS_PROPS_VAL=1 || SYS_PROPS_VAL=0
  [ "$KERNEL_TWEAKS" = "1" ] && KERNEL_TWEAKS_VAL=1 || KERNEL_TWEAKS_VAL=0
  
  # Save user preferences
  cat > $CONFIG_FILE << EOF
# GhostGMS User Preferences
# Generated during installation

# Enable/disable kernel tweaks (0=disabled, 1=enabled)
ENABLE_KERNEL_TWEAKS=$KERNEL_TWEAKS_VAL

# Enable/disable log disabling (0=disabled, 1=enabled)
ENABLE_LOG_DISABLE=$LOG_DISABLE_VAL

# Enable/disable property changes (0=disabled, 1=enabled)
ENABLE_PROP_CHANGES=$PROP_CHANGES_VAL

# Enable/disable system properties (0=disabled, 1=enabled)
ENABLE_SYS_PROPS=$SYS_PROPS_VAL
EOF
  
  ui_print "User preferences saved"
  ui_print " "
  
  # Set system.prop flag based on user preference
  if [ "$SYS_PROPS_VAL" = "0" ]; then
    ui_print "System property optimizations disabled"
    # Rename system.prop to prevent it from being applied
    mv $MODPATH/system.prop $MODPATH/system.prop.disabled
  else
    ui_print "System property optimizations enabled"
  fi
}

set_permissions() {
  # Set permissions for all files
  set_perm_recursive $MODPATH 0 0 0755 0644
  
  # Set execution permissions for scripts
  set_perm $MODPATH/action.sh 0 0 0755
}

# Function to get user choice
get_choose() {
  local choice
  local timeout=30
  
  # Default selection (1) if timeout
  choice=1
  
  # Wait for key input or timeout
  timeout $timeout keycheck
  if [ $? -eq 143 ]; then
    # Timeout occurred, use default
    ui_print "   Using default: Yes"
    return $choice
  fi
  
  # Get key press
  while true; do
    timeout $timeout keycheck
    if [ $? -eq 142 ]; then
      # Volume Up (select 1)
      choice=1
      break
    elif [ $? -eq 141 ]; then
      # Volume Down (select 2)
      choice=2
      break
    fi
  done
  
  if [ $choice -eq 1 ]; then
    ui_print "   Selected: Yes"
  else
    ui_print "   Selected: No"
  fi
  
  return $choice
} 