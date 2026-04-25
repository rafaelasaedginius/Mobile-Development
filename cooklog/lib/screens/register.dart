import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String _errorCode = "";

  void navigateLogin() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'login');
  }

  void register() async {
    setState(() {
      _isLoading = true;
      _errorCode = "";
    });
    try {
      await _authService.register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
      );
      navigateLogin();
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
            // Perkecil bagian atas
            Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    size: 44,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'CookLog',
                  style: GoogleFonts.jost(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  'Join and share your recipes',
                  style: GoogleFonts.jost(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),

          // Bagian form ambil sisa ruang
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFFF8F0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text(
                        'Sign up',
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
                      Text('Full Name',
                          style: GoogleFonts.jost(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2D2D2D))),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        style: GoogleFonts.jost(),
                        decoration: InputDecoration(
                          hintText: 'your name',
                          hintStyle: GoogleFonts.jost(color: Colors.black26),
                          prefixIcon: const Icon(Icons.person_outline,
                              color: Color(0xFFE8733A), size: 20),
                          enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12)),
                          focusedBorder: const UnderlineInputBorder(
                              borderSide:
                              BorderSide(color: Color(0xFFE8733A), width: 2)),
                        ),
                      ),
                      const SizedBox(height: 20),
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
                          hintText: 'create a password',
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
                          onPressed: _isLoading ? null : register,
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
                              : Text('Register',
                              style: GoogleFonts.jost(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already have an account? ',
                              style: GoogleFonts.jost(
                                  color: Colors.black45, fontSize: 13)),
                          GestureDetector(
                            onTap: navigateLogin,
                            child: Text('Sign in',
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