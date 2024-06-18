// ignore_for_file: use_build_context_synchronously

import 'package:desley_app/Manager_screen.dart';
import 'package:desley_app/driver_screen.dart';
import 'package:desley_app/finance_home_screen.dart';
import 'package:desley_app/home_screen.dart';
import 'package:desley_app/inventory_screen.dart';
import 'package:desley_app/onboarding_screen.dart';
import 'package:desley_app/supervisor_home_screen.dart';
import 'package:desley_app/supplier_screen.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _fetchApiData();
  }

  Future<void> _fetchApiData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // ignore: await_only_futures
    var token = await prefs.getString('token');
    // ignore: avoid_print
    print(token);
    String? role;

    if (token != null) {
      // ignore: await_only_futures
      role = await prefs.getString(token);
      // ignore: avoid_print
      print(role);
      if (role != null) {
        if (role == 'finance') {
          Future.delayed(
              const Duration(seconds: 2),
              () => {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FinanceHome(
                                  token: token,
                                )))
                  });
        } else if (role == 'supervisor') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SupervisorHome(
                        token: token,
                      )));
        } else if (role == 'driver') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DriverHome(token: token)));
        } else if (role == 'inventory manager') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => InventoryHome(token: token)));
        } else if (role == 'supplier') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SupplierHome(token: token)));
        } else if (role == 'manager') {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => ManagerHome()));
        }
      } else {
        //check if user is verified and send him to the verify screen
        Future.delayed(
            const Duration(seconds: 2),
            () => {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomeScreen(
                                token: token,
                              )))
                });
      }
    } else {
      Future.delayed(
          const Duration(seconds: 2),
          () => {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const OnBoarding()))
              });
    }
  }

  // @override
  // void dispose() {
  //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
  //       overlays: SystemUiOverlay.values);
  //   super.dispose();
  // }

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
