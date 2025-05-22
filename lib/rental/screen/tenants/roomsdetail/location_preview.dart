import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sankaestay/core/config/view_map_screen.dart';
import 'package:sankaestay/rental/util/icon_util.dart';
import 'package:sankaestay/rental/widgets/Contact_Owner_Card.dart';
import 'package:sankaestay/rental/widgets/Feature_Tag.dart';
import 'package:sankaestay/rental/widgets/Info_Row.dart';
import 'package:sankaestay/rental/widgets/Section_Title.dart';
import 'package:sankaestay/rental/widgets/dynamicscreen/base_screen.dart';
import 'package:sankaestay/rental/widgets/image_slide.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sankaestay/util/constants.dart';

class LocationPreview extends StatelessWidget {
  const LocationPreview({super.key});

  @override
  Widget build(BuildContext context) {
    LatLng roomLocation = const LatLng(13.0957, 103.2022);
    return BaseScreen(
      title: "location_preview.roomDetails".tr,
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ImageCarousel(
                            imagePaths: [
                              "images/homerental.jpg",
                              "images/homerental2.jpg",
                              "images/homerental3.jpg",
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Room Rental Battambang",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(Iconsax.location,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 5),
                                    Text(
                                      "#105 Group 04 Commune, City",
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "50.0 \$ / month",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildUtilityInfo(),
                                const SizedBox(height: 20),
                                SectionTitle(title: "location_preview.descriptionTitle".tr),
                                const Text(
                                  "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                                const SizedBox(height: 20),
                                SectionTitle(title: "location_preview.roomFeature".tr),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    FeatureTag(
                                        icon: Icons.bed, label: "1 Bedroom"),
                                    FeatureTag(
                                        icon: Icons.bathtub,
                                        label: "1 Bathroom"),
                                    FeatureTag(
                                        icon: Icons.square_foot,
                                        label: "3 × 4 m"),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                SectionTitle(title: "location_preview.locationOnMap".tr),
                                const SizedBox(height: 15),
                                GestureDetector(
                                  onTap: () {
                                    debugPrint(
                                        "Map tapped! Opening full screen..."); // Debugging log
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ViewMapScreen(
                                            location: roomLocation),
                                      ),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Stack(
                                      children: [
                                        SizedBox(
                                          height: 150,
                                          width: double.infinity,
                                          child: IgnorePointer(
                                            // Ensures InkWell detects taps
                                            child: GoogleMap(
                                              initialCameraPosition:
                                                  CameraPosition(
                                                target: roomLocation,
                                                zoom: 14,
                                              ),
                                              markers: {
                                                Marker(
                                                  markerId: const MarkerId(
                                                      'roomLocation'),
                                                  position: roomLocation,
                                                  infoWindow: const InfoWindow(
                                                      title: "Room Rental"),
                                                ),
                                              },
                                              zoomControlsEnabled: false,
                                              scrollGesturesEnabled:
                                                  false, // Disable scrolling
                                              tiltGesturesEnabled: false,
                                              rotateGesturesEnabled: false,
                                            ),
                                          ),
                                        ),
                                        Positioned.fill(
                                          child: Container(
                                            color: Colors
                                                .transparent, // Allows taps to pass through
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ContactOwnerCard(
                            ownerName: "Borenn Morm",
                            phoneNumber: "0971264873",
                            onCall: () {
                              // Handle call action
                            },
                            onMessage: () {
                              // Handle message action
                            },
                            onBookNow: () {
                              // Handle book now action
                            },
                          )
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

  Widget _buildUtilityInfo() {
    return Column(
      children: [
        InfoRow(
            icon: AppIcons.electricity,
            label: "location_preview.electricity".tr,
            value: ":0.35     \$ / kWh"),
        InfoRow(
            icon: AppIcons.water,
            label: "location_preview.water".tr,
            value: "       :0.35     \$ / m³"),
        InfoRow(
            icon: AppIcons.delete,
            label: "location_preview.garbage".tr,
            value: "  :0           \$ / month"),
        InfoRow(
            icon: AppIcons.internet,
            label: "location_preview.internet".tr,
            value: "   :0           \$ / month"),
      ],
    );
  }
}
