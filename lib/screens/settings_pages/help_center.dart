import 'package:flutter/material.dart';
import 'package:leafloop/screens/homepage.dart';
import 'package:leafloop/screens/eco_timeline.dart';
import 'package:leafloop/screens/missions.dart';
import 'package:leafloop/screens/profile.dart';
import 'package:leafloop/widgets/nav_menu.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Help Center", style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildFaqTile(
            context,
            "How do I track a mission?",
            "Go to the Missions tab and click 'Start' on any active eco-challenge.",
          ),
          _buildFaqTile(
            context,
            "What is the Tree Growth animation?",
            "It represents your real-world environmental impact visualised digitally.",
          ),
          _buildFaqTile(
            context,
            "How to report a bug?",
            "Contact us at support@leafloop.com",
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildFaqTile(BuildContext context, String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(padding: const EdgeInsets.all(15), child: Text(answer)),
        ],
      ),
    );
  }

  // --- NAVIGATION (SAME AS SETTINGS) ---
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
