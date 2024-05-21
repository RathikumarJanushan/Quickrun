import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  String locationMessage = "Press the button to get location";
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          locationMessage = "Location permissions are denied";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        locationMessage =
            "Location permissions are permanently denied, we cannot request permissions.";
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      locationMessage =
          "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
    });

    saveLocationToFirestore(position);
  }

  void saveLocationToFirestore(Position position) async {
    User? user = _auth.currentUser;
    if (user != null) {
      String uid = user.uid;

      await FirebaseFirestore.instance.collection('locations').doc(uid).set({
        'latitude': position.latitude,
        'longitude': position.longitude,
      });

      setState(() {
        locationMessage =
            "Location saved to Firestore: Latitude: ${position.latitude}, Longitude: ${position.longitude}";
      });
    } else {
      setState(() {
        locationMessage = "User not logged in";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Get Location'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              locationMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: getLocation,
              child: Text('Get Location'),
            ),
          ],
        ),
      ),
    );
  }
}
