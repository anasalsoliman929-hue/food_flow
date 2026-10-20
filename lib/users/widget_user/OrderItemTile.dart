import 'package:flutter/material.dart';

class OrderItemTile extends StatelessWidget {
  final dynamic orderData; // البيانات التي سيتم تمريرها

  const OrderItemTile({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ListTile(
        title: Text('Order ID: ${orderData['id']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Price: ${orderData['total_price']}'),
            Text('Status: ${orderData['status']}'),
            Text('Order Type: ${orderData['order_type']}'),
            SizedBox(height: 10),
            // عرض العناصر في الطلب
            ...orderData['items'].map<Widget>((item) {
              return ListTile(
                title: Text(item['meal']['name']),
                subtitle: Text('Quantity: ${item['quantity']}'),
                trailing: Text('Price: ${item['price_per_unit']}'),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
