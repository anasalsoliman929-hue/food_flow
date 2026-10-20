import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:food_flow/modele/CartItem.dart';
import 'package:food_flow/users/splashscren.dart';
import 'package:food_flow/users/widget_user/CartItemDetailsPage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:food_flow/data&theme/variable.dart';
import 'package:shimmer/shimmer.dart';

// 🟢 الصفحة الرئيسية للسلة
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with TickerProviderStateMixin {
  List<CartItem> cartItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCart();
  }

  Future<void> _fetchCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:8000/api/cart"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json"
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<CartItem> items = [];
        for (var c in data['cart']) {
          items.add(CartItem.fromJson(c));
        }
        if (!mounted) return;
        setState(() {
          cartItems = items;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("API Error: $e");
    }
  }

  void _openCartItemDetails(CartItem item, int index) async {
    final updatedItem = await Navigator.push<CartItem>(
      context,
      MaterialPageRoute(
        builder: (_) => CartItemDetailsPage(cartItem: item),
      ),
    );

    if (!mounted) return;
    if (updatedItem == null) return;

    setState(() {
      if (updatedItem.quantity == 0) {
        cartItems.removeAt(index);
      } else {
        cartItems[index] = updatedItem;
      }
    });
  }

  Future<void> _submitOrder(String orderType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return;

    // تحقق إذا كانت السلة فارغة قبل الإرسال
    if (cartItems.isEmpty) {
      _showErrorDialog("السلة فارغة. يرجى إضافة عناصر إلى السلة.");
      return;
    }

    // تأكد من إرسال حقل order_type
    if (orderType == null ||
        (orderType != 'internal' && orderType != 'external')) {
      _showErrorDialog("نوع الطلب غير صالح. يرجى اختيار نوع طلب صحيح.");
      return;
    }

    // بناء قائمة العناصر (items) للتأكد من عدم وجود قيم فارغة أو null
    List<Map<String, dynamic>> items = cartItems.map((item) {
      return {
        "meal_id": item.mealId,
        "quantity": item.quantity,
        "price_per_unit": item.originalPrice,
      };
    }).toList();

    // تأكد من أن items ليست فارغة أو null
    if (items.isEmpty) {
      _showErrorDialog("لا توجد عناصر صالحة في السلة.");
      return;
    }

    try {
      // إرسال البيانات إلى الـ API
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/api/orders"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json", // تأكد من إضافة هذا السطر
        },
        body: jsonEncode({
          "order_type": orderType, // تأكد من إرسال order_type بشكل صحيح
          "items": items, // إضافة قائمة العناصر
        }),
      );

      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title:
                const Icon(Icons.check_circle, color: Colors.green, size: 48),
            content: Text(data['message'] ?? 'تم إنشاء الطلب بنجاح',
                textAlign: TextAlign.center),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // العودة للصفحة السابقة
                },
                child: const Text('موافق'),
              ),
            ],
          ),
        );
      } else {
        final data = jsonDecode(response.body);
        _showErrorDialog(data['message'] ?? "فشل في إنشاء الطلب.");
      }
    } catch (e) {
      print("API Error: $e");
      _showErrorDialog("حدث خطأ أثناء إرسال الطلب. يرجى المحاولة لاحقًا.");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("موافق"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCartSummaryItem(CartItem item, int index) {
    return GestureDetector(
      onTap: () => _openCartItemDetails(item, index),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 6,
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.mealName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "الكمية: ${item.quantity}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "السعر: ${item.finalPrice.toStringAsFixed(2)} \$",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                    if (item.offer != null)
                      Text(
                        "خصم ${item.offer!.discountPercent}%",
                        style: const TextStyle(color: Colors.green),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.grey.shade400, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showOrderTypeDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('اختار نوع الطلب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('داخلي'),
              onTap: () {
                Navigator.pop(context);
                _submitOrder('internal');
              },
            ),
            ListTile(
              title: Text('خارجي'),
              onTap: () {
                Navigator.pop(context);
                _submitOrder('external');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: theTextDecoration,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colbg,
          iconTheme: IconThemeData(color: coltext, size: 28),
          title: Shimmer.fromColors(
            baseColor: Colors.orange,
            highlightColor: Colors.red,
            child: const Text(
              "cart",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ElevatedButton(
                onPressed: _showOrderTypeDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'تحويل لطلب',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: colbg,
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : cartItems.isEmpty
                ? Center(
                    child: Text("Your cart is empty",
                        style: TextStyle(
                            color: coltext.withOpacity(0.7), fontSize: 18)),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) =>
                        _buildCartSummaryItem(cartItems[index], index),
                  ),
      ),
    );
  }
}
