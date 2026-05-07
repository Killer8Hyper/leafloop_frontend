import 'package:flutter/material.dart';
import 'package:leafloop/screens/homepage.dart';
import 'package:leafloop/screens/eco_timeline.dart';
import 'package:leafloop/screens/missions.dart';
import 'package:leafloop/screens/profile.dart';
import 'package:leafloop/widgets/nav_menu.dart';

class AboutLeafLoopPage extends StatelessWidget {
  const AboutLeafLoopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "About LeafLoop",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Image.asset('assets/images/logo/LeafLoop2.png', height: 100),
            const SizedBox(height: 20),
            const Text(
              "LeafLoop v1.0.2",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 20),
            const Text(
              "LeafLoop is a mobile application designed to encourage young adults to take measurable environmental actions. "
              "Our mission is to turn small daily habits into a global movement for sustainability.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 40),
            const Text(
              "Developed by graduating BSIT students at Quezon City University.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // --- REUSED NAVIGATION LOGIC ---
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
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                Icons.home_outlined,
                "Home",
                const HomePage(),
              ),
              _buildNavItem(
                context,
                Icons.access_time,
                "Timeline",
                const EcoTimeline(),
              ),
              const SizedBox(width: 50),
              _buildNavItem(
                context,
                Icons.track_changes,
                "Missions",
                const MissionsScreen(),
              ),
              _buildNavItem(
                context,
                Icons.person_outline,
                "Profile",
                const ProfileScreen(),
              ),
            ],
          ),
        ),
        Positioned(
          top: -30,
          child: GestureDetector(
            onTap: () => showNavigationMenu(context),
            child: _buildCenterLogo(context),
          ),
        ),
      ],
    );
  }

  Widget _buildCenterLogo(BuildContext context) => Container(
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
          child: Image.asset('assets/images/logo/LeafLoop2.png'),
        ),
      ),
    ),
  );

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    Widget destination,
  ) => GestureDetector(
    onTap: () => Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => destination),
    ),
    behavior: HitTestBehavior.opaque,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFFA5A5A5), size: 30),
        Text(
          label,
          style: const TextStyle(color: Color(0xFFA5A5A5), fontSize: 11),
        ),
      ],
    ),
  );
}
