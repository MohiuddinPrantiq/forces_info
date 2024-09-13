import 'package:flutter/material.dart';
import 'package:forces_info/Home.dart';
import 'package:forces_info/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'SplashScreen.dart';
import 'Notification.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBbsPVWI8hBHE0cJsDZSnOmoSHR9h1V7oA",
      appId: "1:32836022909:android:288b3ff155f62ccf977714",
      messagingSenderId: "com.example.forces_info",
      projectId: "forces-info10",
    ),
  );
  Notification_Sch.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Codeforces Info',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}


