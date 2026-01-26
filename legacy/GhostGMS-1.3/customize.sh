# Verify ZIP
unzip -o "$ZIPFILE" 'verify.sh' -d "$TMPDIR" >&2
if [ ! -f "$TMPDIR/verify.sh" ]; then
ui_print "-----------------------------------------"
ui_print "- Module files are corrupt, please re-download"
abort    "-----------------------------------------"
fi

echo " "
echo "----------------------------------------"
echo "Verifying Module Files..."
echo "----------------------------------------"
echo " "
. "$TMPDIR/verify.sh"

extract "$ZIPFILE" 'customize.sh'  "$TMPDIR/.vunzip"
export ZIPFILE
ui_print "- Files verified successfully!"

# Variables
MODNAME=`grep_prop name $TMPDIR/module.prop`
MODVER=`grep_prop version $TMPDIR/module.prop`
DV=`grep_prop author $TMPDIR/module.prop`
Device=`getprop ro.product.device`
Model=`getprop ro.product.model`
Brand=`getprop ro.product.brand` 
Architecture=`getprop ro.product.cpu.abi`
SDK=`getprop ro.system.build.version.sdk`
Android=`getprop ro.system.build.version.release`
Type=`getprop ro.system.build.type`
Built=`getprop ro.system.build.date`
Time=$(date "+%d, %b - %H:%M %Z")

show_message () {
  local message="$1"
  local delay="${2:-0.3}"
  local type="$3"
  local padding_length=5
  local line_length=$((${#message} + 2 * padding_length))
  if [ "$type" == "boxed" ]; then
    ui_print ""
    printf '%*s\n' "$line_length" | tr ' ' '-'
    printf "%-${padding_length}s%s%${padding_length}s\n" "" "$message" ""
    printf '%*s\n' "$line_length" | tr ' ' '-'
    ui_print ""
  else
    ui_print "$message"
  fi
  sleep "$delay"
}

# Installation Begins
show_message "Fetching module info..." 0.5 "boxed"
show_message "- Author: $DV"
show_message "- Module: $MODNAME"
show_message "- Version: $MODVER"
echo -e "- Provider: \c"
if [ "$BOOTMODE" ] && [ "$KSU" ]; then
  ui_print "KernelSU"
  sed -i '/^description=/c\description=[🦄 KernelSU Mode] Nukes cache, Disables 200+ GMS services, Disables 95% logs, Applies Kernel Tweaks for Battery and much more. Run Action button to Toggle GMS Services and Cleanup.' "$MODPATH/module.prop"
  ui_print "- KernelSU: $KSU_KERNEL_VER_CODE (kernel) + $KSU_VER_CODE (ksud)"
  if [ "$(which magisk)" ]; then
    ui_print "-----------------------------------------------------------"
    ui_print "! Multiple root implementation is NOT supported!"
    abort    "-----------------------------------------------------------"
  fi
elif [ "$BOOTMODE" ] && [ "$MAGISK_VER_CODE" ]; then
  ui_print "Magisk"
  sed -i '/^description=/c\description=[🪷 Magisk Mode] Nukes cache, Disables 200+ GMS services, Disables 95% logs, Applies Kernel Tweaks for Battery and much more. Run Action button to Toggle GMS Services and Cleanup.' "$MODPATH/module.prop"
else
  ui_print "--------------------------------------------------------"
  ui_print "Installation from recovery is not supported"
  ui_print "Please install from KernelSU or Magisk app"
  abort "----------------------------------------------------------"
fi

show_message "Fetching your device info..." 0.5 "boxed"
show_message "- Brand: $Brand"
show_message "- Device: $Device"
show_message "- Model: $Model"
show_message "- RAM: $(free | grep Mem | awk '{print $2}')"
show_message "Fetching your ROM information..." 0.3 "boxed"
show_message "- Android: $Android"
show_message "- Kernel: $(uname -r)"
show_message "- CPU: $Architecture"
show_message "- SDK: $SDK"
show_message "- Build Date: $Built"
show_message "- Build Type: $Type"

ui_print "---------------------------------------------"
ui_print "- Running $MODNAME"
ui_print "- Flashing started at $Time"
ui_print "---------------------------------------------"
ui_print " ⚡"
ui_print " 🔋 "
sleep 1

# Print Preview GMS results (will be applied after reboot)
show_message "KILLING GMS SERVICES BRO, PLEASE WAIT" 0.3 "boxed"
show_message "✦ Disabled advertising and tracking in Google Play services."
show_message "✦ Restricted Google’s data collection on your device."
show_message "✦ Disabled the battery-draining HardwareArProviderService."
show_message "✦ Disabled bug reporting in Google Play services."
show_message "✦ Disabled Google Cast services."
show_message "✦ Disabled debugging services in Google Play Services."
show_message "✦ Disabled component discovery services in Google Play and Firebase."
show_message "✦ Disabled location and time zone services."
show_message "✦ Disabled key authentication services in Google Play."
show_message "✦ Disabled various background update services."
show_message "✦ Disabled services for smartwatches and wearables."
show_message "✦ Disabled Trusted Agents / Find My Device services."
show_message "✦ Disabled enpromo-related services."
show_message "✦ Disabled emergency features and child safety services."
show_message "✦ Disabled Google Fit health tracking services."
show_message "✦ Disabled Google Nearby services."
show_message "✦ Disabled logging and data collection services."
show_message "✦ Disabled security and app verification services."
show_message "✦ Disabled Google Pay and Wallet services."
show_message "✦ Disabled location services."
show_message "✦ Disabled Google Play Games-related services."
show_message "✦ Disabled Google Instant Apps services."

# Remove modules that conflicts with power saver (if available)
rm -rf /data/adb/modules/AdvanceCleaner
rm -rf /data/adb/modules/Energy_Saver
sleep 1

# Print Preview System Prop Results
Dikhao "DISABLING LOGS & COMPONENTS" 0.2 "sar"
Dikhao "✦ Disabled Real-Time Transport Protocol (RTP) logging"
Dikhao "✦ Disabled JNI (Java Native Interface) checks, reducing logging related to native code interaction."
Dikhao "✦ Stopped logging slow database queries."
Dikhao "✦ Disabled debugging logs related to Qualcomm's Sensor Network Services (SNS)."
Dikhao "✦ Disabled profiling logs for the EGL graphics API."
Dikhao "✦ Disabled logging related to gamed and Wayland."
Dikhao "✦ Disabled logging related to the Hardware Composer (HWC) and SurfaceFlinger components."
Dikhao "✦ Disabled logging related to SurfaceFlinger's backpressure mechanism."
Dikhao "✦ Disabled logging related to surface re-computations."
Dikhao "✦ Disabled logging of Application Not Responding (ANR) events."
Dikhao "✦ Disabled GPU-based pixel buffers, impacting rendering."
Dikhao "✦ Disabled real-time logcat output and streaming."
Dikhao "✦ Disabled TCP metrics logging."
Dikhao "✦ Disabled logging related to the Stagefright media framework."
Dikhao "✦ Disabled various profiling tools."
Dikhao "✦ Disabled StrictMode, which checks for potential performance and security issues."
Dikhao "✦ Changed behavior related to EGL context destruction."
Dikhao "✦ Disabled support for Kernel Samepage Merging (KSM), a memory optimization technique."
Dikhao "✦ Disabled \"checkin\" logging that sends system information to Google."
Dikhao "✦ Disabled debugging capabilities for the device."
Dikhao "✦ Setting the log buffer size to zero, effectively disable the log system."
Dikhao "✦ Disabled the default compression cache."
Dikhao "✦ Disabled JNI checks and QEMU-related logging."
Dikhao "✦ Disabled battery-related logging."
Dikhao "✦ Disabled multiple simultaneous call ringtones."
Dikhao "✦ Disabled the RW logger, used for debugging network interactions."
Dikhao "✦ Disabled IMS (IP Multimedia Subsystem) debug logs."
Dikhao "✦ Disabled debugging related to Wi-Fi Direct (WFD)."
Dikhao "✦ Disabled AAC support for Bluetooth A2DP."
Dikhao "✦ Disabled QMI (Qualcomm MSM Interface) logging for ADB."
Dikhao "✦ Disabled debug logging for the sensors HAL (Hardware Abstraction Layer)."
Dikhao "✦ Disabled logging and crash reports related to Broadcom components."
Dikhao "✦ Disabled an override for USB tethering."
Dikhao "✦ Disabled an OEM socket for the radio."
Dikhao "✦ Disabled virtual WFD capabilities."
Dikhao "✦ Disabled various IMS logging and functionality."
Dikhao "✦ Enabled offline logging for the kernel and logcat."
Dikhao "✦ Disabled OEM-specific dumps"
Dikhao "✦ Enabled the system's sleep mode."
Dikhao "✦ Force disabled error reports and ulog."
Dikhao "✦ Disabled debugging related to display management."
Dikhao "✦ Enabled profiling for game tools."
Dikhao "✦ Disabled GPU performance mode."
Dikhao "✦ Disabled concurrent A2DP connections for FM radio."
Dikhao "✦ Disabled B-frame encoding for the video decoder."
Dikhao "✦ Disabled video decoder debugging."
Dikhao "✦ Disabled Ultra Buffer With Cache (UBWC) for video."
Dikhao "✦ Setting the systems composition type to GPU-based."
Dikhao "✦ Disabled various SurfaceFlinger display options."
Dikhao "✦ Disabled specific tags for the \"atrace\" profiling tool."
Dikhao "✦ Disabled a mechanism for killing tasks that are allocating memory excessively."
Dikhao "✦ Disabled logging for specific services."
Dikhao "✦ Disabled redirecting standard input/output to the log system."
Dikhao "✦ Disabled additional profiling features."
Dikhao "✦ Disabled StrictMode, which checks for potential performance and security issues."
Dikhao "✦ Disabled bytecode verification for the Dalvik VM, impacting security."
Dikhao "✦ Disabled debug logging for memory allocation."
Dikhao "✦ Disabled persistent caching for the A/V system."
Dikhao "✦ Disabled RAM dumps for the SSR (System Server Recovery) service."
Dikhao "✦ Disabled various log outputs related to the systems core functionality, including media playback, rendering, and audio output."
Dikhao "✦ Disabled debug-specific logging and testing"
Dikhao "✦ Disabled Memory Dump"
Dikhao "✦ Disabled CRC"
Dikhao "✦ Disabled IOSTATS"
Dikhao "✦ Disabled Tombstoned"
Dikhao "✦ Disabled Low Memory Killer"
Dikhao "✦ Disabled Dalvik"
Dikhao "✦ Disabled Blur"
Dikhao "✦ Disabled Timer Migration"
echo 0 > /proc/sys/kernel/timer_migration

# Stop/Delete Logs & Cache
show_message "DISABLING KERNEL LOGS" 1 "boxed"
sysctl -w kernel.panic=0
sysctl -w vm.panic_on_oom=0
sysctl -w kernel.panic_on_oops=0
sysctl -w vm.oom_dump_tasks=0
sysctl -w vm.oom_kill_allocating_task=0
echo "0 0 0 0" > /proc/sys/kernel/printk
echo "off" > /proc/sys/kernel/printk_devkmsg
echo "0" > /proc/sys/debug/exception-trace

show_message "OPTIMIZING STORAGE PERFORMANCE" 0.5 "boxed"
fstrim -v /cache
fstrim -v /system
fstrim -v /vendor
fstrim -v /data
fstrim -v /persist

show_message "APPLYING KERNEL LEVEL TWEAKS FOR BATTERY BACKUP" 1 "boxed"

# Action Button
setprop veloxine-install rukho
cat > "$MODPATH/action.sh" << 'EOF'
#!/bin/sh
MODDIR="${0%/*}"
chmod +x "$MODDIR/veloxine.sh"
. "$MODDIR/veloxine.sh"
EOF

# Log script
touch "/data/local/tmp/DisabledAllGoogleServices"
cat > "$MODPATH/veloxine.sh" << 'EOF'
#!/system/bin/sh
# Log file path
log_file="/sdcard/veloxineology.log"

# Function to write to the log file
log() {
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "$timestamp: $1" >> "$log_file" 2>&1
}

# Create log file if it doesn't exist.
if [ ! -f $log_file ]; then
  touch $log_file
fi

# Wait for some time before toggling services and cleaning again
if [ "$(getprop veloxine-action)" == "bro, wait." ]; then
echo "----------------------------------------------------------"
echo "WAIT FOR IT TO INITIALIZE, DO NOT SPAM THE BUTTON."
echo "----------------------------------------------------------"
am start -a android.intent.action.MAIN -e powersaver "PLEASE WAIT, DO NOT INTERRUPT." -n powersaver.pro/.MainActivity
sleep 3
exit
fi

# Nuke Logs & Cache
log " ⚡ Switching GMS mode × Starting CACHE and LOG deletion "
echo "----------------------------------------------------------"
echo "STARTING TO CLEAN & TOGGLE GMS"
echo "----------------------------------------------------------"
echo " "
sleep 0.3

echo "✦ Deleting Package Cache"
rm -rf /data/package_cache || log "Error deleting /data/package_cache: $?"
sleep 0.3

echo "✦ Deleting Dalvik Cache"
rm -rf /data/dalvik-cache || log "Error deleting /data/dalvik-cache: $?"
sleep 0.3

echo "✦ Deleting Cached Data"
rm -rf /data/cache || log "Error deleting /data/cache: $?"
sleep 0.3

echo "✦ Deleting WLAN Logs"
rm -rf /data/vendor/wlan_logs || log "Error deleting /data/vendor/wlan_logs: $?"
sleep 0.3

echo "✦ Deleting System Logs"
rm -rf /dev/log/* || log "Error deleting /dev/log/*: $?"
sleep 0.3

echo "✦ Deleting System Package Cache"
rm -rf /data/system/package_cache || log "Error deleting /data/system/package_cache: $?"
sleep 0.3

echo "✦ Deleting Thumbnail Cache"
rm -rf /data/media/0/DCIM/.thumbnails || log "Error deleting /data/media/0/DCIM/.thumbnails: $?"
rm -rf /data/media/0/Pictures/.thumbnails || log "Error deleting /data/media/0/Pictures/.thumbnails: $?"
rm -rf /data/media/0/Music/.thumbnails || log "Error deleting /data/media/0/Music/.thumbnails: $?"
rm -rf /data/media/0/Movies/.thumbnails || log "Error deleting /data/media/0/Movies/.thumbnails: $?"
sleep 0.3

echo "✦ Deleting Thermal Logs"
rm -rf /data/vendor/thermal/thermal.dump || log "Error deleting /data/vendor/thermal/thermal.dump: $?"
rm -rf /data/vendor/thermal/last_thermal.dump || log "Error deleting /data/vendor/thermal/last_thermal.dump: $?"
rm -rf /data/vendor/thermal/thermal_history.dump || log "Error deleting /data/vendor/thermal/thermal_history.dump: $?"
rm -rf /data/vendor/thermal/thermal_history_last.dump || log "Error deleting /data/vendor/thermal/thermal_history_last.dump: $?"
sleep 0.3

echo "✦ Deleting ANR Logs"
rm -rf /data/anr/* || log "Error deleting /data/anr/*: $?"
sleep 0.3

echo "✦ Deleting Dev Logs"
rm -rf /dev/log/* || log "Error deleting /dev/log/*: $?"
sleep 0.3

# Toggle Services
Kaushik="/data/local/tmp/DisabledAllGoogleServices"
if [ -f "$Kaushik" ]; then
am start -a android.intent.action.MAIN -e powersaver "GMS SHIT HAS BEEN FREEZED 🥶" -n powersaver.pro/.MainActivity
 ALL="pm disable"
 echo "--------------------------------------------------"
 echo "✦ Disabled All Unnecessary Google Services"
 sleep 0.5
 echo "|| This may break some features depends on Google. ||"
 echo "[Run action button again to Disable Safe Services]"
 sleep 1.5
 rm "$Kaushik"
 echo "--------------------------------------------------"
 sleep 0.3
else
am start -a android.intent.action.MAIN -e powersaver "GMS SHIT HAS BEEN ENABLED 🥵" -n powersaver.pro/.MainActivity
 ALL="pm enable"
 echo "--------------------------------------------------"
 echo "✦ Enabled Safe Google Services"
 sleep 0.3
 echo "|| This will not break any features depends on Google. ||"
 echo "[Run action button again to Disable All Google Services]"
 sleep 1.5
 echo "--------------------------------------------------"
 touch "$Kaushik"
 sleep 0.3
fi
(
until [ "$(getprop veloxine-action)" == "finished" -o "$(getprop veloxine-install)" == "finished" ]; do
  sleep 1
done

# Toggle All Google Services (may break features)
# Toggle the advertising and tracking capabilities of Google Play Services.
$ALL "com.google.android.gms/com.google.android.gms.ads.identifier.service.AdvertisingIdNotificationService"
$ALL "com.google.android.gms/com.google.android.gms.ads.identifier.service.AdvertisingIdService"
$ALL "com.google.android.gms/com.google.android.gms.nearby.mediums.nearfieldcommunication.NfcAdvertisingService"
 
# Restrict/Allow Google's data collection and analytics on your Android device.
$ALL "com.google.android.gms/com.google.android.gms.analytics.AnalyticsService"
$ALL "com.google.android.gms/com.google.android.gms.analytics.AnalyticsTaskService"
$ALL "com.google.android.gms/com.google.android.gms.analytics.internal.PlayLogReportingService"
$ALL "com.google.android.gms/com.google.android.gms.stats.eastworld.EastworldService"
$ALL "com.google.android.gms/com.google.android.gms.stats.service.DropBoxEntryAddedService"
$ALL "com.google.android.gms/com.google.android.gms.stats.PlatformStatsCollectorService"
$ALL "com.google.android.gms/com.google.android.gms.common.stats.GmsCoreStatsService"
$ALL "com.google.android.gms/com.google.android.gms.common.stats.StatsUploadService"
$ALL "com.google.android.gms/com.google.android.gms.backup.stats.BackupStatsService"
$ALL "com.google.android.gms/com.google.android.gms.checkin.CheckinApiService"
$ALL "com.google.android.gms/com.google.android.gms.checkin.CheckinService"
$ALL "com.google.android.gms/com.google.android.gms.tron.CollectionService"
$ALL "com.google.android.gms/com.google.android.gms.common.config.PhenotypeCheckinService"

# Toggle bug reporting functionality of gms.
$ALL "com.google.android.gms/com.google.android.gms.feedback.FeedbackAsyncService"
$ALL "com.google.android.gms/com.google.android.gms.feedback.LegacyBugReportService"
$ALL "com.google.android.gms/com.google.android.gms.feedback.OfflineReportSendTaskService"
$ALL "com.google.android.gms/com.google.android.gms.googlehelp.metrics.ReportBatchedMetricsGcmTaskService"
$ALL "com.google.android.gms/com.google.android.gms.analytics.internal.PlayLogReportingService"
$ALL "com.google.android.gms/com.google.android.gms.locationsharingreporter.service.reporting.periodic.PeriodicReporterMonitoringService"
$ALL "com.google.android.gms/com.google.android.location.reporting.service.ReportingAndroidService"
$ALL "com.google.android.gms/com.google.android.location.reporting.service.ReportingSyncService"
$ALL "com.google.android.gms/com.google.android.gms.common.stats.net.NetworkReportService"
$ALL "com.google.android.gms/com.google.android.gms.presencemanager.service.PresenceManagerPresenceReportService"
$ALL "com.google.android.gms/com.google.android.gms.usagereporting.service.UsageReportingIntentService"

# Toggle Google Cast services.
$ALL "com.google.android.gms/com.google.android.gms.cast.media.CastMediaRoute2ProviderService"
$ALL "com.google.android.gms/com.google.android.gms.cast.media.CastMediaRoute2ProviderService_Isolated"
$ALL "com.google.android.gms/com.google.android.gms.cast.media.CastMediaRoute2ProviderService_Persistent"
$ALL "com.google.android.gms/com.google.android.gms.cast.media.CastMediaRouteProviderService"
$ALL "com.google.android.gms/com.google.android.gms.cast.media.CastMediaRouteProviderService_Isolated"
$ALL "com.google.android.gms/com.google.android.gms.cast.media.CastMediaRouteProviderService_Persistent"
$ALL "com.google.android.gms/com.google.android.gms.cast.media.CastRemoteDisplayProviderService"
$ALL "com.google.android.gms/com.google.android.gms.cast.media.CastRemoteDisplayProviderService_Isolated"
$ALL "com.google.android.gms/com.google.android.gms.cast.media.CastRemoteDisplayProviderService_Persistent"
$ALL "com.google.android.gms/com.google.android.gms.cast.service.CastPersistentService_Persistent"
$ALL "com.google.android.gms/com.google.android.gms.cast.service.CastSocketMultiplexerLifeCycleService"
$ALL "com.google.android.gms/com.google.android.gms.cast.service.CastSocketMultiplexerLifeCycleService_Isolated"
$ALL "com.google.android.gms/com.google.android.gms.cast.service.CastSocketMultiplexerLifeCycleService_Persistent"
$ALL "com.google.android.gms/com.google.android.gms.chimera.CastPersistentBoundBrokerService"

# Toggle debugging services related to Google Play Services.
$ALL "com.google.android.gms/com.google.android.gms.nearby.messages.debug.DebugPokeService"
$ALL "com.google.android.gms/com.google.android.gms.clearcut.debug.ClearcutDebugDumpService"

# Toggle services related to component discovery within Google Play Services and Firebase.
$ALL "com.google.firebase.components.ComponentDiscoveryService"
$ALL "com.google.android.gms/com.google.android.gms.nearby.discovery.service.DiscoveryService"
$ALL "com.google.android.gms/com.google.mlkit.common.internal.MlKitComponentDiscoveryService"

# Toggle services related to location and time zone information.
$ALL "com.google.android.gms/com.google.android.gms.geotimezone.GeoTimeZoneService"
$ALL "com.google.android.gms/com.google.android.gms.location.geocode.GeocodeService"

# Toggle specific services related to Google Play Services, particularly those associated with authentication and account management.
$ALL "com.google.android.gms/com.google.android.gms.chimera.GmsIntentOperationService_AuthAccountIsolated"
$ALL "com.google.android.gms/com.google.android.gms.chimera.GmsIntentOperationService_AuthAccountIsolate"
$ALL "com.google.android.gms/com.google.android.gms.chimera.PersistentApiService_AuthAccountIsolated"
$ALL "com.google.android.gms/com.google.android.gms.chimera.PersistentIntentOperationService_AuthAccountIsolated"

# Toggle various background update services.
$ALL "com.google.android.gms/com.google.android.gms.auth.folsom.service.FolsomPublicKeyUpdateService"
$ALL "com.google.android.gms/com.google.android.gms.fonts.update.UpdateSchedulerService"
$ALL "com.google.android.gms/com.google.android.gms.icing.proxy.IcingInternalCorporaUpdateService"
$ALL "com.google.android.gms/com.google.android.gms.instantapps.routing.DomainFilterUpdateService"
$ALL "com.google.android.gms/com.google.android.gms.mobiledataplan.service.PeriodicUpdaterService"
$ALL "com.google.android.gms/com.google.android.gms.phenotype.service.sync.PackageUpdateTaskService"
$ALL "com.google.android.gms/com.google.android.gms.update.SystemUpdateGcmTaskService"
$ALL "com.google.android.gms/com.google.android.gms.update.SystemUpdateService"
$ALL "com.google.android.gms/com.google.android.gms.update.UpdateFromSdCardService"

# Toggle services related to smartwatches and wearables.
$ALL "com.google.android.gms/com.google.android.gms.backup.wear.BackupSettingsListenerService"
$ALL "com.google.android.gms/com.google.android.gms.dck.service.DckWearableListenerService"
$ALL "com.google.android.gms/com.google.android.gms.fitness.service.wearable.WearableSyncAccountService"
$ALL "com.google.android.gms/com.google.android.gms.fitness.service.wearable.WearableSyncConfigService"
$ALL "com.google.android.gms/com.google.android.gms.fitness.service.wearable.WearableSyncConnectionService"
$ALL "com.google.android.gms/com.google.android.gms.fitness.service.wearable.WearableSyncMessageService"
$ALL "com.google.android.gms/com.google.android.gms.fitness.wearables.WearableSyncService"
$ALL "com.google.android.gms/com.google.android.gms.wearable.service.WearableControlService"
$ALL "com.google.android.gms/com.google.android.gms.wearable.service.WearableService"
$ALL "com.google.android.gms/com.google.android.gms.nearby.fastpair.service.WearableDataListenerService"
$ALL "com.google.android.gms/com.google.android.location.wearable.WearableLocationService"
$ALL "com.google.android.gms/com.google.android.location.fused.wearable.GmsWearableListenerService"
$ALL "com.google.android.gms/com.google.android.gms.mdm.services.MdmPhoneWearableListenerService"
$ALL "com.google.android.gms/com.google.android.gms.tapandpay.wear.WearProxyService"

# Toggle services related to Trusted Agents / Find My Device
$ALL "com.google.android.gms/com.google.android.gms.auth.trustagent.GoogleTrustAgent"
$ALL "com.google.android.gms/com.google.android.gms.trustagent.api.bridge.TrustAgentBridgeService"
$ALL "com.google.android.gms/com.google.android.gms.trustagent.api.state.TrustAgentState"

# Toggle services related to enpromo"
$ALL "com.google.android.gms/com.google.android.gms.enpromo.PromoInternalPersistentService"
$ALL "com.google.android.gms/com.google.android.gms.enpromo.PromoInternalService"

# Toggle services related to emergency features and potentially child safety settings. 
$ALL "com.google.android.gms/com.google.android.gms.thunderbird.EmergencyLocationService" 
$ALL "com.google.android.gms/com.google.android.gms.thunderbird.EmergencyPersistentService"
$ALL "com.google.android.gms/com.google.android.gms.kids.chimera.KidsServiceProxy"
$ALL "com.google.android.gms/com.google.android.gms.personalsafety.service.PersonalSafetyService"

# Toggle services related to Google Fit health and fitness tracking app.
$ALL "com.google.android.gms/com.google.android.gms.fitness.cache.DataUpdateListenerCacheService"
$ALL "com.google.android.gms/com.google.android.gms.fitness.service.ble.FitBleBroker"
$ALL "com.google.android.gms/com.google.android.gms.fitness.service.config.FitConfigBroker"
$ALL "com.google.android.gms/com.google.android.gms.fitness.service.goals.FitGoalsBroker"
$ALL "com.google.android.gms/com.google.android.gms.fitness.service.history.FitHistoryBroker"
$ALL "com.google.android.gms/com.google.android.gms.fitness.service.internal.FitInternalBroker"
$ALL "com.google.android.gms/com.google.android.gms.fitness.service.proxy.FitProxyBroker"
$ALL "com.google.android.gms/com.google.android.gms.fitness.service.recording.FitRecordingBroker"
$ALL "com.google.android.gms/com.google.android.gms.fitness.service.sensors.FitSensorsBroker"
$ALL "com.google.android.gms/com.google.android.gms.fitness.service.sessions.FitSessionsBroker"
$ALL "com.google.android.gms/com.google.android.gms.fitness.sensors.sample.CollectSensorService"
$ALL "com.google.android.gms/com.google.android.gms.fitness.sync.FitnessSyncAdapterService" 
$ALL "com.google.android.gms/com.google.android.gms.fitness.sync.SyncGcmTaskService"

# Toggle services related to Google Nearby / Quick Share
$ALL "com.google.android.gms/com.google.android.gms.nearby.bootstrap.service.NearbyBootstrapService"
$ALL "com.google.android.gms/com.google.android.gms.nearby.connection.service.NearbyConnectionsAndroidService"
$ALL "com.google.android.gms/com.google.location.nearby.direct.service.NearbyDirectService"
$ALL "com.google.android.gms/com.google.android.gms.nearby.messages.service.NearbyMessagesService"

# Toggle services related to logging and data collection.
$ALL "com.google.android.gms/com.google.android.gms.analytics.internal.PlayLogReportingService"
$ALL "com.google.android.gms/com.google.android.gms.romanesco.ContactsLoggerUploadService"
$ALL "com.google.android.gms/com.google.android.gms.magictether.logging.DailyMetricsLoggerService"
$ALL "com.google.android.gms/com.google.android.gms.checkin.EventLogService"
$ALL "com.google.android.gms/com.google.android.gms.backup.component.FullBackupJobLoggerService"

# Toggle services related to security, app verification, and potentially network management.
$ALL "com.google.android.gms/com.google.android.gms.security.safebrowsing.SafeBrowsingUpdateTaskService"
$ALL "com.google.android.gms/com.google.android.gms.security.verifier.ApkUploadService"
$ALL "com.google.android.gms/com.google.android.gms.security.verifier.InternalApkUploadService"
$ALL "com.google.android.gms/com.google.android.gms.security.snet.SnetIdleTaskService"
$ALL "com.google.android.gms/com.google.android.gms.security.snet.SnetNormalTaskService"
$ALL "com.google.android.gms/com.google.android.gms.security.snet.SnetService"
$ALL "com.google.android.gms/com.google.android.gms.tapandpay.security.StorageKeyCacheService"
$ALL "com.google.android.gms/com.google.android.gms.droidguard.DroidGuardGcmTaskService"
$ALL "com.google.android.gms/com.google.android.gms.pay.security.storagekey.service.StorageKeyCacheService"

# Toggle services related to Google Pay (formerly Android Pay) & Google Wallet.
$ALL "com.google.android.gms/com.google.android.gms.tapandpay.gcmtask.TapAndPayGcmTaskService"
$ALL "com.google.android.gms/com.google.android.gms.tapandpay.globalactions.QuickAccessWalletService"
$ALL "com.google.android.gms/com.google.android.gms.tapandpay.globalactions.WalletQuickAccessWalletService"
$ALL "com.google.android.gms/com.google.android.gms.pay.gcmtask.PayGcmTaskService"
$ALL "com.google.android.gms/com.google.android.gms.pay.hce.service.PayHceService"
$ALL "com.google.android.gms/com.google.android.gms.pay.notifications.PayNotificationService"
$ALL "com.google.android.gms/com.google.android.gms.wallet.service.PaymentService"
$ALL "com.google.android.gms/com.google.android.gms.wallet.service.WalletGcmTaskService"

# Toggle services related to location (excluding essential GPS services).
$ALL "com.google.android.gms/com.google.android.gms.fitness.cache.DataUpdateListenerCacheService"
$ALL "com.google.android.gms/com.google.android.gms.fitness.sensors.sample.CollectSensorService"
$ALL "com.google.android.gms/com.google.android.gms.fitness.sync.SyncGcmTaskService"

# Toggle services related to components within Google Play Services related to Google Play Games.
$ALL "com.google.android.gms/com.google.android.gms.games.chimera.GamesSignInIntentServiceProxy"
$ALL "com.google.android.gms/com.google.android.gms.games.chimera.GamesSyncServiceNotificationProxy"
$ALL "com.google.android.gms/com.google.android.gms.games.chimera.GamesUploadServiceProxy"
$ALL "com.google.android.gms/com.google.android.gms.gp.gameservice.GameService"
$ALL "com.google.android.gms/com.google.android.gms.gp.gameservice.GameSessionService"

# Toggle services related to Google Instant Apps.
$ALL "com.google.android.gms/com.google.android.gms.chimera.GmsApiServiceNoInstantApps"
$ALL "com.google.android.gms/com.google.android.gms.chimera.PersistentApiServiceNoInstantApps"
$ALL "com.google.android.gms/com.google.android.gms.instantapps.service.InstantAppsService"
$ALL "com.google.android.gms/com.google.android.gms.chimera.UiApiServiceNoInstantApps"

## Safe Services (doesn't break anything)
# Google Play Instant Apps Services
pm disable "com.android.vending/com.google.android.fisnky.instantapps.InstantAppsLoggingService"
pm disable "com.google.android.gms/.instantapps.service.InstantAppsService"
pm disable "com.google.android.gms/com.google.android.finsky.instantapps.InstantAppsLoggingService"

# Google Work Apps Job Services
pm disable "com.google.android.apps.work.clouddpc/.base.policy.services.ReportingPartialCollectionJobService"
pm disable "com.google.android.apps.work.clouddpc/.base.policy.services.StatusReportJobService"
pm disable "com.google.android.apps.work.clouddpc/.vanilla.bugreport.jobs.RemoteBugReportJobService"

# Google Ads Services
pm disable "com.google.android.gms/.ads.AdRequestBrokerService"
pm disable "com.google.android.gms/.ads.cache.CacheBrokerService"
pm disable "com.google.android.gms/.ads.config.FlagsReceiver"
pm disable "com.google.android.gms/.ads.identifier.service.AdvertisingIdNotificationService"
pm disable "com.google.android.gms/.ads.identifier.service.AdvertisingIdService"
pm disable "com.google.android.gms/.ads.jams.NegotiationService"
pm disable "com.google.android.gms/.ads.measurement.GmpConversionTrackingBrokerService"
pm disable "com.google.android.gms/.ads.social.GcmSchedulerWakeupService"
pm disable "com.google.android.gms/.adsidentity.service.AdServicesExtDataStorageService"

# Google Analytics Services
pm disable "com.google.android.gms/.analytics.AnalyticsReceiver"
pm disable "com.google.android.gms/.analytics.AnalyticsService"
pm disable "com.google.android.gms/.analytics.AnalyticsTaskService"
pm disable "com.google.android.gms/.analytics.internal.PlayLogReportingService"
pm disable "com.google.android.gms/.analytics.service.AnalyticsService"

# Google Trust Agent Services
pm disable "com.google.android.gms/.auth.trustagent.ActiveUnlockTrustAgent"
pm disable "com.google.android.gms/.auth.trustagent.GoogleTrustAgent"

# Google Backup Services
pm disable "com.google.android.gms/.backup.component.FullBackupJobLoggerService"
pm disable "com.google.android.gms/.backup.stats.BackupStatsService"

# Google Check-in and Event Logging Services
pm disable "com.google.android.gms/.checkin.EventLogService"
pm disable "com.google.android.gms/.chimera.GmsIntentOperationService"
pm disable "com.google.android.gms/.chimera.container.logger.ExternalDebugLoggerService"
pm disable "com.google.android.gms/.common.appdoctor.LocalAppDoctorReceiver"
pm disable "com.google.android.gms/.common.stats.GmsCoreStatsService"
pm disable "com.google.android.gms/.common.stats.StatsUploadService"

# Google Feedback and Help Services
pm disable "com.google.android.gms/.feedback.LegacyBugReportService"
pm disable "com.google.android.gms/.feedback.OfflineReportSendTaskService"
pm disable "com.google.android.gms/.googlehelp.metrics.ReportBatchedMetricsGcmTaskService"

# Google Location Reporting Services
pm disable "com.google.android.gms/.location.reporting.service.GcmBroadcastReceiver"

# Magic Tether Services
pm disable "com.google.android.gms/.magictether.logging.DailyMetricsLoggerService"

# Google App Measurement Services
pm disable "com.google.android.gms/.measurement.AppMeasurementJobService"
pm disable "com.google.android.gms/.measurement.AppMeasurementReceiver"
pm disable "com.google.android.gms/.measurement.AppMeasurementService"
pm disable "com.google.android.gms/.measurement.PackageMeasurementReceiver"

# Google Contacts Logger Services
pm disable "com.google.android.gms/.romanesco.ContactsLoggerUploadService"

# Google Stats Services
pm disable "com.google.android.gms/.stats.PlatformStatsCollectorService"
pm disable "com.google.android.gms/.stats.eastworld.EastworldService"
pm disable "com.google.android.gms/.stats.service.DropBoxEntryAddedReceiver"
pm disable "com.google.android.gms/.stats.service.DropBoxEntryAddedService"

# Google Tron Services
pm disable "com.google.android.gms/.tron.AlarmReceiver"
pm disable "com.google.android.gms/.tron.CollectionService"

# Google UDC GCM Services
pm disable "com.google.android.gms/.udc.gcm.GcmBroadcastReceiver"

# Google Usage Reporting Services
pm disable "com.google.android.gms/.usagereporting.service.UsageReportingIntentService"

# Google MDM Services
pm disable "com.google.android.gms/com.google.android.gms.mdm.receivers.MdmDeviceAdminReceiver"
sleep 30
setprop veloxine-action hold
) &

if [ ! "$(getprop veloxine-install)" == "hold" ]; then
  echo "✦ Optimizing storage performance"
  fstrim -v /cache || log "Error running fstrim on /cache: $?"
  fstrim -v /system || log "Error running fstrim on /system: $?"
  fstrim -v /vendor || log "Error running fstrim on /vendor: $?"
  fstrim -v /data || log "Error running fstrim on /data: $?"
  fstrim -v /persist || log "Error running fstrim on /persist: $?"
  
  sleep 0.3
  echo "✦ Deleting Logcat Buffer"
  echo "⌛ Please wait, this may take a while..."
  logcat -c > /dev/null 2>&1 || log "Error clearing Logcat buffer: $?"
  echo " "
  dmesg -c > /dev/null 2>&1 || log "Error clearing Dmesg logs: $?"


echo " "
echo " "
echo " "
echo "⣿⣿⣿⣿⠿⠿⠿⠿⠿⠿⣿⣿⣿⣿"
echo "⣿⣿⡟⠁⣀⡀⢀⡀⠈⢹⣿⣿"
echo "⣿⡇⢀⡾⠿⡇⠸⠿⢦⢸⣿"
echo "⣿⡇⠘⠶⠶⠃⠘⠶⠶⠃⢸⣿"
echo "⣿⣧⡀⠀⠀⠀⠀⠀⠀⢀⣼⣿"
echo "⣿⣿⣷⣶⣶⣶⣶⣶⣾⣿⣿⣿"
echo " "
echo "█░█ █▀█ █▀█ █▀█ █▄█"
echo "█▀█ █▀█ █▀▀ █▀▀ █"
sleep 1
echo " "
echo "-----------------------------------------------------"
echo "✦✦ ACTION COMPLETED SUCCESSFULLY ✦✦"
echo "-----------------------------------------------------"
echo " "
echo " "
sleep 3
log "👾 GMS MODE CHANGE SUCCESSFUL"
setprop veloxine-action complete
exit 0
fi
EOF

# Make executable and Execute veloxine script
chmod +x "$MODPATH/action.sh"
chmod +x "$MODPATH/veloxine.sh"

# Create config directory and default preferences (KernelSU Next/APatch fix)
mkdir -p "$MODPATH/config"
chmod 755 "$MODPATH/config"

# Create default user preferences
{
  echo "ENABLE_GHOSTED=1"
  echo "ENABLE_LOG_DISABLE=1"
  echo "ENABLE_SYS_PROPS=1"
  echo "ENABLE_BLUR_DISABLE=0"
  echo "ENABLE_SERVICES_DISABLE=1"
  echo "ENABLE_RECEIVER_DISABLE=0"
  echo "ENABLE_PROVIDER_DISABLE=0"
  echo "ENABLE_ACTIVITY_DISABLE=0"
} > "$MODPATH/config/user_prefs"
chmod 644 "$MODPATH/config/user_prefs"

# Create default GMS categories
{
  echo "DISABLE_ADS=1"
  echo "DISABLE_TRACKING=1"
  echo "DISABLE_ANALYTICS=1"
  echo "DISABLE_REPORTING=1"
  echo "DISABLE_BACKGROUND=1"
  echo "DISABLE_UPDATE=1"
  echo "DISABLE_LOCATION=0"
  echo "DISABLE_GEOFENCE=0"
  echo "DISABLE_NEARBY=0"
  echo "DISABLE_CAST=0"
  echo "DISABLE_DISCOVERY=0"
  echo "DISABLE_SYNC=0"
  echo "DISABLE_CLOUD=0"
  echo "DISABLE_AUTH=0"
  echo "DISABLE_WALLET=0"
  echo "DISABLE_PAYMENT=0"
  echo "DISABLE_WEAR=0"
  echo "DISABLE_FITNESS=0"
} > "$MODPATH/config/gms_categories"
chmod 644 "$MODPATH/config/gms_categories"

. "$MODPATH/veloxine.sh"

ui_print "- !! Note: Magisk may crash after a few seconds"
ui_print "  but the installation will complete successfully."
sleep 3
ui_print "- Finalizing installation and redirecting"
ui_print "  to the release source in"
sleep 0.3
ui_print "- 3s "
sleep 1
ui_print "- 2s "
sleep 1
ui_print "- 1s "
sleep 1

# Redirect to Veloxineology Chat Support and Finish Installation
am start -a android.intent.action.VIEW -d https://t.me/veloxineology >/dev/null 2>&1
nohup sh -c "(
  sleep 6
  setprop veloxine-install complete
)" &