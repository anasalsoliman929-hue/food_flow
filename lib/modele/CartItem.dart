class CartItem {
  int id;
  int mealId;
  String mealName;
  int quantity;
  String notes;
  String originalPrice;
  double finalPrice;
  double subtotal;
  Offer? offer;
  Category? category;

  CartItem({
    required this.id,
    required this.mealId,
    required this.mealName,
    required this.quantity,
    required this.notes,
    required this.originalPrice,
    required this.finalPrice,
    required this.subtotal,
    this.offer,
    this.category,
  });

  // مصنع CartItem
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      mealId: json['meal_id'],
      mealName: json['meal_name'],
      quantity: json['quantity'],
      notes: json['notes'] ?? '',
      originalPrice: json['original_price'].toString(),
      finalPrice: _parseToDouble(json['final_price']),
      subtotal: _parseToDouble(json['subtotal']),
      offer: json['offer'] != null ? Offer.fromJson(json['offer']) : null,
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
    );
  }

  // دالة ثابتة لتحويل القيم إلى double بشكل آمن
  static double _parseToDouble(dynamic value) {
    if (value is String) {
      return double.tryParse(value) ?? 0.0; // تحويل النص إلى double
    } else if (value is num) {
      return value.toDouble(); // إذا كانت القيمة رقمية بالفعل
    }
    return 0.0; // في حال كانت القيمة null أو غير قابلة للتحويل
  }
}


class Offer {
  int discountPercent;
  String startDate;
  String endDate;

  Offer({
    required this.discountPercent,
    required this.startDate,
    required this.endDate,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      discountPercent: json['discount_percent'],
      startDate: json['start_date'],
      endDate: json['end_date'],
    );
  }
}

class Category {
  int id;
  String name;

  Category({
    required this.id,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
    );
  }
}
