import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VerifyHome extends StatelessWidget {
  const VerifyHome({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        SystemNavigator.pop();
      },
      child: const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(10.0),
          child: Center(
            child: SizedBox(
              height: 200,
              child: Column(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 100,
                    color: Colors.red,
                  ),
                  Text(
                    'Your account is pending approval please wait or contact the Desley admin',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    textAlign: TextAlign.center,
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
