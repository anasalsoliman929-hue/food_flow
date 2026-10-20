import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Changthem extends GetxController {
  Locale theme = const Locale('false');
  
  Changthem(String theme) {
    Get.updateLocale(Locale(theme));
  }

  updatchange(bool b) {
    Get.appUpdate();
  }
}
