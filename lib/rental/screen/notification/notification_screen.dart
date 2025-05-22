import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sankaestay/rental/util/icon_util.dart';
import 'package:sankaestay/rental/widgets/dynamicscreen/base_screen.dart';
import 'package:sankaestay/util/constants.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data for notifications
    final List<Map<String, dynamic>> notifications = [
      {
        "title": "title",
        "message": "Text blah blah",
        "date": "11/03/2025 09:30 PM",
        "isRead": false
      },
      {
        "title": "title",
        "message": "Text blah blah",
        "date": "11/03/2025 09:30 PM",
        "isRead": false
      },
      {
        "title": "title",
        "message": "Text blah blah",
        "date": "11/03/2025 09:30 PM",
        "isRead": true
      },
      {
        "title": "title",
        "message": "Text blah blah",
        "date": "11/03/2025 09:30 PM",
        "isRead": true
      },
    ];

    return BaseScreen(
        title: "notification_screen.notification".tr,
        actionButton: Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: IconButton(
            icon: const Icon(AppIcons.menu, color: Colors.white, size: 30),
            onPressed: () {},
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.secondaryGrey,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(30),
                        topLeft: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                              child: Row(
                                children: [
                                  // Show left indicator only if the message is unread
                                  if (!notification['isRead'])
                                    Container(
                                      width: 5,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryBlue,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          bottomLeft: Radius.circular(10),
                                        ),
                                      ),
                                    ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                notification["title"],
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              Text(
                                                notification["date"],
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            notification["message"],
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
