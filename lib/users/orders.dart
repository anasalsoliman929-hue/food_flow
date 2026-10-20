import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<dynamic> orders = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<void> fetchOrders() async {
    final token = await getToken();

    if (token == null) {
      setState(() {
        isLoading = false;
        errorMessage = "لم يتم العثور على التوكن. يرجى تسجيل الدخول.";
      });
      return;
    }

    final url = Uri.parse('http://10.0.2.2:8000/api/orders/my');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        setState(() {
          orders = json.decode(response.body)["orders"];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'فشل تحميل الطلبات: ${response.statusCode}';
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = 'حدث خطأ: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("طلباتي"),
        backgroundColor: Colors.orange,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : orders.isEmpty
                  ? const Center(child: Text("لا توجد طلبات حالياً."))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return ModernOrderCard(order: order);
                      },
                    ),
    );
  }
}

class ModernOrderCard extends StatelessWidget {
  final dynamic order;

  const ModernOrderCard({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<dynamic> items = order['items'];

    // التأكد من وجود image_url قبل إضافته إلى القائمة
    List<String> imageUrls = items.map<String>((item) {
      // تحقق إذا كانت image_url موجودة وإلا استبدلها بقيمة فارغة
      return item['meal']['image_url'] ?? '';
    }).toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🟠 عنوان الطلب ورقمه
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'طلب #${order['id']}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order['status'] ?? 'غير معروف',
                    style: const TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 🔸 نوع الطلب والتاريخ
            Row(
              children: [
                const Icon(Icons.delivery_dining, size: 18),
                const SizedBox(width: 6),
                Text(order['order_type'] == 'external'
                    ? 'طلب خارجي'
                    : 'طلب داخلي'),
                const Spacer(),
                const Icon(Icons.access_time, size: 18),
                const SizedBox(width: 6),
                Text(order['created_at']
                    .toString()
                    .substring(0, 16)
                    .replaceAll('T', '  ')),
              ],
            ),
            const SizedBox(height: 12),

            // 🖼️ صور الوجبات
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: imageUrls[index].isEmpty
                          ? const Icon(Icons.fastfood, size: 40)
                          : Image.network(
                              imageUrls[index],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.fastfood, size: 40),
                            ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // 💰 السعر الكلي
            Row(
              children: [
                const Icon(Icons.attach_money, size: 20),
                const SizedBox(width: 6),
                Text(
                  'السعر الكلي: ${order['total_price']} \$',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 📋 عرض عدد العناصر داخل الطلب
            Row(
              children: [
                const Icon(Icons.list_alt, size: 18),
                const SizedBox(width: 6),
                Text("عدد العناصر: ${items.length} صنف"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
