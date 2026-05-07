import 'package:flutter/material.dart';
import 'package:leafloop/screens/homepage.dart';
import 'package:leafloop/screens/missions.dart';
import 'package:leafloop/screens/profile.dart';
// Import the navigation menu helper
import 'package:leafloop/widgets/nav_menu.dart';

class EcoTimeline extends StatelessWidget {
  const EcoTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: const Row(
          children: [
            Text(
              'Eco Timeline',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            Spacer(),
            Icon(Icons.access_time, size: 45, color: Colors.white),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        children: [
          _buildDateHeader(context, "Today, Feb, 20"),
          const SizedBox(height: 15),
          _buildTimelineItem(
            context,
            "Brought reusable water",
            "8:30 am",
            Icons.water_drop,
            Colors.blue,
          ),
          _buildTimelineItem(
            context,
            "Recycled 3 Times",
            "9:00 am",
            Icons.recycling,
            Colors.green,
          ),
          _buildTimelineItem(
            context,
            "Plant a seed",
            "9:30 am",
            Icons.eco,
            Colors.brown,
          ),
          _buildTimelineItem(
            context,
            "Biked to School",
            "5:30 pm",
            Icons.directions_bike,
            Colors.black54, // Changed to 54 for better dark mode visibility
          ),

          const SizedBox(height: 20),

          // Achievement Card
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFA8C69F),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: -5,
                  bottom: -5,
                  child: Opacity(
                    opacity: 0.35,
                    child: Image.asset(
                      'assets/images/icons/confetti.png',
                      width: 110,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "27 Days Streak",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(blurRadius: 2, color: Colors.black26),
                          ],
                        ),
                      ),
                      Text(
                        "Unlocked!",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 15,
                  top: 10,
                  bottom: 10,
                  child: Image.asset(
                    'assets/images/icons/trophy.png',
                    width: 90,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),
          _buildDateHeader(context, "Yesterday, Feb 19"),
          const SizedBox(height: 100),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildDateHeader(BuildContext context, String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFA8C69F),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    String title,
    String time,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFA8C69F),
            child: Icon(Icons.check, color: Colors.white),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(time, style: const TextStyle(color: Colors.orangeAccent)),
              ],
            ),
          ),
          Icon(icon, color: iconColor, size: 30),
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
              _buildNavItem(
                context,
                Icons.access_time,
                "Timeline",
                () {},
                isActive: true,
              ),
              const SizedBox(width: 50),
              _buildNavItem(context, Icons.track_changes, "Missions", () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const MissionsScreen(),
                  ),
                );
              }, isActive: false),
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
    Color activeColor = Theme.of(context).primaryColor;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? activeColor : const Color(0xFFA5A5A5),
            size: 30,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? activeColor : const Color(0xFFA5A5A5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
