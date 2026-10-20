import 'dart:math';
import 'package:flutter/material.dart';
import 'package:food_flow/data&theme/variable.dart';
import 'package:food_flow/users/HomePage.dart';
import 'package:food_flow/users/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

bool? islogin;
int? themode = 1;
late int indexlang = 1;
TextDirection theTextDecoration = TextDirection.ltr;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  final Random _random = Random();
  final int _numBubbles = 30;
  final List<_Bubble> _bubbles = [];
  final List<Color> _rainbowColors = [
    Colors.redAccent,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    _initBubbles();
    _initAnimations();
    _checkLogin(context);
  }

  void _initBubbles() {
    for (int i = 0; i < _numBubbles; i++) {
      _bubbles.add(_Bubble(
        radius: _random.nextDouble() * 20 + 10,
        dx: _random.nextDouble(),
        dy: _random.nextDouble(),
        speed: _random.nextDouble() * 0.3 + 0.1,
        color: _rainbowColors[_random.nextInt(_rainbowColors.length)].withOpacity(0.3),
        fluctuation: _random.nextDouble() * 0.3 + 0.7,
      ));
    }
  }

  void _initAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    
    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
  }

  Future<void> _checkLogin(BuildContext context) async {
    await _getTheme();
    await _getLang();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    islogin = token != null && token.isNotEmpty;

    Future.delayed(
      const Duration(seconds: 5),
      () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => islogin! ? MyHomePage() : login(),
          ),
        );
      },
    );
  }

  Future<void> _getLang() async {
    SharedPreferences indexlangug = await SharedPreferences.getInstance();
    indexlang = indexlangug.getInt("indexlang") ?? 1;
    theTextDecoration = indexlang == 0 ? TextDirection.rtl : TextDirection.ltr;
  }

  Future<void> _getTheme() async {
    SharedPreferences indexthem = await SharedPreferences.getInstance();
    themode = indexthem.getInt("indextheme");
    if (themode == 0) {
      coltext = const Color.fromARGB(255, 73, 73, 73);
      colbg = Colors.white;
    } else {
      coltext = Colors.white;
      colbg = const Color.fromARGB(255, 73, 73, 73);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: theTextDecoration,
      child: Scaffold(
        body: Stack(
          children: [
            // خلفية Gradient ديناميكية
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: themode == 1
                      ? [Colors.black87, Colors.grey.shade900]
                      : [Colors.orange.shade300, Colors.deepOrangeAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // فقاعات قوس قزح خلف الشعار والنص مع تغير الحجم
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _BubblePainter(bubbles: _bubbles, time: _controller.value),
                  child: Container(),
                );
              },
            ),
            // المحتوى المركزي
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: Icon(
                          Icons.fastfood,
                          size: 80,
                          color: Colors.orangeAccent,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Shimmer.fromColors(
                        baseColor: Colors.orangeAccent,
                        highlightColor: Colors.yellowAccent,
                        child: const Text(
                          "Food Flow",
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Shimmer.fromColors(
                        baseColor: Colors.orange,
                        highlightColor: Colors.red,
                        child: const CircularProgressIndicator(
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// نموذج فقاعات مع تغير الحجم
class _Bubble {
  double dx;
  double dy;
  double radius;
  double speed;
  double fluctuation;
  Color color;

  _Bubble({
    required this.dx,
    required this.dy,
    required this.radius,
    required this.speed,
    required this.color,
    required this.fluctuation,
  });
}

// رسام الفقاعات مع تأثير Fluctuation
class _BubblePainter extends CustomPainter {
  final List<_Bubble> bubbles;
  final double time;

  _BubblePainter({required this.bubbles, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    for (var bubble in bubbles) {
      // تغيير الحجم بشكل موجي لتأثير واقعي
      double currentRadius = bubble.radius * (0.8 + 0.2 * sin(time * 2 * pi / bubble.fluctuation));
      final offset = Offset(
        bubble.dx * size.width,
        (bubble.dy - time * bubble.speed) % 1 * size.height,
      );
      final paint = Paint()..color = bubble.color;
      canvas.drawCircle(offset, currentRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
