// ignore_for_file: use_build_context_synchronously
import 'package:desley_app/supplier_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Slogin extends StatefulWidget {
  const Slogin({super.key});

  @override
  State<Slogin> createState() => _SloginState();
}

class _SloginState extends State<Slogin> {
  final _emailInputController = TextEditingController();
  final _passwordInputController = TextEditingController();
  String? errorMessage;

  void _storeValue(String key, String value, BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var stored = await prefs.setString(key, value);
    var stored2 = await prefs.setString(value, 'supplier');
    if (stored && stored2) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => SupplierHome(token: value)));
    }
  }

  loginEmployee() async {
    final dio = Dio();
    dio.options.baseUrl = 'http://138.68.154.175';
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(minutes: 1);
    dio.options.contentType = 'application/vnd.api+json';
    dio.options.responseType = ResponseType.json;

    try {
      var response = await dio.post('/api/slogin',
          options: Options(headers: {
            'Accept': 'application/vnd.api+json',
          }),
          data: {
            'email': _emailInputController.text.toLowerCase().trim(),
            'password': _passwordInputController.text
          });
      var data = response.data['data'];
      _storeValue('token', data['token'], context);
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
                'Only for Suppliers',
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
