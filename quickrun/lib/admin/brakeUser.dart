import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class brakepage extends StatelessWidget {
  final String userName;
  final String userId;
  final String userEmail; // Added userEmail parameter

  const brakepage({
    Key? key,
    required this.userName,
    required this.userId,
    required this.userEmail, // Required userEmail parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userName),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background_image.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 12.0),
              ElevatedButton(
                onPressed: () async {
                  await _updateAvailability(
                      userId, 'break', userEmail); // Pass userEmail parameter
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(16.0),
                ),
                child: Text(
                  'Break',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
              SizedBox(height: 12.0),
              ElevatedButton(
                onPressed: () async {
                  await _updateAvailability(
                      userId, 'start', userEmail); // Pass userEmail parameter

                  await _StartTime(userId, 'start', userEmail);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(16.0),
                ),
                child: Text(
                  'Start',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Inside _updateAvailability method signature and implementation
  Future<void> _updateAvailability(
      String userId, String availability, String userEmail) async {
    // Added userEmail parameter
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userRef =
            FirebaseFirestore.instance.collection('available').doc(userId);

        // Check if the document exists before updating
        final userDoc = await userRef.get();
        if (userDoc.exists) {
          await userRef.update({
            'available': availability,
            'email': userEmail, // Include clicked user's email when updating
          });
          print('Availability updated successfully!');
        } else {
          // Handle the case where the document does not exist
          print('User document not found. Creating new document...');
          await userRef.set({
            'available': availability,
            'email': userEmail, // Include clicked user's email when creating
          });
          print('User document created with availability: $availability');
        }

        // Example email sending code (you need to implement your own email sending logic)
        // Send email based on the availability status
        switch (availability) {
          case 'start':
            print('Send email for availability started to $userEmail');
            break;
          case 'end':
            print('Send email for availability ended to $userEmail');
            break;
          case 'break':
            print('Send email for break to $userEmail');
            break;
          default:
            print('Unknown availability status');
        }
      } else {
        print('User not logged in!');
      }
    } catch (e) {
      print('Error updating availability: $e');
    }
  }

  Future<void> _StartTime(
      String userId, String availability, String userEmail) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
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

  Future<void> _cal(String userId) async {
    try {
      // Get the start time document for the user
      DocumentSnapshot startTimeSnapshot = await FirebaseFirestore.instance
          .collection('StartTime')
          .doc(userId)
          .get();

      if (!startTimeSnapshot.exists) {
        // If start time document doesn't exist, handle accordingly
        print('Start Time Not Available');
        return;
      }

      // Extract start time from the document
      Timestamp startTimeTimestamp = startTimeSnapshot['startTime'];
      DateTime formattedStartTime = DateTime.fromMillisecondsSinceEpoch(
          startTimeTimestamp.seconds * 1000);

      // Calculate the difference between start time and current time
      DateTime currentTime = DateTime.now();
      Duration difference = currentTime.difference(formattedStartTime);

      // Save the difference to Firestore
      await FirebaseFirestore.instance.collection('workingtime').add({
        'userId': userId,
        'date': DateTime.now(),
        'differenceInHours': difference.inHours,
        'differenceInMinutes': difference.inMinutes.remainder(60)
      });

      // Print the results or return them as needed
      print('Start Time: $formattedStartTime');
      print(
          'Working Time: ${difference.inHours} hours and ${difference.inMinutes.remainder(60)} minutes');
    } catch (error) {
      print('Error: $error');
    }
  }
}
