import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:sankaestay/util/constants.dart';

class ViewMapScreen extends StatelessWidget {
  final LatLng location;

  const ViewMapScreen({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Ensures the body extends behind the AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Makes the AppBar transparent
        elevation: 0, // Removes shadow
        shadowColor: Colors.transparent, // Ensures no shadow
        // title: const Text(
        //   'Room Locations',
        //   style: TextStyle(
        //     color: Colors.black,
        //     fontSize: 20,
        //     fontWeight: FontWeight.bold,
        //   ),
        // ),
        centerTitle: true, // Centers the title
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: location,
              zoom: 16,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('roomLocation'),
                position: location,
                infoWindow: const InfoWindow(title: "Room Rental"),
              ),
            },
          ),
        ],
      ),
    );
  }
}
