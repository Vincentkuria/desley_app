// ignore_for_file: use_build_context_synchronously

import 'package:desley_app/Manager_screen.dart';
import 'package:desley_app/driver_screen.dart';
import 'package:desley_app/finance_home_screen.dart';
import 'package:desley_app/inventory_screen.dart';
import 'package:desley_app/service_manager.dart';
import 'package:desley_app/serviceworker.dart';
import 'package:desley_app/supervisor_home_screen.dart';
import 'package:desley_app/supplier_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Elogin extends StatefulWidget {
  const Elogin({super.key});

  @override
  State<Elogin> createState() => _EloginState();
}

class _EloginState extends State<Elogin> {
  final _emailInputController = TextEditingController();
  final _passwordInputController = TextEditingController();
  String? errorMessage;

  storeValue(
      String key, String value, String role, BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var stored = await prefs.setString(key, value);
    var stored2 = await prefs.setString(value, role);
    if (stored && stored2) {
      if (role == 'finance') {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FinanceHome(
                      token: value,
                    )));
      } else if (role == 'supervisor') {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SupervisorHome(
                      token: value,
                    )));
      } else if (role == 'driver') {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => DriverHome(token: value)));
      } else if (role == 'inventory manager') {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => InventoryHome(token: value)));
      } else if (role == 'supplier') {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SupplierHome(token: value)));
      } else if (role == 'manager') {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ManagerHome(token: value)));
      } else if (role == 'service manager') {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ServiceManager(token: value)));
      } else if (role == 'service') {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ServiceWorker(token: value)));
      }
    }
  }

  loginEmployee() async {
    final dio = Dio();
    dio.options.baseUrl = 'http://192.168.100.3:8000';
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(minutes: 1);
    dio.options.contentType = 'application/vnd.api+json';
    dio.options.responseType = ResponseType.json;

    try {
      var response = await dio.post('/api/elogin',
          options: Options(headers: {
            'Accept': 'application/vnd.api+json',
          }),
          data: {
            'email': _emailInputController.text.toLowerCase().trim(),
            'password': _passwordInputController.text
          });
      var data = response.data['data'];

      storeValue('token', data['token'], data['role'], context);
    } on DioException catch (e) {
      if (e.response != null) {
        setState(() {
          errorMessage = e.response!.data['message'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Only for employees',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              Container(
                height: 30,
              ),
              Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 60,
                  ),
                  const Text(
                    'Desley',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
              Container(
                height: 40,
              ),
              TextField(
                onChanged: (value) {
                  if (errorMessage != null) {
                    setState(() {
                      errorMessage = null;
                    });
                  }
                },
                controller: _emailInputController,
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    prefixIconColor: Colors.indigo,
                    hintText: 'email',
                    border: OutlineInputBorder()),
              ),
              Container(
                height: 20,
              ),
              TextField(
                onChanged: (value) {
                  if (errorMessage != null) {
                    setState(() {
                      errorMessage = null;
                    });
                  }
                },
                autocorrect: false,
                obscureText: true,
                controller: _passwordInputController,
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.password),
                    prefixIconColor: Colors.indigo,
                    hintText: 'Password',
                    border: OutlineInputBorder()),
              ),
              errorMessage != null
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : Container(
                      height: 20,
                    ),
              MaterialButton(
                  color: Colors.indigo,
                  onPressed: () {
                    if (_emailInputController.text.isNotEmpty &&
                        _passwordInputController.text.isNotEmpty) {
                      loginEmployee();
                    }
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(color: Colors.white),
                  )),
            ],
          ),
        ),
      )),
    );
  }
}
