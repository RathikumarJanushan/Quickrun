import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:quickrun/auth/auth_service.dart';
import 'package:quickrun/auth/signup_screen.dart';
import 'package:quickrun/admin/adminhome_screen.dart';
import 'package:quickrun/user/home_screen.dart';
import 'package:quickrun/widgets/button.dart';
import 'package:quickrun/widgets/textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();

  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 50),
            const Text("Login",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500)),
            const SizedBox(height: 50),
            CustomTextField(
              hint: "Enter Email",
              label: "Email",
              controller: _email,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hint: "Enter Password",
              label: "Password",
              isPassword: true,
              controller: _password,
            ),
            const SizedBox(height: 30),
            CustomButton(
              label: "Login",
              onPressed: _login,
              textColor: Colors.white, // Text color
              buttonColor: Color.fromARGB(255, 11, 126, 164), // Button color
            ),
            const SizedBox(height: 5),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("Don't have an account? "),
              InkWell(
                onTap: () => goToSignup(context),
                child:
                    const Text("Signup", style: TextStyle(color: Colors.red)),
              )
            ]),
            const Spacer()
          ],
        ),
      ),
    );
  }

  goToSignup(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SignupScreen()),
      );

  goToHome(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );

  goToAdminHome(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdminhomeomeScreen()),
      );
  _login() async {
    print("Attempting login with email: ${_email.text}");
    final user =
        await _auth.loginUserWithEmailAndPassword(_email.text, _password.text);

    if (user != null) {
      log("User Logged In: ${user.uid}");

      // Check if the user's email is admin@gmail.com
      if (_email.text == "admin@gmail.com") {
        print("Admin logged in");
        // Navigate to the admin home screen
        goToAdminHome(context);
      } else {
        print("Regular user logged in");
        // Navigate to the regular home screen
        goToHome(context);
      }
    } else {
      print("Login failed");
    }
  }
}
