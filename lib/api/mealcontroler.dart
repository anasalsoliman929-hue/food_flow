import 'dart:convert';
import 'package:food_flow/modele/meal.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MealController {
  static const String baseUrl = 'http://10.0.2.2:8000';

  static String? fullImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    return '$baseUrl$path';
  }

  Future<List<Meal>> fetchMeals() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null || token.isEmpty) {
      throw Exception("يجب تسجيل الدخول أولاً.");
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/meals'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      List<dynamic> data = decoded;
      return data.map((json) => Meal.fromJson(json)).toList();
    } else {
      throw Exception('فشل تحميل البيانات: ${response.statusCode}');
    }
  }
}
