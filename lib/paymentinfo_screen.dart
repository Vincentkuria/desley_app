import 'package:desley_app/home_screen.dart';
import 'package:flutter/material.dart';

class PaymentInfo extends StatefulWidget {
  final String token;
  // ignore: prefer_const_constructors_in_immutables
  PaymentInfo({super.key, required this.token});

  @override
  // ignore: no_logic_in_create_state
  State<PaymentInfo> createState() => _PaymentInfoState(token: token);
}

class _PaymentInfoState extends State<PaymentInfo> {
  String token;
  _PaymentInfoState({required this.token});
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) => Navigator.push(context,
          MaterialPageRoute(builder: (context) => HomeScreen(token: token))),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 70,
                ),
                Image.asset(
                  'assets/images/logo.png',
                  height: 60,
                  width: 60,
                  fit: BoxFit.contain,
                ),
                const Text(
                  'Desley',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(
                  height: 40,
                ),
                Image.asset(
                  'assets/images/done.png',
                  height: 100,
                  width: 100,
                  fit: BoxFit.contain,
                ),
                Text(
                  'Order received successfully',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 150,
                ),
                MaterialButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomeScreen(token: token))),
                  child: const Text('Back Home'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
