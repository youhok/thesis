import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sankaestay/core/config/custom_google_map.dart';
import 'package:sankaestay/rental/widgets/Custom_button.dart';
import 'package:sankaestay/rental/widgets/image_slide.dart';
import 'package:sankaestay/util/constants.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng initialLocation = const LatLng(37.7749, -122.4194);
  Set<Marker> _markers = {};

  final List<Map<String, dynamic>> houseLocations = [
    {
      "location": LatLng(37.7749, -122.4194),
      "title": "Room Rental Battambang",
      "localtitle": "Commune, City, Province",
      "price": 50,
      "images": [
        "images/homerental.jpg",
        "images/homerental2.jpg",
        "images/homerental3.jpg"
      ]
    },
    {
      "location": LatLng(37.7785, -122.4175),
      "title": "Cozy Apartment",
      "localtitle": "Commune, City, Province",
      "price": 75,
      "images": [
        "images/homerental.jpg",
        "images/homerental2.jpg",
        "images/homerental3.jpg"
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  void _loadMarkers() {
    setState(() {
      _markers = houseLocations.map((house) {
        return Marker(
          markerId: MarkerId(house['title']),
          position: house['location'],
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          onTap: () => _onMarkerTapped(house),
        );
      }).toSet();
    });
  }

  void _onMarkerTapped(Map<String, dynamic> house) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _buildHouseDetails(house);
      },
    );
  }

  Widget _buildHouseDetails(Map<String, dynamic> house) {
    List<String> imagePaths = List<String>.from(
        house['images']); // Convert dynamic list to List<String>

    return Padding(
      padding: const EdgeInsets.all(26.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Use ImageCarousel here
          ImageCarousel(imagePaths: imagePaths),

          const SizedBox(height: 10),
          Text(house['title'],
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(house['localtitle'],
              style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 5),
          Text("${house['price']} \$ / month",
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
           Text("map_screen.description".tr,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text(
              "Lorem Ipsum is simply dummy text of the printing industry."),
          const SizedBox(height: 10),
          Custombutton(onPressed: () {}, text: "map_screen.view_more".tr),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  child: CustomGoogleMap(
                    initialLocation: initialLocation,
                    allowSelection: true,
                    markers: _markers, // Pass markers to the map
                    onLocationSelected: (LatLng newLocation) {
                      print("New location selected: $newLocation");
                    },
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 25,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration:  InputDecoration(
                  hintText: "map_screen.placeholder".tr,
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                print("GPS Button Pressed");
              },
              backgroundColor: Colors.white,
              shape: const CircleBorder(),
              elevation: 5,
              child: const Icon(Icons.my_location, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
