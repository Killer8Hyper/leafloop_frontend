import 'package:flutter/material.dart';
import 'package:leafloop/screens/homepage.dart';
import 'package:leafloop/screens/eco_timeline.dart';
import 'package:leafloop/screens/missions.dart';
import 'package:leafloop/widgets/nav_menu.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dynamic background based on theme
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: Row(
          children: [
            const Text(
              'Profile',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.account_circle,
              size: 50,
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Dynamic background for the bottom part
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                // Top Section with Curve - Primary Green
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(bottom: 30),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.elliptical(250, 100),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Theme.of(
                          context,
                        ).scaffoldBackgroundColor,
                        child: Icon(
                          Icons.person,
                          size: 80,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Username123",
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const Text(
                        "Eco-Type",
                        style: TextStyle(fontSize: 34, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // Cards Section
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      _buildProfileCard(
                        context: context,
                        title: "Progression",
                        status: "Green Grower",
                        description:
                            "\"Building momentum, one eco-action at a time.\"",
                        percentage: "47%",
                        progress: 0.47,
                        icon: Icons.emoji_events_outlined,
                      ),
                      const SizedBox(height: 20),
                      _buildProfileCard(
                        context: context,
                        title: "Behavior",
                        status: "Water Wizard",
                        description:
                            "\"Every drop counts, and you make them matter.\"",
                        percentage: "",
                        progress: 0.0,
                        icon: Icons.opacity,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildProfileCard({
    required BuildContext context,
    required String title,
    required String status,
    required String description,
    required String percentage,
    required double progress,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              color: Color(0xFFD6A573), // Accent color usually stays consistent
              decoration: TextDecoration.underline,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                children: [
                  const TextSpan(text: "Status: "),
                  TextSpan(
                    text: status,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(icon, size: 60, color: Theme.of(context).primaryColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
          if (percentage.isNotEmpty) ...[
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                percentage,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 5),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFE0D9D1),
              color: const Color(0xFFD6A573),
              minHeight: 12,
              borderRadius: BorderRadius.circular(10),
            ),
          ],
        ],
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
              _buildNavItem(context, Icons.home_outlined, "Home", () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              }),
              _buildNavItem(context, Icons.access_time, "Eco Timeline", () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const EcoTimeline()),
                );
              }),
              const SizedBox(width: 50),
              _buildNavItem(context, Icons.track_changes, "Missions", () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const MissionsScreen(),
                  ),
                );
              }),
              _buildNavItem(
                context,
                Icons.person_outline,
                "Profile",
                () {},
                isActive: true,
              ),
            ],
          ),
        ),
        Positioned(
          top: -30,
          child: GestureDetector(
            onTap: () => showNavigationMenu(context),
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
    BuildContext context,
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
