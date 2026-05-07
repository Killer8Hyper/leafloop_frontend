import 'dart:math';
import 'package:flutter/material.dart';

class LeafLoopApp extends StatefulWidget {
  const LeafLoopApp({super.key});

  @override
  State<LeafLoopApp> createState() => _LeafLoopAppState();
}

class _LeafLoopAppState extends State<LeafLoopApp>
    with SingleTickerProviderStateMixin {
  // Growth range is 0.0 (seed) to 1.0 (full grown)
  double _currentGrowth = 0.0;
  late AnimationController _controller;
  late Animation<double> _growthAnimation;

  @override
  void initState() {
    super.initState();
    // This controller handles the smooth "jump" between growth stages
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _growthAnimation = Tween<double>(begin: 0, end: 0).animate(_controller);
  }

  void _waterTree() {
    if (_currentGrowth < 1.0) {
      double nextStage = (_currentGrowth + 0.1).clamp(0.0, 1.0);

      // Define the animation from the current state to the next 10%
      _growthAnimation = Tween<double>(begin: _currentGrowth, end: nextStage)
          .animate(
            CurvedAnimation(
              parent: _controller,
              curve: Curves.elasticOut, // Gives a slight "bounce" to the growth
            ),
          );

      setState(() {
        _currentGrowth = nextStage;
      });

      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF1F8E9,
      ), // Light organic green background
      appBar: AppBar(
        title: const Text('LeafLoop: My Impact Tree'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // The Tree Display Area
          Expanded(
            child: AnimatedBuilder(
              animation: _growthAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: TreePainter(growth: _growthAnimation.value),
                  size: Size.infinite,
                );
              },
            ),
          ),

          // The Action Panel
          Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Maturity: ${(_currentGrowth * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: _currentGrowth >= 1.0 ? null : _waterTree,
                    icon: const Icon(Icons.water_drop),
                    label: const Text('LEAF MY MARK'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TreePainter extends CustomPainter {
  final double growth;
  TreePainter({required this.growth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Start at bottom center
    final startOffset = Offset(size.width / 2, size.height * 0.85);

    // Initial branch properties
    double trunkLength = size.height * 0.22 * growth;
    double trunkWidth = 12.0 * (1 - growth * 0.2);

    _drawBranch(
      canvas,
      startOffset,
      -pi / 2,
      trunkLength,
      trunkWidth,
      0,
      paint,
    );
  }

  void _drawBranch(
    Canvas canvas,
    Offset start,
    double angle,
    double length,
    double width,
    int depth,
    Paint paint,
  ) {
    if (depth > 7 || length < 2) return;

    final end = Offset(
      start.dx + cos(angle) * length,
      start.dy + sin(angle) * length,
    );

    // Color gradient: Brown for trunk, lighter brown for outer branches
    paint.color = Color.lerp(Colors.brown[800], Colors.brown[400], depth / 7)!;
    paint.strokeWidth = width;

    canvas.drawLine(start, end, paint);

    // Leaf Generation
    if (depth > 3 && growth > 0.2) {
      final leafPaint = Paint()
        ..color = Colors.green[600]!.withOpacity(
          ((growth - 0.2) * 1.5).clamp(0, 1),
        )
        ..style = PaintingStyle.fill;

      // Draws leaves at the tips of the branches
      canvas.drawOval(
        Rect.fromCenter(center: end, width: 7, height: 11),
        leafPaint,
      );
    }

    // Branching Logic: Branches sprout as growth increases
    if (growth > (depth * 0.12)) {
      double nextLength = length * 0.75;
      double nextWidth = width * 0.7;

      // Create two sub-branches
      _drawBranch(
        canvas,
        end,
        angle + 0.38,
        nextLength,
        nextWidth,
        depth + 1,
        paint,
      );
      _drawBranch(
        canvas,
        end,
        angle - 0.38,
        nextLength,
        nextWidth,
        depth + 1,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(TreePainter oldDelegate) => oldDelegate.growth != growth;
}
