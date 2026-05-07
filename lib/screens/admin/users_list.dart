import 'package:flutter/material.dart';
import 'package:leafloop/database/database_helper.dart';
import 'package:leafloop/screens/homepage.dart';
import 'package:leafloop/screens/missions.dart';
import 'package:leafloop/screens/profile.dart';
import 'package:leafloop/widgets/nav_menu.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await DatabaseHelper().getAllUsers();
    setState(() {
      _users = users;
      _filteredUsers = users;
      _isLoading = false;
    });
  }

  void _filterUsers(String query) {
    setState(() {
      _filteredUsers = _users.where((user) {
        final username = user['username'].toString().toLowerCase();
        final email = user['email'].toString().toLowerCase();
        final searchLower = query.toLowerCase();
        return username.contains(searchLower) || email.contains(searchLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF3B5236),
        title: const Text("Users Management", style: TextStyle(color: Colors.white, fontSize: 28)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterUsers,
                    decoration: InputDecoration(
                      hintText: "Search by username or email...",
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF3B5236)),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: user['is_admin'] == 1 ? Colors.orange : const Color(0xFF3B5236),
                            child: Icon(user['is_admin'] == 1 ? Icons.admin_panel_settings : Icons.person, color: Colors.white),
                          ),
                          title: Text(user['username'] ?? 'User'),
                          subtitle: Text(user['email'] ?? ''),
                          trailing: user['is_admin'] == 1 
                            ? const Chip(label: Text("ADMIN", style: TextStyle(fontSize: 10)), backgroundColor: Colors.orangeAccent)
                            : null,
                          onTap: () {
                            _showUserDetails(user);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user['username'] ?? 'User Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Full Name: ${user['first_name'] ?? ''} ${user['last_name'] ?? ''}"),
            Text("Email: ${user['email'] ?? ''}"),
            Text("Streak: ${user['current_streak'] ?? 0} Days"),
            Text("Energy Level: ${user['energy_level'] ?? 2}"),
            Text("Total Missions: ${user['total_missions'] ?? 0}"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
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
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, "Dashboard", () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
              }),
              _buildNavItem(Icons.people, "Users", () {}, isActive: true),
              const SizedBox(width: 50),
              _buildNavItem(Icons.track_changes, "Missions", () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MissionsScreen()));
              }),
              _buildNavItem(Icons.person_outline, "Profile", () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
              }),
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
  }

  Widget _buildCenterLogo() => Container(
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, shape: BoxShape.circle),
    child: Container(
      width: 70, height: 70,
      decoration: const BoxDecoration(color: Color(0xFF3B5236), shape: BoxShape.circle),
      child: ClipOval(child: Padding(padding: const EdgeInsets.all(8.0), child: Image.asset('assets/images/logo/LeafLoop2.png'))),
    ),
  );

  Widget _buildNavItem(IconData icon, String label, VoidCallback onTap, {bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? const Color(0xFF3B5236) : const Color(0xFFA5A5A5), size: 30),
          Text(label, style: TextStyle(color: isActive ? const Color(0xFF3B5236) : const Color(0xFFA5A5A5), fontSize: 11)),
        ],
      ),
    );
  }
}
