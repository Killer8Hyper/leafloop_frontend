import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:leafloop/screens/homepage.dart'; // Ensure this path is correct
import 'package:leafloop/database/database_helper.dart';
import 'package:leafloop/services/local_auth_service.dart';

class EnergyLevelPage extends StatefulWidget {
  final String username;
  final String email;
  final String password;
  final String? profileImagePath;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String dob;

  const EnergyLevelPage({
    super.key, 
    required this.username, 
    required this.email, 
    required this.password, 
    this.profileImagePath,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.dob,
  });

  @override
  State<EnergyLevelPage> createState() => _EnergyLevelPageState();
}

class _EnergyLevelPageState extends State<EnergyLevelPage> {
  final TextEditingController _energyController = TextEditingController();
  double _currentEnergyValue = 50.0;

  @override
  void initState() {
    super.initState();
    _energyController.text = _currentEnergyValue.toInt().toString();
  }

  @override
  void dispose() {
    _energyController.dispose();
    super.dispose();
  }

  void _updateMeter(String value) {
    if (value.isEmpty) return;
    double? newValue = double.tryParse(value);
    if (newValue != null && newValue >= 1 && newValue <= 100) {
      setState(() {
        _currentEnergyValue = newValue;
      });
    }
  }

  void _handleInteraction(Offset localPosition, Size size) {
    // The meter is centered horizontally and at the bottom vertically of its container
    final double centerX = size.width / 2;
    final double centerY = size.height; // Since the height is radius
    
    // Calculate angle from center to touch point
    double angle = math.atan2(localPosition.dy - centerY, localPosition.dx - centerX);
    
    // For the top half of the meter:
    // Left side (1) is at pi (approx 3.14) or -pi
    // Right side (100) is at 0
    if (angle < 0) {
      double normalizedAngle = angle.abs(); // 0 (right) to pi (left)
      
      // Map pi (left) -> 1, 0 (right) -> 100
      double percentage = 1.0 - (normalizedAngle / math.pi); // 0 (left) to 1 (right)
      double newValue = (percentage * 99) + 1;
      
      setState(() {
        _currentEnergyValue = newValue.clamp(1, 100);
        _energyController.text = _currentEnergyValue.toInt().toString();
      });
    }
  }

  // --- NEW: POPUP LOGIC ---
  void _showEnergySetPopup() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must click the button
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Success!"),
          content: const Text("Energy is now set!"),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  // Navigate to Homepage and remove the current screen from stack
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                    (route) => false,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(
        context,
      ).scaffoldBackgroundColor, // Dark mode support
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 80),
              Center(
                child: SizedBox(
                  width: screenWidth * 0.5,
                  child: Image.asset(
                    'assets/images/logo/LeafLoop_name.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 60),

              Text(
                "Select your energy level:",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.color?.withOpacity(0.7),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 100),

              Center(
                child: GestureDetector(
                  onPanUpdate: (details) {
                    RenderBox renderBox = context.findRenderObject() as RenderBox;
                    _handleInteraction(details.localPosition, renderBox.size);
                  },
                  onTapDown: (details) {
                    RenderBox renderBox = context.findRenderObject() as RenderBox;
                    _handleInteraction(details.localPosition, renderBox.size);
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.85,
                        height: screenWidth * 0.45,
                        child: CustomPaint(
                          painter: EnergyMeterPainter(
                            value: _currentEnergyValue,
                            screenWidth: screenWidth,
                            needleColor:
                                Theme.of(context).textTheme.bodyLarge?.color ??
                                const Color(0xFF2E2E2E),
                          ),
                        ),
                      ),
                      // Green Icon
                      Positioned(
                        left: -25,
                        bottom: 100,
                        child: Column(
                          children: [
                            const Text(
                              "Z Z Z",
                              style: TextStyle(
                                color: Color(0xFF67AC78),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Icon(
                              Icons.person,
                              size: screenWidth * 0.12,
                              color: const Color(0xFF67AC78),
                            ),
                          ],
                        ),
                      ),
                      // Yellow Icon
                      Positioned(
                        top: -65,
                        child: Icon(
                          Icons.accessibility_new,
                          size: screenWidth * 0.15,
                          color: const Color(0xFFE9CE5B),
                        ),
                      ),
                      // Orange Icon
                      Positioned(
                        right: -55,
                        bottom: 100,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.bolt,
                              color: Color(0xFFF1A851),
                              size: 16,
                            ),
                            Icon(
                              Icons.directions_run,
                              size: screenWidth * 0.15,
                              color: const Color(0xFFF1A851),
                            ),
                            const Icon(
                              Icons.bolt,
                              color: Color(0xFFF1A851),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 60),

              Container(
                width: screenWidth * 0.6,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _energyController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    onChanged: _updateMeter,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 20),
                      border: InputBorder.none,
                      hintText: "1-100",
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 50),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    int energy = _currentEnergyValue.toInt();
                    int energyLevel = 2;
                    if (energy < 33) energyLevel = 1;
                    else if (energy > 66) energyLevel = 3;

                    try {
                      bool userTaken = await DatabaseHelper().isUsernameTaken(widget.username);
                      if (userTaken) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Username already exists. Please go back and change it.')),
                        );
                        return;
                      }

                      bool emailTaken = await DatabaseHelper().isEmailTaken(widget.email);
                      if (emailTaken) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Email address is already in use.')),
                        );
                        return;
                      }

                      int userId = await DatabaseHelper().createUser(
                          widget.username,
                          widget.email,
                          widget.password,
                          energyLevel,
                          profileImagePath: widget.profileImagePath,
                          firstName: widget.firstName,
                          middleName: widget.middleName,
                          lastName: widget.lastName,
                          dob: widget.dob,
                      );
                      await LocalAuthService().login(userId, widget.username);
                      
                      // Triggers the popup
                      _showEnergySetPopup();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('An error occurred while creating your account.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "Select",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.045,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class EnergyMeterPainter extends CustomPainter {
  final double value;
  final double screenWidth;
  final Color needleColor;

  EnergyMeterPainter({
    required this.value,
    required this.screenWidth,
    required this.needleColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height;
    final double radius = size.width * 0.42;

    final Map<int, Color> segmentColors = {
      0: const Color(0xFF67AC78),
      1: const Color(0xFFE9CE5B),
      2: const Color(0xFFF1A851),
    };

    final double arcWidth = size.width * 0.20;
    final double startAngle = math.pi;
    final double sweepAngle = math.pi;

    final Paint arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = arcWidth
      ..strokeCap = StrokeCap.butt;

    for (int i = 0; i < 3; i++) {
      arcPaint.color = segmentColors[i]!;
      double segmentSweep = (sweepAngle / 3) - 0.04;
      double segmentStart = startAngle + (i * (sweepAngle / 3)) + 0.02;

      canvas.drawArc(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
        segmentStart,
        segmentSweep,
        false,
        arcPaint,
      );
    }

    final double needleLength = radius + (arcWidth / 4);
    final double needleBaseRadius = 15.0;

    final Paint needlePaint = Paint()
      ..color = needleColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(centerX, centerY), needleBaseRadius, needlePaint);

    double degrees = ((value - 1) / 99) * 180;
    double radians = (degrees * (math.pi / 180)) + startAngle;

    final double needleEndX = centerX + math.cos(radians) * needleLength;
    final double needleEndY = centerY + math.sin(radians) * needleLength;

    final Paint linePaint = Paint()
      ..color = needleColor
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(centerX, centerY),
      Offset(needleEndX, needleEndY),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant EnergyMeterPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.needleColor != needleColor;
  }
}
