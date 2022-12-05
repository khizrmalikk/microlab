import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:microlab/Home/mobile_body.dart';
import 'package:microlab/Home/desktop_body.dart';
import 'package:microlab/responsive_layout.dart';
import '../Chart/ZoneData.dart';
import 'package:flutter/widgets.dart' show WidgetsFlutterBinding;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<ZoneData> _data = <ZoneData>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
                mobileBody: MyMobileBody(),
                desktopBody: MyDesktopBody(),
              ),
    );
  }
}
