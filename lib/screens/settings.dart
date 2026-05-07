import 'package:flutter/material.dart';
import 'package:leafloop/main.dart';
import 'package:leafloop/screens/homepage.dart';
import 'package:leafloop/screens/eco_timeline.dart';
import 'package:leafloop/screens/missions.dart';
import 'package:leafloop/screens/profile.dart';
import 'package:leafloop/widgets/nav_menu.dart';
import 'package:leafloop/screens/settings_pages/edit_profile.dart';
import 'package:leafloop/screens/settings_pages/account_credentials.dart';
import 'package:leafloop/screens/settings_pages/help_center.dart';
import 'package:leafloop/screens/settings_pages/about_leafloop.dart';
// IMPORT YOUR LOGIN SCREEN HERE
import 'package:leafloop/starting/log-in.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = themeNotifier.value == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: const Text(
          "Settings",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          const SizedBox(height: 20),
          _buildSectionHeader("Account"),
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: "Edit Profile",
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const EditProfilePage()),
            ),
          ),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: "Account Credentials",
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AccountCredentialsPage(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader("Preferences"),
          _buildSwitchTile(
            icon: Icons.notifications_none_outlined,
            title: "Push Notifications",
            value: _notificationsEnabled,
            onChanged: (val) => setState(() => _notificationsEnabled = val),
          ),
          _buildSwitchTile(
            icon: Icons.dark_mode_outlined,
            title: "Dark Mode",
            value: isDarkMode,
            onChanged: (val) {
              setState(() {
                themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
              });
            },
          ),
          const SizedBox(height: 20),
          _buildSectionHeader("Support"),
          _buildSettingsTile(
            icon: Icons.help_outline,
            title: "Help Center",
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const HelpCenterPage()),
            ),
          ),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: "About LeafLoop",
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AboutLeafLoopPage(),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: () {
                // LOGOUT LOGIC
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ), // Matches your class in log-in.dart
                  (route) => false, // This clears the navigation history
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).cardColor,
                foregroundColor: Colors.redAccent,
                elevation: 0,
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                "Logout",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              "Version 1.0.2",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // --- UI Helper Methods ---
  Widget _buildSectionHeader(String title) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Text(
      title.toUpperCase(),
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 13,
        letterSpacing: 1.2,
      ),
    ),
  );

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(15),
    ),
    child: ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    ),
  );

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(15),
    ),
    child: ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
      ),
    ),
  );

  Widget _buildBottomNav(BuildContext context) => Stack(
    alignment: Alignment.center,
    clipBehavior: Clip.none,
    children: [
      Container(
        height: 80,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              Icons.home_outlined,
              "Home",
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              ),
            ),
            _buildNavItem(
              Icons.access_time,
              "Timeline",
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const EcoTimeline()),
              ),
            ),
            const SizedBox(width: 50),
            _buildNavItem(
              Icons.track_changes,
              "Missions",
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MissionsScreen()),
              ),
            ),
            _buildNavItem(
              Icons.person_outline,
              "Profile",
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              ),
            ),
          ],
        ),
      ),
      Positioned(
        top: -30,
        child: GestureDetector(
          onTap: () => showNavigationMenu(context),
          child: _buildCenterLogo(),
        ),
      ),
    ],
  );

  Widget _buildCenterLogo() => Container(
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

  Widget _buildNavItem(IconData icon, String label, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
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
