import 'package:firebase_cloud_messaging/notification_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import 'main.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  static const String myHomePage = "myHomePage";

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    initializeNotifications();

    super.initState();

    // When app is in foreground and a notification arrives

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher',
              ),
            ));
      }
    });

    // When the app is in background or terminated state, and user click on the notification

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Background notification is tapped');
      final notification = message.notification;
      final android = message.notification?.android;
      if (notification != null && android != null) {
        Navigator.of(context).pushNamed(NotificationPage.notificationPage,
            arguments: [notification.title, notification.body]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Flutter Push Notification',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade300,
      ),
      body: Container(
        margin: const EdgeInsets.all(15),
        child: const SingleChildScrollView(
          child: Column(
            children: [],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blue.shade300,
        child: const Icon(Icons.add),
      ),
    );
  }

  void initializeNotifications() async {
    var status = await Permission.notification.status;
    if (status.isDenied) {
      showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Warning'),
              content: const Text(
                  'Your notification permission is restricted. Kindly enable your notification permission.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Ok'),
                  onPressed: () async {
                    await openAppSettings();
                  },
                ),
              ],
            );
          });
    } else {
      print("Notifications are enabled");
    }
  }
}
