import 'package:flutter/material.dart';

class Menu_meal extends StatelessWidget {
  // قائمة الوجبات
  final List<Meal> meals = [
    Meal(
      name: 'مقبلات خفيفة',
      price: 15.0,
      ingredients: ['خس', 'طماطم', 'زيتون', 'جبن'],
      image: 'assets/food_flow_dark.jpg', // إضافة صورة للوجبة
    ),
    Meal(
      name: 'دجاج مشوي',
      price: 35.0,
      ingredients: ['دجاج', 'ثوم', 'عصير ليمون', 'بهارات'],
      image: 'assets/food_flow_dark.jpg', // إضافة صورة للوجبة
    ),
    Meal(
      name: 'مكرونة بالصلصة',
      price: 20.0,
      ingredients: ['مكرونة', 'صلصة طماطم', 'ريحان', 'ثوم'],
      image: 'assets/food_flow_dark.jpg', // إضافة صورة للوجبة
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: meals.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return view_meal(
          meal: meals[index],
          delay: Duration(milliseconds: 500 * index),
        );
      },
    );
  }
}

class Meal {
  final String name;
  final double price;
  final List<String> ingredients;
  final String image; // إضافة خاصية الصورة

  Meal(
      {required this.name,
      required this.price,
      required this.ingredients,
      required this.image});
}

class view_meal extends StatefulWidget {
  final Meal meal;
  final Duration delay;

  view_meal({required this.meal, required this.delay});

  @override
  _FadeInItemState createState() => _FadeInItemState();
}

class _FadeInItemState extends State<view_meal> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..forward();

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // تأخير التدرج باستخدام Duration
    Future.delayed(widget.delay, () {
      if (mounted) {
        setState(() {
          _controller.fling();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // عند الضغط على العنصر، يتم الانتقال إلى نافذة جديدة
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Detail_meal(meal: widget.meal),
          ),
        );
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: ListTile(
            leading: Hero(
              tag: widget.meal.name, // استخدام meal.name كـ tag فريد
              child: Image.asset(
                widget.meal.image,
                width: 100, // التحكم في حجم الصورة
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              widget.meal.name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('السعر: ${widget.meal.price} ريال'),
                Text('المكونات: ${widget.meal.ingredients.join(', ')}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Detail_meal extends StatelessWidget {
  final Meal meal;

  Detail_meal({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(meal.name),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // استخدام Hero لربط الصورة
            Hero(
              tag: meal.name, // استخدام نفس الـ tag الذي تم استخدامه في القائمة
              child: Image.asset(
                meal.image,
                width: MediaQuery.of(context).size.width, // عرض الصورة بالكامل
                height:
                    MediaQuery.of(context).size.height * 0.4, // تكبير الصورة
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),
            // عرض تفاصيل الوجبة
            Text(
              meal.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'السعر: ${meal.price} ريال',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'المكونات: ${meal.ingredients.join(', ')}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
