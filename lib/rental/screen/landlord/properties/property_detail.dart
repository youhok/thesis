import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sankaestay/core/config/view_map_screen.dart';
import 'package:sankaestay/rental/screen/landlord/properties/rooms/rooms_with_property.dart';
import 'package:sankaestay/rental/util/icon_util.dart';
import 'package:sankaestay/rental/widgets/Feature_Tag.dart';
import 'package:sankaestay/rental/widgets/Info_Row.dart';
import 'package:sankaestay/rental/widgets/Section_Title.dart';
import 'package:sankaestay/rental/widgets/dynamicscreen/base_screen.dart';
import 'package:sankaestay/rental/widgets/image_slide.dart';
import 'package:sankaestay/util/constants.dart';



class PropertyDetailScreen extends StatelessWidget {
  const PropertyDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    LatLng roomLocation = const LatLng(13.0957, 103.2022);
    return BaseScreen(
      title: "property_detail.title".tr, 
      child:  Stack(
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
                                      color: AppColors.primaryBlue),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(Iconsax.location,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 5),
                                    Text("#105 Group 04 Commune, City",
                                        style:
                                            TextStyle(color: Colors.grey[600])),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                InfoRow(
                                    icon: AppIcons.home,
                                    label: "property_detail.property_id".tr,
                                    value: ": BTB1241"),
                                InfoRow(
                                    icon: Icons.meeting_room,
                                    label: "property_detail.rooms".tr,
                                    value: "        : 10"),
                                const SizedBox(height: 10),
                                const Text(
                                  "50.0 \$ / month",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red),
                                ),
                                const SizedBox(height: 20),
                                _buildUtilityInfo(),
                                const SizedBox(height: 20),
                                SectionTitle(title: "property_detail.description".tr),
                                const Text(
                                  "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                                const SizedBox(height: 20),
                                SectionTitle(title: "property_detail.room_feature".tr),
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
                                SectionTitle(title: "property_detail.location_on_map".tr),
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
                          _buildActionButtons(context),
                                      
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
            label: "property_detail.utilities.electricity".tr,
            value: ":0.35     \$ / kWh"),
        InfoRow(
            icon: AppIcons.water,
            label: "property_detail.utilities.water".tr,
            value: "       :0.35     \$ / m³"),
        InfoRow(
            icon: AppIcons.delete,
            label: "property_detail.utilities.garbage".tr,
            value: "  :0           \$ / month"),
        InfoRow(
            icon: AppIcons.internet,
            label: "property_detail.utilities.internet".tr,
            value: "   :0           \$ / month"),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Delete Button
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: Colors.red.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child:  Text(
              "property_detail.delete_property".tr,
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          // View As & Manage Rooms Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("property_detail.edit".tr,
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoomsWithProperty(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:  Text("property_detail.manage_rooms".tr,
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
