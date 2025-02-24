// ignore_for_file: empty_catches
import 'package:desley_app/paymentinfo_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  bool ordertype = false; //true with service false without service
  bool ordertype2 = false;
  //true with service + other, false meaning service only without other
  _CartState({required this.token});

  var toMoney = NumberFormat("#,##0.00", "en_US");
  TextEditingController addressController = TextEditingController();

  void _getCartItems() async {
    final dio1 = Dio();
    data = null;
    dio1.options.baseUrl = dotenv.env['BASE_URL']!!;
    dio1.options.connectTimeout = const Duration(seconds: 5);
    dio1.options.receiveTimeout = const Duration(minutes: 1);
    dio1.options.contentType = 'application/vnd.api+json';
    dio1.options.responseType = ResponseType.json;

    try {
      var dioresponse = await dio1.get('/api/cartitems',
          options: Options(headers: {
            'Accept': 'application/vnd.api+json',
            'Authorization': 'Bearer $token'
          }));
      setState(() {
        data = dioresponse.data['data'];
      });

      print(data);

      // ignore: unused_catch_clause
    } on DioException catch (e) {
      //dynamic error = e.response?.data;
    }
  }

  void _removeCart(item, currentCount) async {
    final dio2 = Dio();
    dio2.options.baseUrl = dotenv.env['BASE_URL']!!;
    dio2.options.connectTimeout = const Duration(seconds: 5);
    dio2.options.receiveTimeout = const Duration(minutes: 1);
    dio2.options.contentType = 'application/vnd.api+json';
    dio2.options.responseType = ResponseType.json;

    if (currentCount == 1) {
      return deletCartItem(item);
    }
    var total = currentCount - 1;
    var addData = {'count': total};
    try {
      await dio2.patch('/api/cartitems/$item',
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
    final dio3 = Dio();
    dio3.options.baseUrl = dotenv.env['BASE_URL']!!;
    dio3.options.connectTimeout = const Duration(seconds: 5);
    dio3.options.receiveTimeout = const Duration(minutes: 1);
    dio3.options.contentType = 'application/vnd.api+json';
    dio3.options.responseType = ResponseType.json;

    var total = currentCount + 1;
    var addData = {'count': total};
    try {
      // ignore: unused_local_variable
      var dioresponse = await dio3.patch('/api/cartitems/$item',
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
    final dio4 = Dio();
    dio4.options.baseUrl = dotenv.env['BASE_URL']!!;
    dio4.options.connectTimeout = const Duration(seconds: 5);
    dio4.options.receiveTimeout = const Duration(minutes: 1);
    dio4.options.contentType = 'application/vnd.api+json';
    dio4.options.responseType = ResponseType.json;
    try {
      // ignore: unused_local_variable
      var dioresponse = await dio4.delete('/api/cartitems/$item',
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
    bool eq = false;
    bool sp = false;
    bool ser = false;
    for (var i = 0; i < data!.length; i++) {
      var itemType = '';
      if (data![i]['equipment'] != null) {
        itemType = 'equipment';
        if (!eq) {
          eq = true;
        }
      } else if (data![i]['service'] != null) {
        itemType = 'service';
        if (!ser) {
          ser = true;
        }
      } else {
        itemType = 'spare';
        if (!sp) {
          sp = true;
        }
      }
      int count = data![i]['count'];
      dynamic price = data![i][itemType]['price'] * count;
      checkoutPrice = checkoutPrice + price;
    }

    if (ser) {
      ordertype = true;
      if (sp || eq) {
        ordertype2 = true;
      }
    } else {
      ordertype = false;
    }
    return checkoutPrice;
  }

  void sendPayment() async {
    int paymentId;
    var dio5 = Dio();
    dio5.options.baseUrl = dotenv.env['BASE_URL']!!;
    dio5.options.connectTimeout = const Duration(seconds: 5);
    dio5.options.receiveTimeout = const Duration(minutes: 1);
    dio5.options.contentType = 'application/vnd.api+json';
    dio5.options.responseType = ResponseType.json;

    try {
      var response = await dio5.post('/api/payments',
          data: {'amount': totalPrice()},
          options: Options(headers: {
            'Accept': 'application/vnd.api+json',
            'Authorization': 'Bearer $token'
          }));

      paymentId = response.data['data']['id'];
      writeTransaction(paymentId);
      // ignore: use_build_context_synchronously
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PaymentInfo(
                    token: token,
                    ordertype: ordertype,
                    ordertype2: ordertype2,
                  )));
    } catch (e) {}

    //write to customer transactions
  }

  writeTransaction(int paymentId) async {
    var dio = Dio();
    dio.options.baseUrl = dotenv.env['BASE_URL']!!;
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(minutes: 1);
    dio.options.contentType = 'application/vnd.api+json';
    dio.options.responseType = ResponseType.json;
    for (Map item in data!) {
      var theData = {
        'payment_id': paymentId,
        'equipment_id':
            item['equipment'] == null ? null : item['equipment']['id'],
        'spare_id': item['spare'] == null ? null : item['spare']['id'],
        'service_id': item['service'] == null ? null : item['service']['id'],
        'count': item['count'],
        'shipping_address': addressController.text
      };
      print(theData);
      try {
        await dio.post('/api/custransactions',
            data: theData,
            options: Options(headers: {
              'Accept': 'application/vnd.api+json',
              'Authorization': 'Bearer $token'
            }));

        await dio.delete('/api/cartitems/${item['id']}',
            options: Options(headers: {
              'Accept': 'application/vnd.api+json',
              'Authorization': 'Bearer $token'
            }));
      } on DioException catch (e) {
        dynamic error = e.response?.data;
        print(error);
      }
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
                              const Text('Shipping Address'),
                              CupertinoTextField(
                                controller: addressController,
                                prefix: const Icon(
                                  Icons.location_on,
                                  color: Colors.indigo,
                                ),
                                placeholder: 'r1, Home Appartments',
                              ),
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
                                    controller.text.isNotEmpty &&
                                    addressController.text.isNotEmpty &&
                                    controller.text.length >= 10) {
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
                              GestureDetector(
                                onTap: () {
                                  _addCart(id, count);
                                },
                                child: Image.asset(
                                  'assets/images/add-to-cart.png',
                                  height: 30,
                                  width: 30,
                                ),
                              ),
                              Container(
                                width: 8,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                }));
  }
}
