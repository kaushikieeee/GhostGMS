cat > "/data/adb/uninstall.sh" << 'EOF'
until [[ -e "/sdcard/" ]]; do
  sleep 1
done
# Enable Google Services

# Enable the advertising and tracking capabilities of Google Play Services.
pm enable "com.google.android.gms/com.google.android.gms.ads.identifier.service.AdvertisingIdNotificationService"
pm enable "com.google.android.gms/com.google.android.gms.ads.identifier.service.AdvertisingIdService"
pm enable "com.google.android.gms/com.google.android.gms.nearby.mediums.nearfieldcommunication.NfcAdvertisingService"

# Allow Google's data collection and analytics on your Android device.
pm enable "com.google.android.gms/com.google.android.gms.analytics.AnalyticsService"
pm enable "com.google.android.gms/com.google.android.gms.analytics.AnalyticsTaskService"
pm enable "com.google.android.gms/com.google.android.gms.analytics.internal.PlayLogReportingService"
pm enable "com.google.android.gms/com.google.android.gms.stats.eastworld.EastworldService"
pm enable "com.google.android.gms/com.google.android.gms.stats.service.DropBoxEntryAddedService"
pm enable "com.google.android.gms/com.google.android.gms.stats.PlatformStatsCollectorService"
pm enable "com.google.android.gms/com.google.android.gms.common.stats.GmsCoreStatsService"
pm enable "com.google.android.gms/com.google.android.gms.common.stats.StatsUploadService"
pm enable "com.google.android.gms/com.google.android.gms.backup.stats.BackupStatsService"
pm enable "com.google.android.gms/com.google.android.gms.checkin.CheckinApiService"
pm enable "com.google.android.gms/com.google.android.gms.checkin.CheckinService"
pm enable "com.google.android.gms/com.google.android.gms.tron.CollectionService"
pm enable "com.google.android.gms/com.google.android.gms.common.config.PhenotypeCheckinService"

# Enable HardwareArProviderService that eats your battery 24×7
pm enable "com.google.android.gms/com.google.android.location.internal.server.HardwareArProviderService"

# Enable bug reporting functionality of gms.
pm enable "com.google.android.gms/com.google.android.gms.feedback.FeedbackAsyncService"
pm enable "com.google.android.gms/com.google.android.gms.feedback.LegacyBugReportService"
pm enable "com.google.android.gms/com.google.android.gms.feedback.OfflineReportSendTaskService"
pm enable "com.google.android.gms/com.google.android.gms.googlehelp.metrics.ReportBatchedMetricsGcmTaskService"
pm enable "com.google.android.gms/com.google.android.gms.analytics.internal.PlayLogReportingService"
pm enable "com.google.android.gms/com.google.android.gms.locationsharingreporter.service.reporting.periodic.PeriodicReporterMonitoringService"
pm enable "com.google.android.gms/com.google.android.location.reporting.service.ReportingAndroidService"
pm enable "com.google.android.gms/com.google.android.location.reporting.service.ReportingSyncService"
pm enable "com.google.android.gms/com.google.android.gms.common.stats.net.NetworkReportService"
pm enable "com.google.android.gms/com.google.android.gms.presencemanager.service.PresenceManagerPresenceReportService"
pm enable "com.google.android.gms/com.google.android.gms.usagereporting.service.UsageReportingIntentService"

# Enable Google Cast services.
pm enable "com.google.android.gms/com.google.android.gms.cast.media.CastMediaRoute2ProviderService"
pm enable "com.google.android.gms/com.google.android.gms.cast.media.CastMediaRoute2ProviderService_Isolated"
pm enable "com.google.android.gms/com.google.android.gms.cast.media.CastMediaRoute2ProviderService_Persistent"
pm enable "com.google.android.gms/com.google.android.gms.cast.media.CastMediaRouteProviderService"
pm enable "com.google.android.gms/com.google.android.gms.cast.media.CastMediaRouteProviderService_Isolated"
pm enable "com.google.android.gms/com.google.android.gms.cast.media.CastMediaRouteProviderService_Persistent"
pm enable "com.google.android.gms/com.google.android.gms.cast.media.CastRemoteDisplayProviderService"
pm enable "com.google.android.gms/com.google.android.gms.cast.media.CastRemoteDisplayProviderService_Isolated"
pm enable "com.google.android.gms/com.google.android.gms.cast.media.CastRemoteDisplayProviderService_Persistent"
pm enable "com.google.android.gms/com.google.android.gms.cast.service.CastPersistentService_Persistent"
pm enable "com.google.android.gms/com.google.android.gms.cast.service.CastSocketMultiplexerLifeCycleService"
pm enable "com.google.android.gms/com.google.android.gms.cast.service.CastSocketMultiplexerLifeCycleService_Isolated"
pm enable "com.google.android.gms/com.google.android.gms.cast.service.CastSocketMultiplexerLifeCycleService_Persistent"
pm enable "com.google.android.gms/com.google.android.gms.chimera.CastPersistentBoundBrokerService"

# Enable debugging services related to Google Play Services.
pm enable "com.google.android.gms/com.google.android.gms.nearby.messages.debug.DebugPokeService"
pm enable "com.google.android.gms/com.google.android.gms.clearcut.debug.ClearcutDebugDumpService"

# Enable services related to component discovery within Google Play Services and Firebase.
pm enable "com.google.firebase.components.ComponentDiscoveryService"
pm enable "com.google.android.gms/com.google.android.gms.nearby.discovery.service.DiscoveryService"
pm enable "com.google.android.gms/com.google.mlkit.common.internal.MlKitComponentDiscoveryService"

# Enable services related to location and time zone information.
pm enable "com.google.android.gms/com.google.android.gms.geotimezone.GeoTimeZoneService"
pm enable "com.google.android.gms/com.google.android.gms.location.geocode.GeocodeService"

# Enable specific services related to Google Play Services, particularly those associated with authentication and account management.
pm enable "com.google.android.gms/com.google.android.gms.chimera.GmsIntentOperationService_AuthAccountIsolated"
pm enable "com.google.android.gms/com.google.android.gms.chimera.GmsIntentOperationService_AuthAccountIsolate"
pm enable "com.google.android.gms/com.google.android.gms.chimera.PersistentApiService_AuthAccountIsolated"
pm enable "com.google.android.gms/com.google.android.gms.chimera.PersistentIntentOperationService_AuthAccountIsolated"

# Enable various background update services.
pm enable "com.google.android.gms/com.google.android.gms.auth.folsom.service.FolsomPublicKeyUpdateService"
pm enable "com.google.android.gms/com.google.android.gms.fonts.update.UpdateSchedulerService"
pm enable "com.google.android.gms/com.google.android.gms.icing.proxy.IcingInternalCorporaUpdateService"
pm enable "com.google.android.gms/com.google.android.gms.instantapps.routing.DomainFilterUpdateService"
pm enable "com.google.android.gms/com.google.android.gms.mobiledataplan.service.PeriodicUpdaterService"
pm enable "com.google.android.gms/com.google.android.gms.phenotype.service.sync.PackageUpdateTaskService"
pm enable "com.google.android.gms/com.google.android.gms.update.SystemUpdateGcmTaskService"
pm enable "com.google.android.gms/com.google.android.gms.update.SystemUpdateService"
pm enable "com.google.android.gms/com.google.android.gms.update.UpdateFromSdCardService"

# Enable services related to smartwatches and wearables.
pm enable "com.google.android.gms/com.google.android.gms.backup.wear.BackupSettingsListenerService"
pm enable "com.google.android.gms/com.google.android.gms.dck.service.DckWearableListenerService"
pm enable "com.google.android.gms/com.google.android.gms.fitness.service.wearable.WearableSyncAccountService"
pm enable "com.google.android.gms/com.google.android.gms.fitness.service.wearable.WearableSyncConfigService"
pm enable "com.google.android.gms/com.google.android.gms.fitness.service.wearable.WearableSyncConnectionService"
pm enable "com.google.android.gms/com.google.android.gms.fitness.service.wearable.WearableSyncMessageService"
pm enable "com.google.android.gms/com.google.android.gms.fitness.wearables.WearableSyncService"
pm enable "com.google.android.gms/com.google.android.gms.wearable.service.WearableControlService"
pm enable "com.google.android.gms/com.google.android.gms.wearable.service.WearableService"
pm enable "com.google.android.gms/com.google.android.gms.nearby.fastpair.service.WearableDataListenerService"
pm enable "com.google.android.gms/com.google.android.location.wearable.WearableLocationService"
pm enable "com.google.android.gms/com.google.android.location.fused.wearable.GmsWearableListenerService"
pm enable "com.google.android.gms/com.google.android.gms.mdm.services.MdmPhoneWearableListenerService"
pm enable "com.google.android.gms/com.google.android.gms.tapandpay.wear.WearProxyService"

# Enable services related to Trusted Agents / Find My Device
pm enable "com.google.android.gms/com.google.android.gms.auth.trustagent.GoogleTrustAgent"
pm enable "com.google.android.gms/com.google.android.gms.trustagent.api.bridge.TrustAgentBridgeService"
pm enable "com.google.android.gms/com.google.android.gms.trustagent.api.state.TrustAgentState"

# Enable services related to enpromo"
pm enable "com.google.android.gms/com.google.android.gms.enpromo.PromoInternalPersistentService"
pm enable "com.google.android.gms/com.google.android.gms.enpromo.PromoInternalService"

# Enable services related to emergency features and potentially child safety settings. 
pm enable "com.google.android.gms/com.google.android.gms.thunderbird.EmergencyLocationService" 
pm enable "com.google.android.gms/com.google.android.gms.thunderbird.EmergencyPersistentService"
pm enable "com.google.android.gms/com.google.android.gms.kids.chimera.KidsServiceProxy"
pm enable "com.google.android.gms/com.google.android.gms.personalsafety.service.PersonalSafetyService"

# Enable services related to Google Fit health and fitness tracking app.
pm enable "com.google.android.gms/com.google.android.gms.fitness.cache.DataUpdateListenerCacheService"
pm enable "com.google.android.gms/com.google.android.gms.fitness.service.ble.FitBleBroker"
pm enable "com.google.android.gms/com.google.android.gms.fitness.service.config.FitConfigBroker"
pm enable "com.google.android.gms/com.google.android.gms.fitness.service.goals.FitGoalsBroker"
pm enable "com.google.android.gms/com.google.android.gms.fitness.service.history.FitHistoryBroker"
pm enable "com.google.android.gms/com.google.android.gms.fitness.service.internal.FitInternalBroker"
pm enable "com.google.android.gms/com.google.android.gms.fitness.service.proxy.FitProxyBroker"
pm enable "com.google.android.gms/com.google.android.gms.fitness.service.recording.FitRecordingBroker"
pm enable "com.google.android.gms/com.google.android.gms.fitness.service.sensors.FitSensorsBroker"
pm enable "com.google.android.gms/com.google.android.gms.fitness.service.sessions.FitSessionsBroker"
pm enable "com.google.android.gms/com.google.android.gms.fitness.sensors.sample.CollectSensorService"
pm enable "com.google.android.gms/com.google.android.gms.fitness.sync.FitnessSyncAdapterService" 
pm enable "com.google.android.gms/com.google.android.gms.fitness.sync.SyncGcmTaskService"

# Enable services related to Google Nearby / Quick Share
pm enable "com.google.android.gms/com.google.android.gms.nearby.bootstrap.service.NearbyBootstrapService"
pm enable "com.google.android.gms/com.google.android.gms.nearby.connection.service.NearbyConnectionsAndroidService"
pm enable "com.google.android.gms/com.google.location.nearby.direct.service.NearbyDirectService"
pm enable "com.google.android.gms/com.google.android.gms.nearby.messages.service.NearbyMessagesService"

# Enable services related to logging and data collection.
pm enable "com.google.android.gms/com.google.android.gms.analytics.internal.PlayLogReportingService"
pm enable "com.google.android.gms/com.google.android.gms.romanesco.ContactsLoggerUploadService"
pm enable "com.google.android.gms/com.google.android.gms.magictether.logging.DailyMetricsLoggerService"
pm enable "com.google.android.gms/com.google.android.gms.checkin.EventLogService"
pm enable "com.google.android.gms/com.google.android.gms.backup.component.FullBackupJobLoggerService"

# Enable services related to security, app verification, and potentially network management.
pm enable "com.google.android.gms/com.google.android.gms.security.safebrowsing.SafeBrowsingUpdateTaskService"
pm enable "com.google.android.gms/com.google.android.gms.security.verifier.ApkUploadService"
pm enable "com.google.android.gms/com.google.android.gms.security.verifier.InternalApkUploadService"
pm enable "com.google.android.gms/com.google.android.gms.security.snet.SnetIdleTaskService"
pm enable "com.google.android.gms/com.google.android.gms.security.snet.SnetNormalTaskService"
pm enable "com.google.android.gms/com.google.android.gms.security.snet.SnetService"
pm enable "com.google.android.gms/com.google.android.gms.tapandpay.security.StorageKeyCacheService"
pm enable "com.google.android.gms/com.google.android.gms.droidguard.DroidGuardGcmTaskService"
pm enable "com.google.android.gms/com.google.android.gms.pay.security.storagekey.service.StorageKeyCacheService"

# Enable services related to Google Pay (formerly Android Pay) & Google Wallet.
pm enable "com.google.android.gms/com.google.android.gms.tapandpay.gcmtask.TapAndPayGcmTaskService"
pm enable "com.google.android.gms/com.google.android.gms.tapandpay.globalactions.QuickAccessWalletService"
pm enable "com.google.android.gms/com.google.android.gms.tapandpay.globalactions.WalletQuickAccessWalletService"
pm enable "com.google.android.gms/com.google.android.gms.pay.gcmtask.PayGcmTaskService"
pm enable "com.google.android.gms/com.google.android.gms.pay.hce.service.PayHceService"
pm enable "com.google.android.gms/com.google.android.gms.pay.notifications.PayNotificationService"
pm enable "com.google.android.gms/com.google.android.gms.wallet.service.PaymentService"
pm enable "com.google.android.gms/com.google.android.gms.wallet.service.WalletGcmTaskService"

# Enable services related to location.
pm enable "com.google.android.gms/com.google.android.gms.fitness.cache.DataUpdateListenerCacheService"
pm enable "com.google.android.gms/com.google.android.gms.fitness.sensors.sample.CollectSensorService"
pm enable "com.google.android.gms/com.google.android.gms.fitness.sync.SyncGcmTaskService"
pm enable "com.google.android.gms/com.google.android.location.fused.FusedLocationService"
pm enable "com.google.android.gms/com.google.android.location.internal.server.GoogleLocationService"
pm enable "com.google.android.gms/com.google.android.location.network.NetworkLocationService"
pm enable "com.google.android.gms/com.google.android.location.persistent.LocationPersistentService"
pm enable "com.google.android.gms/com.google.android.location.reporting.service.LocationHistoryInjectorService"
pm enable "com.google.android.gms/com.google.android.location.util.LocationAccuracyInjectorService"
pm enable "com.google.android.gms/com.google.android.location.wearable.WearableLocationService"
pm enable "com.google.android.gms/com.google.android.gms.locationsharing.service.LocationSharingSettingInjectorService"
pm enable "com.google.android.gms/com.google.android.gms.locationsharing.service.LocationSharingService"
pm enable "com.google.android.gms/com.google.android.gms.semanticlocation.service.SemanticLocationService"

# Enable services related to components within Google Play Services related to Google Play Games.
pm enable "com.google.android.gms/com.google.android.gms.games.chimera.GamesSignInIntentServiceProxy"
pm enable "com.google.android.gms/com.google.android.gms.games.chimera.GamesSyncServiceNotificationProxy"
pm enable "com.google.android.gms/com.google.android.gms.games.chimera.GamesUploadServiceProxy"
pm enable "com.google.android.gms/com.google.android.gms.gp.gameservice.GameService"
pm enable "com.google.android.gms/com.google.android.gms.gp.gameservice.GameSessionService"

# Enable services related to Google Instant Apps.
pm enable "com.google.android.gms/com.google.android.gms.chimera.GmsApiServiceNoInstantApps"
pm enable "com.google.android.gms/com.google.android.gms.chimera.PersistentApiServiceNoInstantApps"
pm enable "com.google.android.gms/com.google.android.gms.instantapps.service.InstantAppsService"
pm enable "com.google.android.gms/com.google.android.gms.chimera.UiApiServiceNoInstantApps"

## Safe Services (doesn't break anything)
# Google Play Instant Apps Services
pm enable "com.android.vending/com.google.android.fisnky.instantapps.InstantAppsLoggingService"
pm enable "com.google.android.gms/.instantapps.service.InstantAppsService"
pm enable "com.google.android.gms/com.google.android.finsky.instantapps.InstantAppsLoggingService"

# Google Work Apps Job Services
pm enable "com.google.android.apps.work.clouddpc/.base.policy.services.ReportingPartialCollectionJobService"
pm enable "com.google.android.apps.work.clouddpc/.base.policy.services.StatusReportJobService"
pm enable "com.google.android.apps.work.clouddpc/.vanilla.bugreport.jobs.RemoteBugReportJobService"

# Google Ads Services
pm enable "com.google.android.gms/.ads.AdRequestBrokerService"
pm enable "com.google.android.gms/.ads.cache.CacheBrokerService"
pm enable "com.google.android.gms/.ads.config.FlagsReceiver"
pm enable "com.google.android.gms/.ads.identifier.service.AdvertisingIdNotificationService"
pm enable "com.google.android.gms/.ads.identifier.service.AdvertisingIdService"
pm enable "com.google.android.gms/.ads.jams.NegotiationService"
pm enable "com.google.android.gms/.ads.measurement.GmpConversionTrackingBrokerService"
pm enable "com.google.android.gms/.ads.social.GcmSchedulerWakeupService"
pm enable "com.google.android.gms/.adsidentity.service.AdServicesExtDataStorageService"

# Google Analytics Services
pm enable "com.google.android.gms/.analytics.AnalyticsReceiver"
pm enable "com.google.android.gms/.analytics.AnalyticsService"
pm enable "com.google.android.gms/.analytics.AnalyticsTaskService"
pm enable "com.google.android.gms/.analytics.internal.PlayLogReportingService"
pm enable "com.google.android.gms/.analytics.service.AnalyticsService"

# Google Trust Agent Services
pm enable "com.google.android.gms/.auth.trustagent.ActiveUnlockTrustAgent"
pm enable "com.google.android.gms/.auth.trustagent.GoogleTrustAgent"

# Google Backup Services
pm enable "com.google.android.gms/.backup.component.FullBackupJobLoggerService"
pm enable "com.google.android.gms/.backup.stats.BackupStatsService"

# Google Check-in and Event Logging Services
pm enable "com.google.android.gms/.checkin.EventLogService"
pm enable "com.google.android.gms/.chimera.GmsIntentOperationService"
pm enable "com.google.android.gms/.chimera.container.logger.ExternalDebugLoggerService"
pm enable "com.google.android.gms/.common.appdoctor.LocalAppDoctorReceiver"
pm enable "com.google.android.gms/.common.stats.GmsCoreStatsService"
pm enable "com.google.android.gms/.common.stats.StatsUploadService"

# Google Feedback and Help Services
pm enable "com.google.android.gms/.feedback.LegacyBugReportService"
pm enable "com.google.android.gms/.feedback.OfflineReportSendTaskService"
pm enable "com.google.android.gms/.googlehelp.metrics.ReportBatchedMetricsGcmTaskService"

# Google Location Reporting Services
pm enable "com.google.android.gms/.location.reporting.service.GcmBroadcastReceiver"

# Magic Tether Services
pm enable "com.google.android.gms/.magictether.logging.DailyMetricsLoggerService"

# Google App Measurement Services
pm enable "com.google.android.gms/.measurement.AppMeasurementJobService"
pm enable "com.google.android.gms/.measurement.AppMeasurementReceiver"
pm enable "com.google.android.gms/.measurement.AppMeasurementService"
pm enable "com.google.android.gms/.measurement.PackageMeasurementReceiver"

# Google Contacts Logger Services
pm enable "com.google.android.gms/.romanesco.ContactsLoggerUploadService"

# Google Stats Services
pm enable "com.google.android.gms/.stats.PlatformStatsCollectorService"
pm enable "com.google.android.gms/.stats.eastworld.EastworldService"
pm enable "com.google.android.gms/.stats.service.DropBoxEntryAddedReceiver"
pm enable "com.google.android.gms/.stats.service.DropBoxEntryAddedService"

# Google Tron Services
pm enable "com.google.android.gms/.tron.AlarmReceiver"
pm enable "com.google.android.gms/.tron.CollectionService"

# Google UDC GCM Services
pm enable "com.google.android.gms/.udc.gcm.GcmBroadcastReceiver"

# Google Usage Reporting Services
pm enable "com.google.android.gms/.usagereporting.service.UsageReportingIntentService"

# Google MDM Services
pm enable "com.google.android.gms/com.google.android.gms.mdm.receivers.MdmDeviceAdminReceiver"

sleep 30 
rm -rf "/data/adb/uninstall.sh"
EOF
chmod +x "/data/adb/uninstall.sh"
nohup sh -c "/data/adb/uninstall.sh" &