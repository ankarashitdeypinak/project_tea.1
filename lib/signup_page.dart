import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _obsPass = true;
  bool _obsConfirm = true;
  Timer? _verificationTimer;

  // স্ট্রং Regex: অবশ্যই অক্ষর দিয়ে শুরু হতে হবে এবং সঠিক ডোমেইন (.com, .org ইত্যাদি) থাকতে হবে
  final RegExp _emailRegex = RegExp(r'^[a-zA-Z][a-zA-Z0-9._%+-]*@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  // বাংলাদেশি ফোন নম্বরের Regex (01 দিয়ে শুরু এবং মোট ১১ ডিজিট)
  final RegExp _phoneRegex = RegExp(r'^01[3-9]\d{8}$');

  @override
  void dispose() {
    _verificationTimer?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    _verificationTimer?.cancel();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
    );
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passController.text.trim(),
        );

        if (userCredential.user != null) {
          await userCredential.user!.sendEmailVerification();

          if (mounted) {
            _showVerificationWaitingDialog();
          }

          _verificationTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
            User? user = _auth.currentUser;
            await user?.reload();

            if (user != null && user.emailVerified) {
              timer.cancel();
              if (mounted) {
                Navigator.pop(context);
                _navigateToHome();
              }
            }
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent));
        }
      }
    }
  }

  void _showVerificationWaitingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.email_outlined, color: Color(0xFF2D5A27)),
            SizedBox(width: 10),
            Text("Verify Your Email"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "A verification link has been sent to:\n${_emailController.text.trim()}",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 25),
            const CircularProgressIndicator(color: Color(0xFF2D5A27)),
            const SizedBox(height: 20),
            const Text(
              "Please check your email inbox/spam folder and click the link. We will automatically take you to Home Page once verified.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              _verificationTimer?.cancel();
              await _auth.signOut();
              if (mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text("Cancel", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      _navigateToHome();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Google Sign-In failed: $e"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 30),
                Image.asset(
                  "images/signin.png",
                  height: 90,
                  color: const Color(0xFF2D5A27),
                ),
                const SizedBox(height: 10),
                const Text("Create Account", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const Text("Register a new account", style: TextStyle(color: Colors.grey)),

                const SizedBox(height: 30),

                _buildField(
                  "Full Name", "Enter full name", Icons.person_outline,
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return "Please enter your name";
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                _buildField(
                    "Email Address", "Enter your email", Icons.email_outlined,
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return "Please enter your email";
                      if (!_emailRegex.hasMatch(value.trim())) return "Enter a valid email";
                      return null;
                    }
                ),
                const SizedBox(height: 15),
                _buildField(
                    "Phone Number", "Enter phone number", Icons.phone_outlined,
                    controller: _phoneController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return "Please enter your phone number";
                      if (!_phoneRegex.hasMatch(value.trim())) return "Enter a valid phone number";
                      return null;
                    }
                ),
                const SizedBox(height: 15),
                _buildField(
                  "Password", "Create password", Icons.lock_outline,
                  controller: _passController,
                  isPass: true,
                  obs: _obsPass,
                  onTap: () => setState(() => _obsPass = !_obsPass),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Please enter a password";
                    if (value.length < 6) return "Min 6 characters required";
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                _buildField(
                  "Confirm Password", "Confirm password", Icons.lock_outline,
                  controller: _confirmController,
                  isPass: true,
                  obs: _obsConfirm,
                  onTap: () => setState(() => _obsConfirm = !_obsConfirm),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Please confirm your password";
                    if (value != _passController.text) return "Passwords do not match";
                    return null;
                  },
                ),

                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D5A27),
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _signUp,
                  child: const Text("Sign Up", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),

                const SizedBox(height: 20),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("or continue with", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          await _signInWithGoogle();
                        },
                        child: _socialBtn("Google", "images/Google logo.png"),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Facebook Login coming soon!")),
                          );
                        },
                        child: _socialBtn("Facebook", "images/Facebook logo.png"),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text("Login", style: TextStyle(color: Color(0xFF2D5A27), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, String hint, IconData icon, {required TextEditingController controller, bool isPass = false, bool obs = false, VoidCallback? onTap, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ),
        TextFormField(
          controller: controller,
          obscureText: obs,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: hint,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
            prefixIcon: Icon(icon, size: 20),
            prefixIconConstraints: const BoxConstraints(minWidth: 40),
            suffixIcon: isPass ? GestureDetector(onTap: onTap, child: Icon(obs ? Icons.visibility_off : Icons.visibility, size: 20)) : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2D5A27)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _socialBtn(String label, String assetPath) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(assetPath, height: 20, errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, size: 20)),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}