import 'dart:async';
import 'package:flutter/material.dart';
import 'package:food_flow/data&theme/langugus.dart';
import 'package:food_flow/data&theme/variable.dart';
import 'package:food_flow/users/HomePage.dart';
import 'package:food_flow/users/splashscren.dart';


class code_verification extends StatefulWidget {
  const code_verification({Key? key}) : super(key: key);

  @override
  State<code_verification> createState() => _code_verificationState();
}

class _code_verificationState extends State<code_verification> {
  bool timerisend = false;
  Timer? _timer;
  int time = 30;
  @override
  void initState() {
    starttimer();
    super.initState();
  }

  void starttimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (time > 0) {
        setState(() {
          time--;
        });
      } else {
        setState(() {
          timerisend = true;
        });
        _timer!.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: theTextDecoration,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: colbg,
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      langugus[indexlang]['verification'],
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.w900,
                        color: coltext,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      langugus[indexlang]['EnterTheverificationcode'],
                      style: TextStyle(
                        fontSize: 20,
                        color: coltext,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 10, left: 50, right: 50, bottom: 10),
                    child: SizedBox(
                      height: 50,
                      child: TextField(
                        textAlignVertical: TextAlignVertical.bottom,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              gapPadding: 10),
                          fillColor: Colors.orange,
                          enabled: true,
                          filled: true,
                          hintText: langugus[indexlang]['Entercode'],
                          hintStyle:
                              const TextStyle(color: Colors.white, fontSize: 17),
                        ),
                        onTap: () {},
                        onChanged: (value) {},
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                         langugus[indexlang]['Thiscodewillexpiredin'],
                          style: TextStyle(fontSize: null, color: coltext),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "  00:$time  ",
                          style: const TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      )
                    ],
                  ),
                  timerisend == true
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            MaterialButton(
                              onPressed: () {
                                setState(
                                  () {
                                    time = 30;
                                    timerisend = false;
                                  },
                                );
                                starttimer();
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.mail,
                                    color: coltext,
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(left: 20, right: 20),
                                    child: Text(
                                      'This code will expired in',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: coltext,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : const SizedBox(),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 100),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.orange,
                    ),
                    child: MaterialButton(
                      height: 50,
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyHomePage(),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.double_arrow_rounded,
                            color: Colors.white,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 20, right: 20),
                            child: Text(
                              'Next',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 19,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
