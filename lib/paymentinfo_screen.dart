import 'package:desley_app/home_screen.dart';
import 'package:flutter/material.dart';

class PaymentInfo extends StatefulWidget {
  final String token;
  final bool ordertype;
  final bool ordertype2;

  const PaymentInfo(
      {super.key,
      required this.token,
      required this.ordertype,
      required this.ordertype2});

  @override
  State<PaymentInfo> createState() => _PaymentInfoState();
}

class _PaymentInfoState extends State<PaymentInfo> {
  late String token = widget.token;
  late bool ordertype = widget.ordertype;
  late bool ordertype2 = widget.ordertype2;

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
                ordertype && ordertype2
                    ? Text(
                        'Service request and Order received successfully',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : SizedBox(
                        height: 0,
                      ),
                ordertype && !ordertype2
                    ? Text(
                        'Service received successfully',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : SizedBox(
                        height: 0,
                      ),
                !ordertype
                    ? Text(
                        'Order received successfully',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : SizedBox(
                        height: 0,
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
