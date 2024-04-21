// ignore_for_file: empty_catches

import 'package:desley_app/PaymentinfoScreen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';

class Cart extends StatefulWidget {
  final String token;
  const Cart({super.key, required this.token});

  @override
  // ignore: no_logic_in_create_state
  State<Cart> createState() => _CartState(token: token);
}

class _CartState extends State<Cart> {
  final String token;
  List<dynamic>? data;
  _CartState({required this.token});
  final dio = Dio();
  var toMoney = NumberFormat("#,##0.00", "en_US");

  void _getCartItems() async {
    data = null;
    dio.options.baseUrl = 'http://10.0.2.2:8000';
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(minutes: 1);
    dio.options.contentType = 'application/vnd.api+json';
    dio.options.responseType = ResponseType.json;

    try {
      var dioresponse = await dio.get('/api/cartitems',
          options: Options(headers: {
            'Accept': 'application/vnd.api+json',
            'Authorization': 'Bearer $token'
          }));
      setState(() {
        data = dioresponse.data['data'];
      });

      // print(data);

      // ignore: unused_catch_clause
    } on DioException catch (e) {
      //dynamic error = e.response?.data;
    }
  }

  void _removeCart(item, currentCount) async {
    if (currentCount == 1) {
      return deletCartItem(item);
    }
    var total = currentCount - 1;
    var addData = {'count': total};
    try {
      await dio.patch('/api/cartitems/$item',
          data: addData,
          options: Options(headers: {
            'Accept': 'application/vnd.api+json',
            'Authorization': 'Bearer $token'
          }));
      setState(() {
        _getCartItems();
      });
      // ignore: unused_catch_clause
    } on DioException catch (e) {}
  }

  void _addCart(item, currentCount) async {
    var total = currentCount + 1;
    var addData = {'count': total};
    try {
      // ignore: unused_local_variable
      var dioresponse = await dio.patch('/api/cartitems/$item',
          data: addData,
          options: Options(headers: {
            'Accept': 'application/vnd.api+json',
            'Authorization': 'Bearer $token'
          }));
      setState(() {
        _getCartItems();
      });
      // ignore: unused_catch_clause
    } on DioException catch (e) {}
  }

  void deletCartItem(item) async {
    try {
      // ignore: unused_local_variable
      var dioresponse = await dio.delete('/api/cartitems/$item',
          options: Options(headers: {
            'Accept': 'application/vnd.api+json',
            'Authorization': 'Bearer $token'
          }));
      setState(() {
        _getCartItems();
      });

      // ignore: unused_catch_clause
    } on DioException catch (e) {}
  }

  @override
  void initState() {
    _getCartItems();
    super.initState();
  }

  double totalPrice() {
    if (data == null) {
      return 0.00;
    }
    double checkoutPrice = 0;
    for (var i = 0; i < data!.length; i++) {
      var itemType = '';
      if (data![i]['equipment'] != null) {
        itemType = 'equipment';
      } else if (data![i]['service'] != null) {
        itemType = 'service';
      } else {
        itemType = 'spare';
      }
      int count = data![i]['count'];
      dynamic price = data![i][itemType]['price'] * count;
      checkoutPrice = checkoutPrice + price;
    }
    return checkoutPrice;
  }

  void sendPayment() async {
    int paymentId;

    dio.options.baseUrl = 'http://10.0.2.2:8000';
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(minutes: 1);
    dio.options.contentType = 'application/vnd.api+json';
    dio.options.responseType = ResponseType.json;

    try {
      var response = await dio.post('/api/payments',
          data: {'amount': totalPrice()},
          options: Options(headers: {
            'Accept': 'application/vnd.api+json',
            'Authorization': 'Bearer $token'
          }));

      paymentId = response.data['data']['id'];
      writeTransaction(paymentId);
      // ignore: use_build_context_synchronously
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => PaymentInfo(token: token)));
    } catch (e) {}

    //write to customer transactions
  }

  writeTransaction(int paymentId) async {
    for (Map item in data!) {
      try {
        await dio.post('/api/custransactions',
            data: {
              'payment_id': paymentId,
              'eqipment_id': item.containsKey('equipment_id')
                  ? item['equipment_id']
                  : null,
              'spare_id':
                  item.containsKey('spare_id') ? item['spare_id'] : null,
              'service_id':
                  item.containsKey('service_id') ? item['service_id'] : null,
              'count': item['count']
            },
            options: Options(headers: {
              'Accept': 'application/vnd.api+json',
              'Authorization': 'Bearer $token'
            }));

        await dio.delete('/api/cartitems/${item['id']}',
            options: Options(headers: {
              'Accept': 'application/vnd.api+json',
              'Authorization': 'Bearer $token'
            }));
      } catch (e) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.indigo,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Cart',
            style: TextStyle(color: Colors.white),
          ),
        ),
        bottomNavigationBar: SizedBox(
          height: 70,
          child: Center(
            child: MaterialButton(
              minWidth: 250,
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      TextEditingController controller =
                          TextEditingController();
                      return CupertinoAlertDialog(
                        title: Image.asset(
                          'assets/images/mpesa.png',
                          width: 100,
                          height: 60,
                          fit: BoxFit.contain,
                        ),
                        content: SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Amount Ksh',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    Text(toMoney.format(totalPrice()),
                                        style: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold))
                                  ],
                                ),
                              ),
                              CupertinoTextField(
                                controller: controller,
                                prefix: const Icon(
                                  Icons.call,
                                  color: Colors.indigo,
                                ),
                                placeholder: '07-12-345-678',
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: MaterialButton(
                              color: Colors.green,
                              onPressed: () {
                                if (totalPrice() > 0 &&
                                    controller.text.isNotEmpty) {
                                  sendPayment();
                                }
                              },
                              child: const Text(
                                'Pay',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      );
                    });
              },
              color: Colors.indigo[900],
              child: Text(
                'checkout Ksh ${toMoney.format(totalPrice())}',
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ),
        ),
        body: data == null
            ? Center(
                child: Lottie.asset('assets/images/loading.json', height: 100),
              )
            : ListView.builder(
                itemCount: data!.length,
                itemBuilder: (context, index) {
                  var itemType = '';
                  if (data![index]['equipment'] != null) {
                    itemType = 'equipment';
                  } else if (data![index]['service'] != null) {
                    itemType = 'service';
                  } else {
                    itemType = 'spare';
                  }

                  String imageUrl = data![index][itemType]['img_url'];
                  String name = data![index][itemType]['name'];
                  String price =
                      toMoney.format(data![index][itemType]['price']);
                  dynamic count = data![index]['count'];
                  int id = data![index]['id'];

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 150,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  imageUrl,
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text(
                                      name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Row(
                                      children: [
                                        const Text('ksh'),
                                        Container(
                                          width: 10,
                                        ),
                                        Text(
                                          price,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    deletCartItem(id);
                                  });
                                },
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.indigo,
                                ),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _removeCart(id, count);
                                },
                                child: Image.asset(
                                  'assets/images/removecart.png',
                                  height: 30,
                                  width: 30,
                                ),
                              ),
                              Container(
                                width: 8,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                        color: Colors.indigo, width: 3)),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 4, right: 4),
                                  child: Text('$count'),
                                ),
                              ),
                              Container(
                                width: 8,
                              ),
                              GestureDetector(
                                onTap: () {
                                  _addCart(id, count);
                                },
                                child: Image.asset(
                                  'assets/images/add-to-cart.png',
                                  height: 30,
                                  width: 30,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                }));
  }
}
