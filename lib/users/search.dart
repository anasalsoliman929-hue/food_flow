import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:food_flow/data&theme/variable.dart';
import 'package:food_flow/modele/meal.dart';
import 'package:food_flow/users/splashscren.dart';
import 'package:food_flow/users/widget_user/MealTile.dart';
import 'package:http/http.dart' as http;

// استدعاء صفحة تفاصيل الوجبة

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController textController = TextEditingController();

  List<Meal> searchResults = [];
  bool isLoading = false;
  String errorMessage = '';

  Future<void> fetchSearchResults(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        errorMessage = '';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/meals/search/for?name=$query'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List results = data['results'] ?? [];

        if (results.isEmpty) {
          setState(() {
            errorMessage = 'لا توجد نتائج للبحث.';
            searchResults = [];
          });
        } else {
          List<Meal> meals = results.map<Meal>((item) {
            return Meal(
              id: item['id'] ?? 0,
              name: item['name'] ?? 'غير معروف',
              description:
                  item['description'] ?? 'لا يوجد وصف', // تم التعديل هنا
              price: double.tryParse(item['price']?.toString() ?? '') ?? 0.0,
              finalPrice:
                  double.tryParse(item['final_price']?.toString() ?? '') ?? 0.0,
              image: item['image_url'],
              categoryId: item['category_id'] ?? 0,
              isInternal: (item['is_internal'] ?? 0) == 1,
              createdAt:
                  DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now(),
              updatedAt:
                  DateTime.tryParse(item['updated_at'] ?? '') ?? DateTime.now(),
              category: Category(
                id: 0,
                name: 'غير معروف',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
              offer: null,
            );
          }).toList();

          setState(() {
            searchResults = meals;
          });
        }
      } else {
        setState(() {
          errorMessage = 'فشل في جلب النتائج: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'حدث خطأ: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: theTextDecoration,
      child: Scaffold(
        backgroundColor: colbg,
        appBar: AppBar(
          backgroundColor: colbg,
          title: TextFormField(
            controller: textController,
            textInputAction: TextInputAction.search,
            keyboardType: TextInputType.text,
            style: TextStyle(color: coltext),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'أدخل اسم الوجبة أو المكان',
              hintStyle: TextStyle(color: coltext.withOpacity(0.7)),
              suffixIcon: IconButton(
                icon: Icon(Icons.close, color: coltext),
                onPressed: () {
                  textController.clear();
                  setState(() {
                    searchResults = [];
                    errorMessage = '';
                  });
                },
              ),
            ),
            onFieldSubmitted: (value) {
              fetchSearchResults(value.trim());
            },
          ),
          iconTheme: IconThemeData(color: coltext, size: 30),
          actionsIconTheme: IconThemeData(color: coltext),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              if (isLoading) const LinearProgressIndicator(),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              Expanded(
                child: searchResults.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد نتائج للبحث',
                          style: TextStyle(color: coltext),
                        ),
                      )
                    : ListView.separated(
                        itemCount: searchResults.length,
                        separatorBuilder: (_, __) => Divider(color: coltext),
                        itemBuilder: (context, index) {
                          final meal = searchResults[index];
                          // استخدام MealTile بدلاً من ListTile
                          return MealTile(
                            meal: meal,
                            delay: Duration(milliseconds: 100 * index),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
