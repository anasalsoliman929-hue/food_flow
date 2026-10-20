import 'dart:convert';
import 'package:food_flow/modele/meal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CategoryController {
  String baseUrl = 'http://10.0.2.2:8000/api';
  String? token;

  Future<void> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token");
  }

  Future<List> fetchCategories() async {
    await init();
    final url = Uri.parse('$baseUrl/categories');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("فشل في جلب التصنيفات");
    }
  }

  Future<List<Meal>> fetchMealsByCategory(String categoryName) async {
    await init();
    final encodedName = Uri.encodeComponent(categoryName);
    final url =
        Uri.parse('$baseUrl/meals/search/for?category_name=$encodedName');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['results'];
      return data.map<Meal>((mealJson) => Meal.fromJson(mealJson)).toList();
    } else {
      throw Exception("فشل في جلب الوجبات");
    }
  }
}
