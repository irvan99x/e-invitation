import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learning/pages/home.dart';
import 'package:learning/utils.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({Key? key}) : super(key: key);

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    // user needs to be created before!
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future checkEmailVerified() async {
    // call after email verified
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) timer?.cancel();
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(
        () => canResendEmail = false,
      );
      await Future.delayed(
        const Duration(
          seconds: 5,
        ),
      );
      setState(
        () => canResendEmail = true,
      );
    } catch (e) {
      Utils.showSnackBar(
        e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) => isEmailVerified
      ? const HomePage()
      : Scaffold(
          appBar: AppBar(
            title: Text(
              'Verify Email',
              style: GoogleFonts.openSans(),
            ),
            centerTitle: true,
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'email verifikasi telah dikirim ke email Anda',
                  style: GoogleFonts.openSans(fontSize: 20.0),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                ElevatedButton(
                  onPressed: canResendEmail ? sendVerificationEmail : null,
                  child: Text(
                    'Kirim Ulang',
                    style: GoogleFonts.openSans(),
                  ),
                ),
                const SizedBox(
                  height: 8.0,
                ),
                TextButton(
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  child: Text(
                    'Kembali',
                    style: GoogleFonts.openSans(),
                  ),
                )
              ],
            ),
          ),
        );
}
