import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfPreviewPage extends StatefulWidget {
  const PdfPreviewPage({Key? key}) : super(key: key);

  @override
  State<PdfPreviewPage> createState() => _PdfPreviewPageState();
}

class _PdfPreviewPageState extends State<PdfPreviewPage> {
  String convertMonthToString($month) {
    switch ($month) {
      case 1:
        return "January";
      case 2:
        return "February";
      case 3:
        return "Maret";
      case 4:
        return "April";
      case 5:
        return "Mei";
      case 6:
        return "Juni";
      case 7:
        return "Juli";
      case 8:
        return "Agustus";
      case 9:
        return "September";
      case 10:
        return "Oktober";
      case 11:
        return "November";
      default:
        return "Desember";
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<Uint8List> makePdf() async {
      final pdf = pw.Document();
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference visitors = firestore.collection('visitors');
      DateTime now = DateTime.now();
      String convertMonth = convertMonthToString(now.month);
      String date = ("${now.day} $convertMonth ${now.year}");

      var visitorList = await visitors.orderBy('name').get();

      var len = visitorList.docs.length;
      var size = 30;
      var chunks = [];

      for (var i = 0; i < len; i += size) {
        var end = (i + size < len) ? i + size : len;
        chunks.add(visitorList.docs.sublist(i, end));
      }

      for (var visitor in chunks) {
        pdf.addPage(
          pw.Page(
            build: (context) {
              return pw.Table(
                border: const pw.TableBorder(
                  verticalInside: pw.BorderSide(width: 2),
                  horizontalInside: pw.BorderSide(width: 2),
                  top: pw.BorderSide(width: 2),
                  right: pw.BorderSide(width: 2),
                  bottom: pw.BorderSide(width: 2),
                  left: pw.BorderSide(width: 2),
                ),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Column(
                        children: [
                          pw.SizedBox(height: 8),
                          pw.Center(
                            child: pw.Text(
                              "Laporan Tamu Undangan",
                              style: pw.TextStyle(
                                  fontSize: 28, fontWeight: pw.FontWeight.bold),
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Divider(),
                          pw.SizedBox(height: 8),
                          pw.Align(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(
                              "Tanggal Dibuat : " + date,
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Divider(),
                          pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.SizedBox(
                                  width: 120,
                                  child: pw.Text(
                                    "Nama",
                                    textAlign: pw.TextAlign.left,
                                  ),
                                ),
                                pw.SizedBox(
                                  width: 220,
                                  child: pw.Text(
                                    "Alamat",
                                    textAlign: pw.TextAlign.left,
                                  ),
                                ),
                                pw.SizedBox(
                                  width: 120,
                                  child: pw.Text(
                                    "Status",
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                    textAlign: pw.TextAlign.left,
                                  ),
                                ),
                              ]),
                          pw.Divider(),
                          pw.ListView.separated(
                            separatorBuilder: (context, index) =>
                                pw.Divider(height: 2),
                            itemCount: visitor.length,
                            itemBuilder: (context, int index) {
                              var currentVisitor = visitor[index];

                              return pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.SizedBox(
                                    width: 120,
                                    child: pw.Text(
                                      currentVisitor['name'],
                                      textAlign: pw.TextAlign.left,
                                    ),
                                  ),
                                  pw.SizedBox(
                                    width: 220,
                                    child: pw.Text(
                                      currentVisitor['address'],
                                      textAlign: pw.TextAlign.left,
                                    ),
                                  ),
                                  pw.SizedBox(
                                    width: 120,
                                    child: pw.Text(
                                      currentVisitor['is_scan']
                                          ? "Hadir"
                                          : "Tidak Hadir",
                                      style: const pw.TextStyle(
                                        fontSize: 10.0,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          )
                        ],
                      )
                    ],
                  )
                ],
              );
            },
          ),
        );
      }

      return pdf.save();
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Laporan Tamu Undangan',
          style: GoogleFonts.openSans(),
        ),
      ),
      body: PdfPreview(
        build: (context) => makePdf(),
      ),
    );
  }
}
