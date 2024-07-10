import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: must_be_immutable
class MyDialog extends StatefulWidget {
  List<dynamic>? supplierdata;
  String itemName;
  String token;
  int inventoryId;
  MyDialog(
      {super.key,
      required this.supplierdata,
      required this.itemName,
      required this.token,
      required this.inventoryId});

  @override
  State<MyDialog> createState() => _MyDialogState(
      supplierdata: supplierdata,
      itemName: itemName,
      token: token,
      inventoryId: inventoryId);
}

class _MyDialogState extends State<MyDialog> {
  String? ddValue;
  String itemName;
  String token;
  int inventoryId;

  List<dynamic>? supplierdata;
  _MyDialogState(
      {required this.supplierdata,
      required this.itemName,
      required this.token,
      required this.inventoryId});
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Text('Restock'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Item: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(itemName),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                  labelText: 'No of items',
                  prefixIcon: Icon(Icons.inventory_rounded),
                  prefixIconColor: Colors.indigo,
                  border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 20,
            ),
            Center(child: Text('Supplier')),
            DropdownButton(
                isExpanded: true,
                hint: Text('Select supplier'),
                items: dropItems(),
                value: ddValue,
                onChanged: (value) {
                  setState(() {
                    ddValue = value;
                  });
                }),
            SizedBox(
              height: 20,
            ),
            MaterialButton(
              onPressed: () async {
                if (ddValue != null && controller.text.isNotEmpty) {
                  final dio = Dio();
                  dio.options.baseUrl = 'http://164.90.212.129';
                  dio.options.connectTimeout = const Duration(seconds: 5);
                  dio.options.receiveTimeout = const Duration(minutes: 1);

                  try {
                    var response = await dio.post('/api/suptransactions',
                        data: {
                          'inventory_id': inventoryId,
                          'supplier_id': findsupplierId(ddValue),
                          'count': controller.text,
                        },
                        options: Options(headers: {
                          'Accept': 'application/vnd.api+json',
                          'Authorization': 'Bearer $token'
                        }));
                    Navigator.pop(context);
                    print(response);
                  } on DioException catch (e) {
                    dynamic error = e.response?.data;
                    print(error);
                  }
                }
              },
              color: Colors.indigo,
              minWidth: MediaQuery.of(context).size.width / 2,
              child: const Text(
                'Request restock',
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<dynamic>> dropItems() {
    return supplierdata!.map((e) {
      return DropdownMenuItem(
        value: e['company_name'],
        child: Text(e['company_name']),
      );
    }).toList();
  }

  int? findsupplierId(String? company) {
    if (company == null) {
      return null;
    }
    for (var element in supplierdata!) {
      if (element['company_name'] == company) {
        return element['id'];
      }
    }
    return null;
  }
}
