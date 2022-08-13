import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learning/pages/auth_page.dart';
import 'package:learning/pages/input.dart';
import 'package:learning/pages/list_visitors.dart';
import 'package:learning/pages/scan_qr.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  int totalVisitor = 0, totalAttedance = 0, totalNotPresent = 0;

  @override
  void initState() {
    firestore.collection('visitors').get().then((snap) {
      setState(() {
        totalVisitor = snap.size;
      });
    });

    firestore
        .collection('visitors')
        .where(
          'is_scan',
          isEqualTo: true,
        )
        .get()
        .then((snap) {
      setState(() {
        totalAttedance = snap.size;
      });
    });

    firestore
        .collection('visitors')
        .where(
          'is_scan',
          isEqualTo: false,
        )
        .get()
        .then((snap) {
      setState(() {
        totalNotPresent = snap.size;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ClipPath(
            clipper: ClipPathClass(),
            child: Container(
              height: 250,
              width: MediaQuery.of(context).size.width,
              color: Colors.teal,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 45.0,
                    ),
                    child: Center(
                      child: Text(
                        'HOME',
                        style: GoogleFonts.openSans(
                          color: Colors.white,
                          letterSpacing: 1,
                          fontWeight: FontWeight.bold,
                          fontSize: 30.0,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.count(
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    crossAxisCount: 2,
                    primary: false,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ScanPage(),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              8.0,
                            ),
                          ),
                          elevation: 4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.qr_code_scanner_rounded,
                                size: 90,
                              ),
                              Text(
                                'Scan QR Code',
                                style: GoogleFonts.openSans(
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const InputPage(),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              8.0,
                            ),
                          ),
                          elevation: 4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.person_add_rounded,
                                size: 90,
                              ),
                              Text(
                                'Tambah Tamu',
                                style: GoogleFonts.openSans(
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: ((context) => const VisitorsPage()),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              8.0,
                            ),
                          ),
                          elevation: 4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.group_rounded,
                                size: 90,
                              ),
                              Text(
                                'Tamu Undangan',
                                style: GoogleFonts.openSans(
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _signOut();

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AuthPage(),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              8.0,
                            ),
                          ),
                          elevation: 4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.logout_rounded,
                                size: 90,
                              ),
                              Text(
                                'Keluar',
                                style: GoogleFonts.openSans(
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Card(
                      elevation: 4,
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: Icon(
                            Icons.people_rounded,
                            color: Colors.black,
                          ),
                        ),
                        title: Text(
                          "Total Tamu Undangan : $totalVisitor",
                          style: GoogleFonts.openSans(),
                        ),
                      ),
                    ),
                    Card(
                      elevation: 4,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal.withOpacity(.8),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          "Hadir : $totalAttedance",
                          style: GoogleFonts.openSans(),
                        ),
                      ),
                    ),
                    Card(
                      elevation: 4,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red.withOpacity(.8),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          "Belum Hadir : $totalNotPresent",
                          style: GoogleFonts.openSans(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}

class ClipPathClass extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(
      0.0,
      size.height - 60,
    );

    path.quadraticBezierTo(
      size.width / 2.0,
      size.height,
      size.width,
      size.height - 60.0,
    );

    path.lineTo(
      size.width,
      0.0,
    );
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
