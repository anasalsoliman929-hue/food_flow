import 'package:flutter/material.dart';
import 'package:food_flow/api/mealcontroler.dart';
import 'package:food_flow/modele/meal.dart';
import 'package:food_flow/users/widget_user/MealTile.dart';
import 'package:food_flow/users/widget_user/OffersOnTheMeal.dart';
import 'package:shimmer/shimmer.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Future<List<Meal>> _mealsFuture;
  final controller = MealController();

  @override
  void initState() {
    super.initState();
    _mealsFuture = controller.fetchMeals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          _buildTitle("العروض"),
          OffersOnTheMeal(),
          _buildTitle("الوجبات"),
          FutureBuilder<List<Meal>>(
            future: _mealsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildShimmerList();
              } else if (snapshot.hasError) {
                return Center(child: Text('خطأ: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('لا توجد وجبات متاحة'));
              }

              final meals = snapshot.data!;
              // print(meals[0].);
              return ListView.builder(
                itemCount: meals.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return MealTile(
                      meal: meals[index],
                      delay: Duration(milliseconds: 300 * index));
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(String text) {
    return Shimmer.fromColors(
      baseColor: Colors.orange,
      highlightColor: Colors.red,
      child: Text(
        text,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

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
              leading: Container(width: 100, height: 100, color: Colors.white),
              title: Container(height: 20, color: Colors.white),
              subtitle: Container(height: 14, color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
