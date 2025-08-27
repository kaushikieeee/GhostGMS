#!/system/bin/sh

# Tombstoned
resetprop -n tombstoned.max_tombstone_count 0

# Low Memory Killer
resetprop -n ro.lmk.debug false
resetprop -n ro.lmk.log_stats false

# Dalvik
resetprop -n dalvik.vm.check-dex-sum false
resetprop -n dalvik.vm.checkjni false
resetprop -n dalvik.vm.dex2oat-minidebuginfo false
resetprop -n dalvik.vm.minidebuginfo false
resetprop -n dalvik.vm.verify-bytecode false

# Disable Blur
resetprop -n disableBlurs true
resetprop -n enable_blurs_on_windows 0
resetprop -n ro.launcher.blur.appLaunch 0
resetprop -n ro.sf.blurs_are_expensive 0
resetprop -n ro.surface_flinger.supports_background_blur 0