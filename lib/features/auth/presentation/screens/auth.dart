import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nostalgia/features/auth/data/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:sign_button/sign_button.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final TextEditingController enteredEmail = TextEditingController();
    final TextEditingController enteredPassword = TextEditingController();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 250, 248),
      body: SingleChildScrollView(
        child: Container(
          height: screenHeight,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: screenHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        HexColor('1f2022'),
                        HexColor('1f2c32'),
                        HexColor('0e626d'),
                        HexColor('358491'),
                        HexColor('e1e2e4'),
                      ],
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        right: 16,
                        left: 16,
                        top: 150,
                      ),
                      child: Form(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Nostalgia",
                              style: GoogleFonts.acme(
                                textStyle: const TextStyle(
                                    fontSize: 87,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Email Address',
                                labelStyle: TextStyle(
                                    color: Colors.white, fontSize: 20),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              style: const TextStyle(color: Colors.white),
                              controller: enteredEmail,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    !value.contains('@')) {
                                  return 'Please enter a valid email address.';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                labelStyle: TextStyle(
                                    color: Colors.white, fontSize: 20),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                              obscureText: true,
                              style: const TextStyle(color: Colors.white),
                              controller: enteredPassword,
                              validator: (value) {
                                if (value == null || value.trim().length < 6) {
                                  return 'Password must be at least 6 characters long.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Consumer<AuthProvider>(
                              builder: (context, auth, _) => Column(
                                children: [
                                  if (auth.isLogin)
                                    TextButton(
                                      onPressed: () {
                                        authProvider.resetPassword(
                                            enteredEmail.text, context);
                                      },
                                      child: const Text(
                                        'Forget Password?',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  if (auth.isAuthenticating)
                                    const CircularProgressIndicator(),
                                  if (!auth.isAuthenticating)
                                    ElevatedButton(
                                      onPressed: () {
                                        authProvider.submit(enteredEmail.text,
                                            enteredPassword.text, context);
                                      },
                                      style: ButtonStyle(
                                        minimumSize:
                                            WidgetStateProperty.all<Size>(
                                                const Size(235.0, 20.0)),
                                        backgroundColor:
                                            WidgetStateProperty.all<Color>(
                                                const Color.fromARGB(
                                                    255, 231, 232, 233)),
                                        foregroundColor:
                                            WidgetStateProperty.all<Color>(
                                          HexColor('0e626d'),
                                        ),
                                        textStyle:
                                            WidgetStateProperty.all<TextStyle>(
                                          const TextStyle(fontSize: 16),
                                        ),
                                        padding: WidgetStateProperty.all<
                                            EdgeInsetsGeometry>(
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 10),
                                        ),
                                        shape: WidgetStateProperty.all<
                                            OutlinedBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(35),
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        auth.isLogin ? 'Login' : 'Sign Up',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  SignInButton(
                                    buttonType: ButtonType.google,
                                    onPressed: () {
                                      authProvider.signInWithGoogle(context);
                                    },
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      authProvider.isLogin = !auth.isLogin;
                                    },
                                    child: Text(
                                      auth.isLogin
                                          ? 'Create new account'
                                          : 'I already have an account',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
