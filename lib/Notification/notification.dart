import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Utils/app_colors.dart';

class NotificationModel {
  final String title;
  final String imageUrl;
  final bool isRead;

  NotificationModel({
    required this.title,
    required this.imageUrl,
    required this.isRead,
  });
}


class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {


  final List<NotificationModel> notifications = [
    NotificationModel(
      title: "New Message from John",
      imageUrl: "https://cdn-icons-png.flaticon.com/128/3602/3602145.png",
      isRead: false,
    ),
    NotificationModel(
      title: "Reminder: Meeting at 3 PM",
      imageUrl: "https://cdn-icons-png.flaticon.com/128/3602/3602145.png",
      isRead: true,
    ),
    NotificationModel(
      title: "Update Available",
      imageUrl: "https://cdn-icons-png.flaticon.com/128/3602/3602145.png",
      isRead: false,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Notification',style: TextStyle(color: Colors.white),),
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Card(
            elevation: 5,
            child: ListTile(
              leading: SizedBox(
                width: 20.sp,
                  child: Image.network(notification.imageUrl,)),
              title: Text(
                notification.title,
                style: TextStyle(
                  fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                  color: notification.isRead ? Colors.grey : Colors.black,
                ),
              ),
              trailing: notification.isRead
                  ? Icon(Icons.check, color: Colors.grey)
                  : Icon(Icons.fiber_new, color: Colors.red),
            ),
          );
        },
      ),
    );
  }
}
