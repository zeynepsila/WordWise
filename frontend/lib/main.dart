import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const WordGuessingApp());
}

class WordGuessingApp extends StatelessWidget {
  const WordGuessingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Guessing Game',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
