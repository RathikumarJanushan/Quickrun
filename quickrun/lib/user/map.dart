import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapPage extends StatefulWidget {
  const GoogleMapPage({super.key});

  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  static const hospital = LatLng(9.31606, 80.704);
  static const hospital2 = LatLng(9.3175, 80.7110);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: hospital,
            zoom: 13,
          ),
          markers: {
            const Marker(
              markerId: MarkerId('sourceLocation'),
              icon: BitmapDescriptor.defaultMarker,
              position: hospital,
            ),
            const Marker(
              markerId: MarkerId('destionationLocation'),
              icon: BitmapDescriptor.defaultMarker,
              position: hospital2,
            )
          },
        ),
      );
}
