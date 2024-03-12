import 'package:desley_app/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _fetchApiData();
  }

  Future<void> _fetchApiData() async {
    Future.delayed(
        const Duration(seconds: 2),
        () => {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const OnBoarding()))
            });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [Colors.indigo, Colors.lightBlue]),
        ),
        child: Center(
          child: Image.asset('assets/images/logo.png', width: 150, height: 150),
        ),
      ),
    );
  }
}
