import 'package:flutter/material.dart';
import 'package:map_project/screens/flutter_map_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Map Project',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FlutterMapScreen(),
    );
  }
}
