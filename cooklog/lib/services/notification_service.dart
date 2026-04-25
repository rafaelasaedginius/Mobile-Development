import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'cooklog_channel',
          channelName: 'CookLog Notifications',
          channelDescription: 'Notifications from CookLog',
          importance: NotificationImportance.High,
          defaultColor: const Color(0xFFE8733A),
          ledColor: const Color(0xFFE8733A),
        ),
      ],
    );
  }

  Future<void> requestPermission() async {
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'cooklog_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  Future<void> showExportNotification() async {
    await showNotification(
      id: 1,
      title: 'Recipe Exported',
      body: 'Your recipe has been exported successfully!',
    );
  }

  Future<void> showRecipeAddedNotification(String recipeName) async {
    await showNotification(
      id: 2,
      title: 'Recipe Added',
      body: '$recipeName has been added to your cookbook!',
    );
  }
}