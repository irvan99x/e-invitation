import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learning/main.dart';
import 'package:learning/utils.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    Key? key,
    required this.onClickedSignIn,
  }) : super(key: key);

  final Function() onClickedSignIn;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Show Hide Password
  bool _obscureText = true;

  // Text Editing Controller
  final emailRegistController = TextEditingController();
  final passwordRegistController = TextEditingController();

  @override
  void dispose() {
    emailRegistController.dispose();
    passwordRegistController.dispose();

    super.dispose();
  }

  // Key Form
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/invitation.png',
                height: MediaQuery.of(context).size.width / 1.2,
              ),
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  // vertical: 10.0,
                ),
                child: TextFormField(
                  controller: emailRegistController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: 'Email',
                    labelStyle: GoogleFonts.openSans(
                      color: Colors.grey,
                    ),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (email) =>
                      email != null && !EmailValidator.validate(email)
                          ? 'Masukkan email yang valid!'
                          : null,
                ),
              ),
              const SizedBox(
                height: 12.0,
              ),
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  // vertical: 10.0,
                ),
                child: TextFormField(
                  controller: passwordRegistController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: 'Password',
                    labelStyle: GoogleFonts.openSans(
                      color: Colors.grey,
                    ),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => value != null && value.length < 6
                      ? 'Enter min. 6 characters'
                      : null,
                ),
              ),
              const SizedBox(
                height: 14.0,
              ),
              ElevatedButton(
                onPressed: signUp,
                child: Text(
                  'DAFTAR',
                  style: GoogleFonts.openSans(
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.openSans(
                    color: Colors.black,
                  ),
                  text: 'Sudah punya akun ?',
                  children: [
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = widget.onClickedSignIn,
                      text: ' Masuk',
                      style: GoogleFonts.openSans(
                        color: Colors.teal,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future signUp() async {
    final isValid = formKey.currentState!.validate();
    if (isValid) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailRegistController.text.trim(),
        password: passwordRegistController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        // print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        // print('The account already exists for that email.');
      }

      Utils.showSnackBar(e.message);
    } catch (e) {
      print(e);
    }

    // Navigator.of(context) not working!
    navigatorKey.currentState!.popUntil(
      (route) => route.isFirst,
    );
  }
}
