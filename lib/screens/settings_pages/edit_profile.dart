import 'package:flutter/material.dart';
import 'package:leafloop/screens/homepage.dart';
import 'package:leafloop/screens/eco_timeline.dart';
import 'package:leafloop/screens/missions.dart';
import 'package:leafloop/screens/profile.dart';
import 'package:leafloop/widgets/nav_menu.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Uses the theme's background color
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 80,
        automaticallyImplyLeading: true,
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontSize: 28, color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(
          bottom: 100,
          left: 20,
          right: 20,
          top: 20,
        ),
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          const SizedBox(height: 30),
          _buildTextField(context, "Full Name", "User Name"),
          const SizedBox(height: 20),
          _buildTextField(context, "Bio", "Eco-warrior in training!"),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              "Save Changes",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    String label,
    String placeholder,
  ) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        // Uses cardColor so it turns dark in Dark Mode
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
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
    Widget destination,
  ) {
    return GestureDetector(
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
}
