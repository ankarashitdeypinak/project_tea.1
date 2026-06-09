import 'package:flutter/material.dart';
import 'login_page.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          Positioned.fill(
            child: Image.asset(
              'images/welcome.png',
              fit: BoxFit.cover,
            ),
          ),


          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.3, 0.9],
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.85),
                  ],
                ),
              ),
            ),
          ),


          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Tea",
                                    style: TextStyle(
                                      fontSize: 62,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: -1.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Plus",
                                    style: TextStyle(
                                      fontSize: 62,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF4CAF50),
                                      letterSpacing: -1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Positioned(
                              top: -45,
                              right: -40,
                              child: ColorFiltered(
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.modulate,
                                ),
                                child: Image.asset(
                                  "images/pata.png",
                                  height: 90,
                                  width: 90,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Smart Solution for\nProductive Tea Gardens",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.8,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Button Section
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D5A27),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 65),
                        elevation: 12,
                        shadowColor: Colors.black.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "GET STARTED",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(width: 6),

                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}