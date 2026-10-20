import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_flow/users/widget_user/MealDetail.dart';
import 'package:http/http.dart' as http;
import 'package:food_flow/modele/meal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart'; // استيراد حزمة intl لتنسيق التواريخ

class Offer {
  final int id;
  final int mealId;
  final double discountPercent;
  final String startDate;
  final String endDate;
  final String description;
  final Meal meal;

  Offer({
    required this.id,
    required this.mealId,
    required this.discountPercent,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.meal,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'],
      mealId: json['meal_id'],
      discountPercent: json['discount_percent']?.toDouble() ?? 0.0,
      startDate: json['start_date'],
      endDate: json['end_date'],
      description: json['description'] ?? '',
      meal: Meal.fromJson(json['meal']),
    );
  }
}

class OffersOnTheMeal extends StatefulWidget {
  const OffersOnTheMeal({super.key});

  @override
  State<OffersOnTheMeal> createState() => _OffersOnTheMealState();
}

class _OffersOnTheMealState extends State<OffersOnTheMeal> {
  Timer? _autoScrollTimer;
  late PageController _pageController;
  int _currentPage = 0;
  List<Offer> _offers = [];

  @override
  void initState() {
    super.initState();
    _fetchOffers();
    _pageController = PageController(
      viewportFraction: 0.7,
      initialPage: _currentPage,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  String? token;

  Future<void> _fetchOffers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token");
    if (token == null) {
      print("No token found!");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:8000/api/user/offers"),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          final List<dynamic> data = json.decode(response.body)["offers"];
          _offers = data.map((item) => Offer.fromJson(item)).toList();
        });
      } else {
        print("Failed to load offers");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_offers.isNotEmpty) {
        _currentPage = (_currentPage + 1) % _offers.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.45,
      child: _offers.isEmpty
          ? _buildShimmer() // عرض الـ shimmer عند التحميل
          : PageView.builder(
              controller: _pageController,
              itemCount: _offers.length,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index % _offers.length;
                });
              },
              itemBuilder: (context, index) {
                var offer = _offers[index];
                var meal = offer.meal;

                // حساب مدة العرض باليوم والشهر
                final startDate =
                    DateFormat("yyyy-MM-dd").parse(offer.startDate);
                final endDate = DateFormat("yyyy-MM-dd").parse(offer.endDate);
                final difference = endDate.difference(startDate);

                final daysLeft = difference.inDays;
                final monthsLeft =
                    (difference.inDays / 30).floor(); // تحويل الأيام إلى أشهر

                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 0;
                    if (_pageController.position.haveDimensions) {
                      value = _pageController.page! - index;
                      value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                    }

                    final double scale =
                        Curves.easeOut.transform(value) * 0.3 + 0.7;

                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..scale(scale, scale),
                      child: Center(
                        child: SizedBox(
                          height: Curves.easeOut.transform(value) *
                              screenHeight *
                              0.45,
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MealDetailPage(meal: meal),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 10),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: meal.image != null &&
                                        meal.image!.isNotEmpty
                                    ? NetworkImage(meal.image!)
                                    : AssetImage('assets/food_flow_dark.jpg')
                                        as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 15,
                            left: 15,
                            right: 15,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        meal.name,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black,
                                              offset: Offset(1, 1),
                                              blurRadius: 5,
                                            ),
                                          ],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (offer.discountPercent > 0)
                                          Text(
                                            '${meal.price} ل.س',
                                            style: TextStyle(
                                              color: const Color.fromARGB(255, 139, 3, 3),
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                          ),
                                        Text(
                                          '${(meal.price * (1 - offer.discountPercent / 100)).toStringAsFixed(2)} ل.س',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          ' باقي  ${daysLeft > 0 ? '$daysLeft  يوم ' : ''}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        );
      },
    );
  }
}
