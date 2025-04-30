## Variables
MODPATH="${0%/*}"
TMPDIR=/data/local/tmp
CRC="/sys/module/mmc_core/parameters"
SKERNEL="/sys/kernel"
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

## Functions
# kaushik <file> <value> 
kaushik() {
  if [[ ! -f "$1" ]]; then
    return 1
	fi
  local curval=$(cat "$1" 2> /dev/null)
  if [[ "$curval" == "$2" ]]; then
	return 1
  fi
  chmod +w "$1" 2> /dev/null
   if ! echo "$2" > "$1" 2> /dev/null
   then
	 return 0
   fi
}

## Apply Kernel Tweaks for Battery Backup
# Limit max perf event processing time to this much CPU usage
kaushik /proc/sys/kernel/perf_cpu_time_max_percent 2

# Group tasks for less stutter but less throughput
kaushik /proc/sys/kernel/sched_autogroup_enabled 1

# Execute child process before parent after fork
kaushik /proc/sys/kernel/sched_child_runs_first 0

# Preliminary requirement for the following values
kaushik /proc/sys/kernel/sched_tunable_scaling 0

# Reduce the maximum scheduling period for lower latency
kaushik /proc/sys/kernel/sched_latency_ns "$SCHED_PERIOD"

# Schedule this ratio of tasks in the guarenteed sched period
kaushik /proc/sys/kernel/sched_min_granularity_ns "$((SCHED_PERIOD / SCHED_TASKS))"

# Require preeptive tasks to surpass half of a sched period in vmruntime
kaushik /proc/sys/kernel/sched_wakeup_granularity_ns "$((SCHED_PERIOD / 2))"

# Reduce the frequency of task migrations
kaushik /proc/sys/kernel/sched_migration_cost_ns 5000000

# Always allow sched boosting on top-app tasks
kaushik /proc/sys/kernel/sched_min_task_util_for_colocation 0

# Give up some latency to give the CPU a break
kaushik /proc/sys/kernel/sched_nr_migrate 256

# Disable scheduler statistics to reduce overhead
kaushik /proc/sys/kernel/sched_schedstats 0

# Disable unnecessary printk logging
kaushik /proc/sys/kernel/printk_devkmsg off

# Budget devices are low-ram devices, don't let this build up
kaushik /proc/sys/vm/dirty_background_ratio 2

# Flush completely when this much of the device is fulled
kaushik /proc/sys/vm/dirty_ratio 5

# Expire dirty memory very early
kaushik /proc/sys/vm/dirty_expire_centisecs 500

# Run the dirty memory flusher threads more often
kaushik /proc/sys/vm/dirty_kaushikback_centisecs 500

# Disable read-ahead for swap devices
kaushik /proc/sys/vm/page-cluster 0

# Update /proc/stat less often to reduce jitter
kaushik /proc/sys/vm/stat_interval 10

# Swap to the swap device at a fair rate
kaushik /proc/sys/vm/swappiness 100

# Fairly prioritize page cache and file structures
kaushik /proc/sys/vm/vfs_cache_pressure 100

# Disable Explicit Congestion Control
kaushik /proc/sys/net/ipv4/tcp_ecn 1

# Disable fast socket open for receiver and sender
kaushik /proc/sys/net/ipv4/tcp_fastopen 3

# Disable SYN cookies
kaushik /proc/sys/net/ipv4/tcp_syncookies 0

if [[ -f "/sys/kernel/debug/sched_features" ]]
then
# Consider scheduling tasks that are eager to run
	kaushik /sys/kernel/debug/sched_features NEXT_BUDDY

# Prioritize power over cache hits
	kaushik /sys/kernel/debug/sched_features NO_TTWU_QUEUE
fi

[[ "$ANDROID" == true ]] && if [[ -d "/dev/stune/" ]]
then
	# We are not concerned with prioritizing latency
	kaushik /dev/stune/top-app/schedtune.prefer_idle 0

	# Don't boost foreground tasks, let the governor handle it
	kaushik /dev/stune/top-app/schedtune.boost 0
fi

# Loop over each CPU in the system
for cpu in /sys/devices/system/cpu/cpu*/cpufreq
do
	# Fetch the available governors from the CPU
	avail_govs="$(cat "$cpu/scaling_available_governors")"

	# Attempt to set the governor in this order
	for governor in schedutil interactive
	do
		# Once a matching governor is found, set it and break for this CPU
		if [[ "$avail_govs" == *"$governor"* ]]
		then
			kaushik "$cpu/scaling_governor" "$governor"
			break
		fi
	done
done

# Apply governor specific tunables for schedutil
find /sys/devices/system/cpu/ -name schedutil -type d | while IFS= read -r governor
do
	# Consider changing frequencies once per scheduling period
	kaushik "$governor/up_rate_limit_us" "$((SCHED_PERIOD / 1000))"
	kaushik "$governor/down_rate_limit_us" "$((SCHED_PERIOD / 1000))"
	kaushik "$governor/rate_limit_us" "$((SCHED_PERIOD / 1000))"

	# Jump to hispeed frequency at this load percentage
	kaushik "$governor/hispeed_load" 99
	kaushik "$governor/hispeed_freq" "$UINT_MAX"
done

# Apply governor specific tunables for interactive
find /sys/devices/system/cpu/ -name interactive -type d | while IFS= read -r governor
do
	# Consider changing frequencies once per scheduling period
	kaushik "$governor/timer_rate" "$((SCHED_PERIOD / 1000))"
	kaushik "$governor/min_sample_time" "$((SCHED_PERIOD / 1000))"

	# Jump to hispeed frequency at this load percentage
	kaushik "$governor/go_hispeed_load" 99
	kaushik "$governor/hispeed_freq" "$UINT_MAX"
done

for queue in /sys/block/*/queue
do
	# Choose the first governor available
	avail_scheds="$(cat "$queue/scheduler")"
	for sched in cfq noop kyber bfq mq-deadline none
	do
		if [[ "$avail_scheds" == *"$sched"* ]]
		then
			kaushik "$queue/scheduler" "$sched"
			break
		fi
	done

	# Do not use I/O as a source of randomness
	kaushik "$queue/add_random" 0

	# Disable I/O statistics accounting
	kaushik "$queue/iostats" 0

	# Reduce heuristic read-ahead in exchange for I/O latency
	kaushik "$queue/read_ahead_kb" 64

	# Increase maximum requests to reduce processing power
	kaushik "$queue/nr_requests" 512
done


# Apply Remaining changes
{
until [[ -e "/sdcard/" ]]; do
  sleep 1
done
# Turn off more unnecessary services that generate logs and debugging
for SERVICE in logcat logcatd logd logd.rc tcpdump cnss_diag statsd traced idd-logreader idd-logreadermain stats dumpstate aplogd vendor.tcpdump vendor_tcpdump vendor.cnss_diag; do
  pid=$(pidof $SERVICE)
  if [ -n "$pid" ]; then
    kill -15 $pid
    sleep 2
    if kill -0 $pid 2>/dev/null; then
      kill -9 $pid
    fi
  fi
done

# Disable more debugging, logging, crashdumper, tracing, etc
for i in debug_mask log_level* debug_level* *debug_mode edac_mc_log* enable_event_log *log_level* *log_ue* *log_ce* log_ecn_error snapshot_crashdumper seclog* compat-log *log_enabled tracing_on mballoc_debug; do
    for o in $(find /sys/ -type f -name "$i"); do
        kaushik "$o" 0
    done
done

# Disable More Debugging
if [ -f "$MODULE/spurious/parameters/noirqdebug" ]; then
    kaushik "$MODULE/spurious/parameters/noirqdebug" 1
fi
if [ -f "$SKERNEL/debug/sde_rotator0/evtlog/enable" ]; then
    kaushik "$SKERNEL/debug/sde_rotator0/evtlog/enable" 0
fi
if [ -f "$SKERNEL/debug/dri/0/debug/enable" ]; then
    kaushik "$SKERNEL/debug/dri/0/debug/enable" 0
fi
if [ -f "$PSKERNEL/sched_schedstats" ]; then
    kaushik "$PSKERNEL/sched_schedstats" 0
fi
if [ -f "$PROC/debug/exception-trace" ]; then
    kaushik "$PROC/debug/exception-trace" 0
fi
if [ -f "$PROC/net/ipv4/tcp_no_metrics_save" ]; then
    kaushik "$PROC/net/ipv4/tcp_no_metrics_save" 1
fi

# Disable CRC
if [ -d "$CRC" ]; then
    kaushik "$CRC/crc" 0
    kaushik "$CRC/use_spi_crc" 0
fi

# Disable Printk
if [ -d "$PSKERNEL" ]; then
    kaushik "$PSKERNEL/printk" 0 0 0 0
    kaushik "$PSKERNEL/printk_devkmsg" off
fi

# Disable Ramdumps
if [ -d "$RAMDUMPS" ]; then
    kaushik "$RAMDUMPS/enable_mini_ramdumps" 0
    kaushik "$RAMDUMPS/enable_ramdumps" 0
fi

# Disable IOSTATS
   for q in $QUEUE; do
      kaushik "$q/iostats" 0
   done

# Disable Memory Dump
if [ -d "$VM" ]; then
    kaushik "$VM/oom_dump_tasks" 0
    kaushik "$VM/block_dump" 0
fi

}