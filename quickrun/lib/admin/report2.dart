import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class report2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Working Time Data'),
      ),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance.collection('workingtime').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          // Display data if available
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                var data = doc.data() as Map<String, dynamic>;
                return ListTile(
                  subtitle: Text('Date: ${data['date'].toDate().toString()}'),
                  trailing: Text(
                      'Difference: ${data['differenceInHours']} hours ${data['differenceInMinutes']} minutes'),
                );
              },
            );
          } else {
            return Text('No data available');
          }
        },
      ),
    );
  }
}
