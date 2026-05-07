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

  void _updateMeter(double newValue) {
    setState(() {
      _currentEnergyValue = newValue.clamp(0, 100);
      _energyController.text = _currentEnergyValue.toInt().toString();
    });
  }

  void _handleInteraction(Offset localPosition, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height;
    
    double dx = localPosition.dx - centerX;
    double dy = localPosition.dy - centerY;
    
    double angle = math.atan2(dy, dx);
    
    // Normalize angle to be between -PI and 0 for the top arc
    if (angle > 0) angle = angle - (2 * math.pi);
    
    // Map -PI (0%) to 0 (100%)
    double percentage = (angle + math.pi) / math.pi;
    _updateMeter(percentage * 100);
  }

  String _getEnergyStatus() {
    if (_currentEnergyValue < 33) return "Resting / Low Energy";
    if (_currentEnergyValue < 67) return "Active / Moderate Energy";
    return "High / Energetic";
  }

  Color _getEnergyColor() {
    if (_currentEnergyValue < 33) return const Color(0xFF67AC78);
    if (_currentEnergyValue < 67) return const Color(0xFFE9CE5B);
    return const Color(0xFFF1A851);
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
              const SizedBox(height: 50),
              Center(
                child: SizedBox(
                  width: screenWidth * 0.5,
                  child: Image.asset(
                    'assets/images/logo/LeafLoop_name.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 30),

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
              const SizedBox(height: 60),

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

              const SizedBox(height: 20),
              const SizedBox(height: 20),
              
              // New Slider for 0-100 dragging
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Theme.of(context).primaryColor,
                    inactiveTrackColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    thumbColor: Theme.of(context).primaryColor,
                    overlayColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    valueIndicatorColor: Theme.of(context).primaryColor,
                    valueIndicatorTextStyle: const TextStyle(color: Colors.white),
                  ),
                  child: Slider(
                    value: _currentEnergyValue,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: _currentEnergyValue.toInt().toString(),
                    onChanged: _updateMeter,
                  ),
                ),
              ),

              Text(
                _getEnergyStatus(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getEnergyColor(),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "${_currentEnergyValue.toInt()}%",
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  color: _getEnergyColor(),
                ),
              ),

              const SizedBox(height: 30),

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

    double degrees = (value / 100) * 180;
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
