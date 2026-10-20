import 'package:flutter/material.dart';
import 'package:food_flow/data&theme/langugus.dart';
import 'package:food_flow/users/splashscren.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: langugus[indexlang]["food_flow"],
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
