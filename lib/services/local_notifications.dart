import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Local notification helper (Android & iOS-ready)
class LocalNotifs {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  /// Call once at app startup
  static Future<void> ensureInitialized() async {
    // Timezone
    tz.initializeTimeZones();

    // Android init (uses default launcher icon)
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS init (request permissions up front)
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );
  }

  /// Schedule a daily reminder at [hour]:[minute] local time.
  static Future<void> scheduleDailyAt({
    required int hour,
    required int minute,
  }) async {
    final tzNow = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      tzNow.year,
      tzNow.month,
      tzNow.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(tzNow)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'workout', // channel id
      'Workout Reminders', // channel name
      channelDescription: 'Daily reminder to log/do a workout',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    await _plugin.zonedSchedule(
      1001, // id
      'Workout Reminder',
      'Time to log your workout!',
      scheduled,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Optional helpers
  static Future<void> cancelAll() => _plugin.cancelAll();

  static Future<bool?>? areNotificationsEnabled() =>
      _plugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled();
}
