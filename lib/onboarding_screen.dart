import 'package:Desley/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          SystemNavigator.pop();
        },
        child: SafeArea(
            child: Stack(
          children: [
            PageView(
              controller: controller,
              children: [
                Container(
                  color: Colors.lightBlue[50],
                ),
                Container(
                  color: Colors.lightBlue[50],
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
