import 'package:flutter/material.dart';
import 'package:food_flow/api/favorite_controller.dart';
import 'package:food_flow/data&theme/variable.dart';
import 'package:food_flow/modele/meal.dart';
import 'package:food_flow/api/mealcontroler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MealDetailPage extends StatefulWidget {
  final Meal meal;

  const MealDetailPage({super.key, required this.meal});

  @override
  State<MealDetailPage> createState() => _MealDetailPageState();
}

class _MealDetailPageState extends State<MealDetailPage> {
  late MealDetailController _controller;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _controller = MealDetailController(widget.meal.id);
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final status = await _controller.checkIfFavorite();
    setState(() {
      isFavorite = status;
    });
  }

  Future<void> _toggleFavorite() async {
    if (isFavorite) {
      final error = await _controller.removeFromFavorites();
      if (error == null) {
        setState(() => isFavorite = false);
        _showSnackBar('تمت الإزالة من المفضلة ❌');
      } else {
        _showSnackBar(error);
      }
    } else {
      final error = await _controller.addToFavorites();
      if (error == null) {
        setState(() => isFavorite = true);
        _showSnackBar('تمت الإضافة إلى المفضلة ✅');
      } else {
        _showSnackBar(error);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showAddToCartDialog() async {
    final TextEditingController quantityController =
        TextEditingController(text: "1");
    final TextEditingController notesController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'تحديد الكمية والملاحظات',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'الكمية',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.confirmation_num),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'ملاحظات (اختياري)',
                      hintText: 'مثال: بدون زيتون',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note_alt_outlined),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final int? quantity =
                          int.tryParse(quantityController.text);
                      if (quantity == null || quantity <= 0) {
                        _showSnackBar('يرجى إدخال كمية صحيحة');
                        return;
                      }

                      Navigator.pop(context);
                      await _addToCartRequest(
                          quantity, notesController.text.trim()+" ");
                    },
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('تأكيد الإضافة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      minimumSize: const Size.fromHeight(50),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _addToCartRequest(int quantity, String notes) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      _showSnackBar("الرجاء تسجيل الدخول أولاً");
      return;
    }

    final url = Uri.parse("http://10.0.2.2:8000/api/cart/add");
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "meal_id": widget.meal.id,
        "quantity": quantity,
        "notes": notes,
      }),
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      _showSnackBar(
          responseBody["message"] ?? "تمت الإضافة إلى السلة بنجاح 🛒");
    } else {
      _showSnackBar(
          responseBody["message"] ?? "حدث خطأ أثناء الإضافة إلى السلة ❌");
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = MealController.fullImageUrl(widget.meal.image);
    final hasOffer = widget.meal.offer != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meal.name),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.grey,
            ),
            tooltip: isFavorite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body:  SafeArea(
  child: LayoutBuilder(
    builder: (context, constraints) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight,
          ),
          child: IntrinsicHeight(
            child: Column(
              children: [
                Hero(
                  tag: widget.meal.id,
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'assets/food_flow_dark.jpg',
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.meal.name,
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        if (hasOffer)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'عرض: ${widget.meal.offer!.title}',
                              style: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        const SizedBox(height: 10),
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _infoRow('السعر الأساسي:', '${widget.meal.price.toStringAsFixed(2)} ريال'),
                                const SizedBox(height: 5),
                                _infoRow('السعر النهائي:', '${widget.meal.finalPrice.toStringAsFixed(2)} ريال'),
                                const SizedBox(height: 5),
                                _infoRow('القسم:', widget.meal.category.name),
                                const SizedBox(height: 10),
                                const Divider(),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'الوصف:',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.meal.description,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: _showAddToCartDialog,
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: const Text('أضف إلى السلة'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green[600],
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  ),
),
    );
  }

  Widget _infoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(value,
            style:  TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: coltext)),
        Text(title, style: TextStyle(fontSize: 16, color: coltext)),
      ],
    );
  }
}
