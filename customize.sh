# shellcheck disable=SC2034
SKIPUNZIP=1

# Variables
MODNAME=`grep_prop name $MODPATH/module.prop`
MODVER=`grep_prop version $MODPATH/module.prop`
DV=`grep_prop author $MODPATH/module.prop`
Device=`getprop ro.product.device`
Model=`getprop ro.product.model`
Brand=`getprop ro.product.brand` 
Architecture=`getprop ro.product.cpu.abi`
SDK=`getprop ro.system.build.version.sdk`
Android=`getprop ro.system.build.version.release`
Type=`getprop ro.system.build.type`
Built=`getprop ro.system.build.date`
Time=$(date "+%d, %b - %H:%M %Z")

show_message() {
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
show_message "OPTIMIZING GMS SERVICES, PLEASE WAIT" 0.3 "boxed"
show_message "✦ Disabling advertising and tracking in Google Play services."
show_message "✦ Restricting Google's data collection on your device."
show_message "✦ Disabling bug reporting in Google Play services."
show_message "✦ Disabling Google Cast services."
show_message "✦ Disabling debugging services in Google Play Services."
show_message "✦ Disabling component discovery services in Google Play and Firebase."
show_message "✦ Disabling location and time zone services."
show_message "✦ Disabling various background update services."
show_message "✦ Disabling smartwatches and wearables services."
show_message "✦ Disabling Trusted Agents / Find My Device services."
show_message "✦ Disabling logging and data collection services."

# Extract module files
ui_print "- Extracting module files"
unzip -o "$ZIPFILE" 'module.prop' -d "$MODPATH" >&2
unzip -o "$ZIPFILE" 'service.sh' -d "$MODPATH" >&2
unzip -o "$ZIPFILE" 'system/bin/ghost-utils' -d "$MODPATH" >&2
unzip -o "$ZIPFILE" 'misc_optimizations.prop' -d "$MODPATH" >&2

# Extract webroot
ui_print "- Extracting webroot"
unzip -o "$ZIPFILE" "webroot/*" -d "$MODPATH" >&2

# Set configs
ui_print "- GMS Control Panel configuration setup"
# Check if data directory exists, create it if not
if [ ! -d /data/ghost ]; then
    mkdir -p /data/ghost
fi

# Extract gmslist.txt if it exists
if unzip -l "$ZIPFILE" | grep -q "gmslist.txt"; then
    unzip -o "$ZIPFILE" 'gmslist.txt' -d "/data/ghost" >&2
# For backward compatibility, also check for gamelist.txt
elif unzip -l "$ZIPFILE" | grep -q "gamelist.txt"; then
    unzip -o "$ZIPFILE" 'gamelist.txt' -d "/data/ghost" >&2
    # Rename to gmslist.txt if extracted
    if [ -f "/data/ghost/gamelist.txt" ]; then
        mv "/data/ghost/gamelist.txt" "/data/ghost/gmslist.txt"
    fi
fi

unzip -o "$ZIPFILE" 'ghost_logo.png' -d "/data/local/tmp" >&2
[ ! -f /data/ghost/kill_logd ] && echo 0 >/data/ghost/kill_logd
[ ! -f /data/ghost/misc_opt ] && echo 0 >/data/ghost/misc_opt

# Optimize System
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

# Bellavita Toast
if ! pm list packages | grep -q bellavita.toast; then
	ui_print "- Installing bellavita Toast"
	unzip -o "$ZIPFILE" 'toast.apk' -d "$TMPDIR" >&2
	pm install $TMPDIR/toast.apk >&2
	rm -f $TMPDIR/toast.apk
	if ! pm list packages | grep -q bellavita.toast; then
		ui_print "- Can't install Bellavita Toast due to selinux restrictions"
		ui_print "  Please install the app manually after installation."
	fi
fi

# PowerSaver Pro installation
if ! pm list packages | grep -q powersaver.pro; then
	ui_print "- Installing PowerSaver Pro"
	unzip -o "$ZIPFILE" 'powersaver.apk' -d "$TMPDIR" >&2
	pm install $TMPDIR/powersaver.apk >&2
	rm -f $TMPDIR/powersaver.apk
	if ! pm list packages | grep -q powersaver.pro; then
		ui_print "- Can't install PowerSaver Pro due to selinux restrictions"
		ui_print "  Please install the app manually after installation."
	fi
fi

# Permission settings
ui_print "- Permission setup"
set_perm_recursive "$MODPATH/system/bin" 0 0 0755 0755

ui_print ""
ui_print "- GMS Control Panel successfully installed! Toggle the optimization switch in the app."
ui_print "- Made with love by Kaushik."
