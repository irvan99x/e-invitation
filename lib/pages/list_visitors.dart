import 'dart:io';
import 'dart:math' as math;
import 'package:learning/pages/pdf_preview_page.dart';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learning/pages/home.dart';
import 'package:learning/pages/input.dart';
import 'package:learning/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:random_string_generator/random_string_generator.dart';
import 'package:share_plus/share_plus.dart';

class VisitorsPage extends StatefulWidget {
  const VisitorsPage({Key? key}) : super(key: key);

  @override
  State<VisitorsPage> createState() => _VisitorsPageState();
}

class _VisitorsPageState extends State<VisitorsPage> {
  @override
  Widget build(BuildContext context) {
    // Firebase
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference visitors = firestore.collection('visitors');

    //Controller Text
    TextEditingController nameTextController = TextEditingController();
    TextEditingController addressTextController = TextEditingController();

    //Drop Down Button
    String? dropDownValue;

    // RepaintBoundary Key
    GlobalKey qrKey = GlobalKey();

    //File
    File? file;

    //QR Code
    String? dataQr;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          },
          child: const Icon(
            Icons.arrow_back,
          ),
        ),
        centerTitle: true,
        title: Text(
          'Tamu Undangan',
          style: GoogleFonts.openSans(),
        ),
        actions: [
          PopupMenuButton<int>(
            position: PopupMenuPosition.under,
            onSelected: (item) => onSelected(context, item),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 0,
                child: Row(
                  children: [
                    const Icon(
                      Icons.restore_rounded,
                      color: Colors.grey,
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      'Reset',
                      style: GoogleFonts.openSans(),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    const Icon(
                      Icons.file_download_rounded,
                      color: Colors.grey,
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      'Export',
                      style: GoogleFonts.openSans(),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
      body: ListView(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: visitors.orderBy('name').snapshots(),
            builder: (
              BuildContext context,
              AsyncSnapshot<QuerySnapshot> snapshot,
            ) {
              if (snapshot.hasError) {
                return Text(
                  'Something went wrong!',
                  style: GoogleFonts.openSans(),
                );
              }

              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 5.0,
                  ),
                  child: Column(
                    children: snapshot.data!.docs.map((e) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 3.0,
                          ),
                          child: Slidable(
                            endActionPane: ActionPane(
                              motion: const BehindMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                        title: Text(
                                          'Hapus Tamu',
                                          style: GoogleFonts.openSans(),
                                        ),
                                        content: Text(
                                          'Yakin ingin menghapus tamu undangan ?',
                                          style: GoogleFonts.openSans(),
                                        ),
                                        actions: <Widget>[
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              primary:
                                                  Colors.teal.withOpacity(.8),
                                            ),
                                            onPressed: () => Navigator.pop(
                                                context, 'Cancel'),
                                            child: const Text('Tidak'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              visitors.doc(e.id).delete();
                                              Navigator.pop(context, 'OK');
                                              Utils.showSnackBar(
                                                'Berhasil menghapus data tamu.',
                                              );
                                            },
                                            child: const Text('Yakin'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  backgroundColor: Colors.red,
                                  icon: Icons.delete_rounded,
                                )
                              ],
                            ),
                            startActionPane: ActionPane(
                                motion: const BehindMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (context) {
                                      nameTextController.text = e['name'];
                                      addressTextController.text = e['address'];
                                      dropDownValue = e['gender'];

                                      showDialog(
                                        context: context,
                                        builder: (context) => StatefulBuilder(
                                          builder:
                                              (context, StateSetter setState) {
                                            return Dialog(
                                              child: Container(
                                                color: Colors.white,
                                                child: ListView(
                                                  shrinkWrap: true,
                                                  children: [
                                                    const SizedBox(
                                                      height: 10.0,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 8.0,
                                                      ),
                                                      child: TextFormField(
                                                        controller:
                                                            nameTextController,
                                                        decoration:
                                                            InputDecoration(
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          labelText: 'Nama',
                                                          labelStyle:
                                                              GoogleFonts
                                                                  .openSans(
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10.0,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 8.0,
                                                      ),
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 12,
                                                          vertical: 4,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            10.0,
                                                          ),
                                                          border: Border.all(
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                        child:
                                                            DropdownButtonHideUnderline(
                                                          child: DropdownButton<
                                                              String>(
                                                            hint: Text(
                                                              'Jenis Kelamin',
                                                              style: GoogleFonts
                                                                  .openSans(
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                            value:
                                                                dropDownValue,
                                                            isExpanded: true,
                                                            items: <String>[
                                                              'Laki-laki',
                                                              'Perempuan',
                                                            ].map<
                                                                DropdownMenuItem<
                                                                    String>>((String
                                                                value) {
                                                              return DropdownMenuItem<
                                                                  String>(
                                                                value: value,
                                                                child:
                                                                    Text(value),
                                                              );
                                                            }).toList(),
                                                            onChanged: (String?
                                                                newValue) {
                                                              setState(() {
                                                                dropDownValue =
                                                                    newValue!;
                                                              });
                                                              // print(dropdownValue);
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10.0,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 8.0,
                                                      ),
                                                      child: TextFormField(
                                                        controller:
                                                            addressTextController,
                                                        maxLines: 3,
                                                        decoration:
                                                            InputDecoration(
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          labelText: 'Alamat',
                                                          labelStyle:
                                                              GoogleFonts
                                                                  .openSans(
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 8.0,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        RepaintBoundary(
                                                          key: qrKey,
                                                          child: Container(
                                                            color: Colors.white,
                                                            child: QrImage(
                                                              embeddedImage:
                                                                  const AssetImage(
                                                                      'assets/images/logo.png'),
                                                              embeddedImageStyle:
                                                                  QrEmbeddedImageStyle(
                                                                size:
                                                                    const Size(
                                                                        20, 20),
                                                              ),
                                                              data: dataQr ??
                                                                  e['qr_code'],
                                                              version:
                                                                  QrVersions
                                                                      .auto,
                                                              size: (math.min(
                                                                    MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width,
                                                                    MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height,
                                                                  )) /
                                                                  3,
                                                            ),
                                                          ),
                                                        ),
                                                        Column(
                                                          children: [
                                                            ElevatedButton(
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                  horizontal:
                                                                      30.0,
                                                                ),
                                                              ),
                                                              onPressed: () {
                                                                setState(() {
                                                                  var generator =
                                                                      RandomStringGenerator(
                                                                    fixedLength:
                                                                        10,
                                                                  );

                                                                  dataQr = nameTextController.text +
                                                                      dropDownValue
                                                                          .toString() +
                                                                      addressTextController
                                                                          .text +
                                                                      generator
                                                                          .generate();
                                                                });
                                                              },
                                                              child: Text(
                                                                'Create QR Code',
                                                                style: GoogleFonts
                                                                    .openSans(),
                                                              ),
                                                            ),
                                                            ElevatedButton(
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                  horizontal:
                                                                      32.0,
                                                                ),
                                                              ),
                                                              onPressed:
                                                                  () async {
                                                                try {
                                                                  RenderRepaintBoundary
                                                                      boundary =
                                                                      qrKey.currentContext!
                                                                              .findRenderObject()
                                                                          as RenderRepaintBoundary;
                                                                  //captures qr image
                                                                  var image =
                                                                      await boundary
                                                                          .toImage();
                                                                  ByteData?
                                                                      byteData =
                                                                      await image.toByteData(
                                                                          format:
                                                                              ImageByteFormat.png);
                                                                  Uint8List
                                                                      pngBytes =
                                                                      byteData!
                                                                          .buffer
                                                                          .asUint8List();
                                                                  //app directory for storing images.
                                                                  final appDir =
                                                                      await getApplicationDocumentsDirectory();
                                                                  //current time
                                                                  var datetime =
                                                                      DateTime
                                                                          .now();
                                                                  //qr image file creation
                                                                  file = await File(
                                                                          '${appDir.path}/$datetime.png')
                                                                      .create();
                                                                  //appending data
                                                                  await file
                                                                      ?.writeAsBytes(
                                                                          pngBytes);
                                                                  //Shares QR image
                                                                  await Share
                                                                      .shareFiles(
                                                                    [
                                                                      file!.path
                                                                    ],
                                                                    mimeTypes: [
                                                                      "image/png"
                                                                    ],
                                                                    text:
                                                                        "Share the QR Code",
                                                                  );
                                                                } catch (e) {
                                                                  print(
                                                                    e.toString(),
                                                                  );
                                                                }
                                                              },
                                                              child: Text(
                                                                'Share QR Code',
                                                                style: GoogleFonts
                                                                    .openSans(),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 8.0,
                                                      ),
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          visitors
                                                              .doc(e.id)
                                                              .update({
                                                            'name':
                                                                nameTextController
                                                                    .text,
                                                            'gender':
                                                                dropDownValue,
                                                            'address':
                                                                addressTextController
                                                                    .text,
                                                            'qr_code': dataQr
                                                          }).whenComplete(
                                                            () => Navigator.pop(
                                                                context),
                                                          );
                                                          Utils.showSnackBar(
                                                            'Berhasil mengubah data tamu.',
                                                          );
                                                        },
                                                        child: Text(
                                                          'Update',
                                                          style: GoogleFonts
                                                              .openSans(
                                                            letterSpacing: 1.0,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10.0,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    backgroundColor: Colors.blue,
                                    icon: Icons.edit_rounded,
                                  )
                                ]),
                            child: Container(
                              color: Colors.grey[300],
                              child: ListTile(
                                leading: CircleAvatar(
                                    backgroundColor: (e['is_scan']
                                            ? Colors.teal
                                            : Colors.red)
                                        .withOpacity(.8),
                                    child: Icon(
                                      e['is_scan']
                                          ? Icons.check_rounded
                                          : Icons.close_rounded,
                                      color: Colors.white,
                                    )),
                                title: Text(
                                  e['name'],
                                  style: GoogleFonts.openSans(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  e['address'],
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.openSans(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: Text(
                                  e['gender'],
                                  style: GoogleFonts.openSans(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                ],
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InputPage(),
            ),
          );
        },
        backgroundColor: Colors.teal,
        child: const Icon(
          Icons.group_add_rounded,
        ),
      ),
    );
  }

  void onSelected(BuildContext context, int item) {
    switch (item) {
      case 0:
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text(
              'Reset Data Tamu',
              style: GoogleFonts.openSans(),
            ),
            content: Text(
              'Yakin ingin mereset data tamu undangan ?',
              style: GoogleFonts.openSans(),
            ),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Colors.teal.withOpacity(.8)),
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: Text(
                  'Tidak',
                  style: GoogleFonts.openSans(),
                ),
              ),
              TextButton(
                onPressed: () {
                  FirebaseFirestore firestore = FirebaseFirestore.instance;
                  firestore.collection('visitors').get().then((snapshot) {
                    for (DocumentSnapshot ds in snapshot.docs) {
                      ds.reference.delete();
                    }
                  }).whenComplete(
                    () => Navigator.pop(context, 'Cancel'),
                  );
                  Utils.showSnackBar(
                    'Berhasil mereset data tamu.',
                  );
                },
                child: Text(
                  'Yakin',
                  style: GoogleFonts.openSans(),
                ),
              ),
            ],
          ),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PdfPreviewPage(),
          ),
        );
        break;
      default:
    }
  }
}