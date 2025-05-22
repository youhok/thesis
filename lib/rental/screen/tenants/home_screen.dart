import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sankaestay/rental/widgets/tenentwidgets/Rental_Card.dart';
import 'package:sankaestay/util/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> rooms = [
      {
        "image": "images/homerental.jpg",
        "title": "Room Rental Battambang",
        "location": "Commune, City, Province",
        "price": "\$50.0"
      },
      {
        "image": "images/homerental.jpg",
        "title": "Room Rental Battambang",
        "location": "Commune, City, Province",
        "price": "\$50.0"
      },
      {
        "image": "images/homerental.jpg",
        "title": "Room Rental Battambang",
        "location": "Commune, City, Province",
        "price": "\$50.0"
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.secondaryGrey,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 13.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            height: 155,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 6,
                                    spreadRadius: 2,
                                  ),
                                ]),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                "images/Ad-banner.png",
                                width: double.infinity,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),

                          //Near your Area Section
                           Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "home_screen.nearyourArea".tr,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          //Room List  (Near your Area)
                          _buildHorizontalRoomList(rooms),

                          const SizedBox(
                            height: 15,
                          ),
                          // Find Your Room Section

                           Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "home_screen.findyourRoom".tr,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          _buildHorizontalRoomList(rooms),

                          const SizedBox(height: 20),
                          _buildHorizontalRoomList(rooms),
                          const SizedBox(height: 20),
                        // More Button
                          Center(
                            child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 11, horizontal: 50),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child:  Text(
                                  'home_screen.more'.tr,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.secondaryBlue),
                                )),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// **Helper Method: Creates a Horizontal List of Rental Cards**
  Widget _buildHorizontalRoomList(List<Map<String, String>> rooms) {
    return SizedBox(
      height: 250,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: rooms
            .map((room) => RentalCard(
                  image: room['image'] ?? '',
                  title: room['title'] ?? 'Room Title',
                  location: room['location'] ?? 'Unknown Location',
                  price: room['price'] ?? '\$0.0',
                  onBookmarkPressed: () {
                    print("Bookmarked: ${room['title']}");
                  },
                ))
            .toList(),
      ),
    );
  }
}
