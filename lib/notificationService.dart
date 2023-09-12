import 'package:flutter_local_notifications/flutter_local_notifications.dart';

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,onDidReceiveNotificationResponse: (NotificationResponse notificationResponse){
      hideNotification();
      persistNotification();
    });
  }

  Future<void> persistNotification()async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
        'my_channel_id_1',
        'My Channel 1',
        importance: Importance.max,
        priority: Priority.high,
        ongoing: true,
        showWhen: false,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
        1,
        'EstoiClock esta funcionando',
        'EstoiClock te esta ayudando a cuidar tu tiempo',
        notificationDetails);

  }
  Future<void> showNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'my_channel_id_1',
      'My Channel 1',
      channelDescription: 'Descioptionnnnn',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
        1,
        'EstoiClock esta funcionando',
        'EstoiClock te esta ayudando a cuidar tu tiempo',
        notificationDetails);
  }

  Future<void> hideNotification() async {
    await flutterLocalNotificationsPlugin.cancel(1);
  }

