import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:quickrun/auth/auth_service.dart';
import 'package:quickrun/auth/login_screen.dart';
import 'package:quickrun/widgets/button.dart';
import 'package:quickrun/admin/availableUser.dart';
import 'package:quickrun/admin/report.dart';
import 'package:quickrun/admin/report2.dart';

class AdminhomeomeScreen extends StatelessWidget {
  const AdminhomeomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService auth = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Home'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(206, 45, 175, 219),
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
              title: Text('Available User'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
            ),
            ListTile(
              title: Text('View Report'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AllUsersScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Sign Out'),
              onTap: () async {
                await auth.signout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                "assets/background.png"), // Path to your background image
            fit: BoxFit.cover,
          ),
        ),
        child: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Welcome Admin",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 20),
              CustomButton(
                label: "Sign Out",
                onPressed: () async {
                  await auth.signout();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
