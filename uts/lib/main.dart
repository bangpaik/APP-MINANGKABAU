import 'package:flutter/material.dart';
import 'package:uts/splashscreen.dart';

const String  api_url = 'http://192.168.248.42/SERVER-UTS/';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Kebudayaan Minangkabau',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
