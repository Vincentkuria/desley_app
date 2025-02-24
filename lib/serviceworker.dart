import 'package:desley_app/onboarding_screen.dart';
import 'package:desley_app/verify_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServiceWorker extends StatefulWidget {
  final String token;
  const ServiceWorker({super.key, required this.token});

  @override
  State<ServiceWorker> createState() => _ServiceWorkerState();
}

class _ServiceWorkerState extends State<ServiceWorker> {
  late String token = widget.token;

  Map<String, dynamic>? data;
  Map<String, dynamic> euser = {};

  getData() async {
    final dio = Dio();
    dio.options.baseUrl = dotenv.env['BASE_URL']!!;
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(minutes: 1);
    dio.options.contentType = 'application/vnd.api+json';
    dio.options.responseType = ResponseType.json;

    try {
      var response = await dio.get('/api/service-worker-data',
          options: Options(headers: {
            'Accept': 'application/vnd.api+json',
            'Authorization': 'Bearer $token'
          }));
//shipping ==null
      setState(() {
        data = response.data;
        print(response);
      });

      // ignore: unused_catch_clause
    } on DioException catch (e) {
      dynamic error = e.response?.data;
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
      if (euser['status']['manager'] == 'pending') {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const VerifyHome()));
      }

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
            'Service Technician',
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
                    dio.options.baseUrl = dotenv.env['BASE_URL']!!;
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
        body: data == null
            ? Center(
                child: Center(
                  child: Text('No Job now check later'),
                ),
              )
            : Column(
                children: [
                  Text(
                    'your group supervisor is ${data?['supervisor']['first_name']} ${data?['supervisor']['last_name']}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                  Text(
                    'email: ${data?['supervisor']['email']}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: 1,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              title: Text(
                                  'Job: ${data?['job']} For: ${data?['count']} hours'),
                              subtitle: Text('Address:${data?['address']}'),
                              trailing: data?['issupervisor']
                                  ? PopupMenuButton(onSelected: (value) async {
                                      if (value == 1) {
                                        final dio = Dio();
                                        dio.options.baseUrl =
                                            dotenv.env['BASE_URL']!!;
                                        dio.options.connectTimeout =
                                            const Duration(seconds: 5);
                                        dio.options.receiveTimeout =
                                            const Duration(minutes: 1);
                                        dio.options.contentType =
                                            'application/vnd.api+json';
                                        dio.options.responseType =
                                            ResponseType.json;

                                        try {
                                          await dio.post('/api/job-done',
                                              data: {
                                                'shipping': data!['shipping'],
                                                'serviceGroup':
                                                    data!['serviceGroup'],
                                              },
                                              options: Options(headers: {
                                                'Accept':
                                                    'application/vnd.api+json',
                                                'Authorization': 'Bearer $token'
                                              }));

                                          setState(() {
                                            data = null;
                                          });
                                        } catch (e) {
                                          //dynamic error = e.response?.data;
                                        }
                                      }
                                    }, itemBuilder: (context) {
                                      return [
                                        const PopupMenuItem(
                                          child: Text('Job Done'),
                                          value: 1,
                                        ),
                                      ];
                                    })
                                  : SizedBox(
                                      width: 0,
                                    ),
                            ),
                          );
                        }),
                  ),
                ],
              ),
      ),
    );
  }
}
