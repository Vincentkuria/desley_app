import 'package:desley_app/feedback_message.dart';
import 'package:desley_app/onboarding_screen.dart';
import 'package:desley_app/verify_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class ManagerHome extends StatefulWidget {
  String token;
  ManagerHome({super.key, required this.token});

  @override
  // ignore: no_logic_in_create_state
  State<ManagerHome> createState() => _ManagerHomeState(token: token);
}

class _ManagerHomeState extends State<ManagerHome> {
  String token;
  _ManagerHomeState({required this.token});
  final controller = PageController();
  int currentPage = 0;
  Map<String, dynamic> euser = {};
  List<dynamic>? data1 = [];
  List<dynamic>? data2 = [];
  List<dynamic>? data3 = [];

  getData() async {
    final dio = Dio();
    dio.options.baseUrl = 'http://138.68.154.175';
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(minutes: 1);
    dio.options.contentType = 'application/vnd.api+json';
    dio.options.responseType = ResponseType.json;

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
      // dynamic error = e.response?.data;
    }

    try {
      var response = await dio.get('/api/suptransactions',
          options: Options(headers: {
            'Accept': 'application/vnd.api+json',
            'Authorization': 'Bearer $token'
          }));

      setState(() {
        var data = response.data['data'];
        for (var element in data!) {
          if (element['status']['manager'] == 'pending') {
            data1?.add(element);
          }
        }
      });

      // ignore: unused_catch_clause
    } on DioException catch (e) {
      dynamic error = e.response?.data;
      print(error);
    }

    try {
      var response = await dio.get('/api/inventories',
          options: Options(headers: {
            'Accept': 'application/vnd.api+json',
            'Authorization': 'Bearer $token'
          }));

      setState(() {
        var data = response.data['data'];
        for (var element in data) {
          if (element['status']['manager'] == 'pending') {
            data2?.add(element);
          }
        }
      });

      // ignore: unused_catch_clause
    } on DioException catch (e) {
      dynamic error = e.response?.data;
      print(error);
    }

    try {
      var response = await dio.get('/api/suppliers',
          options: Options(headers: {
            'Accept': 'application/vnd.api+json',
            'Authorization': 'Bearer $token'
          }));

      setState(() {
        var data = response.data['data'];
        print(data);
        for (var element in data) {
          if (element['status']['manager'] == 'pending') {
            print('hello hhhhhhh');
            print(element);
            data3?.add(element);
            print('hello hhhhhhh');
            print(data3);
          }
        }
      });

      // ignore: unused_catch_clause
    } on DioException catch (e) {
      dynamic error = e.response?.data;
      print(error);
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
            'Manager',
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
                    dio.options.baseUrl = 'http://138.68.154.175';
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
              ),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                FeedbackMessageScreen(token: token)));
                  },
                  child: Text('Feedback')),
            ],
          ),
        ),
        body: PageView(
          controller: controller,
          children: [
            Container(
              child: data1 == null
                  ? Center(
                      child: Lottie.asset('assets/images/loading.json',
                          height: 100),
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Restock requests',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                              itemCount: data1!.length,
                              itemBuilder: (context, index) {
                                var dataItem = data1?[index];
                                return ListTile(
                                  title: Text(dataItem['inventory']['name']),
                                  subtitle: Row(
                                    children: [
                                      Text(
                                        'count: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(dataItem['count'].toString()),
                                    ],
                                  ),
                                  trailing: PopupMenuButton(
                                      onSelected: (value) async {
                                        final dio = Dio();
                                        dio.options.baseUrl =
                                            'http://138.68.154.175';
                                        dio.options.connectTimeout =
                                            const Duration(seconds: 5);
                                        dio.options.receiveTimeout =
                                            const Duration(minutes: 1);
                                        dio.options.contentType =
                                            'application/vnd.api+json';
                                        dio.options.responseType =
                                            ResponseType.json;
                                        if (value == 1) {
                                          try {
                                            // ignore: unused_local_variable
                                            var response = await dio.post(
                                                '/api/approve-suptransactions',
                                                data: {'id': dataItem['id']},
                                                options: Options(headers: {
                                                  'Accept':
                                                      'application/vnd.api+json',
                                                  'Authorization':
                                                      'Bearer $token'
                                                }));

                                            setState(() {
                                              data1!.removeAt(index);
                                            });
                                            print(response.data);

                                            // ignore: unused_catch_clause
                                          } on DioException catch (e) {
                                            // dynamic error = e.response?.data;
                                          }
                                        } else {
                                          try {
                                            // ignore: unused_local_variable
                                            var response = await dio.post(
                                                '/api/cancel-suptransactions',
                                                data: {'id': dataItem['id']},
                                                options: Options(headers: {
                                                  'Accept':
                                                      'application/vnd.api+json',
                                                  'Authorization':
                                                      'Bearer $token'
                                                }));

                                            setState(() {
                                              data1!.removeAt(index);
                                            });
                                            print(response.data);

                                            // ignore: unused_catch_clause
                                          } on DioException catch (e) {
                                            // dynamic error = e.response?.data;
                                          }
                                        }
                                      },
                                      itemBuilder: (context) => [
                                            PopupMenuItem(
                                                value: 1,
                                                child: Text('Approve')),
                                            PopupMenuItem(
                                                value: 2,
                                                child: Text('Cancel')),
                                          ]),
                                );
                              }),
                        )
                      ],
                    ),
            ),
            Container(
              child: data2 == null
                  ? Center(
                      child: Lottie.asset('assets/images/loading.json',
                          height: 100),
                    )
                  : Column(
                      children: [
                        Text(
                          'New Inventories',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        Expanded(
                          child: ListView.builder(
                              itemCount: data2!.length,
                              itemBuilder: (context, index) {
                                var dataItem = data2?[index];
                                final TextEditingController controller =
                                    TextEditingController();
                                return ListTile(
                                  title: Text(dataItem['name']),
                                  trailing: PopupMenuButton(
                                      onSelected: (value) async {
                                        final dio = Dio();
                                        dio.options.baseUrl =
                                            'http://138.68.154.175';
                                        dio.options.connectTimeout =
                                            const Duration(seconds: 5);
                                        dio.options.receiveTimeout =
                                            const Duration(minutes: 1);
                                        dio.options.contentType =
                                            'application/vnd.api+json';
                                        dio.options.responseType =
                                            ResponseType.json;
                                        if (value == 1) {
                                          try {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Agreed Price'),
                                                    content: TextField(
                                                      controller: controller,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      decoration:
                                                          InputDecoration(
                                                        hintText:
                                                            'Enter the price',
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop(); // Close the dialog without any value
                                                        },
                                                        child: Text('Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () async {
                                                          int? value =
                                                              int.tryParse(
                                                                  controller
                                                                      .text);
                                                          if (value != null) {
                                                            // Pass the integer back
                                                            // ignore: unused_local_variable
                                                            var response =
                                                                await dio.post(
                                                                    '/api/approve-inventories',
                                                                    data: {
                                                                      'id': dataItem[
                                                                          'id'],
                                                                      'price':
                                                                          value
                                                                    },
                                                                    options:
                                                                        Options(
                                                                            headers: {
                                                                          'Accept':
                                                                              'application/vnd.api+json',
                                                                          'Authorization':
                                                                              'Bearer $token'
                                                                        }));

                                                            setState(() {
                                                              data2!.removeAt(
                                                                  index);
                                                            });
                                                            print(
                                                                response.data);

                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          } else {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                  content: Text(
                                                                      "Please enter a valid integer")),
                                                            );
                                                          }
                                                        },
                                                        child: Text('Approve'),
                                                      ),
                                                    ],
                                                  );
                                                });

                                            // ignore: unused_catch_clause
                                          } on DioException catch (e) {
                                            // dynamic error = e.response?.data;
                                          }
                                        } else {
                                          try {
                                            // ignore: unused_local_variable
                                            var response = await dio.post(
                                                '/api/cancel-inventories',
                                                data: {'id': dataItem['id']},
                                                options: Options(headers: {
                                                  'Accept':
                                                      'application/vnd.api+json',
                                                  'Authorization':
                                                      'Bearer $token'
                                                }));

                                            setState(() {
                                              data2!.removeAt(index);
                                            });
                                            print(response.data);

                                            // ignore: unused_catch_clause
                                          } on DioException catch (e) {
                                            // dynamic error = e.response?.data;
                                          }
                                        }
                                      },
                                      itemBuilder: (context) => [
                                            PopupMenuItem(
                                                value: 1,
                                                child: Text(
                                                    'set buying price and Approve')),
                                            PopupMenuItem(
                                                value: 2, child: Text('Cancel'))
                                          ]),
                                );
                              }),
                        )
                      ],
                    ),
            ),
            Container(
              child: data3 == null
                  ? Center(
                      child: Lottie.asset('assets/images/loading.json',
                          height: 100),
                    )
                  : Column(
                      children: [
                        Text(
                          'New Suppliers',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        Expanded(
                          child: ListView.builder(
                              itemCount: data3!.length,
                              itemBuilder: (context, index) {
                                var dataItem = data3?[index];
                                return ListTile(
                                  title: Text(dataItem['company_name']),
                                  trailing: PopupMenuButton(
                                      onSelected: (value) async {
                                        final dio = Dio();
                                        dio.options.baseUrl =
                                            'http://138.68.154.175';
                                        dio.options.connectTimeout =
                                            const Duration(seconds: 5);
                                        dio.options.receiveTimeout =
                                            const Duration(minutes: 1);
                                        dio.options.contentType =
                                            'application/vnd.api+json';
                                        dio.options.responseType =
                                            ResponseType.json;
                                        if (value == 1) {
                                          try {
                                            // ignore: unused_local_variable
                                            var response = await dio.post(
                                                '/api/approve-suppliers',
                                                data: {'id': dataItem['id']},
                                                options: Options(headers: {
                                                  'Accept':
                                                      'application/vnd.api+json',
                                                  'Authorization':
                                                      'Bearer $token'
                                                }));

                                            setState(() {
                                              data3!.removeAt(index);
                                            });
                                            print(response.data);

                                            // ignore: unused_catch_clause
                                          } on DioException catch (e) {
                                            // dynamic error = e.response?.data;
                                          }
                                        } else {
                                          try {
                                            // ignore: unused_local_variable
                                            var response = await dio.post(
                                                '/api/cancel-suppliers',
                                                data: {'id': dataItem['id']},
                                                options: Options(headers: {
                                                  'Accept':
                                                      'application/vnd.api+json',
                                                  'Authorization':
                                                      'Bearer $token'
                                                }));

                                            setState(() {
                                              data3!.removeAt(index);
                                            });
                                            print(response.data);

                                            // ignore: unused_catch_clause
                                          } on DioException catch (e) {
                                            // dynamic error = e.response?.data;
                                          }
                                        }
                                      },
                                      itemBuilder: (context) => [
                                            PopupMenuItem(
                                                value: 1,
                                                child: Text('Approve')),
                                            PopupMenuItem(
                                                value: 2, child: Text('Cancel'))
                                          ]),
                                );
                              }),
                        )
                      ],
                    ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          color: Colors.indigo[900],
          height: 50,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MaterialButton(
                onPressed: () {
                  setState(() {
                    controller.animateToPage(0,
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.easeInOut);
                    currentPage = 0;
                  });
                },
                textColor: currentPage == 0 ? Colors.blue : Colors.white,
                child: const Text('Restocks'),
              ),
              MaterialButton(
                onPressed: () {
                  setState(() {
                    controller.animateToPage(1,
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.easeInOut);
                    currentPage = 1;
                  });
                },
                textColor: currentPage == 1 ? Colors.blue : Colors.white,
                child: const Text(
                  'Inventories',
                ),
              ),
              MaterialButton(
                onPressed: () {
                  setState(() {
                    controller.animateToPage(2,
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.easeInOut);
                    currentPage = 2;
                  });
                },
                textColor: currentPage == 2 ? Colors.blue : Colors.white,
                child: const Text('Suppliers'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
