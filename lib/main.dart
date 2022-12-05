import 'package:flutter/material.dart';
import 'package:microlab/Home/home.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MicroLab',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color.fromARGB(255, 52, 52, 52),
        accentColor: Color.fromARGB(255, 138, 136, 136),
        
      ),
      home: const HomePage(),
    );
  }
}
