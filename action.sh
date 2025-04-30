#!/system/bin/sh
# GhostGMS Action Script
# This script runs on each boot and applies optimizations based on user preferences

MODDIR=${0%/*}
CONFIG_FILE="$MODDIR/config/user_prefs"

# Log function for debugging
ghost_log() {
  echo "[GhostGMS] $1" >> $MODDIR/ghost.log
}

# Initialize defaults
ENABLE_KERNEL_TWEAKS=0
ENABLE_LOG_DISABLE=0
ENABLE_PROP_CHANGES=0
ENABLE_SYS_PROPS=0

# Load user preferences if they exist
if [ -f "$CONFIG_FILE" ]; then
  ghost_log "Loading user preferences from $CONFIG_FILE"
  . $CONFIG_FILE
else
  ghost_log "No user preferences found, using defaults"
fi

# Apply kernel tweaks if enabled
if [ "$ENABLE_KERNEL_TWEAKS" -eq 1 ]; then
  ghost_log "Applying kernel tweaks"
  
  # Apply VM tweaks
  echo "50" > /proc/sys/vm/swappiness
  echo "10" > /proc/sys/vm/dirty_ratio
  echo "5" > /proc/sys/vm/dirty_background_ratio
  echo "3000" > /proc/sys/vm/dirty_writeback_centisecs
  echo "1" > /proc/sys/vm/oom_kill_allocating_task
  
  # Apply kernel tweaks
  echo "96000" > /proc/sys/kernel/msgmni
  echo "96000" > /proc/sys/kernel/msgmax
  
  # Apply TCP tweaks
  echo "0" > /proc/sys/net/ipv4/tcp_timestamps
  echo "1" > /proc/sys/net/ipv4/tcp_tw_reuse
  echo "1" > /proc/sys/net/ipv4/tcp_sack
  echo "0" > /proc/sys/net/ipv4/tcp_dsack
  echo "1024" > /proc/sys/net/core/rmem_default
  echo "1024" > /proc/sys/net/core/wmem_default
  echo "4096" > /proc/sys/net/core/rmem_max
  echo "4096" > /proc/sys/net/core/wmem_max
  echo "4096 87380 174760" > /proc/sys/net/ipv4/tcp_rmem
  echo "4096 16384 131072" > /proc/sys/net/ipv4/tcp_wmem
  echo "0" > /proc/sys/net/ipv4/tcp_slow_start_after_idle
fi

# Disable logs if enabled
if [ "$ENABLE_LOG_DISABLE" -eq 1 ]; then
  ghost_log "Disabling system logs"
  
  # Disable kernel logging
  echo "0" > /proc/sys/kernel/printk
  
  # Disable logd
  stop logd 2>/dev/null
  
  # Disable various logging services
  for svc in logcatd statsd stats statsd-c logd-auditctl mdnsd diagnostic_report_service; do
    if [ "$(getprop init.svc.$svc)" = "running" ]; then
      stop $svc 2>/dev/null
      ghost_log "Stopped $svc service"
    fi
  done
fi

# Apply property changes if enabled
if [ "$ENABLE_PROP_CHANGES" -eq 1 ]; then
  ghost_log "Applying property changes"
  
  # Disable debuggable flag
  resetprop ro.debuggable 0
  
  # Disable adb
  resetprop persist.sys.usb.config none
  
  # Disable profiling
  resetprop dalvik.vm.profiler 0
  
  # Improve battery life
  resetprop ro.ril.disable.power.collapse 0
  resetprop ro.ril.power_collapse 1
  resetprop pm.sleep_mode 1
  resetprop power.saving.mode 1
  
  # Disable ART debugging
  resetprop dalvik.vm.check-dex-sum false
  resetprop dalvik.vm.checkjni false
  resetprop dalvik.vm.debug.alloc 0
fi

# Apply system properties if enabled - these are in the system.prop file already,
# but we can force-apply some critical ones here too
if [ "$ENABLE_SYS_PROPS" -eq 1 ]; then
  ghost_log "Applying system properties"
  
  # Disable debugging
  resetprop debug.atrace.tags.enableflags 0
  resetprop debug.mdpcomp.logs 0
  resetprop debug.sf.disable_backpressure 1
  resetprop debug.sf.latch_unsignaled 1
  
  # Performance improvements
  resetprop debug.performance.tuning 1
  resetprop debug.sf.hw 1
  resetprop debug.enable.sglscale 1
  
  # Battery optimizations
  resetprop ro.config.hw_power_saving true
  resetprop persist.sys.shutdown.mode hibernate
  resetprop persist.sys.purgeable_assets 1
fi

ghost_log "GhostGMS optimizations applied according to user preferences"
exit 0 