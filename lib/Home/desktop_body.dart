import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:microlab/Home/dataCoverter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../Chart/ZoneData.dart';
import '/NavBar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Chart/developer_chart.dart';
import 'package:flutter_echarts/flutter_echarts.dart';

const List<Widget> meas = <Widget>[
  Text(' Temperature '),
  Text('Light'),
  Text('Noise'),
  Text('Doors')
];

class MyDesktopBody extends StatefulWidget {
  const MyDesktopBody({super.key});

  @override
  _MyDesktopBody createState() => _MyDesktopBody();
}

class _MyDesktopBody extends State<MyDesktopBody> {
  late Timer _everySecond;

  bool lightOn = false;
  String light = 'Off';
  bool fanOn = false;
  String fan = 'Off';

  final CollectionReference collectionReferenceHr =
      FirebaseFirestore.instance.collection('Hours');

  final CollectionReference collectionReferenceMin =
      FirebaseFirestore.instance.collection('Minute');

  final CollectionReference collectionReferenceObj =
      FirebaseFirestore.instance.collection('Objects');

  final decoder = const FirebaseNamesDecoder();

  final List<bool> measurements = <bool>[true, false, false, false];
  bool vertical = false;

  String mes = "T";
  String tableName = "Zone 1";

  Future<List<ZoneData>> getData(String zone, String measurement) async {
    // Get docs from collection reference
    List<ZoneData> data = [];
    if (measurement == "O") {
      QuerySnapshot querySnapshot = await collectionReferenceObj
          .doc('Doors')
          .collection(zone)
          .orderBy('time', descending: true)
          .get();
      final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
      var map = jsonDecode(jsonEncode(allData));
      for (var e in map) {
        ZoneData nyu = ZoneData(e['time'], e['open for']);
        data.add(nyu);
      }
    } else {
      QuerySnapshot querySnapshot = await collectionReferenceHr
          .doc(zone)
          .collection(measurement)
          .orderBy('time', descending: true)
          .get();
      // Get data from docs and convert map to List
      final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
      var map = jsonDecode(jsonEncode(allData));
      for (var e in map) {
        ZoneData nyu = ZoneData(e['time'], e['value']);
        data.add(nyu);
      }
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
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: ListView(
                  children: [
                    const SizedBox(height: 15),
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
                            if (index == 3) {
                              mes = "O";
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
                    const SizedBox(height: 5),
                    FutureBuilder(
                        future: getData("Zone1", mes),
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
                                aspectRatio: 5 / 2,
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
                        future: getData("Zone2", mes),
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
                                aspectRatio: 5 / 2,
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
                        future: getData("Zone3", mes),
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
                                aspectRatio: 5 / 2,
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
                        const Padding(padding: EdgeInsets.all(8.0)),
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
                                  height: 60,
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
                                  const Padding(padding: EdgeInsets.all(20.0)),
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
                                            radius: 36.0,
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
                                                fontSize: 15,
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
                                            radius: 36.0,
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
                                                fontSize: 15,
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
                                            radius: 36.0,
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
                                                fontSize: 15,
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
                        const Padding(padding: EdgeInsets.all(8)),
                        TextButton(
                          onPressed: () {
                            setState(() {
                            lightOn = !lightOn;
                            
                            if(lightOn == true){
                              light = 'On';
                            }else {
                              light = 'Off';
                            }
                            });
                          },
                          child: Container(
                            color: Colors.green,
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            child: Text(
                              light,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 13.0),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {

                            fanOn = !fanOn;
                            
                            if(fanOn == true){
                              fan = 'On';
                            }else {
                              fan = 'Off';
                            }
                            });
                          },
                          child: Container(
                            color: Colors.green,
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            child: Text(
                              fan,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 13.0),
                            ),
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
