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

  void _navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
    );
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passController.text.trim(),
        );
        _navigateToHome();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      _navigateToHome();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In failed: $e")),
      );
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

                _buildField("Full Name", "Enter full name", Icons.person_outline, controller: _nameController),
                const SizedBox(height: 15),
                _buildField(
                    "Email Address", "Enter your email", Icons.email_outlined,
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || !value.contains('@') || !value.contains('.')) return "Please enter a valid email";
                      return null;
                    }
                ),
                const SizedBox(height: 15),
                _buildField(
                    "Phone Number", "Enter phone number", Icons.phone_outlined,
                    controller: _phoneController,
                    validator: (value) {
                      if (value == null || value.length < 10) return "Please enter a valid phone number";
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
                  validator: (value) => (value != null && value.length < 6) ? "Min 6 characters" : null,
                ),
                const SizedBox(height: 15),
                _buildField(
                  "Confirm Password", "Confirm password", Icons.lock_outline,
                  controller: _confirmController,
                  isPass: true,
                  obs: _obsConfirm,
                  onTap: () => setState(() => _obsConfirm = !_obsConfirm),
                  validator: (value) => (value != _passController.text) ? "Passwords do not match" : null,
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
                      child: GestureDetector(
                        onTap: _signInWithGoogle,
                        child: _socialBtn("Google", "images/Google logo.png"), // Updated to Asset
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _socialBtn("Facebook", "images/Facebook logo.png"), // Updated to Asset
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          TextFormField(
            controller: controller,
            obscureText: obs,
            validator: validator,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: hint,
              prefixIcon: Icon(icon, size: 20),
              prefixIconConstraints: const BoxConstraints(minWidth: 35),
              suffixIcon: isPass ? GestureDetector(onTap: onTap, child: Icon(obs ? Icons.visibility_off : Icons.visibility, size: 20)) : null,
            ),
          ),
        ],
      ),
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
          Image.asset(assetPath, height: 20), // Updated to Image.asset
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}