import 'package:flutter/material.dart';
import 'package:leafloop/screens/homepage.dart';
import 'package:leafloop/screens/eco_timeline.dart';
import 'package:leafloop/screens/profile.dart';
import 'package:leafloop/widgets/nav_menu.dart';
import 'package:leafloop/database/database_helper.dart';
import 'package:leafloop/services/local_auth_service.dart';

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  List<Map<String, dynamic>> _missions = [];
  Set<int> _completedMissionIds = {};

  @override
  void initState() {
    super.initState();
    _loadMissions();
  }

  Future<void> _loadMissions() async {
    int? userId = LocalAuthService().currentUserId;
    if (userId != null) {
      var allMissions = await DatabaseHelper().getAllMissions();
      var completedMissions = await DatabaseHelper().getUserCompletedMissions(userId);
      
      if (mounted) {
        setState(() {
          _missions = allMissions;
          _completedMissionIds = completedMissions.map((m) => m['mission_id'] as int).toSet();
        });
      }
    }
  }

  Future<void> _completeMission(int missionId) async {
    int? userId = LocalAuthService().currentUserId;
    if (userId != null && !_completedMissionIds.contains(missionId)) {
      await DatabaseHelper().completeMission(userId, missionId);
      setState(() {
        _completedMissionIds.add(missionId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mission completed! Streak updated.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dynamic background color
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: const Row(
          children: [
            Text(
              'Missions',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            Spacer(),
            Icon(Icons.notifications_none, size: 35, color: Colors.white),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Top Action Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA8C69F),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: const Text(
                    "Edit Missions",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "Refresh: ",
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.refresh,
                        size: 35,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Missions List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              children: [
                if (_missions.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else
                  ..._missions.map((m) => _buildMissionCard(
                    context,
                    m,
                    _completedMissionIds.contains(m['id']),
                  )).toList(),
                const SizedBox(height: 100), // Space for bottom nav
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildMissionCard(BuildContext context, Map<String, dynamic> mission, bool isCompleted) {
    return GestureDetector(
      onTap: () {
        if (!isCompleted) {
          _completeMission(mission['id']);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor, // Adapts to theme
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isCompleted ? const Color(0xFFA8C69F) : const Color(0xFFE0D9D1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: isCompleted 
                  ? const Icon(Icons.check, color: Colors.white)
                  : Text(mission['icon'] ?? '', style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                mission['title'] ?? '',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).primaryColor,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
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
              _buildNavItem(
                context,
                Icons.track_changes,
                "Missions",
                () {},
                isActive: true,
              ),
              _buildNavItem(context, Icons.person_outline, "Profile", () {
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
