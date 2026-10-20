import 'package:flutter/material.dart';
import 'package:food_flow/data&theme/langugus.dart';
import 'package:food_flow/data&theme/variable.dart';
import 'package:food_flow/users/Cart.dart';
import 'package:food_flow/users/catgry_meal.dart';
import 'package:food_flow/users/MainPage.dart';
import 'package:food_flow/users/notifications.dart';
import 'package:food_flow/users/orders.dart';
import 'package:food_flow/users/search.dart';
import 'package:food_flow/users/setting.dart';
import 'package:food_flow/users/splashscren.dart';
import 'package:get/get.dart';
import 'package:motion_tab_bar/MotionBadgeWidget.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
import 'package:motion_tab_bar/MotionTabBarController.dart';
import 'package:shimmer/shimmer.dart';

MotionTabBarController? motionTabBarController;

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  // TabController? _tabController;

  @override
  void initState() {
    super.initState();
    //// Use normal tab controller
    // _tabController = TabController(
    //   initialIndex: 1,
    //   length: 5,
    //   vsync: this,
    // );

    //// use "MotionTabBarController" to replace with "TabController", if you need to programmatically change the tab
    motionTabBarController = MotionTabBarController(
      initialIndex: 2,
      length: 5,
      vsync: this,
    );
  }

  @override
  void dispose() {
    super.dispose();
    motionTabBarController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: theTextDecoration,
      child: Scaffold(
        appBar: motionTabBarController?.index == 2
            ? AppBar(
                backgroundColor: colbg,
                iconTheme: IconThemeData(
                  color: coltext,
                  size: 30,
                ),
                actionsIconTheme: IconThemeData(color: coltext),
                elevation: 0,
                title: Shimmer.fromColors(
                  baseColor: Colors.orange,
                  highlightColor: Colors.red,
                  child: Text(
                    langugus[indexlang]["food_flow"],
                    style: TextStyle(
                      color: coltext,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      Get.to(
                        SearchPage(),
                        duration: const Duration(milliseconds: 500),
                        transition: Transition.fade,
                      );
                    },
                    icon: Icon(
                      Icons.search,
                      color: coltext,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Get.to(
                        Notifications(),
                        duration: const Duration(milliseconds: 500),
                        transition: Transition.cupertino,
                      );
                    },
                    icon: Icon(
                      Icons.notification_add,
                      color: const Color.fromARGB(255, 255, 230, 1),
                    ),
                  ),
                ],
              )
            : null,
        bottomNavigationBar: MotionTabBar(
          controller:
              motionTabBarController, // Add this controller if you need to change your tab programmatically
          initialSelectedTab: langugus[indexlang]['Home'],

          useSafeArea: false, // default: true, apply safe area wrapper
          labels: [
            langugus[indexlang]['categories'],
            langugus[indexlang]['Cart'],
            langugus[indexlang]['Home'],
            langugus[indexlang]['my_requests'],
            langugus[indexlang]['settings']
          ],
          icons: const [
            Icons.dashboard,
            Icons.add_shopping_cart_sharp,
            Icons.home,
            Icons.history,
            Icons.settings
          ],

          // optional badges, length must be same with labels
          // ignore: prefer_const_literals_to_create_immutables
          badges: [
            // Default Motion Badge Widget
            const MotionBadgeWidget(
              show: true,
              text: '10+',
              textColor: Colors.white, // optional, default to Colors.white
              color: Colors.red, // optional, default to Colors.red
              size: 18, // optional, default to 18
            ),

            // custom badge Widget
            const MotionBadgeWidget(
              show: true,
              text: '5+',
              textColor: Colors.white, // optional, default to Colors.white
              color: Colors.red, // optional, default to Colors.red
              size: 18, // optional, default to 18
            ),

            // allow null
            null,

            // Default Motion Badge Widget with indicator only
            const MotionBadgeWidget(
              isIndicator: true,
              color: Colors.red, // optional, default to Colors.red
              size: 5, // optional, default to 5,
              show: true, // true / false
            ),
            null,
          ],
          tabSize: 50,
          tabBarHeight: 55,
          textStyle: const TextStyle(
            fontSize: 17,
            color: Colors.orange,
            fontWeight: FontWeight.w900,
          ),
          tabIconColor: Colors.orange,
          tabIconSize: 28.0,
          tabIconSelectedSize: 26.0,
          tabSelectedColor: Colors.red,

          tabIconSelectedColor: Colors.white,
          tabBarColor: colbg,

          onTabItemSelected: (int value) {
            if (indexlang >= 0 && indexlang <= 4) {
              setState(() {
                motionTabBarController!.index = value;
              });
            } else {
              // التعامل مع الحالة حيث يكون indexlang غير صالح
              print("خطأ: قيمة indexlang غير صحيحة.");
            }
            // setState(() {
            //   motionTabBarController!.index = value;
            // });
          },
        ),
        body: TabBarView(
          // physics:
          //     const NeverScrollableScrollPhysics(), // swipe navigation handling is not supported
          controller: motionTabBarController,
          children: <Widget>[
            CatgryMeal(),
            CartPage(),
            MainPage(),
            OrdersPage(),
            Setting(),
          ],
        ),
      ),
    );
  }
}
