import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class CustomGoogleMap extends StatefulWidget {
  final LatLng initialLocation;
  final bool allowSelection;
  final Function(LatLng)? onLocationSelected;
  final Set<Marker>? markers; // Accept markers

  const CustomGoogleMap({
    super.key,
    required this.initialLocation,
    this.allowSelection = false,
    this.onLocationSelected,
    this.markers, // Add markers
  });

  @override
  State<CustomGoogleMap> createState() => _CustomGoogleMapState();
}

class _CustomGoogleMapState extends State<CustomGoogleMap> {
  final Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: widget.initialLocation,
        zoom: 15.0,
      ),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      onTap: widget.allowSelection
          ? (LatLng location) {
              widget.onLocationSelected?.call(location);
            }
          : null,
      markers: widget.markers ?? {}, // Pass markers here
      myLocationEnabled: widget.allowSelection,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: true,
      mapToolbarEnabled: true,
      compassEnabled: true,
      buildingsEnabled: false,
      tiltGesturesEnabled: false,
    );
  }
}
