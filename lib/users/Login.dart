import 'package:flutter/material.dart';
import 'package:food_flow/api/AuthService.dart';
import 'package:food_flow/data&theme/langugus.dart';
import 'package:food_flow/data&theme/variable.dart';
import 'package:food_flow/users/HomePage.dart';
import 'package:food_flow/users/create_acount.dart';
import 'package:food_flow/users/splashscren.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';

IconData? iconpass = Icons.visibility;
bool hidenpass = true;
var erorr = AutovalidateMode.disabled;
String? password = '';
String? email = '';
bool isLoading = false; // لا تستعمل nullable لتسهيل الاستخدام

class login extends StatefulWidget {
  login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: theTextDecoration,
      child: Scaffold(
        backgroundColor: colbg,
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(0, 0, 0, 0),
          elevation: 0,
          iconTheme: IconThemeData(color: coltext, size: 30),
          actionsIconTheme: IconThemeData(color: coltext),
        ),
        body: Form(
          autovalidateMode: erorr,
          key: _formKey,
          child: ListView(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      // color: colbg,
                      borderRadius: BorderRadius.circular(30),
                      image: DecorationImage(
                        image: themode == 1
                            ? AssetImage('assets/food_flow_dark.jpg')
                            : AssetImage('assets/food_flow_light.jpg'),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Shimmer.fromColors(
                      baseColor: Colors.orange,
                      highlightColor: Colors.red,
                      child: Text(
                        langugus[indexlang]['welcomeBack'],
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 30, right: 30, bottom: 10),
                    child: TextFormField(
                      textInputAction: TextInputAction.send,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: colbg),
                      validator: (value) {
                        return !GetUtils.isEmail(value ?? "")
                            ? 'ايميل غير صالح '
                            : null;
                      },
                      decoration: InputDecoration(
                        fillColor: Colors.orange,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          gapPadding: 10,
                        ),
                        prefixIcon: Icon(Icons.email,
                            color: Color.fromARGB(255, 234, 211, 6)),
                        labelText: langugus[indexlang]['gmail'],
                        labelStyle: TextStyle(color: coltext),
                      ),
                      onChanged: (v) => email = v,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 30, right: 30, top: 10, bottom: 10),
                    child: TextFormField(
                      obscureText: hidenpass,
                      cursorColor: coltext,
                      keyboardType: TextInputType.visiblePassword,
                      style: TextStyle(color: colbg),
                      validator: (value) {
                        if ((value ?? "").length >= 6) return null;
                        return 'كلمة المرور غير صحيحة ';
                      },
                      decoration: InputDecoration(
                        fillColor: Colors.orange,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          gapPadding: 10,
                        ),
                        labelText: langugus[indexlang]['password'],
                        suffixIcon: IconButton(
                          icon: Icon(hidenpass
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() => hidenpass = !hidenpass);
                          },
                        ),
                        prefixIcon: Icon(Icons.lock, color: Colors.yellow),
                      ),
                      onChanged: (v) => password = v,
                    ),
                  ),
                ],
              ),

              // زر تسجيل الدخول
              Column(
                children: [
                  Center(
                    child: !isLoading
                        ? ElevatedButton.icon(
                            onPressed: () async {
                              setState(() => erorr = AutovalidateMode.always);

                              if (_formKey.currentState!.validate()) {
                                setState(() => isLoading = true);

                                try {
                                  final res = await AuthService.loginUser(
                                    email: email!,
                                    password: password!,
                                  );

                                  print("✅ ${res.message}");
                                  print("👤 ${res.user.username}");
                                  print("🔑 ${res.token}");

                                  // تخزين التوكن في SharedPreferences
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setString("token", res.token);
                                  await prefs.setString(
                                      "username", res.user.username);
                                  await prefs.setString(
                                      "email", res.user.email);

                                  // الانتقال إلى الصفحة الرئيسية
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: ((context) => MyHomePage()),
                                    ),
                                  );
                                } catch (e) {
                                  // لو في خطأ من API
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text("فشل تسجيل الدخول ⚠️ \n $e"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                } finally {
                                  setState(() => isLoading = false);
                                }
                              }
                            },
                            icon: Icon(Icons.login,
                                size: 30, color: Colors.white),
                            label: Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Text(
                                langugus[indexlang]['login'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              Text('جاري تسجيل الدخول'),
                              SizedBox(height: 8),
                              CircularProgressIndicator(),
                            ],
                          ),
                  ),
                  SizedBox(height: 20),
                ],
              ),

              // الذهاب لإنشاء حساب
              Container(
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.only(bottom: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      langugus[indexlang]['ifyoudonthaveacount'],
                      style: TextStyle(
                        color: coltext,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(width: 10),
                    InkWell(
                      child: Text(
                        langugus[indexlang]['clickhere'],
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateAcount()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
