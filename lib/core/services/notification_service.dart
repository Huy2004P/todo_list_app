import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_10y.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../domain/entities/todo_entity.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool get _isSupportedPlatform =>
      Platform.isAndroid ||
      Platform.isIOS ||
      Platform.isMacOS ||
      Platform.isLinux;

  Future<void> init() async {
    // Initialize timezone
    tz.initializeTimeZones();

    if (!_isSupportedPlatform) {
      print(
        'ℹ️ NotificationService: Thông báo không hỗ trợ trên nền tảng này.',
      );
      return;
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Xử lý khi nhấn vào thông báo
        },
      );
    } catch (e) {
      print('❌ Lỗi khởi tạo NotificationService: $e');
    }
  }

  Future<bool> requestPermissions() async {
    if (!_isSupportedPlatform) return false;

    try {
      final bool? androidGranted = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();

      final bool? iosGranted = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      return (androidGranted ?? false) || (iosGranted ?? false);
    } catch (e) {
      print('❌ Lỗi yêu cầu quyền thông báo: $e');
      return false;
    }
  }

  Future<void> scheduleNotification(TodoEntity todo, int minutesBefore) async {
    if (!_isSupportedPlatform) return;
    if (todo.dueDate == null) return;

    final scheduleTime = todo.dueDate!.subtract(
      Duration(minutes: minutesBefore),
    );
    if (scheduleTime.isBefore(DateTime.now())) {
      // Nếu thời gian lên lịch đã qua, không lên lịch nữa
      return;
    }

    // Hủy notification cũ nếu có để tránh trùng
    await cancelNotification(todo.id);

    final tz.TZDateTime tzScheduleTime = tz.TZDateTime.from(
      scheduleTime,
      tz.local,
    );

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'todo_reminders_channel',
          'Reminders',
          channelDescription: 'Channel for Todo reminders',
          importance: Importance.max,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final notificationMessage = minutesBefore == 0
        ? 'Đã đến hạn thực hiện việc này!'
        : 'Sắp đến hạn: Còn $minutesBefore phút!';

    try {
      await _notificationsPlugin.zonedSchedule(
        todo.id, // Sử dụng ID của todo làm ID thông báo
        todo.title,
        todo.description?.isNotEmpty == true
            ? todo.description
            : notificationMessage,
        tzScheduleTime,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      print('❌ Lỗi khi lên lịch thông báo: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    if (!_isSupportedPlatform) return;
    try {
      await _notificationsPlugin.cancel(id);
    } catch (e) {
      print('❌ Lỗi khi hủy thông báo: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    if (!_isSupportedPlatform) return;
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      print('❌ Lỗi khi hủy tất cả thông báo: $e');
    }
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_isSupportedPlatform) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'todo_instant_channel',
      'Instant Alerts',
      channelDescription: 'Channel for instant alert notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notificationsPlugin.show(id, title, body, platformDetails);
    } catch (e) {
      print('❌ Lỗi khi hiển thị thông báo tức thời: $e');
    }
  }
}
