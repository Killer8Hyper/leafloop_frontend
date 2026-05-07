import 'package:flutter/material.dart';
import 'package:leafloop/screens/homepage.dart';
import 'package:leafloop/screens/eco_timeline.dart';
import 'package:leafloop/screens/missions.dart';
import 'package:leafloop/screens/profile.dart';
import 'package:leafloop/widgets/nav_menu.dart';

class AccountCredentialsPage extends StatefulWidget {
  const AccountCredentialsPage({super.key});

  @override
  State<AccountCredentialsPage> createState() => _AccountCredentialsPageState();
}

class _AccountCredentialsPageState extends State<AccountCredentialsPage> {
  final TextEditingController _userController = TextEditingController(
    text: "CurrentUsername",
  );
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Account Credentials",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(
          bottom: 120,
          left: 20,
          right: 20,
          top: 20,
        ),
        children: [
          _buildSectionTitle("Username"),
          _buildTextField(
            context: context,
            controller: _userController,
            label: "New Username",
            icon: Icons.alternate_email,
          ),
          const SizedBox(height: 30),
          _buildSectionTitle("Security"),
          _buildTextField(
            context: context,
            label: "New Password",
            icon: Icons.lock_outline,
            isPassword: true,
            obscure: _obscurePassword,
            onSuffixTap: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
          const SizedBox(height: 15),
          _buildTextField(
            context: context,
            label: "Confirm New Password",
            icon: Icons.lock_reset,
            isPassword: true,
            obscure: _obscurePassword,
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Credentials Updated Successfully!"),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              "Update Credentials",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    TextEditingController? controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onSuffixTap,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: onSuffixTap,
              )
            : null,
        labelText: label,
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
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
