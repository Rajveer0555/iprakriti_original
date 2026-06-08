import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationPreferenceKeys {
  static const dailyHealthTip = 'notification_daily_health_tip';
  static const reassessmentReminder = 'notification_reassessment_reminder';
  static const productUpdates = 'notification_product_updates';
  static const dailyHealthTipHour = 'notification_daily_health_tip_hour';
  static const dailyHealthTipMinute = 'notification_daily_health_tip_minute';
  static const reassessmentReminderHour =
      'notification_reassessment_reminder_hour';
  static const reassessmentReminderMinute =
      'notification_reassessment_reminder_minute';
  static const reassessmentReminderWeekday =
      'notification_reassessment_reminder_weekday';
  static const productUpdatesHour = 'notification_product_updates_hour';
  static const productUpdatesMinute = 'notification_product_updates_minute';
  static const productUpdatesWeekday = 'notification_product_updates_weekday';
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const _dailyHealthTipId = 2001;
  static const _reassessmentReminderId = 2002;
  static const _productUpdatesId = 2003;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool _timeZonesInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(initializationSettings);
    await _configureLocalTimeZone();
    _isInitialized = true;
  }

  Future<void> syncWithStoredPreferences() async {
    await initialize();
    final prefs = await SharedPreferences.getInstance();
    await _applyPreferences(
      dailyHealthTips:
          prefs.getBool(NotificationPreferenceKeys.dailyHealthTip) ?? true,
      reassessmentReminder:
          prefs.getBool(NotificationPreferenceKeys.reassessmentReminder) ?? true,
      productUpdates:
          prefs.getBool(NotificationPreferenceKeys.productUpdates) ?? true,
      prefs: prefs,
    );
  }

  Future<void> updatePreference({
    required String key,
    required bool value,
  }) async {
    await initialize();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    await _ensureStoredScheduleDefaults(prefs, toggledKey: key, toggledValue: value);
    await _syncFromPrefs(prefs);
  }

  Future<void> updateReminderTime({
    required String reminderKey,
    required int hour,
    required int minute,
  }) async {
    await initialize();
    final prefs = await SharedPreferences.getInstance();
    final schedule = _scheduleForPreference(reminderKey);
    if (schedule == null) {
      return;
    }

    await prefs.setInt(schedule.hourKey, hour);
    await prefs.setInt(schedule.minuteKey, minute);
    if (schedule.weekdayKey != null && !prefs.containsKey(schedule.weekdayKey!)) {
      await prefs.setInt(schedule.weekdayKey!, DateTime.now().weekday);
    }
    await _syncFromPrefs(prefs);
  }

  TimeOfDayValue getStoredTime({
    required SharedPreferences prefs,
    required String reminderKey,
  }) {
    final schedule = _scheduleForPreference(reminderKey);
    if (schedule == null) {
      return const TimeOfDayValue(hour: 9, minute: 0);
    }

    return TimeOfDayValue(
      hour: prefs.getInt(schedule.hourKey) ?? schedule.defaultHour,
      minute: prefs.getInt(schedule.minuteKey) ?? schedule.defaultMinute,
    );
  }

  Future<void> _syncFromPrefs(SharedPreferences prefs) async {
    await _applyPreferences(
      dailyHealthTips:
          prefs.getBool(NotificationPreferenceKeys.dailyHealthTip) ?? true,
      reassessmentReminder:
          prefs.getBool(NotificationPreferenceKeys.reassessmentReminder) ?? true,
      productUpdates:
          prefs.getBool(NotificationPreferenceKeys.productUpdates) ?? true,
      prefs: prefs,
    );
  }

  Future<void> _applyPreferences({
    required bool dailyHealthTips,
    required bool reassessmentReminder,
    required bool productUpdates,
    required SharedPreferences prefs,
  }) async {
    // BUG #2 FIX: The original expression used a complex short-circuit that
    // was hard to reason about and evaluated permission only when at least one
    // toggle was true, but the logic was expressed as:
    //   !(a || b || c) || await _requestPermissionsIfNeeded()
    // which is equivalent to:
    //   (none enabled) → skip permission + cancel all
    //   (any enabled)  → request permission
    // That's actually logically correct but was confusing and error-prone.
    // Rewritten below with explicit branching so intent is clear and auditable:

    final anyEnabled = dailyHealthTips || reassessmentReminder || productUpdates;

    if (!anyEnabled) {
      // No notifications wanted — cancel everything without asking for permission.
      await cancelAllScheduled();
      return;
    }

    // At least one notification type is enabled — request permission now.
    // This is called AFTER the app is rendered (see main.dart fix), so the
    // Android Activity is alive and the system dialog can appear properly.
    final hasPermission = await _requestPermissionsIfNeeded();

    if (!hasPermission) {
      // User denied — cancel any previously scheduled notifications.
      await cancelAllScheduled();
      return;
    }

    // Schedule / cancel each type individually based on user preference.
    if (dailyHealthTips) {
      final time = getStoredTime(
        prefs: prefs,
        reminderKey: NotificationPreferenceKeys.dailyHealthTip,
      );
      await _plugin.zonedSchedule(
        _dailyHealthTipId,
        'Daily health tip',
        'Take a moment for mindful hydration, movement, and balanced meals today.',
        _nextDailyInstance(time),
        _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } else {
      await _plugin.cancel(_dailyHealthTipId);
    }

    if (reassessmentReminder) {
      final time = getStoredTime(
        prefs: prefs,
        reminderKey: NotificationPreferenceKeys.reassessmentReminder,
      );
      final weekday =
          prefs.getInt(NotificationPreferenceKeys.reassessmentReminderWeekday) ??
          DateTime.now().weekday;
      await _plugin.zonedSchedule(
        _reassessmentReminderId,
        'Reassessment reminder',
        'Check in with your latest Prakruti changes and refresh your profile when needed.',
        _nextWeeklyInstance(time, weekday),
        _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } else {
      await _plugin.cancel(_reassessmentReminderId);
    }

    if (productUpdates) {
      final time = getStoredTime(
        prefs: prefs,
        reminderKey: NotificationPreferenceKeys.productUpdates,
      );
      final weekday =
          prefs.getInt(NotificationPreferenceKeys.productUpdatesWeekday) ??
          DateTime.now().weekday;
      await _plugin.zonedSchedule(
        _productUpdatesId,
        'Product updates',
        'See what is new in IPrakriti, including fresh features and wellness improvements.',
        _nextWeeklyInstance(time, weekday),
        _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } else {
      await _plugin.cancel(_productUpdatesId);
    }
  }

  Future<bool> _requestPermissionsIfNeeded() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final iosPlugin =
        _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final macosPlugin =
        _plugin.resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();

    final androidGranted = await androidPlugin?.requestNotificationsPermission();
    final iosGranted = await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    final macosGranted = await macosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    // null means the platform plugin is not present — treat as granted.
    return (androidGranted ?? true) &&
        (iosGranted ?? true) &&
        (macosGranted ?? true);
  }

  Future<void> cancelAllScheduled() async {
    await initialize();
    await _plugin.cancel(_dailyHealthTipId);
    await _plugin.cancel(_reassessmentReminderId);
    await _plugin.cancel(_productUpdatesId);
  }

  Future<void> _configureLocalTimeZone() async {
    if (_timeZonesInitialized) {
      return;
    }

    tz_data.initializeTimeZones();
    try {
      final timezoneIdentifier = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneIdentifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
    _timeZonesInitialized = true;
  }

  Future<void> _ensureStoredScheduleDefaults(
    SharedPreferences prefs, {
    required String toggledKey,
    required bool toggledValue,
  }) async {
    if (!toggledValue) {
      return;
    }

    final schedule = _scheduleForPreference(toggledKey);
    if (schedule == null) {
      return;
    }

    if (!prefs.containsKey(schedule.hourKey)) {
      await prefs.setInt(schedule.hourKey, schedule.defaultHour);
    }
    if (!prefs.containsKey(schedule.minuteKey)) {
      await prefs.setInt(schedule.minuteKey, schedule.defaultMinute);
    }
    if (schedule.weekdayKey != null && !prefs.containsKey(schedule.weekdayKey!)) {
      await prefs.setInt(schedule.weekdayKey!, DateTime.now().weekday);
    }
  }

  _ReminderSchedule? _scheduleForPreference(String reminderKey) {
    switch (reminderKey) {
      case NotificationPreferenceKeys.dailyHealthTip:
        return const _ReminderSchedule(
          hourKey: NotificationPreferenceKeys.dailyHealthTipHour,
          minuteKey: NotificationPreferenceKeys.dailyHealthTipMinute,
          defaultHour: 9,
          defaultMinute: 0,
        );
      case NotificationPreferenceKeys.reassessmentReminder:
        return const _ReminderSchedule(
          hourKey: NotificationPreferenceKeys.reassessmentReminderHour,
          minuteKey: NotificationPreferenceKeys.reassessmentReminderMinute,
          weekdayKey: NotificationPreferenceKeys.reassessmentReminderWeekday,
          defaultHour: 10,
          defaultMinute: 0,
        );
      case NotificationPreferenceKeys.productUpdates:
        return const _ReminderSchedule(
          hourKey: NotificationPreferenceKeys.productUpdatesHour,
          minuteKey: NotificationPreferenceKeys.productUpdatesMinute,
          weekdayKey: NotificationPreferenceKeys.productUpdatesWeekday,
          defaultHour: 11,
          defaultMinute: 0,
        );
    }
    return null;
  }

  tz.TZDateTime _nextDailyInstance(TimeOfDayValue time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  tz.TZDateTime _nextWeeklyInstance(TimeOfDayValue time, int weekday) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    while (scheduled.weekday != weekday || !scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  NotificationDetails get _notificationDetails => const NotificationDetails(
    android: AndroidNotificationDetails(
      'iprakriti_reminders',
      'IPrakriti reminders',
      channelDescription: 'Personalized reminder notifications from IPrakriti',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    ),
    iOS: DarwinNotificationDetails(),
  );
}

class TimeOfDayValue {
  const TimeOfDayValue({required this.hour, required this.minute});

  final int hour;
  final int minute;
}

class _ReminderSchedule {
  const _ReminderSchedule({
    required this.hourKey,
    required this.minuteKey,
    required this.defaultHour,
    required this.defaultMinute,
    this.weekdayKey,
  });

  final String hourKey;
  final String minuteKey;
  final String? weekdayKey;
  final int defaultHour;
  final int defaultMinute;
}
