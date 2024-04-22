import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: must_be_immutable
class FinanceHome extends StatefulWidget {
  String token;
  FinanceHome({super.key, required this.token});

  @override
  // ignore: no_logic_in_create_state
  State<FinanceHome> createState() => _FinanceHomeState(token: token);
}

class _FinanceHomeState extends State<FinanceHome> {
  String token;
  _FinanceHomeState({required this.token});
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
      child: Scaffold(
        body: Container(
          child: Text('Give me money'),
        ),
      ),
    );
  }
}
