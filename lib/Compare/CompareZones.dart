import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:microlab/Chart/developer_chart_compare.dart';
import 'package:microlab/Home/dataCoverter.dart';
import '../Chart/ZoneData.dart';
import '../Chart/developer_chart_compare_zones.dart';
import '/NavBar.dart';
import 'package:google_fonts/google_fonts.dart';

const List<Widget> meas = <Widget>[
  Text(' Temperature'),
  Text('Light'),
  Text('Noise')
];

const List<Widget> zoneslist = <Widget>[
  Text('Zone 1'),
  Text('Zone 2'),
  Text('Zone 3')
];

class CompareZones extends StatefulWidget {
  const CompareZones({super.key});

  @override
  _CompareZones createState() => _CompareZones();
}

class _CompareZones extends State<CompareZones> {
  final CollectionReference collectionReferenceHr =
      FirebaseFirestore.instance.collection('Hours');

  final CollectionReference collectionReferenceMin =
      FirebaseFirestore.instance.collection('Minute');

  final decoder = const FirebaseNamesDecoder();

  final List<bool> measurements = <bool>[true, false, false];
  bool vertical = false;

  final List<bool> zonesa = <bool>[true, false, false];

  String mes = "T";
  String zn = "Zone1";
  List<ZoneData> zone1Compare = [];
  List<ZoneData> zone2Compare = [];
  List<ZoneData> zone3Compare = [];

  List<ZoneData> tempCompare = [];
  List<ZoneData> lightCompare = [];
  List<ZoneData> noiseCompare = [];

  Future<List<ZoneData>> getHrData(String zone, String measurement) async {
    // Get docs from collection reference
    QuerySnapshot querySnapshot = await collectionReferenceHr
        .doc(zone)
        .collection(measurement)
        .orderBy('time', descending: true)
        .get();
    // Get data from docs and convert map to List
    List<ZoneData> data = [];
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    var map = jsonDecode(jsonEncode(allData));
    for (var e in map) {
      ZoneData nyu = ZoneData(e['time'], e['value']);
      data.add(nyu);
    }
    print(data);
    return data;
  }

  Future<void> gendata(int type, String genZone, String genMeasurement) async {
    if (type == 0) {
      tempCompare = await getHrData("Zone1", genMeasurement);
      lightCompare = await getHrData("Zone2", genMeasurement);
      noiseCompare = await getHrData("Zone3", genMeasurement);
    } else {
      zone1Compare = await getHrData(genZone, "T");
      zone2Compare = await getHrData(genZone, "L");
      zone3Compare = await getHrData(genZone, "N");
    }
  }

  Future<ZoneData> getMinData(String zone, String measurement) async {
    // Get docs from collection reference
    QuerySnapshot querySnapshot =
        await collectionReferenceMin.doc(zone).collection(measurement).get();
    // Get data from docs and convert map to List
    ZoneData data = ZoneData(0, 0);
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    var map = jsonDecode(jsonEncode(allData));
    for (var e in map) {
      ZoneData nyu = ZoneData(e['time'], e['value']);
      data = nyu;
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        title: Text(
          'MicroLab',
          style: GoogleFonts.montserrat(
            textStyle: const TextStyle(letterSpacing: 5),
          ),
        ),
      ),
      drawer: const NavBar(),
      body: Container(
        color: Theme.of(context).colorScheme.secondary,
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: ListView(
                  children: [
                    const SizedBox(height: 20),
                    FutureBuilder(
                      future: gendata(0, "", mes),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              CircularProgressIndicator(),
                            ],
                          );
                        } else if (snapshot.connectionState ==
                            ConnectionState.done) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: DeveloperChartCompare(
                                chartTitle: 'Comparison of Measurement',
                                tData: tempCompare,
                                lData: lightCompare,
                                nData: noiseCompare,
                              ),
                            ),
                          );
                        } else {
                          return Text('State: ${snapshot.connectionState}');
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    FutureBuilder(
                      future: gendata(1, zn, ""),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              CircularProgressIndicator(),
                            ],
                          );
                        } else if (snapshot.connectionState ==
                            ConnectionState.done) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: DeveloperChartCompareZones(
                                chartTitle: 'Comparison of Zones',
                                tData: zone1Compare,
                                lData: zone2Compare,
                                nData: zone3Compare,
                              ),
                            ),
                          );
                        } else {
                          return Text('State: ${snapshot.connectionState}');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            //Second Column
            Padding(
                padding: const EdgeInsets.all(25.0),
                child: Container(
                  color: Theme.of(context).primaryColor,
                  width: 500,
                  child: Center(
                    child: ListView(
                      padding: const EdgeInsets.all(8.0),
                      children: [
                        //Measurement Compare
                        Padding(padding: EdgeInsets.all(40)),
                        Center(
                          child: Text("Filter by Measurement"),
                        ),
                        Padding(padding: EdgeInsets.all(20)),
                        const SizedBox(height: 5),
                        Center(
                          child: ToggleButtons(
                            direction:
                                vertical ? Axis.vertical : Axis.horizontal,
                            onPressed: (int index) {
                              setState(() {
                                // The button that is tapped is set to true, and the others to false.
                                print(index);
                                for (int i = 0; i < measurements.length; i++) {
                                  measurements[i] = i == index;
                                }
                                if (index == 0) {
                                  mes = "T";
                                }
                                if (index == 1) {
                                  mes = "L";
                                }
                                if (index == 2) {
                                  mes = "N";
                                }
                              });
                            },
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8)),
                            borderColor: Colors.black,
                            selectedBorderColor: Color.fromARGB(255, 0, 0, 0),
                            selectedColor: Colors.white,
                            fillColor: Theme.of(context).accentColor,
                            color: Color.fromARGB(255, 255, 255, 255),
                            constraints: const BoxConstraints(
                              minHeight: 40.0,
                              minWidth: 80.0,
                            ),
                            isSelected: measurements,
                            children: meas,
                          ),
                        ),

                        //Zone compare
                        const SizedBox(height: 5),
                        const Padding(padding: EdgeInsets.all(30)),
                        const Center(
                          child: Text("Filter by Zone"),
                        ),
                        const Padding(padding: EdgeInsets.all(20)),
                        Center(
                          child: ToggleButtons(
                            direction:
                                vertical ? Axis.vertical : Axis.horizontal,
                            onPressed: (int index) {
                              setState(() {
                                // The button that is tapped is set to true, and the others to false.
                                print(index);
                                for (int i = 0; i < zonesa.length; i++) {
                                  zonesa[i] = i == index;
                                }
                                if (index == 0) {
                                  zn = "Zone1";
                                }
                                if (index == 1) {
                                  zn = "Zone2";
                                }
                                if (index == 2) {
                                  zn = "Zone3";
                                }
                              });
                            },
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8)),
                            borderColor: Colors.black,
                            selectedBorderColor: Color.fromARGB(255, 0, 0, 0),
                            selectedColor: Colors.white,
                            fillColor: Theme.of(context).accentColor,
                            color: Color.fromARGB(255, 255, 255, 255),
                            constraints: const BoxConstraints(
                              minHeight: 40.0,
                              minWidth: 80.0,
                            ),
                            isSelected: zonesa,
                            children: zoneslist,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
