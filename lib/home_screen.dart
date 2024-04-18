import 'package:desley_app/cart_screen.dart';
import 'package:desley_app/viewing_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final String token;
  const HomeScreen({super.key, required this.token});

  @override
  State<HomeScreen> createState() => _HomeScreenState(token: token);
}

class _HomeScreenState extends State<HomeScreen> {
  final String token;

  _HomeScreenState({required this.token});
  final controller = PageController();
  int currentPage = 0;
  var equipments = [];
  var services = [];
  var spares = [];
  Map<String, dynamic> user = {};
  var toMoney = NumberFormat("#,##0.00", "en_US");

  void _getSalesData() async {
    final dio = Dio();
    dio.options.baseUrl = 'http://10.0.2.2:8000';
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(minutes: 1);
    dio.options.contentType = 'application/vnd.api+json';
    dio.options.responseType = ResponseType.json;

    try {
      var equipmentsResponse = await dio.get('/api/equipments',
          options: Options(headers: {
            'Accept': 'application/vnd.api+json',
            'Authorization': 'Bearer $token'
          }));

      setState(() {
        equipments = equipmentsResponse.data['data'];
      });
      // ignore: unused_catch_clause
    } on DioException catch (e) {
      // dynamic error = e.response?.data;
    }

    try {
      var sparesResponse = await dio.get('/api/spares',
          options: Options(headers: {
            'Accept': 'application/vnd.api+json',
            'Authorization': 'Bearer $token'
          }));
      spares = sparesResponse.data['data'];
      // ignore: unused_catch_clause
    } on DioException catch (e) {
      // dynamic error = e.response?.data;
    }

    try {
      var servicesResponse = await dio.get('/api/services',
          options: Options(headers: {
            'Accept': 'application/vnd.api+json',
            'Authorization': 'Bearer $token'
          }));
      services = servicesResponse.data['data'];
      // ignore: unused_catch_clause
    } on DioException catch (e) {
      //dynamic error = e.response?.data;
    }

    try {
      var response = await dio.get('/api/user',
          options: Options(headers: {
            'Accept': 'application/vnd.api+json',
            'Authorization': 'Bearer $token'
          }));
      user = response.data['data'];
      // ignore: unused_catch_clause
    } on DioException catch (e) {
      //dynamic error = e.response?.data;
    }
  }

  @override
  void initState() {
    _getSalesData();

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
          centerTitle: true,
          backgroundColor: Colors.indigo,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'DESLEY',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            GestureDetector(
              child: const Icon(
                Icons.search,
                size: 30,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Cart(token: token))),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.shopping_cart,
                  size: 30,
                ),
              ),
            ),
          ],
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
                        '${user['first_name']}' ' ' '${user['last_name']}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: Colors.white),
                      ),
                      Text(
                        '${user['email']}',
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
                      // ignore: unused_catch_clause
                    } on DioException catch (e) {
                      //dynamic error = e.response?.data;
                    }
                  },
                  color: Colors.indigo,
                  textColor: Colors.white,
                  child: Text('Logout'),
                ),
              )
            ],
          ),
        ),
        //........

        body: PageView(
          controller: controller,
          children: [
            Column(
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Equipments',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                    child: equipments.isEmpty
                        ? Center(
                            child: Lottie.asset('assets/images/loading.json',
                                height: 100),
                          )
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2),
                            itemCount: equipments.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Viewing(
                                              viewtype: 'equipments',
                                              token: token,
                                              data: equipments[index],
                                            ))),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(
                                        equipments[index]['img_url'],
                                        width: 140,
                                        height: 110,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          equipments[index]['name'],
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 20),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              const Text(
                                                'ksh',
                                              ),
                                              Container(
                                                width: 5,
                                              ),
                                              Column(
                                                children: [
                                                  Text('70,000',
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough)),
                                                  Text(
                                                    '${toMoney.format(equipments[index]['price'])}',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              );
                            }))
              ],
            ),
            Column(
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Spares',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                    child: spares.isEmpty
                        ? Center(
                            child: Lottie.asset('assets/images/loading.json',
                                height: 100),
                          )
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2),
                            itemCount: spares.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Viewing(
                                              viewtype: 'spares',
                                              token: token,
                                              data: equipments[index],
                                            ))),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(
                                        spares[index]['img_url'],
                                        width: 140,
                                        height: 110,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${spares[index]['name']}',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 20),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                const Text(
                                                  'ksh',
                                                ),
                                                Container(
                                                  width: 5,
                                                ),
                                                Column(
                                                  children: [
                                                    Text('70,000',
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough)),
                                                    Text(
                                                      "${toMoney.format(spares[index]['price'])}",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700),
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }))
              ],
            ),
            Column(
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Services',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                    child: services.isEmpty
                        ? Center(
                            child: Lottie.asset('assets/images/loading.json',
                                height: 100),
                          )
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2),
                            itemCount: services.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Viewing(
                                              viewtype: 'services',
                                              token: token,
                                              data: services[index],
                                            ))),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(
                                        services[index]['img_url'],
                                        width: 140,
                                        height: 110,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${services[index]['name']}',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 20),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                const Text(
                                                  'ksh',
                                                ),
                                                Container(
                                                  width: 5,
                                                ),
                                                Column(
                                                  children: [
                                                    Text('70,000',
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough)),
                                                    Text(
                                                      '${toMoney.format(services[index]['price'])}',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700),
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }))
              ],
            )
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
                child: const Text('Equipments'),
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
                  'Spares',
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
                child: const Text('Services'),
              ),
            ],
          ),
        ),

        //...........
      ),
    );
  }
}
