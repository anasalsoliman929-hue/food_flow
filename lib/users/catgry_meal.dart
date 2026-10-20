import 'package:flutter/material.dart';
import 'package:food_flow/api/CategoryController.dart';
import 'package:food_flow/modele/meal.dart';
import 'package:food_flow/users/splashscren.dart';
import 'package:food_flow/users/widget_user/MealTile.dart';
import 'package:food_flow/data&theme/variable.dart';
import 'package:shimmer/shimmer.dart';

class CatgryMeal extends StatefulWidget {
  const CatgryMeal({super.key});

  @override
  State<CatgryMeal> createState() => _CatgryMealState();
}

class _CatgryMealState extends State<CatgryMeal> {
  final CategoryController controller = CategoryController();

  List categories = [];
  String selectedCategory = '';
  List<Meal> meals = [];
  bool isLoadingCategories = true;
  bool isLoadingMeals = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      categories = await controller.fetchCategories();
      if (categories.isNotEmpty) {
        selectedCategory = categories[0]['name'];
        await fetchMeals(selectedCategory);
      }
    } catch (e) {
      print(e);
    }

    setState(() {
      isLoadingCategories = false;
    });
  }

  Future<void> fetchMeals(String categoryName) async {
    setState(() {
      isLoadingMeals = true;
      meals = [];
    });

    try {
      meals = await controller.fetchMealsByCategory(categoryName);
    } catch (e) {
      print(e);
    }

    setState(() {
      isLoadingMeals = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: theTextDecoration,
      child: Scaffold(
        backgroundColor: colbg,
        appBar: AppBar(
          backgroundColor: colbg,
          centerTitle: true,
          title: Shimmer.fromColors(
            baseColor: Colors.orange,
            highlightColor: Colors.red,
            child: Text(
              'الأصناف',
              style: TextStyle(
                color: coltext,
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          iconTheme: IconThemeData(color: coltext),
        ),
        body: isLoadingCategories
            ?_buildShimmerList()
            : Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: [
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          String categoryName = categories[index]['name'];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: InkWell(
                              onTap: () async {
                                setState(() {
                                  selectedCategory = categoryName;
                                });
                                await fetchMeals(categoryName);
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: selectedCategory == categoryName
                                      ? Colors.orange
                                      : colbg,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  categoryName,
                                  style: TextStyle(
                                    color: selectedCategory == categoryName
                                        ? Colors.blue
                                        : coltext,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: isLoadingMeals
                          ? _buildShimmerList()
                          : meals.isEmpty
                              ? const Center(child: Text("لا توجد وجبات"))
                              : ListView.builder(
                                  itemCount: meals.length,
                                  itemBuilder: (context, index) {
                                    return MealTile(
                                      meal: meals[index],
                                      delay:
                                          Duration(milliseconds: 300 * index),
                                    );
                                  },
                                ),
                    )
                  ],
                ),
              ),
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
