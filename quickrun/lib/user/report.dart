import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkingTimeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // If user is not logged in, you might want to handle this case
      return Scaffold(
        body: Center(
          child: Text('User not logged in'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Working Time Data'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('workingtime')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          // Display data if available
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            return DataTable(
              columns: [
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Working Hours')),
              ],
              rows: snapshot.data!.docs.map((doc) {
                var data = doc.data() as Map<String, dynamic>;
                var date = data['date'].toDate().toString();
                var workingHours =
                    '${data['differenceInHours']} hours ${data['differenceInMinutes']} minutes';
                return DataRow(cells: [
                  DataCell(Text(date)),
                  DataCell(Text(workingHours)),
                ]);
              }).toList(),
            );
          } else {
            return Text('No data available for the current user');
          }
        },
      ),
    );
  }
}
