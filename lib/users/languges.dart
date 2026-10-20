import 'package:flutter/material.dart';
import 'package:food_flow/data&theme/variable.dart';
import 'package:food_flow/users/splashscren.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class language extends StatefulWidget {
  const language({super.key});

  @override
  State<language> createState() => _languageState();
}

class _languageState extends State<language> {
  setindexlangugus(int index) async {
    SharedPreferences indexlangug = await SharedPreferences.getInstance();
    indexlangug.setInt("indexlang", index);
    print(" indexlangug is saved ");
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: theTextDecoration,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: colbg,
            iconTheme: IconThemeData(
              color: coltext,
              size: 30,
            ),
            actionsIconTheme: IconThemeData(color: coltext),
            centerTitle: true,
            title: Shimmer.fromColors(
              baseColor: Colors.orange,
              highlightColor: Colors.red,
              child: Text(
                'the langugus',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: Colors.orange,
                ),
              ),
            ),
          ),
          body: AnimatedContainer(
            color: colbg,
            duration: const Duration(
              milliseconds: 500,
            ),
            width: double.infinity,
            height: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                RadioListTile<int>(
                  title: Text(
                    'العربية',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: coltext,
                    ),
                  ),
                  value: 0,
                  groupValue: indexlang,
                  onChanged: ((value) {
                    indexlang = value!;
                    setindexlangugus(value);
                    theTextDecoration = TextDirection.rtl;
                    Get.appUpdate();
                      Get.offAll(SplashScreen());
                    // Changthem("false");
                    // print(langugus[indexlang]["Home"]);
                  }),
                ),
                RadioListTile<int>(
                  title: Text(
                    'English',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: coltext,
                    ),
                  ),
                  value: 1,
                  groupValue: indexlang,
                  onChanged: ((value) {
                    indexlang = value!;
                    setindexlangugus(value);
                    theTextDecoration = TextDirection.ltr;
                      Get.offAll(SplashScreen());
                    // Get.appUpdate();
                    // Changthem("false");
                    

                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
