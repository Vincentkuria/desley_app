import 'package:desley_app/items/mydialog.dart';
import 'package:desley_app/onboarding_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class InventoryHome extends StatefulWidget {
  String token;
  InventoryHome({super.key, required this.token});

  @override
  // ignore: no_logic_in_create_state
  State<InventoryHome> createState() => _InventoryHomeState(token: token);
}

class _InventoryHomeState extends State<InventoryHome> {
  String token;
  _InventoryHomeState({required this.token});
  Map<String, dynamic> euser = {};
  List<dynamic>? data;
  List<dynamic>? supplierdata;
  TextEditingController controller = TextEditingController();

  getData() async {
    final dio = Dio();
    dio.options.baseUrl = 'http://10.0.2.2:8000';
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(minutes: 1);

    try {
      var response = await dio.get('/api/inventories-approved',
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
      // print(error);
    }

    try {
      var response = await dio.get('/api/suppliers',
          options: Options(headers: {
            'Accept': 'application/vnd.api+json',
            'Authorization': 'Bearer $token'
          }));

      setState(() {
        supplierdata = response.data['data'];
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

  int totalRevenue() {
    int sum = 0;
    for (var inventory in data!) {
      if (inventory != null) {
        sum = sum + inventory['no_of_items'] as int;
      }
    }
    return sum;
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
            'Inventory',
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
        body: SafeArea(
            child: data == null
                ? Center(
                    child:
                        Lottie.asset('assets/images/loading.json', height: 100),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [
                                    Color.fromARGB(
                                      255,
                                      89,
                                      114,
                                      214,
                                    ),
                                    Color.fromARGB(255, 0, 238, 246)
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter),
                              borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'TOTAL INVENTORY',
                                  style: TextStyle(fontSize: 30),
                                ),
                                Text(totalRevenue().toString(),
                                    style: const TextStyle(fontSize: 20))
                              ],
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: MaterialButton(
                              textColor: Colors.white,
                              color: Colors.indigo,
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Create New Item'),
                                        content: SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              const Text('Inventory name'),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              TextField(
                                                controller: controller,
                                                decoration: const InputDecoration(
                                                    prefixIcon: Icon(
                                                        Icons.inventory_sharp),
                                                    prefixIconColor:
                                                        Colors.indigo,
                                                    hintText: 'Inventory',
                                                    border:
                                                        OutlineInputBorder()),
                                              ),
                                              const SizedBox(
                                                height: 30,
                                              ),
                                              Center(
                                                child: MaterialButton(
                                                  onPressed: () async {
                                                    final dio = Dio();
                                                    dio.options.baseUrl =
                                                        'http://10.0.2.2:8000';
                                                    dio.options.connectTimeout =
                                                        const Duration(
                                                            seconds: 5);
                                                    dio.options.receiveTimeout =
                                                        const Duration(
                                                            minutes: 1);

                                                    if (controller
                                                        .text.isEmpty) {
                                                      return;
                                                    }

                                                    try {
                                                      // ignore: unused_local_variable
                                                      var response =
                                                          await dio.post(
                                                              '/api/inventories',
                                                              data: {
                                                                'name':
                                                                    controller
                                                                        .text,
                                                                'no_of_items': 0
                                                              },
                                                              options: Options(
                                                                  headers: {
                                                                    'Accept':
                                                                        'application/vnd.api+json',
                                                                    'Authorization':
                                                                        'Bearer $token'
                                                                  }));

                                                      setState(() {
                                                        getData();
                                                      });
                                                      controller.text = '';
                                                      // ignore: use_build_context_synchronously
                                                      Navigator.pop(context);
                                                      // ignore: unused_catch_clause
                                                    } on DioException catch (e) {
                                                      // dynamic error =
                                                      //     e.response?.data;
                                                    }
                                                  },
                                                  color: Colors.indigo,
                                                  minWidth:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          2,
                                                  child: const Text('Create'),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                              },
                              child: const Text('+ add'),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                            itemCount: data!.length,
                            itemBuilder: (context, index) {
                              var itemdata = data![index];
                              return ListTile(
                                title: Row(
                                  children: [
                                    const Text('Item: '),
                                    Text(itemdata['name'].toString()),
                                  ],
                                ),
                                subtitle: Text(
                                    'Number of items: ${itemdata['no_of_items']}'),
                                trailing: PopupMenuButton(
                                    onSelected: (value) async {
                                      if (value == 1) {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return MyDialog(
                                                supplierdata: supplierdata,
                                                itemName: itemdata['name'],
                                                token: token,
                                                inventoryId: itemdata['id'],
                                              );
                                            });
                                      } else {
                                        final dio = Dio();
                                        dio.options.baseUrl =
                                            'http://10.0.2.2:8000';
                                        dio.options.connectTimeout =
                                            const Duration(seconds: 5);
                                        dio.options.receiveTimeout =
                                            const Duration(minutes: 1);

                                        try {
                                          // ignore: unused_local_variable
                                          var response = await dio.post(
                                              '/api/status-request-delete',
                                              data: {
                                                'deleteid': itemdata['id']
                                              },
                                              options: Options(headers: {
                                                'Accept':
                                                    'application/vnd.api+json',
                                                'Authorization': 'Bearer $token'
                                              }));

                                          setState(() {
                                            data!.removeAt(index);
                                          });
                                          // ignore: unused_catch_clause
                                        } on DioException catch (e) {
                                          // dynamic error = e.response?.data;
                                        }
                                      }
                                    },
                                    itemBuilder: (context) => const [
                                          PopupMenuItem(
                                            value: 1,
                                            child: Text('restock'),
                                          ),
                                          PopupMenuItem(
                                            value: 2,
                                            child: Text('delete'),
                                          ) //Todo change status manager:delete
                                        ]),
                              );
                            }),
                      )
                    ],
                  )),
      ),
    );
  }
}
