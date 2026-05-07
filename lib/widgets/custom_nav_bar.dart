import 'package:flutter/material.dart';
import 'package:leafloop/screens/homepage.dart';
import 'package:leafloop/screens/eco_timeline.dart';
import 'package:leafloop/screens/missions.dart';
import 'package:leafloop/screens/profile.dart';
import 'package:leafloop/screens/growth_tree.dart';

void showNavigationMenu(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor:
        Colors.transparent, // Allows us to see the curved container
    isScrollControlled: true,
    builder: (context) {
      return Container(
        height:
            MediaQuery.of(context).size.height *
            0.6, // Slide up to 60% of screen
        decoration: const BoxDecoration(
          color: Color(0xFF3B5236),
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 15),
            // The Leaf Icon at the top of the menu
            Image.asset('assets/images/logo/LeafLoop2.png', width: 60),
            const SizedBox(height: 30),

            // Grid of choices
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 20,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildMenuIcon(context, Icons.home, "Home", const HomePage()),
                  _buildMenuIcon(
                    context,
                    Icons.access_time,
                    "Timeline",
                    const EcoTimeline(),
                  ),
                  _buildMenuIcon(
                    context,
                    Icons.track_changes,
                    "Missions",
                    const MissionsScreen(),
                  ),
                  _buildMenuIcon(
                    context,
                    Icons.person,
                    "Profile",
                    const ProfileScreen(),
                  ),
                  _buildMenuIcon(
                    context,
                    Icons.ac_unit,
                    "S.Mission",
                    const MissionsScreen(),
                  ), // Placeholder for Seasonal
                  _buildMenuIcon(
                    context,
                    Icons.park,
                    "Tree",
                    const TreeGrowthScreen(),
                  ),
                  _buildMenuIcon(
                    context,
                    Icons.settings,
                    "Settings",
                    const HomePage(),
                  ), // Placeholder
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
      Navigator.pop(context); // Close the menu
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => destination),
      );
    },
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, size: 40, color: const Color(0xFF3B5236)),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    ),
  );
}
