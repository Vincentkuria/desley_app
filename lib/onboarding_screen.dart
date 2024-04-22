import 'package:desley_app/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  final controller = PageController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: Colors.indigo,
          onPressed: () {
            if (controller.page == 1) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Login()));
            } else {
              controller.nextPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut);
            }
          },
          child: const Icon(
            Icons.navigate_next,
            size: 30,
            color: Colors.white,
          )),
      body: PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (didPop) {
            return;
          }
          if (controller.page == 1) {
            controller.previousPage(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut);
          } else {
            SystemNavigator.pop();
          }
        },
        child: SafeArea(
            child: Stack(
          children: [
            PageView(
              controller: controller,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Container(
                        height: 20,
                      ),
                      Lottie.asset('assets/images/futuristic.json'),
                      Container(
                        height: 20,
                      ),
                      const Text(
                        'Futuristic farm Machenary',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 30,
                        ),
                      ),
                      Container(
                        height: 20,
                      ),
                      const Text(
                        'get the best farm machenary from Desley Holdings Limited and automate your whole farming and Food processing at affordable prices.',
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Container(
                        height: 20,
                      ),
                      Lottie.asset('assets/images/delivery truck.json'),
                      Container(
                        height: 20,
                      ),
                      const Text(
                        'We deliver',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      ),
                      Container(
                        height: 20,
                      ),
                      const Text(
                        'we deliver all machenary regardles of the size to your door step all over Kenya within 48hrs and provide with a skilled technician to help with the installation process',
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                )
              ],
            ),
            Container(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const Login()));
                  },
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: Colors.indigo, fontSize: 20),
                  ),
                ),
              ),
            ),
            Container(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 10, bottom: 20),
                child: SmoothPageIndicator(
                  controller: controller,
                  count: 2,
                  onDotClicked: (index) {
                    controller.animateToPage(index,
                        duration: const Duration(microseconds: 500),
                        curve: Curves.easeInOut);
                  },
                  effect: const ExpandingDotsEffect(dotHeight: 7),
                ),
              ),
            )
          ],
        )),
      ),
    );
  }
}
