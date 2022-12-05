import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Home/home.dart';
import 'Compare/CompareZones.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).accentColor,
      child: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.home),
            title: Text(
              "Home",
              style: GoogleFonts.montserrat(
                textStyle:
                    const TextStyle(color: Colors.white, letterSpacing: 5),
              ),
            ),
            iconColor: Theme.of(context).primaryColor,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ),
              );
            },
          ),
          Divider(),
          // ListTile(
          //   leading: Icon(Icons.looks_one),
          //   title: Text(
          //     "Zone 1",
          //     style: GoogleFonts.montserrat(
          //       textStyle:
          //           const TextStyle(color: Colors.white, letterSpacing: 5),
          //     ),
          //   ),
          //   iconColor: Theme.of(context).primaryColor,
          //   onTap: () {
          //     Navigator.of(context).push(
          //       MaterialPageRoute(
          //         builder: (context) => Zone(zoneNo: 1),
          //       ),
          //     );
          //   },
          // ),
          // ListTile(
          //   leading: Icon(Icons.looks_two),
          //   title: Text(
          //     "Zone 2",
          //     style: GoogleFonts.montserrat(
          //       textStyle:
          //           const TextStyle(color: Colors.white, letterSpacing: 5),
          //     ),
          //   ),
          //   iconColor: Theme.of(context).primaryColor,
          //   onTap: () {
          //     Navigator.of(context).push(
          //       MaterialPageRoute(
          //         builder: (context) => Zone(zoneNo: 2),
          //       ),
          //     );
          //   },
          // ),
          // ListTile(
          //   leading: Icon(Icons.looks_3),
          //   title: Text(
          //     "Zone 3",
          //     style: GoogleFonts.montserrat(
          //       textStyle:
          //           const TextStyle(color: Colors.white, letterSpacing: 5),
          //     ),
          //   ),
          //   iconColor: Theme.of(context).primaryColor,
          //   onTap: () {
          //     Navigator.of(context).push(
          //       MaterialPageRoute(
          //         builder: (context) => Zone(zoneNo: 3),
          //       ),
          //     );
          //   },
          // ),
          // Divider(),
          ListTile(
            leading: Icon(Icons.auto_graph),
            title: Text(
              "Compare Zones",
              style: GoogleFonts.montserrat(
                textStyle:
                    const TextStyle(color: Colors.white, letterSpacing: 5),
              ),
            ),
            iconColor: Theme.of(context).primaryColor,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CompareZones(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
