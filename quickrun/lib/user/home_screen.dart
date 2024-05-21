import 'package:quickrun/user/calculation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickrun/auth/auth_service.dart';
import 'package:quickrun/auth/login_screen.dart';
import 'package:quickrun/user/map.dart';
import 'package:quickrun/user/order.dart';
import 'package:quickrun/user/report.dart';
import 'package:quickrun/widgets/button.dart' as DeleveryButton;
import 'package:geolocator/geolocator.dart';
import 'package:quickrun/user/saveLocation.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void getLocation() async {
    await Geolocator.checkPermission();
    await Geolocator.requestPermission();

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(position);
  }

  @override
  Widget build(BuildContext context) {
    final AuthService auth = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Orders'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderPage(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Location'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocationPage(),
                  ),
                );
              },
            ),
            ListTile(title: Text('loc'), onTap: getLocation),
            ListTile(
              title: Text('Report'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkingTimeView(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('available')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final availability = snapshot.data!['available'];
                Color notificationColor = Colors.grey; // Default color

                if (availability == 'end') {
                  notificationColor = Colors.red;
                } else if (availability == 'start') {
                  notificationColor = Colors.green;
                } else if (availability == 'break') {
                  notificationColor = Colors.orange;
                }

                return Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: notificationColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome,',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '${FirebaseAuth.instance.currentUser?.email ?? 'User'}',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Your availability status is:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '$availability',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            DeleveryButton.CustomButton(
              label: "Start",
              onPressed: () async {
                // Check current availability
                final availability = await getCurrentAvailability();
                if (availability != null && availability == 'start') {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Your availability is already "start".'),
                    duration: Duration(seconds: 2),
                  ));
                } else {
                  // If availability is not "start", proceed with action
                  await checkAvailabilityAndPerformAction("start", context);
                  await _StartTime("start");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GoogleMapPage()),
                  );
                }
              },
              buttonColor: Color.fromARGB(255, 21, 142, 235),
              textColor: Colors.white,
            ),
            SizedBox(height: 10),
            DeleveryButton.CustomButton(
              label: "End",
              onPressed: () async {
                // Check current availability
                final availability = await getCurrentAvailability();
                if (availability != null && availability == 'end') {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Your availability is already "end".'),
                    duration: Duration(seconds: 2),
                  ));
                } else {
                  // If availability is not "end", proceed with action
                  await checkAvailabilityAndPerformAction("end", context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FirestoreExample()),
                  );
                }
              },
              buttonColor: Color.fromARGB(255, 21, 142, 235),
              textColor: Colors.white,
            ),
            SizedBox(height: 20),
            DeleveryButton.CustomButton(
              label: "Sign Out",
              onPressed: () async {
                await auth.signout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                );
              },
              buttonColor: Colors.blue,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> getCurrentAvailability() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userId = user.uid;
        final userRef =
            FirebaseFirestore.instance.collection('available').doc(userId);
        final userDoc = await userRef.get();
        if (userDoc.exists) {
          return userDoc.data()?['available'];
        } else {
          print('User document not found.');
        }
      } else {
        print('User not logged in!');
      }
    } catch (e) {
      print('Error checking current availability: $e');
    }
    return null;
  }

  Future<void> checkAvailabilityAndPerformAction(
      String action, BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userId = user.uid;

        final userRef =
            FirebaseFirestore.instance.collection('available').doc(userId);

        final userDoc = await userRef.get();
        if (userDoc.exists) {
          final availability = userDoc.data()?['available'];

          if (availability == 'break') {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Cannot perform action. Availability is on break.'),
              duration: Duration(seconds: 2),
            ));
          } else {
            await _updateAvailability(action);
          }
        } else {
          print('User document not found.');
        }
      } else {
        print('User not logged in!');
      }
    } catch (e) {
      print('Error checking availability: $e');
    }
  }

  Future<void> _updateAvailability(String availability) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userId = user.uid;
        final userEmail = user.email;

        final userRef =
            FirebaseFirestore.instance.collection('available').doc(userId);

        final userDoc = await userRef.get();
        if (userDoc.exists) {
          await userRef.update({
            'available': availability,
            'email': userEmail,
          });
          print('Availability updated successfully!');
        } else {
          print('User document not found. Creating new document...');
          await userRef.set({
            'available': availability,
            'email': userEmail,
          });
          print('User document created with availability: $availability');
        }
      } else {
        print('User not logged in!');
      }
    } catch (e) {
      print('Error updating availability: $e');
    }
  }

  Future<void> _StartTime(String availability) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userId = user.uid;
        final userEmail = user.email;

        final startTimeRef =
            FirebaseFirestore.instance.collection('StartTime').doc(userId);

        final startTimeDoc = await startTimeRef.get();
        if (startTimeDoc.exists) {
          if (availability == 'start') {
            // Save start time in Firestore
            await startTimeRef.set({
              'startTime': Timestamp.now(), // Save current time as startTime
              'email': userEmail, // Update email if necessary
            });
            print('Start time saved successfully!');
          } else {
            print('Start time document found but availability is not start.');
          }
        } else {
          print('Start time document not found. Creating new document...');
          if (availability == 'start') {
            // Save start time in Firestore
            await startTimeRef.set({
              'startTime': Timestamp.now(), // Save current time as startTime
              'email': userEmail, // Update email if necessary
            });
            print('Start time document created.');
            print('Start time saved successfully!');
          } else {
            print(
                'Start time document not found and availability is not start.');
          }
        }
      } else {
        print('User not logged in!');
      }
    } catch (e) {
      print('Error updating availability: $e');
    }
  }
}
