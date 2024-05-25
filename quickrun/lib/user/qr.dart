import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickrun/user/home_screen.dart';

class qrCode extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: QRViewExample(),
    );
  }
}

class QRViewExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Scanner'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? Text(
                      'Barcode Type: ${result!.format.toString()}   Data: ${result!.code}')
                  : Text('Scan a code'),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        result = scanData;
      });
      if (result?.code == 'start') {
        await checkAvailabilityAndPerformAction("start", context);
        await _StartTime("start");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
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
