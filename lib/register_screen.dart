import 'package:desley_app/home_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  var firstname = false;
  var lastname = false;
  var email = false;
  var phoneno = false;
  var _password = false;
  var _confirmpassword = false;
  var passwordError = '';

  //check for null
  void _register() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_firstnameController.text.isEmpty) {
      firstname = true;
    }

    if (_lastnameController.text.isEmpty) {
      lastname = true;
    }
    if (_emailController.text.isEmpty) {
      email = true;
    }
    if (_phoneNoController.text.isEmpty) {
      phoneno = true;
    }
    if (_passwordController.text.isEmpty) {
      _password = true;
    }
    if (_confirmPasswordController.text.isEmpty) {
      _confirmpassword = true;
    }
    if (_firstnameController.text.isNotEmpty &&
        _lastnameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _phoneNoController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty) {
      if (!_emailController.text.trim().contains('@') ||
          !_emailController.text.trim().contains('.')) {
        passwordError = 'please give a valid email adress';
        return;
      }

      if (_phoneNoController.text.trim().length < 10) {
        passwordError = 'phone number should be a minimum of  10 numbers';
        return;
      }
      if (!RegExp(r'^\d+$').hasMatch(_phoneNoController.text.trim())) {
        passwordError = 'please give a valid phone number';
        return;
      }
      if (_passwordController.text.length < 8) {
        passwordError = 'password should be a minimum of 8 characters';
        return;
      }
      if (_passwordController.text != _confirmPasswordController.text) {
        passwordError = 'password confirmation does not match';
        return;
      }
      final dio = Dio();
      dio.options.baseUrl = 'http://192.168.100.3:8000';
      dio.options.connectTimeout = const Duration(seconds: 5);
      dio.options.receiveTimeout = const Duration(minutes: 1);
      dio.options.contentType = 'application/vnd.api+json';
      dio.options.responseType = ResponseType.json;
      final data = {
        'first_name': _firstnameController.text,
        'last_name': _lastnameController.text,
        'email': _emailController.text.toLowerCase().trim(),
        'phone_no': _phoneNoController.text,
        'password': _passwordController.text,
        'password_confirmation': _confirmPasswordController.text,
      };

      try {
        var dioresponse = await dio.post('/api/register',
            data: data,
            options: Options(headers: {'Accept': 'application/vnd.api+json'}));
        String token = dioresponse.data['data']['token'];
        var stored = await prefs.setString('token', token);
        if (stored) {
          Navigator.push(
              // ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(
                  builder: (context) => HomeScreen(
                        token: token,
                      )));
        }
      } on DioException catch (e) {
        if (e.response != null) {
          passwordError = e.response?.data['message'];
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                'Register',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              Container(
                height: 20,
              ),
              TextField(
                onChanged: (text) {
                  setState(() {
                    passwordError = '';
                  });
                },
                controller: _firstnameController,
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person),
                    prefixIconColor: firstname ? Colors.red : Colors.indigo,
                    hintText: 'first name',
                    hintStyle:
                        TextStyle(color: firstname ? Colors.red : Colors.grey),
                    border: const OutlineInputBorder()),
              ),
              Container(
                height: 20,
              ),
              TextField(
                onChanged: (text) {
                  setState(() {
                    passwordError = '';
                  });
                },
                controller: _lastnameController,
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person),
                    prefixIconColor: lastname ? Colors.red : Colors.indigo,
                    hintText: 'last name',
                    hintStyle:
                        TextStyle(color: lastname ? Colors.red : Colors.grey),
                    border: const OutlineInputBorder()),
              ),
              Container(
                height: 20,
              ),
              TextField(
                onChanged: (text) {
                  setState(() {
                    passwordError = '';
                  });
                },
                controller: _phoneNoController,
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.call),
                    prefixIconColor: phoneno ? Colors.red : Colors.indigo,
                    hintText: 'phone number',
                    hintStyle:
                        TextStyle(color: phoneno ? Colors.red : Colors.grey),
                    border: const OutlineInputBorder()),
              ),
              Container(
                height: 20,
              ),
              TextField(
                onChanged: (text) {
                  setState(() {
                    passwordError = '';
                  });
                },
                controller: _emailController,
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email),
                    prefixIconColor: email ? Colors.red : Colors.indigo,
                    hintText: 'email',
                    hintStyle:
                        TextStyle(color: email ? Colors.red : Colors.grey),
                    border: const OutlineInputBorder()),
              ),
              Container(
                height: 20,
              ),
              TextField(
                onChanged: (text) {
                  setState(() {
                    passwordError = '';
                  });
                },
                autocorrect: false,
                obscureText: true,
                controller: _passwordController,
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.password),
                    prefixIconColor: _password ? Colors.red : Colors.indigo,
                    hintText: 'password',
                    hintStyle:
                        TextStyle(color: _password ? Colors.red : Colors.grey),
                    border: const OutlineInputBorder()),
              ),
              Container(
                height: 20,
              ),
              TextField(
                onChanged: (text) {
                  setState(() {
                    passwordError = '';
                  });
                },
                autocorrect: false,
                obscureText: true,
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.password),
                    prefixIconColor:
                        _confirmpassword ? Colors.red : Colors.indigo,
                    hintText: 'confirm password',
                    hintStyle: TextStyle(
                        color: _confirmpassword ? Colors.red : Colors.grey),
                    border: const OutlineInputBorder()),
              ),
              // ignore: sized_box_for_whitespace
              Container(
                height: 20,
                child: Text(
                  passwordError,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              MaterialButton(
                  color: Colors.indigo,
                  onPressed: () {
                    setState(() {
                      _register();
                    });
                  },
                  child: const Text(
                    'Register',
                    style: TextStyle(color: Colors.white),
                  )),
            ],
          ),
        ),
      )),
    );
  }
}
