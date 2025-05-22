import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sankaestay/util/constants.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> bookmark = [
      {
        "title": "Room Rental Battambang",
        "address": "Commune, City, Province",
        "price": 50.0,
        "image": "images/homerental.jpg"
      },
      {
        "title": "Room Rental Battambang",
        "address": "Commune, City, Province",
        "price": 50.0,
        "image": "images/homerental.jpg"
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
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: bookmark.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "images/undraw_no-data_ig65-removebg-preview.png",
                                height: 250,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Text(
                                    "Image not found",
                                    style: TextStyle(color: Colors.grey),
                                  );
                                },
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Your Bookmark is empty",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black87),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            // Clear All button
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    // Clear bookmark logic
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: Text(
                                      "bookmark.clearAll".tr,
                                      style: TextStyle(
                                        color: AppColors.secondaryBlue,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // List of bookmarks
                            Expanded(
                              child: ListView.builder(
                                padding:
                                    EdgeInsets.zero, // Remove default padding
                                itemCount: bookmark.length,
                                itemBuilder: (context, index) {
                                  final property = bookmark[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 0),
                                    child: RoomRentalCard(property: property),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RoomRentalCard extends StatelessWidget {
  final Map<String, dynamic> property;
  const RoomRentalCard({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 0,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  property['image'],
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      property['address'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          '\$${property['price']}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Text(" | month",
                            style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon:
                    const Icon(Icons.bookmark, color: AppColors.secondaryBlue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
