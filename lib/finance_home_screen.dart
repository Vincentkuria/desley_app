// ignore_for_file: prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings

import 'package:desley_app/feedback_message.dart';
import 'package:desley_app/onboarding_screen.dart';
import 'package:desley_app/verify_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class FinanceHome extends StatefulWidget {
  String token;
  FinanceHome({super.key, required this.token});

  @override
  // ignore: no_logic_in_create_state
  State<FinanceHome> createState() => _FinanceHomeState(token: token);
}

class _FinanceHomeState extends State<FinanceHome> {
  String token;
  final controller = PageController();
  int currentPage = 0;
  int touchedIndex = -1;
  var total;
  var monthlyIncome;
  int? monthlyDeductions;
  List<dynamic>? pendingPayments;
  List<dynamic>? approvedPayments;
  Map<String, dynamic> euser = {};
  // var toMoney = NumberFormat("#,##0.00", "en_US");
  _FinanceHomeState({required this.token});

  getPaymentsData() async {
    final dio = Dio();
    dio.options.baseUrl = 'http://138.68.154.175';
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(minutes: 1);
    dio.options.contentType = 'application/vnd.api+json';
    dio.options.responseType = ResponseType.json;

    try {
      var response1 = await dio.get('/api/payments-total',
          options: Options(headers: {
            'Accept': 'application/vnd.api+json',
            'Authorization': 'Bearer $token'
          }));

      var response2 = await dio.get('/api/payments-d-monthly',
          options: Options(headers: {
            'Accept': 'application/vnd.api+json',
            'Authorization': 'Bearer $token'
          }));

      var response3 = await dio.get('/api/payments-i-monthly',
          options: Options(headers: {
            'Accept': 'application/vnd.api+json',
            'Authorization': 'Bearer $token'
          }));

      setState(() {
        total = int.parse(response1.data);
        monthlyDeductions = int.parse(response2.data);
        monthlyIncome = int.parse(response3.data);
      });

      var response4 = await dio.get('/api/payments-pending',
          options: Options(headers: {
            'Accept': 'application/vnd.api+json',
            'Authorization': 'Bearer $token'
          }));
      setState(() {
        pendingPayments = response4.data['data'];
      });

      var response5 = await dio.get('/api/payments-approved',
          options: Options(headers: {
            'Accept': 'application/vnd.api+json',
            'Authorization': 'Bearer $token'
          }));
      setState(() {
        approvedPayments = response5.data['data'];
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

      if (euser['status']['manager'] == 'pending') {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const VerifyHome()));
      }

      // ignore: unused_catch_clause
    } on DioException catch (e) {
      //dynamic error = e.response?.data;
    }
  }

  Future<bool> approvePayment(int id) async {
    final dio = Dio();
    dio.options.baseUrl = 'http://138.68.154.175';
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(minutes: 1);
    dio.options.contentType = 'application/vnd.api+json';
    dio.options.responseType = ResponseType.json;

    try {
      // ignore: unused_local_variable
      var approvalResponse = await dio.post('/api/approve-payment',
          data: {'id': id},
          options: Options(headers: {
            'Accept': 'application/vnd.api+json',
            'Authorization': 'Bearer $token'
          }));
      return true;
      // ignore: unused_catch_clause
    } on DioException catch (e) {
      return false;
    }
  }

  @override
  void initState() {
    getPaymentsData();
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
          //leading: const Icon(Icons.monetization_on_rounded),
          title: const Text(
            'Finance',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
          backgroundColor: Colors.indigo,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            currentPage == 0
                ? const SizedBox()
                : Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: GestureDetector(
                        onTap: () {
                          showSearch(
                              context: context,
                              delegate: MySearchDelegate(
                                  token: token,
                                  currentPage: controller.page!.toInt()));
                        },
                        child: const Icon(Icons.search)),
                  )
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
              child: total == null
                  ? Center(
                      child: Lottie.asset('assets/images/loading.json',
                          height: 100),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                    'TOTAL',
                                    style: TextStyle(fontSize: 60),
                                  ),
                                  Text(
                                    'Ksh ${total < 0 ? 0 : total}',
                                    style: const TextStyle(fontSize: 20),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        // ignore: avoid_unnecessary_containers
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                        colors: [
                                          Color.fromARGB(
                                            255,
                                            225,
                                            68,
                                            68,
                                          ),
                                          Color.fromARGB(255, 106, 0, 0)
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('Monthly'),
                                      const Text(
                                        'DEDUCTIONS',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                      Text(
                                          'Ksh ' +
                                              (monthlyDeductions! < 0
                                                  ? (monthlyDeductions! * -1)
                                                      .toString()
                                                  : monthlyDeductions
                                                      .toString()),
                                          style: const TextStyle(fontSize: 20))
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                        colors: [
                                          Color.fromARGB(
                                            255,
                                            0,
                                            255,
                                            17,
                                          ),
                                          Color.fromARGB(255, 65, 117, 65)
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('Monthly'),
                                      const Text('INCOME',
                                          style: TextStyle(fontSize: 15)),
                                      Text('Ksh $monthlyIncome',
                                          style: const TextStyle(fontSize: 20))
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                            child: AspectRatio(
                          aspectRatio: 1.3,
                          child: Column(
                            children: <Widget>[
                              const SizedBox(
                                height: 18,
                              ),
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: PieChart(
                                    PieChartData(
                                      pieTouchData: PieTouchData(
                                        touchCallback: (FlTouchEvent event,
                                            pieTouchResponse) {
                                          setState(() {
                                            if (!event
                                                    .isInterestedForInteractions ||
                                                pieTouchResponse == null ||
                                                pieTouchResponse
                                                        .touchedSection ==
                                                    null) {
                                              touchedIndex = -1;
                                              return;
                                            }
                                            touchedIndex = pieTouchResponse
                                                .touchedSection!
                                                .touchedSectionIndex;
                                          });
                                        },
                                      ),
                                      borderData: FlBorderData(
                                        show: false,
                                      ),
                                      sectionsSpace: 0,
                                      centerSpaceRadius: 40,
                                      sections: showingSections(),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 30),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Column(
                                      children: [
                                        Container(
                                            width: 10,
                                            height: 10,
                                            color: Colors.amber),
                                        const SizedBox(
                                          width: 4,
                                        ),
                                        const Text('Equipments')
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Container(
                                            width: 10,
                                            height: 10,
                                            color: Colors.indigo),
                                        const SizedBox(
                                          width: 4,
                                        ),
                                        const Text('Spares')
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Container(
                                            width: 10,
                                            height: 10,
                                            color: Colors.green),
                                        const SizedBox(
                                          width: 4,
                                        ),
                                        const Text('Services')
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ))
                      ],
                    ),
            ),
            Container(
              child: pendingPayments == null
                  ? Center(
                      child: Lottie.asset('assets/images/loading.json',
                          height: 100),
                    )
                  : ListView.builder(
                      itemCount: pendingPayments!.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration:
                                BoxDecoration(color: Colors.white, boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(
                                    0.4), // Shadow color with opacity
                                spreadRadius: 3, // How much the shadow spreads
                                blurRadius: 2, // How much the shadow blurs
                                offset: const Offset(
                                    1, 3), // Positioning of the shadow (x, y)
                              ),
                            ]),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'CODE:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(pendingPayments![index]
                                              ['payment_code']
                                          .toString())
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        pendingPayments![index]['customer'] !=
                                                null
                                            ? 'Customer:'
                                            : 'Supplier:',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      pendingPayments![index]['customer'] !=
                                              null
                                          // ignore: prefer_adjacent_string_concatenation
                                          ? Text("${pendingPayments![index]['customer']?["first_name"]}" +
                                              " " +
                                              "${pendingPayments![index]['customer']?['last_name']}")
                                          : Text(
                                              "${pendingPayments![index]['supplier']?["company_name"]}")
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Text(
                                        'Amount:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        '${pendingPayments![index]['amount']}',
                                        style: TextStyle(
                                            color: pendingPayments![index]
                                                        ['amount'] >
                                                    0
                                                ? Colors.green
                                                : Colors.red,
                                            fontWeight: FontWeight.w600),
                                      )
                                    ],
                                  ),
                                  Text(pendingPayments![index]['created_at']),
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, right: 8.0),
                                      child: MaterialButton(
                                        minWidth:
                                            MediaQuery.of(context).size.width,
                                        color: Colors.green,
                                        onPressed: () {
                                          approvePayment(
                                                  pendingPayments![index]['id'])
                                              .then((value) => {
                                                    setState(() {
                                                      if (value) {
                                                        pendingPayments!
                                                            .removeAt(index);
                                                      }
                                                    }),
                                                    getPaymentsData()
                                                  });
                                        },
                                        child: const Text('Approve'),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
            ),
            Container(
              child: approvedPayments == null
                  ? Center(
                      child: Lottie.asset('assets/images/loading.json',
                          height: 100),
                    )
                  : approvedPayments!.isEmpty
                      ? const SizedBox()
                      : ListView.builder(
                          itemCount: approvedPayments!.length,
                          itemBuilder: (context, index) {
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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            'CODE',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(approvedPayments?[index]
                                              ['payment_code'])
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            approvedPayments![index]
                                                        ['customer'] !=
                                                    null
                                                ? 'Customer:'
                                                : 'Supplier:',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          approvedPayments![index]
                                                      ['customer'] !=
                                                  null
                                              ? Text(
                                                  "${approvedPayments![index]['customer']?['first_name'] + ' ' + approvedPayments![index]['customer']?['last_name']}")
                                              : Text(
                                                  "${approvedPayments![index]['supplier']?['company_name']}")
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Text(
                                            'Amount:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            '${approvedPayments![index]['amount']}',
                                            style: TextStyle(
                                                color: approvedPayments![index]
                                                            ['amount'] >
                                                        0
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontWeight: FontWeight.w600),
                                          )
                                        ],
                                      ),
                                      Text(approvedPayments![index]
                                          ['created_at'])
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
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
                child: const Text('Home'),
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
                  'Pending',
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
                child: const Text('Approved'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(3, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.amber,
            value: 40,
            title: '40%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              shadows: shadows,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.indigo,
            value: 30,
            title: '30%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              shadows: shadows,
            ),
          );
        case 2:
          return PieChartSectionData(
            color: Colors.green,
            value: 15,
            title: '15%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              shadows: shadows,
            ),
          );
        default:
          throw Error();
      }
    });
  }
}

class MySearchDelegate extends SearchDelegate {
  String token;
  var searchResponse = [];
  var toMoney = NumberFormat("#,##0.00", "en_US");
  int currentPage;
  String searchData = '';
  String title = '';
  String viewtype = '';
  MySearchDelegate({required this.token, required this.currentPage});

  @override
  void showResults(BuildContext context) async {
    final dio = Dio();
    dio.options.baseUrl = 'http://138.68.154.175';
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(minutes: 1);
    dio.options.contentType = 'application/vnd.api+json';
    dio.options.responseType = ResponseType.json;

    try {
      var response = await dio.get('/api/payments-search',
          data: {'search': query},
          options: Options(headers: {
            'Accept': 'application/vnd.api+json',
            'Authorization': 'Bearer $token'
          }));
      searchResponse = response.data['data'];
      // ignore: use_build_context_synchronously
      super.showResults(context);
      // ignore: unused_catch_clause
    } on DioException catch (e) {
      // dynamic error = e.response?.data;
    }
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = '';
          }
        },
        icon: const Icon(Icons.clear),
      ),
      IconButton(
          onPressed: () async {
            showResults(context);
          },
          icon: const Icon(Icons.search))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    return searchResponse.isEmpty
        ? const Center(
            child: Text('your Search was not found'),
          )
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
                itemCount: searchResponse.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(color: Colors.white, boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.4),
                        spreadRadius: 3,
                        blurRadius: 2,
                        offset: const Offset(1, 3),
                      ),
                    ]),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'CODE:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(searchResponse[index]['payment_code']
                                  .toString())
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                searchResponse[index]['customer'] != null
                                    ? 'Customer:'
                                    : 'Supplier',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(searchResponse[index]['customer'] != null
                                  ? searchResponse[index]['customer']
                                              ['first_name']
                                          .toString() +
                                      ' ' +
                                      searchResponse[index]['customer']
                                              ['last_name']
                                          .toString()
                                  : searchResponse[index]['supplier']
                                              ['first_name']
                                          .toString() +
                                      ' ' +
                                      searchResponse[index]['supplier']
                                              ['last_name']
                                          .toString())
                            ],
                          ),
                          Row(
                            children: [
                              const Text(
                                'Amount:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                toMoney.format(searchResponse[index]['amount']),
                                style: TextStyle(
                                    color: searchResponse[index]['amount'] > 0
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                          Text(searchResponse[index]['created_at'].toString()),
                          Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: searchResponse[index]['status']
                                          ['finance'] ==
                                      'approved'
                                  ? const SizedBox()
                                  : MaterialButton(
                                      minWidth:
                                          MediaQuery.of(context).size.width,
                                      color: Colors.green,
                                      onPressed: () async {},
                                      child: const Text('Approve'),
                                    ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }),
          );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const SizedBox();
  }
}
