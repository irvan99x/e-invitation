import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learning/main.dart';
import 'package:learning/pages/forgot_password.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    Key? key,
    required this.onClickedSignUp,
  }) : super(key: key);

  final VoidCallback onClickedSignUp;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Show Hide Password
  bool _obscureText = true;

  // Text Editing Controller
  final emailController = TextEditingController(
      // text: "mirvan3107@gmail.com",
      );
  final passwordController = TextEditingController(
      // text: "password",
      );

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
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
                controller: emailController,
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
                controller: passwordController,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPassword(),
                        ),
                      );
                    },
                    child: Text(
                      'Lupa Password ?',
                      style: GoogleFonts.openSans(),
                    ),
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: signIn,
              child: Text(
                'MASUK',
                style: GoogleFonts.openSans(
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              height: 5.0,
            ),
            // RichText(
            //   text: TextSpan(
            //     style: GoogleFonts.openSans(
            //       color: Colors.black,
            //     ),
            //     text: 'Belum punya akun ?',
            //     children: [
            //       TextSpan(
            //         recognizer: TapGestureRecognizer()
            //           ..onTap = widget.onClickedSignUp,
            //         text: ' Daftar',
            //         style: GoogleFonts.openSans(
            //           color: Colors.teal,
            //         ),
            //       )
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Future signIn() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(
        msg: e.message as String,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.teal,
        textColor: Colors.white,
      );
      print(e);

      // Utils.showSnackBar(e.message);
    }

    //Navigator.of(context) not working!
    navigatorKey.currentState!.popUntil(
      (route) => route.isFirst,
    );
  }
}
