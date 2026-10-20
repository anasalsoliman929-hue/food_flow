import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:food_flow/users/splashscren.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:food_flow/data&theme/langugus.dart';
import 'package:food_flow/users/Login.dart';
import 'package:food_flow/users/acount.dart';
import 'package:food_flow/users/favorite.dart';
import 'package:food_flow/users/languges.dart';
import 'package:food_flow/users/modeofapp.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> with TickerProviderStateMixin {
  String? username;
  String? email;
  String balance = "0.00"; // رصيد المحفظة
  String points = "0"; // نقاط الولاء
  late AnimationController _listController;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchWalletBalance();
    _fetchLoyaltyPoints();

    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username");
      email = prefs.getString("email");
    });
  }

  Future<void> _fetchWalletBalance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:8000/api/wallet"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          balance = data["balance"].toString();
        });
      } else {
        print("Error: ${response.statusCode} => ${response.body}");
      }
    } catch (e) {
      print("API Error: $e");
    }
  }

  // 🟢 جلب نقاط الولاء
  Future<void> _fetchLoyaltyPoints() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:8000/api/loyalty"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          points = data["points"].toString();
        });
      } else {
        print("Error: ${response.statusCode} => ${response.body}");
      }
    } catch (e) {
      print("API Error: $e");
    }
  }

  // 🟢 تحويل النقاط إلى المحفظة
  Future<void> _convertPoints() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) return;

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/api/loyalty/convert"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _fetchWalletBalance();
        _fetchLoyaltyPoints();
      }

      if (data["message"] != null) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Icon(
                response.statusCode == 200 ? Icons.check_circle : Icons.error,
                color: response.statusCode == 200 ? Colors.green : Colors.red,
                size: 50,
              ),
              content: Text(
                data["message"],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("إغلاق"),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print("API Error: $e");
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => login()),
    );
  }

  Widget _buildAnimatedTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required int index,
    Color color = Colors.orange,
  }) {
    final animation = CurvedAnimation(
      parent: _listController,
      curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
    );

    final pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(animation),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: GestureDetector(
            onTapDown: (_) => pressController.reverse(),
            onTapUp: (_) {
              pressController.forward();
              HapticFeedback.lightImpact();
              onTap();
            },
            onTapCancel: () => pressController.forward(),
            child: AnimatedBuilder(
              animation: pressController,
              builder: (context, child) {
                return Transform.scale(
                    scale: pressController.value, child: child);
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.15),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  trailing: Icon(
                    indexlang == 0
                        ? Icons.arrow_back_ios_new
                        : Icons.arrow_forward_ios,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: theTextDecoration,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // الهيدر العصري مع الرصيد ونقاط الولاء
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepOrange, Colors.orange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.white,
                      highlightColor: Colors.yellowAccent,
                      child: const Text(
                        "Settings",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      child: Text(
                        (username != null && username!.isNotEmpty)
                            ? username![0].toUpperCase()
                            : "?",
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      username ?? "User Name",
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email ?? "user@email.com",
                      style: TextStyle(
                          fontSize: 16, color: Colors.white.withOpacity(0.9)),
                    ),
                    const SizedBox(height: 20),
                    // بطاقة الرصيد
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 5))
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.account_balance_wallet,
                                  color: Colors.orange, size: 28),
                              SizedBox(width: 10),
                              Text("Wallet Balance",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                          Text("$balance \$",
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.orange)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    // بطاقة نقاط الولاء مع زر التحويل
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 5))
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.star, color: Colors.amber, size: 28),
                              SizedBox(width: 10),
                              Text("Loyalty Points",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                          Row(
                            children: [
                              Text(points,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.amber)),
                              const SizedBox(width: 15),
                              ElevatedButton(
                                onPressed: int.tryParse(points) != null &&
                                        int.parse(points) > 10
                                    ? _convertPoints
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  disabledBackgroundColor: Colors.grey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text("تحويل"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // قائمة الإعدادات
              _buildAnimatedTile(
                icon: Icons.account_circle,
                title: langugus[indexlang]['account'],
                onTap: () => Get.to(const AccountSettingsPage(),
                    duration: 500.milliseconds, transition: Transition.zoom),
                color: Colors.blue,
                index: 0,
              ),
              _buildAnimatedTile(
                icon: Icons.favorite,
                title: "Favorite",
                onTap: () => Get.to(const Favorite(),
                    duration: 500.milliseconds,
                    transition: Transition.rightToLeftWithFade),
                color: Colors.redAccent,
                index: 1,
              ),
              _buildAnimatedTile(
                icon: Icons.light_mode,
                title: langugus[indexlang]['darkandlightmode'],
                onTap: () => Get.to(modeofapp(),
                    duration: 500.milliseconds, transition: Transition.zoom),
                color: Colors.purple,
                index: 2,
              ),
              _buildAnimatedTile(
                icon: Icons.language,
                title: langugus[indexlang]['language'],
                onTap: () => Get.to(const language(),
                    duration: 500.milliseconds, transition: Transition.zoom),
                color: Colors.green,
                index: 3,
              ),
              _buildAnimatedTile(
                icon: Icons.logout,
                title: langugus[indexlang]['logout'],
                onTap: () => _logout(context),
                color: Colors.black,
                index: 4,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
