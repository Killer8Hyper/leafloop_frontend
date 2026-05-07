import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:leafloop/screens/homepage.dart';
import 'package:leafloop/screens/eco_timeline.dart';
import 'package:leafloop/screens/missions.dart';
import 'package:leafloop/screens/profile.dart';
// Import the navigation menu helper
import 'package:leafloop/widgets/nav_menu.dart';

void main() => runApp(const LeafLoopApp());

class LeafLoopApp extends StatelessWidget {
  const LeafLoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LeafLoop',
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: const TreeGrowthScreen(),
    );
  }
}

class TreeGrowthScreen extends StatefulWidget {
  const TreeGrowthScreen({super.key});

  @override
  State<TreeGrowthScreen> createState() => _TreeGrowthScreenState();
}

class _TreeGrowthScreenState extends State<TreeGrowthScreen>
    with SingleTickerProviderStateMixin {
  double _currentGrowth = 0.0;
  late AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  void _waterTree() {
    if (_currentGrowth < 1.0) {
      double nextStage = (_currentGrowth + 0.1).clamp(0.0, 1.0);
      _lottieController.animateTo(nextStage, curve: Curves.easeInOut);
      setState(() {
        _currentGrowth = nextStage;
      });
    }
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Text(
              'Growth Tree',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            Spacer(),
            Icon(Icons.park, size: 45, color: Color(0xFF90C152)),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFD6A573),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.water_drop, color: Color(0xFF21558E)),
                  SizedBox(width: 10),
                  Text(
                    'Longest Streak: 27 Days',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              width: double.infinity,
              color: Theme.of(context).cardColor,
              child: Center(
                child: Lottie.asset(
                  'assets/animations/tree.json',
                  controller: _lottieController,
                  delegates: LottieDelegates(
                    values: [
                      ValueDelegate.opacity([
                        '**',
                        'Background',
                        '**',
                      ], value: 0),
                      ValueDelegate.opacity(['**', 'Solid', '**'], value: 0),
                    ],
                  ),
                  onLoaded: (composition) {
                    _lottieController.duration = composition.duration;
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFD6A573),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.wb_sunny_rounded,
                    color: Color(0xFFFFE082),
                    size: 60,
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      'Your tree is growing strongly!\nComplete more tasks daily for a boost.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
      floatingActionButton: FloatingActionButton(
        onPressed: _waterTree,
        backgroundColor: Theme.of(context).primaryColor,
        mini: true,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, "Home", () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              }),
              _buildNavItem(Icons.access_time, "Eco Timeline", () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const EcoTimeline()),
                );
              }),
              const SizedBox(width: 50), // Space for center logo
              _buildNavItem(Icons.track_changes, "Missions", () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const MissionsScreen(),
                  ),
                );
              }, isActive: false),
              _buildNavItem(Icons.person_outline, "Profile", () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              }),
            ],
          ),
        ),
        Positioned(
          top: -30,
          child: GestureDetector(
            onTap: () {
              showNavigationMenu(context);
            },
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      'assets/images/logo/LeafLoop2.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive
                ? Theme.of(context).primaryColor
                : const Color(0xFFA5A5A5),
            size: 30,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive
                  ? Theme.of(context).primaryColor
                  : const Color(0xFFA5A5A5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
