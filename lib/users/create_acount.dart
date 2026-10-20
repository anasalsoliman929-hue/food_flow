import 'package:flutter/material.dart';
import 'package:food_flow/api/AuthService.dart';
import 'package:food_flow/data&theme/langugus.dart';
import 'package:food_flow/data&theme/variable.dart';
import 'package:food_flow/users/HomePage.dart';
import 'package:food_flow/users/Login.dart';
import 'package:food_flow/users/code_verification.dart';
import 'package:food_flow/users/splashscren.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

IconData? iconpassword = Icons.visibility;
bool hidenpassword = true;
String? nameuser = '';
String? password = '';
String? email = '';
String? phone = ''; // حقل جديد للرقم

class CreateAcount extends StatefulWidget {
  const CreateAcount({super.key});

  @override
  State<CreateAcount> createState() => _CreateAcountState();
}

class _CreateAcountState extends State<CreateAcount> {
  // savevaleodlogin() async {
  //   SharedPreferences bollogin = await SharedPreferences.getInstance();
  //   bollogin.setBool("islogin", true);
  //   print('is saved');
  // }

  // savetoken() async {
  //   SharedPreferences thetoken = await SharedPreferences.getInstance();
  //   thetoken.setString("thetoken", token!);
  //   print('thetoken is saved');
  //   print(token);
  // }

  final _formKey1 = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: theTextDecoration,
      child: Scaffold(
        backgroundColor: colbg,
        body: Form(
          key: _formKey1,
          child: Container(
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            // decoration: const BoxDecoration(
            //   image: DecorationImage(
            //     image: AssetImage('assets/h.jpg'),
            //     fit: BoxFit.fill,
            //   ),
            // ),
            child: ListView(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: colbg,
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
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Shimmer.fromColors(
                        baseColor: Colors.orange,
                        highlightColor: Colors.red,
                        child: Text(
                          langugus[indexlang]['welcome'],
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ),
                    // const CircleAvatar(
                    //   radius: 100,
                    //   backgroundImage: AssetImage(
                    //     'assets/h.jpg',
                    //   ),
                    // ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30, right: 30),
                      child: TextFormField(
                        textInputAction: TextInputAction.send,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: colbg),
                        validator: (value) {
                          Colors.amber;
                          return !GetUtils.isEmail(value!)
                              ? 'البريد غير صالح '
                              : null;
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              gapPadding: 10),
                          fillColor: Colors.orange,
                          filled: true,
                          prefixIcon: const Icon(
                            Icons.email,
                            color: Color.fromARGB(255, 234, 211, 6),
                          ),
                          labelText: langugus[indexlang]['gmail'],
                          labelStyle: const TextStyle(color: Colors.white),
                          hintStyle: TextStyle(color: coltext),
                        ),
                        onTap: () {
                          // Get.height;
                        },
                        onChanged: (value) {
                          email = value!;
                          print(value);
                        },
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 30, right: 30, top: 10),
                      child: TextFormField(
                        textInputAction: TextInputAction.send,
                        keyboardType: TextInputType.name,
                        style: TextStyle(color: colbg),
                        validator: (value) {
                          return !GetUtils.isUsername(value!)
                              ? 'الاسم غير صالح '
                              : null;
                        },
                        decoration: InputDecoration(
                          fillColor: Colors.orange,
                          filled: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              gapPadding: 10),
                          prefixIcon: const Icon(
                            Icons.health_and_safety,
                            color: Color.fromARGB(255, 234, 211, 6),
                          ),
                          labelText: langugus[indexlang]['name'],
                          hintStyle: TextStyle(color: coltext),
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                        onTap: () {},
                        onChanged: (value) {
                          nameuser = value!;
                          print(value);
                        },
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 30, right: 30, top: 10),
                      child: TextFormField(
                        obscureText: hidenpassword,
                        style: TextStyle(color: colbg),
                        validator: (value) {
                          return (value!.length < 6)
                              ? 'cant_be_less_than_8_letter'
                              : null;
                        },
                        decoration: InputDecoration(
                          fillColor: Colors.orange,
                          filled: true,
                          hintText: '',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              gapPadding: 10),
                          labelText: langugus[indexlang]['password'],
                          labelStyle: const TextStyle(color: Colors.white),
                          suffixIconColor:
                              const Color.fromARGB(255, 3, 68, 121),
                          hintStyle: TextStyle(color: coltext),
                          suffixIcon: InkWell(
                            child: IconButton(
                              icon: Icon(
                                iconpassword,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (hidenpassword == true) {
                                    iconpassword = Icons.visibility_off;
                                    hidenpassword = false;
                                  } else {
                                    iconpassword = Icons.visibility;
                
                                    hidenpassword = true;
                                  }
                                });
                              },
                            ),
                            onLongPress: () {
                              setState(() {
                                iconpassword = Icons.visibility_off;
                                hidenpassword = false;
                              });
                
                              Future.delayed(
                                const Duration(seconds: 2),
                                () {
                                  setState(() {
                                    iconpassword = Icons.visibility;
                                    hidenpassword = true;
                                  });
                                },
                              );
                            },
                          ),
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Colors.green,
                          ),
                        ),
                        onTap: () {},
                        onChanged: (value) {
                          password = value;
                        },
                        onEditingComplete: () {},
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 30, right: 30, top: 10),
                      child: TextFormField(
                        keyboardType: TextInputType.phone,
                        style: TextStyle(color: colbg),
                        validator: (value) {
                          return (value == null || value.length < 8)
                              ? 'رقم الهاتف غير صالح'
                              : null;
                        },
                        decoration: InputDecoration(
                          fillColor: Colors.orange,
                          filled: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              gapPadding: 10),
                          prefixIcon: const Icon(
                            Icons.phone,
                            color: Color.fromARGB(255, 234, 211, 6),
                          ),
                          labelText: langugus[indexlang]['phone'],
                          labelStyle: const TextStyle(color: Colors.white),
                          hintStyle: TextStyle(color: coltext),
                        ),
                        onChanged: (value) {
                          phone = value;
                        },
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (_formKey1.currentState!.validate()) {
                      try {
                        // تسجيل المستخدم
                        final res = await AuthService.registerUser(
                          username: nameuser!,
                          email: email!,
                          password: password!,
                          phone: phone!,
                          theme: themode == 1 ? "dark" : "light",
                        );
                
                        // حفظ التوكن وبيانات المستخدم
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString("token", res.token);
                        await prefs.setString("username", res.user.username);
                        await prefs.setString("email", res.user.email);
                        await prefs.setBool("islogin", true);
                
                        // الانتقال للصفحة الرئيسية
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => MyHomePage()),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("فشل التسجيل: $e"),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('الرجاء إدخال جميع البيانات بشكل صحيح'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.login, size: 35),
                  label: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      langugus[indexlang]['singin'],
                      style: const TextStyle(
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
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        langugus[indexlang]['ifyouhaveacount'],
                        style: TextStyle(
                          color: coltext,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      InkWell(
                        child: Text(
                          langugus[indexlang]['clickhere'],
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => login(),
                            ),
                          );
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   const SnackBar(
                          //     content: Text(
                          //       'المعلومات التي ادخلتها خاطئة',
                          //     ),
                          //   ),
                          // );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
