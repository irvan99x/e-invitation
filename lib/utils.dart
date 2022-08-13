import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Utils {
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();

  static showSnackBar(String? text) {
    if (text == null) return;

    final snackBar = SnackBar(
      duration: const Duration(
        seconds: 3,
      ),
      content: Text(
        text,
        style: GoogleFonts.openSans(
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.teal,
    );

    messengerKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
