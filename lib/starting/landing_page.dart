import 'package:flutter/material.dart';
import 'dart:async';
import 'package:leafloop/starting/log-in.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool _showWelcome = false;
  bool _showLogo = false;
  double _logoScale = 0.5;

  @override
  void initState() {
    super.initState();
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _showWelcome = true);

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _showWelcome = false);

    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _showLogo = true;
        _logoScale = 1.0;
      });
    }
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate responsive sizes
    double screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => _navigateToLogin(context),
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F4F0),
        body: Stack(
          children: [
            Center(
              child: AnimatedOpacity(
                opacity: _showWelcome ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 800),
                child: Text(
                  "Welcome to",
                  style: TextStyle(
                    fontSize: screenWidth * 0.08, // Responsive size
                    color: const Color(0xFF3B5236),
                    fontWeight: FontWeight.w300,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            Center(
              child: AnimatedOpacity(
                opacity: _showLogo ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 1000),
                child: AnimatedScale(
                  scale: _logoScale,
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.elasticOut,
                  child: Container(
                    width: screenWidth * 0.7, // Responsive container
                    height: screenWidth * 0.7,
                    padding: EdgeInsets.all(screenWidth * 0.1),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/images/logo/LeafLoop1.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.eco,
                        size: screenWidth * 0.3,
                        color: const Color(0xFF3B5236),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _showLogo ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 1000),
                child: Text(
                  'Click anywhere to start',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF8A8A8A),
                    fontSize: screenWidth * 0.045, // Responsive size
                    fontWeight: FontWeight.w400,
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
