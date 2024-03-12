import 'package:flutter/material.dart';

class Elogin extends StatefulWidget {
  const Elogin({super.key});

  @override
  State<Elogin> createState() => _EloginState();
}

class _EloginState extends State<Elogin> {
  final _emailInputController = TextEditingController();
  final _passwordInputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
              autocorrect: false,
              obscureText: true,
              controller: _passwordInputController,
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.password),
                  prefixIconColor: Colors.indigo,
                  hintText: 'Password',
                  border: OutlineInputBorder()),
            ),
            Container(
              height: 20,
            ),
            MaterialButton(
                color: Colors.indigo,
                onPressed: () {
                  //loign
                },
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.white),
                )),
          ],
        ),
      )),
    );
  }
}
