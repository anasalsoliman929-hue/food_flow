import 'package:flutter/material.dart';
import 'package:food_flow/data&theme/maincontroler.dart';
import 'package:food_flow/data&theme/variable.dart';
import 'package:food_flow/users/splashscren.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class modeofapp extends StatefulWidget {
  modeofapp({super.key});

  @override
  State<modeofapp> createState() => _modeofappState();
}

class _modeofappState extends State<modeofapp> {
  setindexofthem(int index) async {
    SharedPreferences indexthem = await SharedPreferences.getInstance();
    indexthem.setInt("indextheme", index);
    print(" themode is saved ");
  }

  @override
  void initState() {
    // getinexofthem();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: theTextDecoration,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: colbg,
          appBar: AppBar(
            backgroundColor: colbg,
            iconTheme: IconThemeData(
              color: coltext,
              size: 30,
            ),
            actionsIconTheme: IconThemeData(color: coltext),
            title: Shimmer.fromColors(
              baseColor: Colors.orange,
              highlightColor: Colors.red,
              child: Text(
                'Theme of app',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: Colors.orange,
                ),
              ),
            ),
            centerTitle: true,
            elevation: 2,
          ),
          body: AnimatedContainer(
            color: colbg,
            duration: const Duration(
              milliseconds: 500,
            ),
            width: double.infinity,
            height: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 7.5,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.orange,
                    ),
                    child: RadioListTile<int>(
                      title: Text('light theme',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: coltext)),
                      value: 0,
                      groupValue: themode,
                      onChanged: ((value) {
                        setindexofthem(value!);
                        setState(
                          () {
                            coltext = Color.fromARGB(255, 73, 73, 73);
                            colbg = Colors.white;

                            themode = value;
                            Get.appUpdate();
                            Changthem("false");
                          },
                        );
                      }),
                    ),
                  ),
                  SizedBox(
                    height: 7.5,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.orange,
                    ),
                    child: RadioListTile<int>(
                      title: Text(
                        'dark theme',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: coltext,
                        ),
                      ),
                      value: 1,
                      groupValue: themode,
                      onChanged: ((value) {
                        setindexofthem(value!);
                        setState(
                          () {
                            coltext = Colors.white;
                            colbg = Color.fromARGB(255, 73, 73, 73);

                            themode = value;
                            Get.appUpdate();
                            Changthem("false");
                            //  theMode = ThemeMode.dark;
                          },
                        );
                      }),
                    ),
                  ),
                  SizedBox(
                    height: 7.5,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.orange,
                    ),
                    child: RadioListTile<int>(
                      title: Text(
                        ' Custom theme ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: coltext,
                        ),
                      ),
                      value: 2,
                      groupValue: themode,
                      onChanged: ((value) {
                        setindexofthem(value!);
                        setState(
                          () {
                            themode = value;
                            Get.appUpdate();
                            Changthem("false");
                          },
                        );
                      }),
                    ),
                  ),
                  SizedBox(
                    height: 7.5,
                  ),
                  themode == 2
                      ? Column(
                          children: [
                            Divider(
                              color: coltext,
                            ),
                            Text('data'),
                          ],
                        )
                      : SizedBox(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
