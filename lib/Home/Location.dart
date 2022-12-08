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
import 'UserData.dart';

const List<Widget> meas = <Widget>[
  Text(' Temperature '),
  Text('Light'),
  Text('Noise')
];

class Location extends StatefulWidget {
  const Location({super.key});

  @override
  _Location createState() => _Location();
}

class _Location extends State<Location> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<UserData> users = [];

  final CollectionReference collectionReferenceLoc =
      FirebaseFirestore.instance.collection('Location');
  int userssize = 1;

  Future<int> getNoUsers() async {
    QuerySnapshot querySnapshot = await collectionReferenceLoc.get();
    int count = 1;
    // Get data from docs and convert map to List
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    var map = jsonDecode(jsonEncode(allData));
    for (var e in map) {
      count++;
    }
    return count;
  }

  Future<UserData> getLData(String user) async {
    // Get docs from collection reference
    List<UserData> data = [];
    QuerySnapshot querySnapshot = await collectionReferenceLoc
        .doc(user)
        .collection("History")
        .orderBy('time', descending: true)
        .get();
    // Get data from docs and convert map to List
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    var map = jsonDecode(jsonEncode(allData));
    for (var e in map) {
      UserData nyu = UserData(e['date'], e['time'], e['zone'], e['id']);
      data.add(nyu);
    }
    return data[0];
  }

  Future<List<int>> getSmartData() async {
    // Get docs from collection reference
    int data1 = 0;
    int data2 = 0;
    List<int> waterTilt = [];
    QuerySnapshot querySnapshot = await collectionReferenceObj
        .doc("Smart Cup Water Level")
        .collection("Zone1")
        .get();
    // Get data from docs and convert map to List
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    var map = jsonDecode(jsonEncode(allData));
    for (var e in map) {
      data1 = e['value'];
    }
    waterTilt.add(data1);
    QuerySnapshot querySnapshot2 = await collectionReferenceObj
        .doc("Smart Cup Tilt")
        .collection("Zone1")
        .get();
    // Get data from docs and convert map to List
    final allData2 = querySnapshot2.docs.map((doc) => doc.data()).toList();
    var map2 = jsonDecode(jsonEncode(allData2));
    for (var e in map2) {
      data1 = e['value'];
    }
    waterTilt.add(data2);
    return waterTilt;
  }

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

  final CollectionReference collectionReferenceReq =
      FirebaseFirestore.instance.collection('Requests');

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
        child: Column(
          children: [
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
                          physics: const ScrollPhysics(),
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
                                  width: 450,
                                  child: Row(
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        child: Text(
                                          zone,
                                          style: GoogleFonts.montserrat(
                                            textStyle: const TextStyle(
                                                letterSpacing: 5),
                                          ),
                                        ),
                                      ),
                                      Padding(padding: EdgeInsets.all(50)),
                                    ],
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
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: CircularPercentIndicator(
                                                radius: 36,
                                              ),
                                            )
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
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: CircularPercentIndicator(
                                                radius: 36,
                                              ),
                                            )
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
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: CircularPercentIndicator(
                                                radius: 36,
                                              ),
                                            )
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
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        lightOn = !lightOn;
                                        if (lightOn == true) {
                                          light = 'On';
                                          Map<String, Object?> data = {
                                            'value': 1
                                          };
                                          collectionReferenceReq
                                              .doc('Zone1')
                                              .collection('Lights')
                                              .doc('atmoZone1')
                                              .update(data);
                                        } else {
                                          light = 'Off';
                                          Map<String, Object?> data = {
                                            'value': 0
                                          };
                                          collectionReferenceReq
                                              .doc('Zone1')
                                              .collection('Lights')
                                              .doc('atmoZone1')
                                              .update(data);
                                        }
                                      });
                                    },
                                    child: Container(
                                      color:
                                          lightOn ? Colors.green : Colors.grey,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 10),
                                      child: Text(
                                        "Lights: $light",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13.0),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        fanOn = !fanOn;

                                        if (fanOn == true) {
                                          fan = 'On';
                                          Map<String, Object?> data = {
                                            'value': 1
                                          };
                                          collectionReferenceReq
                                              .doc('Zone2')
                                              .collection('Fans')
                                              .doc('atmoZone2')
                                              .update(data);
                                        } else {
                                          fan = 'Off';
                                          Map<String, Object?> data = {
                                            'value': 0
                                          };
                                          collectionReferenceReq
                                              .doc('Zone2')
                                              .collection('Fans')
                                              .doc('atmoZone2')
                                              .update(data);
                                        }
                                      });
                                    },
                                    child: Container(
                                      color: fanOn ? Colors.green : Colors.grey,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 10),
                                      child: Text(
                                        "Fan: $fan",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13.0),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ]);
                          },
                        ),
                        const Padding(padding: EdgeInsets.all(8)),
                        FutureBuilder(
                            future: getNoUsers(),
                            builder: (context, snapshot) {
                              return TextButton(
                                onPressed: () {
                                  setState(() {
                                    userssize = snapshot.requireData;
                                  });
                                },
                                child: Container(
                                  color: Colors.grey,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  child: const Text(
                                    "Refresh",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 13.0),
                                  ),
                                ),
                              );
                            }),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: userssize,
                              itemBuilder: (context, index) {
                                return FutureBuilder(
                                  future: getLData((index + 1).toString()),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text("Waiting for Data"))
                                        ],
                                      );
                                    } else if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                              "User: ${snapshot.requireData.id}  - Entered: Zone ${snapshot.requireData.zone}  - At: ${snapshot.requireData.date}"));
                                    } else {
                                      return Text(
                                          'State: ${snapshot.connectionState}');
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.all(8)),
                        Center(
                          child: Text(
                            'Smart Cup',
                            style: GoogleFonts.montserrat(
                              textStyle: const TextStyle(letterSpacing: 5),
                            ),
                          ),
                        ),
                        Padding(padding: EdgeInsets.all(8)),
                        
                        RotationTransition(
                          turns:
                              Tween(begin: 0.0, end: 0.25).animate(_controller),
                          child: FutureBuilder(
                          future: getSmartData(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CircularPercentIndicator(
                                      radius: 36,
                                    ),
                                  )
                                ],
                              );
                            } else if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircularPercentIndicator(
                                  radius: 36.0,
                                  lineWidth: 5.0,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.secondary,
                                  percent: snapshot.requireData[0] / 5,
                                  progressColor: Colors.yellow,
                                  circularStrokeCap: CircularStrokeCap.round,
                                  animation: true,
                                  center: Text(
                                    '${(snapshot.requireData[0] / 5) * 100} %',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              );
                            } 
                            else {
                              return Text('State: ${snapshot.connectionState}');
                            }
                          },
                        ),
                        ),
                      ],
                    ),
                  ),
                ))]),
                ),
              );
  }
}
