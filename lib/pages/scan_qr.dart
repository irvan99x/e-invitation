import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  Barcode? barcode;
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Future<void> reassemble() async {
    if (Platform.isAndroid) {
      await controller!.pauseCamera();
    }
    controller!.resumeCamera();

    super.reassemble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Scan QR Code',
          style: GoogleFonts.openSans(),
        ),
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          buildQrView(context),
          Positioned(
            bottom: 80.0,
            child: buildControlButtons(),
          ),
        ],
      ),
    );
  }

  Widget buildControlButtons() => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            8.0,
          ),
          color: Colors.white24,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () async {
                await controller?.toggleFlash();
                setState(() {});
              },
              icon: FutureBuilder<bool?>(
                future: controller?.getFlashStatus(),
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    return Icon(
                      snapshot.data!
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            IconButton(
              onPressed: () async {
                await controller?.flipCamera();
                setState(() {});
              },
              icon: FutureBuilder(
                future: controller?.getCameraInfo(),
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    return const Icon(
                      Icons.switch_camera_rounded,
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ],
        ),
      );

  Widget buildQrView(BuildContext context) => QRView(
        key: qrKey,
        onQRViewCreated: onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Colors.teal,
          borderRadius: 10.0,
          borderLength: 20.0,
          borderWidth: 10.0,
          cutOutSize: MediaQuery.of(context).size.width * 0.8,
        ),
      );

  void onQRViewCreated(QRViewController controller) {
    setState(
      () => this.controller = controller,
    );

    controller.scannedDataStream.listen(
      (barcode) async {
        controller.pauseCamera();
        // Fluttertoast.showToast(
        //   msg: "QR Code tidak cocok!",
        //   gravity: ToastGravity.CENTER,
        //   backgroundColor: Colors.black.withOpacity(.8),
        // );

        await FirebaseFirestore.instance
            .collection('visitors')
            .where('qr_code', isEqualTo: barcode.code.toString())
            .get()
            .then(
          (QuerySnapshot querySnapshot) {
            querySnapshot.docs.forEach(
              (doc) async {
                if (doc['is_scan']) {
                  return showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: CircleAvatar(
                          backgroundColor: Colors.red.withOpacity(.8),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                        ),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: [
                              Text(
                                'Maaf, QR Code sudah di scan!',
                                style: GoogleFonts.openSans(),
                              )
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text(
                              'OK',
                              style: GoogleFonts.openSans(),
                            ),
                            onPressed: () {
                              controller.resumeCamera();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  await FirebaseFirestore.instance
                      .collection('visitors')
                      .doc(doc.id)
                      .update({'is_scan': true}).then(
                    (value) {
                      return showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: CircleAvatar(
                              backgroundColor: Colors.teal.withOpacity(.8),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                            ),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: [
                                  Text(
                                    'Berhasil Scan QR!',
                                    style: GoogleFonts.openSans(),
                                  )
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text(
                                  'OK',
                                  style: GoogleFonts.openSans(),
                                ),
                                onPressed: () {
                                  controller.resumeCamera();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                }
              },
            );
          },
        ).whenComplete(() {
          controller.resumeCamera();
        });
      },
    );
  }
}
