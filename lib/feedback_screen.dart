import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';

class FeedbackScreen extends StatefulWidget {
  final String token;
  const FeedbackScreen({super.key, required this.token});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  late String token = widget.token;
  final _feedbackController = TextEditingController();
  String selectedRole = 'Manager';

  Map<String, dynamic>? data;
  Map<String, dynamic> euser = {};

  getData() async {
    final dio = Dio();
    dio.options.baseUrl = dotenv.env['BASE_URL']!!;
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(minutes: 1);
    dio.options.contentType = 'application/vnd.api+json';
    dio.options.responseType = ResponseType.json;

    try {
      var response = await dio.get('/api/myfeedback',
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
          'Feedback',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(children: [
        Text(
          'Give us your Feedback',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        DropdownButton<String>(
          value: selectedRole,
          items: <String>['Manager', 'Finance'] // Options for selection
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedRole = newValue!;
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (text) {},
            controller: _feedbackController,
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.email),
                prefixIconColor: Colors.indigo,
                hintText: 'email',
                border: OutlineInputBorder()),
          ),
        ),
        MaterialButton(
            color: Colors.indigo,
            onPressed: () {
              if (_feedbackController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Please enter your message'),
                ));
              } else {
                sendmessage(context);
              }
            },
            child: const Text(
              'Send',
              style: TextStyle(color: Colors.white),
            )),
        Expanded(
            child: ListView.builder(
          itemCount: data == null ? 0 : data!['data'].length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                Card(
                  child: ListTile(
                    title: Text('${data!['data'][index]['message']}'),
                    subtitle: Text(
                        'To: ${data!['data'][index]['receiver']['role']} at ${data!['data'][index]['created_at']}'),
                  ),
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
                                'From: ${data!['data'][index]['receiver']['role']} at ${data!['data'][index]['reply']['created_at']}'),
                          ),
                        ),
                      ),
              ],
            );
          },
        ))
      ]),
    );
  }

  void sendmessage(BuildContext context) async {
    final dio = Dio();
    dio.options.baseUrl = dotenv.env['BASE_URL']!!;
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(minutes: 1);
    dio.options.contentType = 'application/vnd.api+json';
    dio.options.responseType = ResponseType.json;
    final data = {
      'message': _feedbackController.text,
      'receiver': selectedRole,
    };
    try {
      // ignore: unused_local_variable
      var response = await dio.post('/api/receive-feedback',
          data: data,
          options: Options(headers: {
            'Accept': 'application/vnd.api+json',
            'Authorization': 'Bearer $token'
          }));
      setState(() {
        _feedbackController.clear();
        getData();
      });
    } on DioException catch (e) {
      dynamic error = e.response?.data;
    }
  }
}
