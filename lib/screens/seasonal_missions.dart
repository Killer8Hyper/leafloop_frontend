import 'package:flutter/material.dart';
import 'package:leafloop/screens/homepage.dart';
import 'package:leafloop/screens/eco_timeline.dart';
import 'package:leafloop/screens/missions.dart';
import 'package:leafloop/screens/profile.dart';
import 'package:leafloop/widgets/nav_menu.dart';
import 'package:leafloop/services/local_auth_service.dart';
import 'package:leafloop/screens/admin/users_list.dart';
import 'package:leafloop/database/database_helper.dart';
import 'package:leafloop/screens/settings_pages/edit_missions.dart';

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
            const SizedBox(height: 25),
            
            // EASY SECTION
            _buildDifficultyHeader("EASY CHALLENGES", Colors.green),
            const SizedBox(height: 10),
            _buildSeasonalActionCard(
              "Refill & Refresh",
              "Bring a reusable water bottle today.",
              "Easy",
              Icons.water_drop,
            ),
            const SizedBox(height: 15),
            _buildSeasonalActionCard(
              "Lights Out",
              "Unplug unused appliances for 2 hours.",
              "Easy",
              Icons.power_off,
            ),
            
            const SizedBox(height: 25),
            
            // MEDIUM SECTION
            _buildDifficultyHeader("MEDIUM CHALLENGES", Colors.orange),
            const SizedBox(height: 10),
            _buildSeasonalActionCard(
              _currentSeason.contains("Tag-init") ? "Natural Breeze" : "Seedling Care",
              _currentSeason.contains("Tag-init") ? "Avoid AC for 4 hours." : "Water your indoor plants.",
              "Medium",
              _currentSeason.contains("Tag-init") ? Icons.air : Icons.local_florist,
            ),
            const SizedBox(height: 15),
            _buildSeasonalActionCard(
              "Waste Sort",
              "Segregate your kitchen waste today.",
              "Medium",
              Icons.delete_sweep,
            ),
            
            const SizedBox(height: 25),
            
            // HARD SECTION
            _buildDifficultyHeader("HARD CHALLENGES", Colors.red),
            const SizedBox(height: 10),
            _buildSeasonalActionCard(
              _currentSeason.contains("Tag-ulan") ? "Tree Planting" : "Park Cleanup",
              _currentSeason.contains("Tag-ulan") ? "Join a local tree planting event." : "Lead a 1-hour park cleanup.",
              "Hard",
              Icons.landscape,
            ),
            
            const SizedBox(height: 30),
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

  Widget _buildDifficultyHeader(String title, Color color) {
    return Row(
      children: [
        Container(width: 4, height: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color, letterSpacing: 1.2)),
      ],
    );
  }

  Widget _buildSeasonalActionCard(String title, String subtitle, String difficulty, IconData icon) {
    Color diffColor = difficulty == "Easy" ? Colors.green : (difficulty == "Medium" ? Colors.orange : Colors.red);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: _seasonColor.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: _seasonColor, size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: diffColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(difficulty.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: diffColor)),
              ),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 10),
                          Expanded(child: Text("Completed! You earned rewards for this $difficulty mission!")),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: const Text("I'm Done", style: TextStyle(color: Colors.white, fontSize: 14)),
              ),
            ],
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
                LocalAuthService().isAdmin ? "Dashboard" : "Home",
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
                LocalAuthService().isAdmin ? Icons.settings_suggest : Icons.track_changes,
                LocalAuthService().isAdmin ? "Manage" : "Missions",
                () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocalAuthService().isAdmin ? const EditMissionsScreen() : const MissionsScreen(),
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
