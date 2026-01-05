import 'dart:async';
import 'package:flutter/material.dart';
import 'main.dart'; // നിങ്ങളുടെ മെയിൻ ഫയലിലെ MainNavigationScreen-ലേക്ക് പോകാൻ

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 3 സെക്കൻഡിന് ശേഷം മെയിൻ സ്ക്രീനിലേക്ക് പോകുന്നു
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 180,
              errorBuilder: (c, e, s) =>
                  const Icon(Icons.shield, size: 100, color: Color(0xFF0D47A1)),
            ),
            const SizedBox(height: 20),
            const Text(
              "HYDRO GUARD PRO",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                  letterSpacing: 1.5),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(color: Color(0xFF0D47A1)),
          ],
        ),
      ),
    );
  }
}
