import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learning/pages/list_visitors.dart';
import 'package:learning/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:random_string_generator/random_string_generator.dart';
import 'package:share_plus/share_plus.dart';

class InputPage extends StatefulWidget {
  const InputPage({Key? key}) : super(key: key);

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  //Drop Down Button
  String? dropDownValue;

  //QR Code
  String? dataQr;

  //Controller Text
  TextEditingController nameTextController = TextEditingController();
  TextEditingController addressTextController = TextEditingController();

  // RepaintBoundary Key
  GlobalKey qrKey = GlobalKey();

  //File
  File? file;

  // Key Form
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    //Firebase
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference visitors = firestore.collection('visitors');

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VisitorsPage(),
                ),
              );
            },
            icon: const Icon(
              Icons.group_rounded,
            ),
            color: Colors.white,
          ),
          const SizedBox(
            width: 10.0,
          ),
        ],
        centerTitle: true,
        title: Text(
          'Tambah Tamu',
          style: GoogleFonts.openSans(),
        ),
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(
                    height: 15.0,
                  ),
                  TextFormField(
                    controller: nameTextController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan nama tamu';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: 'Nama',
                      labelStyle: GoogleFonts.openSans(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        10.0,
                      ),
                      border: Border.all(
                        color: Colors.grey,
                      ),
                    ),
                    child: DropdownButtonFormField<String>(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pilih jenis kelamin.';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        enabledBorder: InputBorder.none,
                      ),
                      hint: Text(
                        'Jenis Kelamin',
                        style: GoogleFonts.openSans(
                          color: Colors.grey,
                        ),
                      ),
                      value: dropDownValue,
                      isExpanded: true,
                      items: <String>[
                        'Laki-laki',
                        'Perempuan',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          dropDownValue = newValue!;
                        });
                        // print(dropdownValue);
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  TextFormField(
                    controller: addressTextController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan alamat tamu';
                      }
                      return null;
                    },
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: 'Alamat',
                      labelStyle: GoogleFonts.openSans(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      RepaintBoundary(
                        key: qrKey,
                        child: Container(
                          color: Colors.white,
                          child: QrImage(
                            embeddedImage:
                                const AssetImage('assets/images/logo.png'),
                            embeddedImageStyle: QrEmbeddedImageStyle(
                              size: const Size(20, 20),
                            ),
                            data: '$dataQr',
                            version: QrVersions.auto,
                            size: (math.min(
                                  MediaQuery.of(context).size.width,
                                  MediaQuery.of(context).size.height,
                                )) /
                                3,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30.0,
                              ),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  var generator = RandomStringGenerator(
                                    fixedLength: 10,
                                  );

                                  dataQr = nameTextController.text +
                                      dropDownValue.toString() +
                                      addressTextController.text +
                                      generator.generate();
                                });
                              }
                            },
                            child: Text(
                              'Create QR Code',
                              style: GoogleFonts.openSans(),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32.0,
                              ),
                            ),
                            onPressed: () async {
                              captureAndSharePng();
                            },
                            child: Text(
                              'Share QR Code',
                              style: GoogleFonts.openSans(),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 40.0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            visitors.add({
              'name': nameTextController.text,
              'address': addressTextController.text,
              'gender': dropDownValue,
              'qr_code': dataQr,
              'is_scan': false,
            });

            // Empty data
            nameTextController.text = '';
            addressTextController.text = '';

            Utils.showSnackBar(
              'Berhasil tambah data tamu.',
            );
          }
        },
        backgroundColor: Colors.teal,
        child: const Icon(
          Icons.person_add_rounded,
        ),
      ),
    );
  }

  Future<void> captureAndSharePng() async {
    try {
      RenderRepaintBoundary boundary =
          qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/image.png').create();
      await file.writeAsBytes(pngBytes);

      await Share.shareFiles(
        [file.path],
        mimeTypes: ["image/png"],
        text: "Share the QR Code",
      );
    } catch (e) {
      // print(e.toString());
    }
  }
}
