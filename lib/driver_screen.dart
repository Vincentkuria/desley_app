import 'package:desley_app/onboarding_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class DriverHome extends StatefulWidget {
  String token;
  DriverHome({super.key, required this.token});

  @override
  // ignore: no_logic_in_create_state
  State<DriverHome> createState() => _DriverHomeState(token: token);
}

class _DriverHomeState extends State<DriverHome> {
  String token;
  Map<String, dynamic> euser = {};
  List<dynamic>? data;

  _DriverHomeState({required this.token});

  getData() async {
    final dio = Dio();
    dio.options.baseUrl = 'http://192.168.100.3:8000';
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(minutes: 1);

    try {
      var response = await dio.get('/api/driver-items',
          options: Options(headers: {
            'Accept': 'application/vnd.api+json',
            'Authorization': 'Bearer $token'
          }));
//shipping ==null
      setState(() {
        data = response.data['data'];
      });

      // ignore: unused_catch_clause
    } on DioException catch (e) {
      // ignore: unused_local_variable
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
              'Driver',
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
                      dio.options.baseUrl = 'http://192.168.100.3:8000';
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
          body: SafeArea(
              child: data == null
                  ? Center(
                      child: Lottie.asset('assets/images/loading.json',
                          height: 100))
                  : ListView.builder(
                      itemCount: data!.length,
                      itemBuilder: (context, index) {
                        if (data!.isNotEmpty) {
                          var itemdata = data![index];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(
                                          0.4), // Shadow color with opacity
                                      spreadRadius:
                                          3, // How much the shadow spreads
                                      blurRadius:
                                          2, // How much the shadow blurs
                                      offset: const Offset(1,
                                          3), // Positioning of the shadow (x, y)
                                    ),
                                  ]),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Text(
                                              'Item: ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              itemdata['equipment'] != null
                                                  ? itemdata['equipment']
                                                      ['name']
                                                  : itemdata['spare']['name'],
                                              overflow: TextOverflow.clip,
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Text(
                                              'Address: ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              itemdata['shipping_address'],
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                    PopupMenuButton(
                                        onSelected: (value) async {
                                          final dio = Dio();
                                          dio.options.baseUrl =
                                              'http://192.168.100.3:8000';
                                          dio.options.connectTimeout =
                                              const Duration(seconds: 5);
                                          dio.options.receiveTimeout =
                                              const Duration(minutes: 1);
                                          if (value == 1) {
                                            try {
                                              await dio.post(
                                                  '/api/update-shipping-status',
                                                  data: {
                                                    'id': itemdata['id'],
                                                    'status': 'delivered'
                                                  },
                                                  options: Options(headers: {
                                                    'Accept':
                                                        'application/vnd.api+json',
                                                    'Authorization':
                                                        'Bearer $token'
                                                  }));

                                              setState(() {
                                                data!.removeAt(index);
                                              });

                                              // ignore: unused_catch_clause
                                            } on DioException catch (e) {
                                              //dynamic error = e.response?.data;
                                            }
                                          } else {
                                            try {
                                              await dio.post(
                                                  '/api/update-shipping-status',
                                                  data: {
                                                    'id': itemdata['id'],
                                                    'status': 'failed'
                                                  },
                                                  options: Options(headers: {
                                                    'Accept':
                                                        'application/vnd.api+json',
                                                    'Authorization':
                                                        'Bearer $token'
                                                  }));

                                              setState(() {
                                                data!.removeAt(index);
                                              });

                                              // ignore: unused_catch_clause
                                            } on DioException catch (e) {
                                              //dynamic error = e.response?.data;
                                            }
                                          }
                                        },
                                        itemBuilder: (context) => const [
                                              PopupMenuItem(
                                                value: 1,
                                                child: Text('delivered'),
                                              ),
                                              PopupMenuItem(
                                                value: 2,
                                                child: Text('failed'),
                                              ),
                                            ])
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else {
                          return const Center(
                            child: Text(
                              'No data',
                              style: TextStyle(color: Colors.black),
                            ),
                          );
                        }
                      }))),
    );
  }
}

// class SideMore extends StatelessWidget {
//   const SideMore({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ;
//   }
// }
