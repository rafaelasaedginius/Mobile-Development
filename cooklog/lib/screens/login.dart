import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String _errorCode = "";

  void navigateRegister() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'register');
  }

  void navigateHome() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'home');
  }

  void signIn() async {
    setState(() {
      _isLoading = true;
      _errorCode = "";
    });
    try {
      await _authService.login(
        _emailController.text,
        _passwordController.text,
      );
      navigateHome();
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorCode = e.code;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8733A),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'CookLog',
                      style: GoogleFonts.jost(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      'Your personal recipe book',
                      style: GoogleFonts.jost(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF8F0),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 36, 28, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sign in',
                        style: GoogleFonts.jost(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D2D2D),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 6, bottom: 24),
                        height: 3,
                        width: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8733A),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Text('Email',
                          style: GoogleFonts.jost(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2D2D2D))),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.jost(),
                        decoration: InputDecoration(
                          hintText: 'demo@email.com',
                          hintStyle: GoogleFonts.jost(color: Colors.black26),
                          prefixIcon: const Icon(Icons.email_outlined,
                              color: Color(0xFFE8733A), size: 20),
                          enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12)),
                          focusedBorder: const UnderlineInputBorder(
                              borderSide:
                              BorderSide(color: Color(0xFFE8733A), width: 2)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Password',
                          style: GoogleFonts.jost(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2D2D2D))),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: GoogleFonts.jost(),
                        decoration: InputDecoration(
                          hintText: 'enter your password',
                          hintStyle: GoogleFonts.jost(color: Colors.black26),
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: Color(0xFFE8733A), size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.black38,
                              size: 20,
                            ),
                            onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12)),
                          focusedBorder: const UnderlineInputBorder(
                              borderSide:
                              BorderSide(color: Color(0xFFE8733A), width: 2)),
                        ),
                      ),
                      const SizedBox(height: 28),
                      if (_errorCode != "")
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(_errorCode,
                              style: GoogleFonts.jost(
                                  color: Colors.red, fontSize: 13)),
                        ),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE8733A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2)
                              : Text('Login',
                              style: GoogleFonts.jost(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an Account? ",
                              style: GoogleFonts.jost(
                                  color: Colors.black45, fontSize: 13)),
                          GestureDetector(
                            onTap: navigateRegister,
                            child: Text('Sign up',
                                style: GoogleFonts.jost(
                                    color: const Color(0xFFE8733A),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}