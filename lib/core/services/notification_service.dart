import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          if (kDebugMode) {
            print('Notifikasi ditekan: ${response.payload}');
          }
        },
      );

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('Gagal inisialisasi notifikasi lokal: $e');
      }
    }
  }

  /// Meminta izin notifikasi (wajib di Android 13+)
  Future<bool> requestPermissions() async {
    try {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final granted =
            await androidImplementation.requestNotificationsPermission();
        return granted ?? false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error meminta izin notifikasi: $e');
      }
    }
    return false;
  }

  /// Menjadwalkan Pengingat Murajaah Harian
  Future<void> scheduleDailyMurajaahReminder({
    required int hour,
    required int minute,
  }) async {
    try {
      await cancelMurajaahReminder();

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // Jika waktu sudah lewat hari ini, jadwalkan untuk besok
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'murajaah_reminder_channel',
        'Pengingat Murajaah Harian',
        channelDescription:
            'Pengingat untuk mengulang dan menjaga hafalan Al-Qur''an.',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const NotificationDetails platformDetails =
          NotificationDetails(android: androidDetails);

      await _notificationsPlugin.zonedSchedule(
        1001, // ID notifikasi murajaah
        'Waktunya Murajaah! 📖',
        'Jaga hafalanmu hari ini dengan mengulang sedikit demi sedikit.',
        scheduledDate,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Mengulang setiap hari pada jam yang sama
      );

      if (kDebugMode) {
        print('Pengingat murajaah berhasil dijadwalkan pada $hour:$minute');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Gagal menjadwalkan notifikasi: $e');
      }
    }
  }

  /// Membatalkan Pengingat Murajaah
  Future<void> cancelMurajaahReminder() async {
    try {
      await _notificationsPlugin.cancel(1001);
    } catch (e) {
      if (kDebugMode) {
        print('Gagal membatalkan notifikasi: $e');
      }
    }
  }
}
