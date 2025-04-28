#!/system/bin/sh

## Variables
MODPATH="${0%/*}"
CRC="/sys/kernel/debug/tracing/events/raw_syscalls/sys_exit/enable"
SKERNEL="/sys/kernel/debug/tracing/events/sched/sched_switch/enable"
PSKERNEL="/proc/sys/kernel"
MODULE="/sys/module"
PROC="/proc/sys"
RAMDUMPS="/sys/module/subsystem_restart/parameters"
VM="/proc/sys/vm"
QUEUE="/sys/block/*/queue"
UINT_MAX="4294967295"
SCHED_PERIOD="$((5 * 1000 * 1000))"
SCHED_TASKS="5"
sync # Avoid Crashes while booting

# Wait for boot to complete
while [ -z "$(getprop sys.boot_completed)" ]; do
	sleep 40
done

# Setup log file
rm -f /data/ghost/ghost_log
touch /data/ghost/ghost_log

## Functions
# kaushik <file> <value> 
kaushik() {
  if [[ -f "$1" ]]; then
    chmod 0666 "$1" 2>/dev/null
    echo "$2" > "$1" 2>/dev/null
    echo "$1 - set to $2" >> /data/ghost/ghost_log 2>/dev/null
  fi
}

# Apply kernel-level optimizations
apply_kernel_tweaks() {
  # CPU scheduling tweaks 
  kaushik /proc/sys/kernel/sched_autogroup_enabled 1
  kaushik /sys/kernel/debug/sched/tunable_scaling 0
  kaushik /proc/sys/kernel/sched_child_runs_first 1
  kaushik /proc/sys/kernel/sched_tunable_scaling 0
  kaushik /proc/sys/kernel/sched_migration_cost_ns 5000000
  kaushik /proc/sys/kernel/sched_min_granularity_ns 100000
  kaushik /proc/sys/kernel/sched_latency_ns 10000000  # sched_period for 10ms
  kaushik /proc/sys/kernel/sched_wakeup_granularity_ns 2000000
  kaushik /proc/sys/kernel/sched_nr_migrate 32
  kaushik /proc/sys/kernel/sched_schedstats 0
  kaushik /proc/sys/kernel/sched_compat_yield 1

  # Memory management tweaks
  kaushik /proc/sys/vm/compact_memory 1
  kaushik /proc/sys/vm/dirty_background_ratio 2
  kaushik /proc/sys/vm/dirty_ratio 5
  kaushik /proc/sys/vm/dirty_expire_centisecs 200
  kaushik /proc/sys/vm/dirty_writeback_centisecs 1000
  kaushik /proc/sys/vm/page-cluster 0
  kaushik /proc/sys/vm/stat_interval 86400
  kaushik /proc/sys/vm/swappiness 100
  kaushik /proc/sys/vm/vfs_cache_pressure 200
  kaushik /proc/sys/vm/drop_caches 3

  # IO scheduler tweaks
  for block in /sys/block/*/queue; do
    kaushik $block/scheduler cfq
    kaushik $block/read_ahead_kb 128
    kaushik $block/nr_requests 128
    kaushik $block/rq_affinity 2
    kaushik $block/nomerges 2
    kaushik $block/add_random 0
    kaushik $block/rotational 0
    kaushik $block/iostats 0
  done

  # Governor specific tunables
  # Schedutil governor
  for cluster in /sys/devices/system/cpu/cpufreq/policy*; do
    if [[ -f "$cluster/scaling_governor" ]]; then
      governor=$(cat $cluster/scaling_governor)
      if [[ "$governor" == "schedutil" ]]; then
        kaushik $cluster/schedutil/up_rate_limit_us 1000
        kaushik $cluster/schedutil/down_rate_limit_us 10000
        kaushik $cluster/schedutil/rate_limit_us 1000  # For older kernels
        kaushik $cluster/schedutil/hispeed_load 85
        kaushik $cluster/schedutil/hispeed_freq $UINT_MAX
      elif [[ "$governor" == "interactive" ]]; then
        # Interactive governor tunables
        kaushik $cluster/interactive/timer_rate 10000
        kaushik $cluster/interactive/timer_slack 10000
        kaushik $cluster/interactive/min_sample_time 10000
        kaushik $cluster/interactive/go_hispeed_load 85
        kaushik $cluster/interactive/boost 0
        kaushik $cluster/interactive/fast_ramp_down 1
        kaushik $cluster/interactive/align_windows 1
        kaushik $cluster/interactive/max_freq_hysteresis 0
        kaushik $cluster/interactive/use_migration_notif 1
        kaushik $cluster/interactive/use_sched_load 1
        kaushik $cluster/interactive/ignore_hispeed_on_notif 0
        kaushik $cluster/interactive/enable_prediction 0
      fi
    fi
  done

  echo "Applied kernel tweaks successfully" >> /data/ghost/ghost_log
}

# Disable debugging and logging
disable_debugging() {
  # Disable various debugging and logging
  if [[ -f "/sys/module/rmnet_data/parameters/rmnet_data_log_level" ]]; then
    echo 0 > /sys/module/rmnet_data/parameters/rmnet_data_log_level
  fi

  if [[ -f "$CRC" ]]; then
    echo 0 > $CRC
  fi

  if [[ -f "$SKERNEL" ]]; then
    echo 0 > $SKERNEL
  fi

  # Disable kernel debugging
  echo 0 > /sys/module/bluetooth/parameters/disable_ertm 2>/dev/null
  echo 0 > /proc/sys/debug/exception-trace 2>/dev/null
  echo 0 > /proc/sys/vm/oom_dump_tasks 2>/dev/null
  echo 0 0 0 0 > /proc/sys/kernel/printk 2>/dev/null
  echo "off" > /proc/sys/kernel/printk_devkmsg 2>/dev/null

  # Disable Qualcomm rmt_storage log spam
  if [ -f /sys/module/rmt_storage/parameters/enable_logs ]; then
    echo 0 > /sys/module/rmt_storage/parameters/enable_logs
  fi

  echo "Disabled debugging services" >> /data/ghost/ghost_log
}

# Run all optimizations
run_all_optimizations() {
  # Apply kernel optimizations
  apply_kernel_tweaks
  
  # Disable debugging and logging
  disable_debugging
  
  # Check for misc optimizations
  if [[ -f "/data/ghost/misc_opt" ]]; then
    MISC_OPT=$(cat /data/ghost/misc_opt)
    if [[ "$MISC_OPT" == "1" ]]; then
      echo "Applying miscellaneous optimizations from prop file" >> /data/ghost/ghost_log
      # Apply properties from misc_optimizations.prop
      if [ -f $MODPATH/misc_optimizations.prop ]; then
        while IFS= read -r line || [ -n "$line" ]; do
          # Skip comments and empty lines
          if [[ "$line" =~ ^[[:space:]]*# || -z "$line" ]]; then
            continue
          fi
          
          # Extract property name and value
          if [[ "$line" =~ ^([^=]+)=(.*)$ ]]; then
            prop_name="${BASH_REMATCH[1]}"
            prop_value="${BASH_REMATCH[2]}"
            setprop "$prop_name" "$prop_value" 2>/dev/null
            echo "Set property: $prop_name=$prop_value" >> /data/ghost/ghost_log
          fi
        done < $MODPATH/misc_optimizations.prop
      fi
    fi
  fi

  # Log completion
  echo "System optimization completed at boot" >> /data/ghost/ghost_log
  
  # Show notification
  su -lp 2000 -c "cmd notification post -S bigtext -t 'GMS Control Panel' 'Tag$(date +%s)' \"System optimizations have been applied at boot for better performance and battery life\""
}

# Check if Optimize GMS Services was enabled before reboot
if [ "$(cat /data/ghost/kill_logd)" -eq 1 ]; then
  # Execute GMS optimization on boot
  ghost-utils set_kill_logd 1
  su -lp 2000 -c "cmd notification post -t 'GMS Control Panel' 'Tag$(date +%s)' \"GMS services optimization applied on boot\""
fi

# Always run system optimizations on boot
run_all_optimizations

# Show notification that GMS Control Panel is running
su -lp 2000 -c "cmd notification post -t 'GMS Control Panel' 'Tag$(date +%s)' \"GMS Control Panel is running. Visit the UI to manage GMS services.\""

# Setup HTTP server
httpd -h "$MODPATH/webroot" -p 8080
