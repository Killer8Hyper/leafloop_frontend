import 'package:flutter/material.dart';
import 'package:leafloop/screens/homepage.dart';
import 'package:leafloop/screens/eco_timeline.dart';
import 'package:leafloop/screens/missions.dart';
import 'package:leafloop/screens/profile.dart';
import 'package:leafloop/screens/growth_tree.dart';
import 'package:leafloop/screens/seasonal_missions.dart';
import 'package:leafloop/services/local_auth_service.dart';
import 'package:leafloop/screens/admin/users_list.dart';
import 'package:leafloop/screens/settings_pages/edit_missions.dart';

void showNavigationMenu(BuildContext context) {
  bool isAdmin = LocalAuthService().isAdmin;
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.55,
        decoration: const BoxDecoration(
          color: Color(0xFF3B5236),
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Image.asset('assets/images/logo/LeafLoop2.png', width: 45),
            const SizedBox(height: 40),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 30,
                crossAxisSpacing: 10,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildMenuIcon(
                    context,
                    Icons.home_outlined,
                    isAdmin ? "Dashboard" : "Home",
                    const HomePage(),
                  ),
                  _buildMenuIcon(
                    context,
                    isAdmin ? Icons.people : Icons.watch_later_outlined,
                    isAdmin ? "Users" : "Eco Timeline",
                    isAdmin ? const UsersListScreen() : const EcoTimeline(),
                  ),
                  _buildMenuIcon(
                    context,
                    isAdmin ? Icons.settings_suggest : Icons.track_changes,
                    isAdmin ? "Manage" : "Missions",
                    isAdmin ? const EditMissionsScreen() : const MissionsScreen(),
                  ),
                  _buildMenuIcon(
                    context,
                    Icons.person_outline,
                    "Profile",
                    const ProfileScreen(),
                  ),
                  _buildMenuIcon(
                    context,
                    Icons.filter_vintage_outlined,
                    "Seasonal",
                    const SeasonalMissionsScreen(),
                  ),
                  _buildMenuIcon(
                    context,
                    Icons.park_outlined,
                    "Tree",
                    const TreeGrowthScreen(),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildMenuIcon(
  BuildContext context,
  IconData icon,
  String label,
  Widget destination,
) {
  return GestureDetector(
    onTap: () {
      Navigator.pop(context);
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => destination));
    },
    child: Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, size: 40, color: const Color(0xFF3B5236)),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
