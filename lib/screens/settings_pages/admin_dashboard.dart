import 'package:flutter/material.dart';
import 'package:leafloop/database/database_helper.dart';
import 'package:leafloop/screens/settings_pages/edit_missions.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final users = await DatabaseHelper().getAllUsers();
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: const Color(0xFF3B5236),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildStatCard(),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Registered Users",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: user['is_admin'] == 1 ? Colors.orange : Colors.green,
                          child: Icon(
                            user['is_admin'] == 1 ? Icons.admin_panel_settings : Icons.person,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(user['username'] ?? 'No Name'),
                        subtitle: Text(user['email'] ?? 'No Email'),
                        trailing: user['is_admin'] == 1 
                          ? const Chip(label: Text("ADMIN"), backgroundColor: Colors.orangeAccent)
                          : null,
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const EditMissionsScreen()),
          );
        },
        label: const Text("Manage Missions"),
        icon: const Icon(Icons.edit),
        backgroundColor: const Color(0xFF3B5236),
      ),
    );
  }

  Widget _buildStatCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF3B5236).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF3B5236), width: 1),
      ),
      child: Column(
        children: [
          const Text("Total Registered Users", style: TextStyle(fontSize: 16)),
          Text(
            "${_users.length}",
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF3B5236)),
          ),
        ],
      ),
    );
  }
}
