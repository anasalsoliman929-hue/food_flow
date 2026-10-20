import 'package:flutter/material.dart';
import 'package:food_flow/users/splashscren.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:food_flow/modele/meal.dart';
import 'package:food_flow/users/widget_user/MealTile.dart';
import 'package:shimmer/shimmer.dart';

class Favorite extends StatefulWidget {
  const Favorite({super.key});

  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  late Future<List<Meal>> _favoriteMealsFuture;

  @override
  void initState() {
    super.initState();
    _favoriteMealsFuture =
        fetchFavorites(); // تحميل البيانات في المتغير الخاص بالـ Future
  }

  Future<List<Meal>> fetchFavorites() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null || token.isEmpty) {
        throw Exception("يجب تسجيل الدخول أولاً.");
      }

      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/favorites'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['favorites'] != null) {
          final List<Meal> loadedMeals = (data['favorites'] as List)
              .map((mealJson) => Meal.fromJson(mealJson))
              .toList();
          return loadedMeals;
        } else {
          return []; // في حال لم توجد وجبات مفضلة
        }
      } else {
        throw Exception('فشل في تحميل المفضلات: ${response.statusCode}');
      }
    } catch (e) {
      print('خطأ: $e');
      throw Exception("خطأ في جلب المفضلات.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Shimmer.fromColors(
          baseColor: Colors.orange,
          highlightColor: Colors.red,
          child: Text(
            "المفضلة",
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: Colors.orange,
            ),
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.black, // تعديل اللون
          size: 30,
        ),
        actionsIconTheme: IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<List<Meal>>(
        future: _favoriteMealsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerList();
          } else if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد عناصر في المفضلة'));
          }

          final favoriteMeals = snapshot.data!;
          return ListView.separated(
            itemCount: favoriteMeals.length,
            separatorBuilder: (context, index) => const Divider(
              height: 10,
              color: Colors.grey,
            ),
            itemBuilder: (context, index) {
              return MealTile(
                meal: favoriteMeals[index],
                delay: Duration(milliseconds: index * 100),
              );
            },
          );
        },
      ),
    );
  }

  // إضافة تأثير Shimmer أثناء التحميل بشكل أفقي
  Widget _buildShimmerList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: ListTile(
              leading: Container(width: 100, height: 150, color: Colors.white),
              title: Container(height: 20, color: Colors.white),
              subtitle: Container(height: 14, color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
