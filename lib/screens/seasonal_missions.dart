import 'package:flutter/material.dart';
import 'package:leafloop/screens/homepage.dart';
import 'package:leafloop/screens/eco_timeline.dart';
import 'package:leafloop/screens/missions.dart';
import 'package:leafloop/screens/profile.dart';
import 'package:leafloop/widgets/nav_menu.dart';
import 'package:leafloop/services/local_auth_service.dart';
import 'package:leafloop/screens/admin/users_list.dart';
import 'package:leafloop/database/database_helper.dart';

class SeasonalMissionsScreen extends StatefulWidget {
  const SeasonalMissionsScreen({super.key});

  @override
  State<SeasonalMissionsScreen> createState() => _SeasonalMissionsScreenState();
}

class _SeasonalMissionsScreenState extends State<SeasonalMissionsScreen> {
  int _currentStreak = 0;
  String _currentSeason = "Spring";
  Color _seasonColor = const Color(0xFFD6A573);

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _determineSeason();
  }

  Future<void> _loadUserData() async {
    final userId = LocalAuthService().currentUserId;
    if (userId != null) {
      final user = await DatabaseHelper().getUserById(userId);
      if (mounted && user != null) {
        setState(() {
          _currentStreak = user['current_streak'] ?? 0;
        });
      }
    }
  }

  void _determineSeason() {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) {
      _currentSeason = "Dry Season (Tag-init)";
      _seasonColor = const Color(0xFFFFB74D); // Sunny Orange
    } else if (month >= 6 && month <= 11) {
      _currentSeason = "Rainy Season (Tag-ulan)";
      _seasonColor = const Color(0xFF64B5F6); // Rain Blue
    } else {
      _currentSeason = "Cool Dry Season (Tag-lamig)";
      _seasonColor = const Color(0xFF81C784); // Refreshing Green
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Updated to use Theme background
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Row(
          children: [
            Text(
              'Seasonal Missions',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            Spacer(),
            Icon(Icons.filter_vintage_outlined, color: Colors.white, size: 40),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _seasonColor.withOpacity(0.1),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSeasonHeader(),
            const SizedBox(height: 20),
            _buildProgressMission(
              context,
              "Seasonal Community Goal",
              0.5,
              "50%",
              "2 more activities to complete",
              subtitle: "Working together for a greener $_currentSeason",
            ),
            const SizedBox(height: 15),
            _buildActionMission(
              context,
              _currentSeason == "Spring" ? "Plant a Sapling" : "Seasonal Cleanup",
              "Earn bonus XP for $_currentSeason activities",
            ),
            const SizedBox(height: 15),
            _buildProgressMission(
              context,
              "Zero Waste Challenge",
              0.75,
              "75%",
              "1 more activity to complete",
              subtitle: "Special $_currentSeason rewards included!",
            ),
            const SizedBox(height: 25),
            _buildStreakCard(context),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildProgressMission(
    BuildContext context,
    String title,
    double progress,
    String percent,
    String remaining, {
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // Updated to use Card Color
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(
                context,
              ).textTheme.bodyLarge?.color?.withOpacity(0.8),
            ),
          ),
          if (subtitle != null)
            Text(subtitle, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Progress",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                percent,
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 15,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFD6A573), // Accent color kept for branding
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            remaining,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _seasonColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _seasonColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.wb_sunny_outlined, color: _seasonColor, size: 40),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("CURRENT SEASON", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _seasonColor)),
              Text(_currentSeason.toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionMission(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.stars, color: Colors.amber),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 10),
                        Expanded(child: Text("Great job! You've contributed to the $_currentSeason goals!")),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: _seasonColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _seasonColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: const Text("Complete Task", style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _seasonColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Seasonal Consistency",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  Icons.eco,
                  size: 60,
                  color: index < (_currentStreak > 3 ? 3 : _currentStreak) ? Colors.white : Colors.white24,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "$_currentStreak Days Streak",
            style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500),
          ),
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
            color: Theme.of(context).cardColor, // Dark mode support
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
                () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                ),
              ),
              _buildNavItem(
                context,
                LocalAuthService().isAdmin ? Icons.people : Icons.access_time,
                LocalAuthService().isAdmin ? "Users" : "Timeline",
                () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LocalAuthService().isAdmin ? const UsersListScreen() : const EcoTimeline()),
                ),
              ),
              const SizedBox(width: 50),
              _buildNavItem(
                context,
                Icons.track_changes,
                "Missions",
                () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MissionsScreen(),
                  ),
                ),
              ),
              _buildNavItem(
                context,
                Icons.person_outline,
                "Profile",
                () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                ),
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

  Widget _buildCenterLogo(BuildContext context) {
    return Container(
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
