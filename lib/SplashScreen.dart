import 'package:flutter/material.dart';
import 'package:forces_info/Home.dart';
import 'package:forces_info/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  _navigateToNextScreen() async {
    // Simulate loading time, waiting for Firebase initialization
    await Future.delayed(const Duration(seconds: 3));

    // Navigate to the Home screen if user is logged in, else LoginPage
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) =>
        (FirebaseAuth.instance.currentUser != null) ? Home() : LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Lottie.asset('assets/splash/forces_info.json'),
      ),
    );
  }
}