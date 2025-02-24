import 'dart:io';

import 'package:desley_app/onboarding_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pw;

class SupplierBilling extends StatefulWidget {
  const SupplierBilling({super.key, required this.token});
  final String token;

  @override
  State<SupplierBilling> createState() => _SupplierBillingState();
}

class _SupplierBillingState extends State<SupplierBilling> {
  late String token = widget.token;
  Map<String, dynamic> suser = {};
  List<dynamic>? data;

  getData() async {
    final dio = Dio();
    dio.options.baseUrl = dotenv.env['BASE_URL']!!;
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(minutes: 1);

    try {
      var response = await dio.get('/api/supplierbillings',
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
          'Supplier Billings',
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
                  dio.options.baseUrl = dotenv.env['BASE_URL']!!;
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
          ],
        ),
      ),
      body: Container(
        child: data == null
            ? Center(
                child: Lottie.asset('assets/images/loading.json', height: 100),
              )
            : ListView.builder(
                itemCount: data!.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration:
                          BoxDecoration(color: Colors.white, boxShadow: [
                        BoxShadow(
                          color: Colors.grey
                              .withOpacity(0.4), // Shadow color with opacity
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
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(data![index]['payment_code'].toString())
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Status',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  '${data![index]['status']['finance']}',
                                  style: TextStyle(
                                      color: data![index]['status']
                                                  ['finance'] ==
                                              'approved'
                                          ? Colors.green
                                          : Colors.red),
                                )
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
                                  '${data![index]['amount']}',
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600),
                                )
                              ],
                            ),
                            Text(data![index]['created_at']),
                            data![index]['status']['finance'] == 'approved'
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, right: 8.0),
                                      child: MaterialButton(
                                        minWidth:
                                            MediaQuery.of(context).size.width,
                                        color: Colors.green,
                                        onPressed: () async {
                                          const click = 0;
                                          if (click < 1) {
                                            // design pdf

                                            final pdf = pw.Document();
                                            final imageLogo = pw.MemoryImage(
                                              (await rootBundle.load(
                                                      'assets/images/logo.png'))
                                                  .buffer
                                                  .asUint8List(),
                                            );

                                            // Date formatting
                                            final createdAt = DateTime.parse(
                                                data![index]['created_at']);
                                            final formattedDate =
                                                "${createdAt.day}-${createdAt.month}-${createdAt.year}";
                                            print('started pdf vini');

                                            pdf.addPage(
                                              pw.Page(
                                                margin:
                                                    const pw.EdgeInsets.all(24),
                                                build: (pw.Context context) =>
                                                    pw.Column(
                                                  crossAxisAlignment: pw
                                                      .CrossAxisAlignment.start,
                                                  children: [
                                                    // Logo and Title
                                                    pw.Row(
                                                      mainAxisAlignment: pw
                                                          .MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        pw.Column(children: [
                                                          pw.Image(imageLogo,
                                                              height: 50),
                                                          pw.Text('Desley',
                                                              style: pw.TextStyle(
                                                                  color: PdfColors
                                                                      .blue900,
                                                                  fontSize: 30,
                                                                  fontWeight: pw
                                                                      .FontWeight
                                                                      .bold))
                                                        ]),
                                                        pw.Text("Receipt",
                                                            style: pw.TextStyle(
                                                                fontSize: 24,
                                                                color: PdfColors
                                                                    .blue800)),
                                                      ],
                                                    ),
                                                    pw.SizedBox(height: 16),

                                                    // Payment Info
                                                    pw.Text("Payment Details",
                                                        style: pw.TextStyle(
                                                            fontSize: 18,
                                                            color: PdfColors
                                                                .blue600)),
                                                    pw.Divider(
                                                        color:
                                                            PdfColors.blue600,
                                                        thickness: 1.5),
                                                    pw.SizedBox(height: 8),
                                                    pw.Text(
                                                        "Payment Code: ${data![index]['payment_code']}"),
                                                    pw.Text(
                                                        "Date: $formattedDate"),
                                                    pw.SizedBox(height: 16),

                                                    // Supplier Info
                                                    pw.Text(
                                                        "Supplier Information",
                                                        style: pw.TextStyle(
                                                            fontSize: 18,
                                                            color: PdfColors
                                                                .blue600)),
                                                    pw.Divider(
                                                        color:
                                                            PdfColors.blue600,
                                                        thickness: 1.5),
                                                    pw.SizedBox(height: 8),
                                                    pw.Text(
                                                        "Company: ${data![index]['supplier']['company_name']}"),
                                                    pw.Text(
                                                        "Email: ${data![index]['supplier']['email']}"),
                                                    pw.SizedBox(height: 16),

                                                    // Amount and Status
                                                    pw.Text("Amount",
                                                        style: pw.TextStyle(
                                                            fontSize: 18,
                                                            color: PdfColors
                                                                .blue600)),
                                                    pw.Divider(
                                                        color:
                                                            PdfColors.blue600,
                                                        thickness: 1.5),
                                                    pw.SizedBox(height: 8),
                                                    pw.Text(
                                                        "Total Amount: ${data![index]['amount']}"),
                                                    pw.Text(
                                                        "Finance Status: ${data![index]['status']['finance']}"),

                                                    // Footer
                                                    pw.Spacer(),
                                                    pw.Divider(
                                                        color:
                                                            PdfColors.blue600,
                                                        thickness: 1.5),
                                                    pw.Center(
                                                      child: pw.Text(
                                                        "Thank you for your business!",
                                                        style: pw.TextStyle(
                                                            fontSize: 14,
                                                            color: PdfColors
                                                                .blue600),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );

                                            print('finished pdf vini');

                                            //request permission

                                            if (await Permission
                                                .manageExternalStorage
                                                .isGranted) {
                                              print(
                                                  "Manage External Storage permission granted.");
                                            } else {
                                              // Request permission or redirect to settings
                                              var status = await Permission
                                                  .manageExternalStorage
                                                  .request();
                                              if (status.isGranted) {
                                                print("Permission granted!");
                                              } else if (status
                                                  .isPermanentlyDenied) {
                                                print(
                                                    "Permission permanently denied. Redirecting to settings...");
                                                openAppSettings(); // Redirect to app settings
                                              } else {
                                                print("Permission denied.");
                                              }
                                            }

                                            //save pdf
                                            final downloads = Directory(
                                                "/storage/emulated/0/Download");

                                            final filepath =
                                                '${downloads.path}/invoice_${data![index]['payment_code']}.pdf';

                                            final file = File(filepath);
                                            await file
                                                .writeAsBytes(await pdf.save());

                                            //open pdf

                                            await OpenFilex.open(filepath);
                                          }
                                        },
                                        child: const Text('Download receipt'),
                                      ),
                                    ),
                                  )
                                : const SizedBox(
                                    height: 0,
                                  )
                          ],
                        ),
                      ),
                    ),
                  );
                }),
      ),
    );
  }
}
