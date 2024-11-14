import 'package:flutter/material.dart';

class Aboutus extends StatefulWidget {
  const Aboutus({super.key});

  @override
  State<Aboutus> createState() => _AboutusState();
}

class _AboutusState extends State<Aboutus> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About Us',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    'COMPANY OVERVIEW\n',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                      " DESLEY HOLDINGS KENYA LTD is one of the leading supplier of Dairy Equipments in Kenya. The company has been in operation since 1994 supplying and servicing Dairy Machineries to Government Institutions, NGO’s, Private Companies and Individuals. \n\nThe equipment we supply range from Milking Machines, Pasteurisers, Homogenizers, Fill and Seal Machines, Generators, Pumps, Cream Separators and others.\n\nWe source our equipment from international companies such as INTERPULS (Italy), PACKO (Belgium), PIETRIBIASI (Italy), PROINOX (France), THERMAL INGITECH (India), NHM (Bulgaria) among others. "),
                  Text(
                    'OUR VISION\n',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                      'To be recognized as a global leader in the supply of Dairy machinery'),
                  Text(
                    'OUR MISSION\n',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                      'To be the preferred partner in the Kenyan and East African market by supplying high quality equipment of approved international standards.\n'),
                  Text(
                    'Call: 0720-495 141 / 0734 288 147',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Email: info@desleyholdings.co.ke',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
