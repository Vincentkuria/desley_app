import 'package:desley_app/onboarding_screen.dart';
import 'package:desley_app/supplier_billings.dart';
import 'package:desley_app/verify_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class SupplierHome extends StatefulWidget {
  String token;
  SupplierHome({super.key, required this.token});

  @override
  // ignore: no_logic_in_create_state
  State<SupplierHome> createState() => _SupplierHomeState(token: token);
}

class _SupplierHomeState extends State<SupplierHome> {
  String token;
  Map<String, dynamic> suser = {};
  List<dynamic>? data;
  _SupplierHomeState({required this.token});

  getData() async {
    final dio = Dio();
    dio.options.baseUrl = 'http://192.168.100.3:8000';
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
        print(data);
      });
      // ignore: unused_catch_clause
    } on DioException catch (e) {
      dynamic error = e.response?.data;
      print(error);
    }

    try {
      var response = await dio.get('/api/suser',
          options: Options(headers: {
            'Accept': 'application/vnd.api+json',
            'Authorization': 'Bearer $token'
          }));

      setState(() {
        suser = response.data['data'];
      });

      if (suser['status']['manager'] == 'pending') {
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
                          '${suser['company_name']}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Colors.white),
                        ),
                        Text(
                          '${suser['email']}',
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
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SupplierBilling(
                                  token: token,
                                )),
                      );
                    },
                    child: const Text('My billings'))
              ],
            ),
          ),
          body: data == null
              ? Center(
                  child:
                      Lottie.asset('assets/images/loading.json', height: 100))
              : ListView.builder(
                  itemCount: data!.length,
                  itemBuilder: (context, index) {
                    var itemdata = data![index];
                    var inventory = itemdata['inventory'];
                    return ListTile(
                      title: Row(
                        children: [
                          const Text(
                            'Item: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(inventory['name'])
                        ],
                      ),
                      subtitle: Text('Number of items: ${itemdata['count']}'),
                      trailing: PopupMenuButton(
                          onSelected: (value) async {
                            if (value == 1) {
                              final dio = Dio();
                              dio.options.baseUrl = 'http://192.168.100.3:8000';
                              dio.options.connectTimeout =
                                  const Duration(seconds: 5);
                              dio.options.receiveTimeout =
                                  const Duration(minutes: 1);

                              try {
                                // ignore: unused_local_variable
                                var response = await dio.post(
                                    '/api/inventory-delivered',
                                    data: {
                                      'inventory_id': inventory['id'],
                                      'no_of_items': itemdata['count'],
                                      'suptransaction_id': itemdata['id']
                                    },
                                    options: Options(headers: {
                                      'Accept': 'application/vnd.api+json',
                                      'Authorization': 'Bearer $token'
                                    }));

                                //store payment info for finance approval
                                await dio.post('/api/payments',
                                    data: {
                                      'amount':
                                          itemdata['count'] * itemdata['price']
                                    },
                                    options: Options(headers: {
                                      'Accept': 'application/vnd.api+json',
                                      'Authorization': 'Bearer $token'
                                    }));

                                setState(() {
                                  data!.removeAt(index);
                                });

                                // ignore: unused_catch_clause
                              } on DioException catch (e) {
                                // dynamic error = e.response?.data;
                                // print(error);
                              }
                            }
                          },
                          itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 1,
                                  child: Text('mark as delivered'),
                                ),
                              ]),
                    );
                  }),
        ));
  }
}
