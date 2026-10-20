class Meal {
  final int id;
  final String name;
  final String description;
  final double price;
  final double finalPrice;
  final String? image;
  final int categoryId;
  final bool isInternal;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Category category;
  final Offer? offer;

  Meal({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.finalPrice,
    required this.image,
    required this.categoryId,
    required this.isInternal,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    this.offer,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'غير معروف',
      description: json['description'] ?? 'لا يوجد وصف',
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      finalPrice: double.tryParse(json['final_price']?.toString() ?? '') ?? 0.0,
      image: json['image_url'],
      categoryId: json['category_id'] ?? 0,
      isInternal: (json['is_internal'] ?? 0) == 1,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      category: Category.fromJson(json['category'] ?? {}),
      offer: json['offer'] != null ? Offer.fromJson(json['offer']) : null,
    );
  }
}

class Category {
  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'غير معروف',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class Offer {
  // حسب المتوقع من future API، هنا مثال فقط
  final int id;
  final String title;

  Offer({
    required this.id,
    required this.title,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'عرض غير معروف',
    );
  }
}
