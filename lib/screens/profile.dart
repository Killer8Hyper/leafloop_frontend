import 'package:flutter/material.dart';
import 'package:leafloop/screens/homepage.dart';
import 'package:leafloop/screens/eco_timeline.dart';
import 'package:leafloop/screens/missions.dart';
import 'package:leafloop/widgets/nav_menu.dart';
import 'package:leafloop/database/database_helper.dart';
import 'package:leafloop/services/local_auth_service.dart';
import 'package:leafloop/starting/landing_page.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    int? userId = LocalAuthService().currentUserId;
    if (userId != null) {
      var user = await DatabaseHelper().getUserById(userId);
      if (mounted) {
        setState(() {
          _user = user;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalMissions = _user?['total_missions'] ?? 0;
    int energyLevel = _user?['energy_level'] ?? 2;
    
    // Calculate eco type and progress
    String ecoType = energyLevel == 1 ? "Beginner" : energyLevel == 2 ? "Eco-Warrior" : "Master";
    double progress = (totalMissions % 10) / 10.0;
    String percentage = "${(progress * 100).toInt()}%";
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
            IconButton(
              icon: Icon(
                Icons.logout,
                size: 35,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              onPressed: () async {
                await LocalAuthService().logout();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LandingPage()),
                    (route) => false,
                  );
                }
              },
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
                        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                        backgroundImage: _user?['profile_image_path'] != null 
                            ? FileImage(File(_user!['profile_image_path'])) 
                            : null,
                        child: _user?['profile_image_path'] == null ? Icon(
                          Icons.person,
                          size: 80,
                          color: Theme.of(context).primaryColor,
                        ) : null,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _user?['username'] ?? "Loading...",
                        style: const TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      Text(
                        ecoType,
                        style: const TextStyle(fontSize: 34, color: Colors.white),
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
                        status: totalMissions >= 10 ? "Green Grower" : "Seedling",
                        description:
                            "\"Building momentum, one eco-action at a time.\"",
                        percentage: percentage,
                        progress: progress,
                        icon: Icons.emoji_events_outlined,
                      ),
                      const SizedBox(height: 20),
                      _buildProfileCard(
                        context: context,
                        title: "Stats",
                        status: "Active",
                        description:
                            "Total Missions: $totalMissions\nLongest Streak: ${_user?['longest_streak'] ?? 0}",
                        percentage: "",
                        progress: 0.0,
                        icon: Icons.bar_chart,
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
