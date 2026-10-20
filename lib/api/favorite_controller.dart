import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MealDetailController {
  final int mealId;

  MealDetailController(this.mealId);

  Future<bool> checkIfFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) return false;

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/favorites'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List favorites = data['favorites'];
      return favorites.any((item) => item['id'] == mealId);
    }

    return false;
  }

  Future<String?> addToFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) return "يجب تسجيل الدخول أولاً";

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/favorites'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'meal_id': mealId}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return null; // لا يوجد خطأ
    } else if (response.statusCode == 400) {
      final decoded = jsonDecode(response.body);
      return decoded['message'] ?? 'خطأ غير معروف';
    }

    return 'فشل في الإضافة إلى المفضلة';
  }

  Future<String?> removeFromFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) return "يجب تسجيل الدخول أولاً";

    final response = await http.delete(
      Uri.parse('http://10.0.2.2:8000/api/favorites/$mealId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return null;
    }

    return 'فشل في الإزالة من المفضلة: ${response.statusCode}';
  }
}
