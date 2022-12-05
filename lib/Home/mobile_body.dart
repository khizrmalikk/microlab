import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../Chart/ZoneData.dart';
import '/NavBar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../Chart/developer_chart.dart';

const List<Widget> meas = <Widget>[
  Text(' Temperature '),
  Text('Light'),
  Text('Noise')
];

class MyMobileBody extends StatefulWidget {
  const MyMobileBody({super.key});

  @override
  _MyMobileBody createState() => _MyMobileBody();
}

class _MyMobileBody extends State<MyMobileBody> {
  final CollectionReference collectionReferenceHr =
      FirebaseFirestore.instance.collection('Hours');

  final CollectionReference collectionReferenceMin =
      FirebaseFirestore.instance.collection('Minute');

  final List<bool> measurements = <bool>[true, false, false];
  bool vertical = false;

  String mes = "T";

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
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ListView(
                  children: [
                    const SizedBox(height: 5),
                    Center(
                      child: ToggleButtons(
                        direction: vertical ? Axis.vertical : Axis.horizontal,
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
                        selectedBorderColor: Color.fromARGB(255, 0, 0, 0),
                        selectedColor: Colors.white,
                        fillColor: Theme.of(context).primaryColor,
                        color: Color.fromARGB(255, 255, 255, 255),
                        constraints: const BoxConstraints(
                          minHeight: 40.0,
                          minWidth: 80.0,
                        ),
                        isSelected: measurements,
                        children: meas,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FutureBuilder(
                        future: getHrData("Zone1", mes),
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
                                child: DeveloperChart(
                                  chartTitle: 'Zone 1',
                                  tData: snapshot.requireData,
                                ),
                              ),
                            );
                          } else {
                            return Text('State: ${snapshot.connectionState}');
                          }
                        }),
                    FutureBuilder(
                        future: getHrData("Zone2", mes),
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
                                child: DeveloperChart(
                                  chartTitle: 'Zone 2',
                                  tData: snapshot.requireData,
                                ),
                              ),
                            );
                          } else {
                            return Text('State: ${snapshot.connectionState}');
                          }
                        }),
                    FutureBuilder(
                        future: getHrData("Zone3", mes),
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
                                child: DeveloperChart(
                                  chartTitle: 'Zone 3',
                                  tData: snapshot.requireData,
                                ),
                              ),
                            );
                          } else {
                            return Text('State: ${snapshot.connectionState}');
                          }
                        }),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            print(index);
                            String zone = "";
                            if (index == 0) {
                              zone = "Zone1";
                            } else if (index == 1) {
                              zone = "Zone2";
                            } else {
                              zone = "Zone3";
                            }
                            return Column(children: [
                              Padding(
                                padding: const EdgeInsets.all(0),
                                child: SizedBox(
                                  height: 75,
                                  width: 100,
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      zone,
                                      style: GoogleFonts.montserrat(
                                        textStyle:
                                            const TextStyle(letterSpacing: 5),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  const Padding(padding: EdgeInsets.all(20)),
                                  FutureBuilder(
                                    future: getMinData(zone, "T"),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            CircularProgressIndicator(),
                                          ],
                                        );
                                      } else if (snapshot.connectionState ==
                                          ConnectionState.done) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: CircularPercentIndicator(
                                            radius: 60.0,
                                            lineWidth: 5.0,
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            percent:
                                                snapshot.requireData.value / 40,
                                            progressColor: Colors.red,
                                            circularStrokeCap:
                                                CircularStrokeCap.round,
                                            animation: true,
                                            center: Text(
                                              '${snapshot.requireData.value} °C',
                                              style: GoogleFonts.montserrat(
                                                color: Colors.white,
                                                fontSize: 25,
                                              ),
                                            ),
                                          ),
                                        );
                                      } else {
                                        return Text(
                                            'State: ${snapshot.connectionState}');
                                      }
                                    },
                                  ),
                                  FutureBuilder(
                                    future: getMinData("Zone1", "N"),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            CircularProgressIndicator(),
                                          ],
                                        );
                                      } else if (snapshot.connectionState ==
                                          ConnectionState.done) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: CircularPercentIndicator(
                                            radius: 60.0,
                                            lineWidth: 5.0,
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            percent:
                                                snapshot.requireData.value /
                                                    120,
                                            progressColor: Colors.blue,
                                            circularStrokeCap:
                                                CircularStrokeCap.round,
                                            animation: true,
                                            center: Text(
                                              '${snapshot.requireData.value} db',
                                              style: GoogleFonts.montserrat(
                                                color: Colors.white,
                                                fontSize: 25,
                                              ),
                                            ),
                                          ),
                                        );
                                      } else {
                                        return Text(
                                            'State: ${snapshot.connectionState}');
                                      }
                                    },
                                  ),
                                  FutureBuilder(
                                    future: getMinData("Zone1", "L"),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            CircularProgressIndicator(),
                                          ],
                                        );
                                      } else if (snapshot.connectionState ==
                                          ConnectionState.done) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: CircularPercentIndicator(
                                            radius: 60.0,
                                            lineWidth: 5.0,
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            percent:
                                                snapshot.requireData.value /
                                                    255,
                                            progressColor: Colors.green,
                                            circularStrokeCap:
                                                CircularStrokeCap.round,
                                            animation: true,
                                            center: Text(
                                              '${snapshot.requireData.value} lx',
                                              style: GoogleFonts.montserrat(
                                                color: Colors.white,
                                                fontSize: 25,
                                              ),
                                            ),
                                          ),
                                        );
                                      } else {
                                        return Text(
                                            'State: ${snapshot.connectionState}');
                                      }
                                    },
                                  ),
                                ],
                              )
                            ]);
                          },
                        ),
                      ],
                    ),
                  ),
                )]),
                ),
              );
  }
}
