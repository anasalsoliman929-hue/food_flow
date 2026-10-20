import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:food_flow/data&theme/variable.dart';
import 'package:food_flow/modele/CartItem.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CartItemDetailsPage extends StatefulWidget {
  final CartItem cartItem;

  const CartItemDetailsPage({super.key, required this.cartItem});

  @override
  State<CartItemDetailsPage> createState() => _CartItemDetailsPageState();
}

class _CartItemDetailsPageState extends State<CartItemDetailsPage> {
  late CartItem cartItem;
  late int tempQuantity;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    cartItem = widget.cartItem;
    tempQuantity = cartItem.quantity;
  }

  void _increment() {
    setState(() => tempQuantity += 1);
  }

  void _decrement() {
    if (tempQuantity > 0) setState(() => tempQuantity -= 1);
  }

  Future<bool> deleteCartItem(int cartItemId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse("http://10.0.2.2:8000/api/cart/$cartItemId"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print("API Delete Error: $e");
      return false;
    }
  }

  Future<void> _saveChanges() async {
    setState(() => isProcessing = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (tempQuantity == 0) {
      final response = await http.delete(
        Uri.parse("http://10.0.2.2:8000/api/cart/${cartItem.id}"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json"
        },
      );

      if (!mounted) return;
      setState(() => isProcessing = false);
      if (response.statusCode == 200 || response.statusCode == 204) {
        cartItem.quantity = 0;
        Navigator.pop(context, cartItem);
      } else {
        print("Delete Error: ${response.body}");
      }
    } else {
      final response = await http.put(
        Uri.parse("http://10.0.2.2:8000/api/cart/${cartItem.id}"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json"
        },
        body: jsonEncode({"quantity": tempQuantity}),
      );

      if (!mounted) return;
      setState(() => isProcessing = false);
      if (response.statusCode == 200) {
        cartItem.quantity = tempQuantity;
        Navigator.pop(context, cartItem);
      } else {
        print("Update Error: ${response.body}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = cartItem.finalPrice * tempQuantity;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colbg,
        iconTheme: IconThemeData(color: coltext, size: 28),
        title: Text("تفاصيل الطبق",
            style: TextStyle(
                color: coltext, fontWeight: FontWeight.bold, fontSize: 22)),
      ),
      backgroundColor: colbg,
      body: isProcessing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.fastfood,
                      size: 100, color: Colors.orangeAccent),
                  const SizedBox(height: 12),
                  Text(cartItem.mealName,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (cartItem.category != null)
                    Text("الفئة: ${cartItem.category!.name}",
                        style: TextStyle(color: Colors.grey[700])),
                  if (cartItem.offer != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        "خصم ${cartItem.offer!.discountPercent}%",
                        style: const TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          onPressed: _decrement,
                          icon: const Icon(Icons.remove_circle,
                              color: Colors.red, size: 32)),
                      const SizedBox(width: 8),
                      Text("$tempQuantity",
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      IconButton(
                          onPressed: _increment,
                          icon: const Icon(Icons.add_circle,
                              color: Colors.green, size: 32)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text("الإجمالي: ${totalPrice.toStringAsFixed(2)} \$",
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 40),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child:
                            const Text("حفظ", style: TextStyle(fontSize: 18)),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          bool deleted = await deleteCartItem(cartItem.id);
                          if (deleted) {
                            Navigator.pop(
                              context,
                              CartItem(
                                id: cartItem.id,
                                mealId: cartItem.mealId,
                                mealName: cartItem.mealName,
                                quantity: 0,
                                notes: cartItem.notes,
                                originalPrice: cartItem.originalPrice,
                                finalPrice: cartItem.finalPrice,
                                subtotal: cartItem.subtotal,
                                offer: cartItem.offer,
                                category: cartItem.category,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("فشل في حذف العنصر")),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 40),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child:
                            const Text("حذف", style: TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
