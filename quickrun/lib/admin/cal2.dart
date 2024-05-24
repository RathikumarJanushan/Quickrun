import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class calculation extends StatelessWidget {
  final String userName;
  final String docId;
  final String userId;
  final String userEmail;

  calculation({
    Key? key,
    required this.userName,
    required this.userId,
    required this.docId,
    required this.userEmail,
  }) : super(key: key);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override

  // Function to save the difference to Firestore
  void saveDifference(Duration difference) {
    DateTime currentDate = DateTime.now();
    FirebaseFirestore.instance.collection('workingtime').add({
      'userId': userId,
      'date': currentDate,
      'differenceInHours': difference.inHours,
      'differenceInMinutes': difference.inMinutes.remainder(60)
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Today Working Hours'),
      ),
      body: Center(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('StartTime')
              .doc(userId)
              .snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot>? snapshot) {
            if (snapshot == null || !snapshot.hasData) {
              return CircularProgressIndicator();
            }
            var data = snapshot.data!.data() as Map<String, dynamic>?;

            if (data == null || !data.containsKey('startTime')) {
              return Text('Start Time Not Available');
            }
            var startTimeTimestamp = data['startTime'];
            var formattedStartTime = DateTime.fromMillisecondsSinceEpoch(
                startTimeTimestamp.seconds * 1000);

            // Calculate the difference in hours and minutes between current time and start time
            var currentTime = DateTime.now();
            var difference = currentTime.difference(formattedStartTime);
            var differenceInHours = difference.inHours;
            var differenceInMinutes = difference.inMinutes.remainder(60);

            // Save the difference to Firestore
            saveDifference(difference);

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Start Time: $formattedStartTime'),
                Text(
                  'Working Time: $differenceInHours hours and $differenceInMinutes minutes',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
