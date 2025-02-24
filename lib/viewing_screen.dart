import 'package:desley_app/cart_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';

class Viewing extends StatefulWidget {
  final String viewtype;
  final String token;
  final Map<String, dynamic> data;
  const Viewing(
      {super.key,
      required this.viewtype,
      required this.token,
      required this.data});

  @override
  State<Viewing> createState() =>
      // ignore: no_logic_in_create_state
      _ViewingState(viewtype: viewtype, token: token, data: data);
}

class _ViewingState extends State<Viewing> {
  final String viewtype;
  final String token;
  final Map<String, dynamic> data;
  _ViewingState(
      {required this.viewtype, required this.token, required this.data});

  void _storeToCart(int id) async {
    final dio = Dio();
    dio.options.baseUrl = dotenv.env['BASE_URL']!!;
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(minutes: 1);
    dio.options.contentType = 'application/vnd.api+json';
    dio.options.responseType = ResponseType.json;

    Map<String, dynamic> data;
    print(viewtype);

    if (viewtype == 'equipments') {
      data = {
        'equipment_id': id,
        'count': 1,
      };
    } else if (viewtype == 'services') {
      data = {'service_id': id, 'count': 1};
    } else {
      data = {
        'spare_id': id,
        'count': 1,
      };
    }

    print(data);

    try {
      print('start http');
      // ignore: unused_local_variable
      var dioresponse = await dio.post('/api/cartitems',
          data: data,
          options: Options(headers: {
            'Accept': 'application/vnd.api+json',
            'Authorization': 'Bearer $token'
          }));
      print('end http');
      print(dioresponse.data);
      // print(dioresponse);
      // ignore: unused_catch_clause
    } on DioException catch (e) {
      print('failled');
      dynamic error = e.response?.data;
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
          'DESLEY',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Cart(token: token)));
            },
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
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                '${data['img_url']}',
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${data['name']}',
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w900),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'ksh',
                    ),
                    Container(
                      width: 5,
                    ),
                    Column(
                      children: [
                        const Text('70,000',
                            style: TextStyle(
                                fontSize: 10,
                                decoration: TextDecoration.lineThrough)),
                        Text(
                          '${data['price']}',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        )
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 20,
          ),
          Center(
            child: MaterialButton(
              minWidth: 250,
              onPressed: () {
                setState(() {
                  _storeToCart(data['id']);
                });
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Cart(token: token)));
              },
              color: Colors.indigo[900],
              child: const Text(
                'add to cart',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  "${viewtype != 'services' ? data['item_description'] : data['service_description']}"),
            ),
          ),
          Container(
            height: 20,
          ),
        ],
      ),
    );
  }
}
