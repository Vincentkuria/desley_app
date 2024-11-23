import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class FeedbackMessageScreen extends StatefulWidget {
  final String token;
  const FeedbackMessageScreen({super.key, required this.token});

  @override
  State<FeedbackMessageScreen> createState() => _FeedbackMessageScreenState();
}

class _FeedbackMessageScreenState extends State<FeedbackMessageScreen> {
  late String token = widget.token;

  Map<String, dynamic>? data;
  Map<String, dynamic> euser = {};
  TextEditingController controller = TextEditingController();

  getData() async {
    final dio = Dio();
    dio.options.baseUrl = 'http://192.168.100.3:8000';
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(minutes: 1);
    dio.options.contentType = 'application/vnd.api+json';
    dio.options.responseType = ResponseType.json;

    try {
      var response = await dio.get('/api/myefeedback',
          options: Options(headers: {
            'Accept': 'application/vnd.api+json',
            'Authorization': 'Bearer $token'
          }));
//shipping ==null
      setState(() {
        data = response.data;
        print(data);
      });

      // ignore: unused_catch_clause
    } on DioException catch (e) {
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
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Messages',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
          backgroundColor: Colors.indigo,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: ListView.builder(
          itemCount: data == null ? 0 : data!['data'].length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                Card(
                  child: ListTile(
                      title: Text('${data!['data'][index]['message']}'),
                      subtitle:
                          Text('at ${data!['data'][index]['created_at']}'),
                      trailing: PopupMenuButton(
                          onSelected: (value) async {
                            if (value == '1') {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Reply'),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            TextField(
                                              controller: controller,
                                              decoration: const InputDecoration(
                                                  prefixIcon:
                                                      Icon(Icons.message),
                                                  prefixIconColor:
                                                      Colors.indigo,
                                                  hintText: 'message',
                                                  border: OutlineInputBorder()),
                                            ),
                                            const SizedBox(
                                              height: 30,
                                            ),
                                            Center(
                                              child: MaterialButton(
                                                onPressed: () async {
                                                  final dio = Dio();
                                                  dio.options.baseUrl =
                                                      'http://192.168.100.3:8000';
                                                  dio.options.connectTimeout =
                                                      const Duration(
                                                          seconds: 5);
                                                  dio.options.receiveTimeout =
                                                      const Duration(
                                                          minutes: 1);

                                                  if (controller.text.isEmpty) {
                                                    return;
                                                  }

                                                  try {
                                                    // ignore: unused_local_variable
                                                    var response =
                                                        await dio.post(
                                                            '/api/replyfeedback',
                                                            data: {
                                                              'message':
                                                                  controller
                                                                      .text,
                                                              'replyingto':
                                                                  data!['data'][
                                                                          index]
                                                                      ['id']
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
                                                minWidth: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2,
                                                child: const Text('Send'),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            }
                          },
                          itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: Text('reply'),
                                  value: '1',
                                ),
                              ])),
                ),
                data!['data'][index]['reply'] == null
                    ? SizedBox(height: 0)
                    : Padding(
                        padding: const EdgeInsets.only(left: 25.0),
                        child: Card(
                          color: Colors.green, // Set background color to green
                          child: ListTile(
                            title: Text(
                                '${data!['data'][index]['reply']['message']}'),
                            subtitle: Text(
                                'at ${data!['data'][index]['reply']['created_at']}'),
                          ),
                        ),
                      ),
              ],
            );
          },
        ));
  }
}
