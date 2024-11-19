import 'package:desley_app/onboarding_screen.dart';
import 'package:desley_app/verify_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class SupervisorHome extends StatefulWidget {
  String token;
  SupervisorHome({super.key, required this.token});

  @override
  // ignore: no_logic_in_create_state
  State<SupervisorHome> createState() => _SupervisorHomeState(token: token);
}

class _SupervisorHomeState extends State<SupervisorHome> {
  String token;
  Map<String, dynamic> euser = {};
  List<dynamic>? data;
  List<dynamic>? driverData;

  _SupervisorHomeState({required this.token});

  getData() async {
    final dio = Dio();
    dio.options.baseUrl = 'http://138.68.154.175';
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(minutes: 1);
    dio.options.contentType = 'application/vnd.api+json';
    dio.options.responseType = ResponseType.json;

    try {
      var response = await dio.get('/api/search-shippings',
          data: {'column': 'shipped_by'},
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
      //dynamic error = e.response?.data;
    }

    try {
      var response = await dio.get('/api/search-employees',
          data: {'column': 'role', 'columnQuery': 'driver'},
          options: Options(headers: {
            'Accept': 'application/vnd.api+json',
            'Authorization': 'Bearer $token'
          }));

      setState(() {
        driverData = response.data['data'];
      });

      // ignore: unused_catch_clause
    } on DioException catch (e) {
      //dynamic error = e.response?.data;
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
            'Shippings',
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
              )
            ],
          ),
        ),
        body: SafeArea(
            child: data == null
                ? Center(
                    child:
                        Lottie.asset('assets/images/loading.json', height: 100))
                : ListView.builder(
                    itemCount: data!.length,
                    itemBuilder: (context, index) {
                      var itemdata = data![index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: itemdata['service'] == null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                            ? itemdata['equipment']['name']
                                            : itemdata['spare']['name'],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Text(
                                        'Location: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(itemdata['shipping_address'])
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: MaterialButton(
                                      minWidth:
                                          MediaQuery.of(context).size.width,
                                      color: Colors.indigo,
                                      onPressed: () async {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                  title: const Text('Drivers'),
                                                  content: ListView.builder(
                                                      itemCount:
                                                          driverData!.length,
                                                      itemBuilder: (context,
                                                          alertindex) {
                                                        var alertitemdata =
                                                            driverData![
                                                                alertindex];
                                                        return Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            // ignore: sized_box_for_whitespace
                                                            Container(
                                                              width: 130,
                                                              child: Text(
                                                                alertitemdata[
                                                                        'first_name'] +
                                                                    ' ' +
                                                                    alertitemdata[
                                                                        'last_name'],
                                                                overflow:
                                                                    TextOverflow
                                                                        .fade,
                                                              ),
                                                            ),
                                                            MaterialButton(
                                                                color: Colors
                                                                    .indigo,
                                                                onPressed:
                                                                    () async {
                                                                  final dio =
                                                                      Dio();
                                                                  dio.options
                                                                          .baseUrl =
                                                                      'http://138.68.154.175';
                                                                  dio.options
                                                                          .connectTimeout =
                                                                      const Duration(
                                                                          seconds:
                                                                              5);
                                                                  dio.options
                                                                          .receiveTimeout =
                                                                      const Duration(
                                                                          minutes:
                                                                              1);
                                                                  dio.options
                                                                          .contentType =
                                                                      'application/vnd.api+json';
                                                                  dio.options
                                                                          .responseType =
                                                                      ResponseType
                                                                          .json;

                                                                  try {
                                                                    // ignore: unused_local_variable
                                                                    var response = await dio.patch(
                                                                        '/api/shippings/${itemdata['id']}',
                                                                        data: {
                                                                          'shipped_by':
                                                                              alertitemdata['id'],
                                                                        },
                                                                        options:
                                                                            Options(
                                                                                headers: {
                                                                              'Accept': 'application/vnd.api+json',
                                                                              'Authorization': 'Bearer $token'
                                                                            }));

                                                                    // ignore: unused_local_variable
                                                                    var response2 = await dio.post(
                                                                        '/api/update-shipping-status',
                                                                        data: {
                                                                          'id':
                                                                              itemdata['id'],
                                                                          'status':
                                                                              'in transit'
                                                                        },
                                                                        options:
                                                                            Options(
                                                                                headers: {
                                                                              'Accept': 'application/vnd.api+json',
                                                                              'Authorization': 'Bearer $token'
                                                                            }));

                                                                    setState(
                                                                        () {
                                                                      data!.removeAt(
                                                                          index);
                                                                    });

                                                                    // ignore: use_build_context_synchronously
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();

                                                                    // ignore: unused_catch_clause
                                                                  } on DioException catch (e) {
                                                                    dynamic
                                                                        // ignore: unused_local_variable
                                                                        error =
                                                                        e.response
                                                                            ?.data;
                                                                    print(
                                                                        error);
                                                                  }
                                                                },
                                                                child: const Text(
                                                                    'Assign'))
                                                          ],
                                                        );
                                                      }));
                                            });
                                      },
                                      child: const Text('Assign Driver'),
                                    ),
                                  )
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(itemdata['service']['name'].toString()),
                                  Row(
                                    children: [
                                      const Text(
                                        'Location: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(itemdata['shipping_address']
                                          .toString())
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: MaterialButton(
                                      minWidth:
                                          MediaQuery.of(context).size.width,
                                      color: Colors.indigo,
                                      onPressed: () async {},
                                      child:
                                          const Text('Assign Service Personel'),
                                    ),
                                  )
                                ],
                              ),
                      );
                    })),
      ),
    );
  }
}
