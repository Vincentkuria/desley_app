import 'package:desley_app/elogin_screen.dart';
import 'package:desley_app/home_screen.dart';
import 'package:desley_app/register_screen.dart';
import 'package:desley_app/slogin_screen.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var emailNull = false;
  var passwordNull = false;
  var loginError = '';
  final _emailInputController = TextEditingController();
  final _passwordInputController = TextEditingController();

  void _storeValue(String key, String value, BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var stored = await prefs.setString(key, value);
    if (stored) {
      Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(
                    token: value,
                  )));
    }
  }

  void _loginCustomer(BuildContext context) async {
    final dio = Dio();
    dio.options.baseUrl = 'http://165.22.123.187';
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(minutes: 1);
    final data = {
      'email': _emailInputController.text.toLowerCase().trim(),
      'password': _passwordInputController.text,
    };

    try {
      var dioresponse = await dio.post('/api/login', data: data);
      String token = dioresponse.data['data']['token'];
      // ignore: use_build_context_synchronously
      _storeValue('token', token, context);
    } on DioException catch (e) {
      if (e.response != null) {
        loginError = e.response!.data['message'];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
              onChanged: (text) {
                setState(() {
                  loginError = '';
                });
              },
              controller: _emailInputController,
              decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email),
                  prefixIconColor: emailNull ? Colors.red : Colors.indigo,
                  hintText: 'email',
                  hintStyle:
                      TextStyle(color: emailNull ? Colors.red : Colors.grey),
                  border: const OutlineInputBorder()),
            ),
            Container(
              height: 20,
            ),
            TextField(
              onChanged: (text) {
                setState(() {
                  loginError = '';
                });
              },
              autocorrect: false,
              obscureText: true,
              controller: _passwordInputController,
              decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.password),
                  prefixIconColor: passwordNull ? Colors.red : Colors.indigo,
                  hintText: 'Password',
                  hintStyle:
                      TextStyle(color: passwordNull ? Colors.red : Colors.grey),
                  border: const OutlineInputBorder()),
            ),
            // ignore: sized_box_for_whitespace
            Container(
              height: 20,
              child: Text(
                loginError,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            MaterialButton(
                color: Colors.indigo,
                onPressed: () {
                  if (_emailInputController.text.isEmpty ||
                      _passwordInputController.text.isEmpty) {
                    if (_emailInputController.text.isEmpty) {
                      setState(() {
                        emailNull = true;
                      });
                    }
                    if (_passwordInputController.text.isEmpty) {
                      setState(() {
                        passwordNull = true;
                      });
                    }
                    return;
                  }
                  setState(() {
                    _loginCustomer(context);
                  });
                },
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.white),
                )),
            Container(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Elogin()));
              },
              child: Text(
                'click me to login as an employee',
                style: TextStyle(color: Colors.blue[600]),
              ),
            ),
            Container(
              height: 10,
            ),
            Text('or'),
            Container(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Slogin()));
              },
              child: Text(
                'click me to login as a supplier',
                style: TextStyle(color: Colors.blue[600]),
              ),
            ),
            Container(
              height: 20,
            ),
            const Text(
              'if you are new here please register below',
              style: TextStyle(color: Colors.grey),
            ),
            MaterialButton(
                color: Colors.indigo,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Register()));
                },
                child: const Text(
                  'Register',
                  style: TextStyle(color: Colors.white),
                )),
          ],
        ),
      )),
    );
  }
}
