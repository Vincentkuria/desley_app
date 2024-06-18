import 'package:desley_app/onboarding_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupplierHome extends StatefulWidget {
  String token;
  SupplierHome({super.key, required this.token});

  @override
  State<SupplierHome> createState() => _SupplierHomeState(token: token);
}

class _SupplierHomeState extends State<SupplierHome> {
  String token;
  Map<String, dynamic> euser = {};
  List<dynamic>? data;
  _SupplierHomeState({required this.token});

  getData() async {
    final dio = Dio();
    dio.options.baseUrl = 'http://10.0.2.2:8000';
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(minutes: 1);

    try {
      var response = await dio.get('/api/suptransactions-approved',
          options: Options(headers: {
            'Accept': 'application/vnd.api+json',
            'Authorization': 'Bearer $token'
          }));

      setState(() {
        data = response.data['data'];
      });
      // ignore: unused_catch_clause
    } on DioException catch (e) {
      // dynamic error = e.response?.data;
    }

    try {
      var response = await dio.get('/api/euser',
          options: Options(headers: {
            'Accept': 'application/vnd.api+json',
            'Authorization': 'Bearer $token'
          }));

      setState(() {
        euser = response.data['data'];
      });

      // ignore: unused_catch_clause
    } on DioException catch (e) {
      //dynamic error = e.response?.data;
    }
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

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
          appBar: AppBar(
            title: const Text(
              'Supplier',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: false,
            backgroundColor: Colors.indigo,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          drawer: Container(
            width: 300,
            color: Colors.white,
            child: ListView(
              children: [
                DrawerHeader(
                    decoration: BoxDecoration(color: Colors.indigo[900]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${euser['first_name']}' ' ' '${euser['last_name']}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Colors.white),
                        ),
                        Text(
                          '${euser['email']}',
                          style: TextStyle(color: Colors.indigo[200]),
                        )
                      ],
                    )),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MaterialButton(
                    onPressed: () async {
                      final dio = Dio();
                      dio.options.baseUrl = 'http://10.0.2.2:8000';
                      dio.options.connectTimeout = const Duration(seconds: 5);
                      dio.options.receiveTimeout = const Duration(minutes: 1);
                      dio.options.contentType = 'application/vnd.api+json';
                      dio.options.responseType = ResponseType.json;

                      try {
                        await dio.post('/api/logout',
                            options: Options(headers: {
                              'Accept': 'application/vnd.api+json',
                              'Authorization': 'Bearer $token'
                            }));
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.remove('token');
                        Navigator.push(
                            // ignore: use_build_context_synchronously
                            context,
                            MaterialPageRoute(
                                builder: (context) => const OnBoarding()));

                        // ignore: unused_catch_clause
                      } catch (e) {
                        //dynamic error = e.response?.data;
                      }
                    },
                    color: Colors.indigo,
                    textColor: Colors.white,
                    child: const Text('Logout'),
                  ),
                )
              ],
            ),
          ),
          body: Text(data.toString()),
        ));
  }
}
