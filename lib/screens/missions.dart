import 'package:flutter/material.dart';
import 'package:leafloop/screens/homepage.dart';
import 'package:leafloop/screens/eco_timeline.dart';
import 'package:leafloop/screens/profile.dart';
import 'package:leafloop/widgets/nav_menu.dart';
import 'package:leafloop/database/database_helper.dart';
import 'package:leafloop/services/local_auth_service.dart';
import 'package:leafloop/screens/settings_pages/edit_missions.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  List<Map<String, dynamic>> _missions = [];
  Set<int> _completedMissionIds = {};
  bool _isProcessing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMissions();
  }

  Future<void> _loadMissions() async {
    try {
      int? userId = LocalAuthService().currentUserId;
      if (userId != null) {
        var allMissions = await DatabaseHelper().getAllMissions();
        var completedMissions = await DatabaseHelper().getUserCompletedMissions(userId);
        
        if (mounted) {
          setState(() {
            _missions = allMissions;
            _completedMissionIds = completedMissions.map((m) => m['mission_id'] as int).toSet();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showCompletionModal(Map<String, dynamic> mission) async {
    final TextEditingController noteController = TextEditingController();
    File? selectedImage;
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              Text(
                "Mission Accomplished?",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(height: 10),
              Text(
                "Have you finished \"${mission['title']}\"?",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: noteController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: "Add a quick note about what you did...",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  final XFile? image = await picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    setModalState(() => selectedImage = File(image.path));
                  }
                },
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                    image: selectedImage != null ? DecorationImage(image: FileImage(selectedImage!), fit: BoxFit.cover) : null,
                  ),
                  child: selectedImage == null 
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.camera_alt, size: 40, color: Colors.grey), Text("Add a picture (Optional)", style: TextStyle(color: Colors.grey))],
                      ) 
                    : null,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Not yet", style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _completeMission(mission['id'], note: noteController.text, imagePath: selectedImage?.path);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA8C69F),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text("Yes, I'm Done!", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddCustomMissionDialog() async {
    final TextEditingController titleController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create Custom Mission"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Make your own eco-goal! Custom missions give 5 XP.", style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 15),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "What's your mission?",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty) return;
              
              final missionData = {
                'title': titleController.text.trim(),
                'description': 'Custom User Mission',
                'difficulty': 1,
                'category': 'community',
                'xp_reward': 5, // LOW EXP as requested
                'icon': '✨',
              };
              
              await DatabaseHelper().addMission(missionData);
              Navigator.pop(context);
              _loadMissions();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B5236)),
            child: const Text("Add", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _completeMission(int missionId, {String? note, String? imagePath}) async {
    if (_isProcessing) return;
    
    int? userId = LocalAuthService().currentUserId;
    if (userId != null && !_completedMissionIds.contains(missionId)) {
      setState(() => _isProcessing = true);
      
      await DatabaseHelper().completeMission(userId, missionId, note: note, imagePath: imagePath);
      
      if (mounted) {
        setState(() {
          _completedMissionIds.add(missionId);
          _isProcessing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Mission completed! Streak updated.'),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
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
                if (LocalAuthService().isAdmin)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const EditMissionsScreen()),
                      ).then((_) => _loadMissions());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B5236), // DARK GREEN for Admin
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
                  )
                else
                  ElevatedButton(
                    onPressed: () => _showAddCustomMissionDialog(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA8C69F), // Light Green for Users
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
                      "Add Mission",
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
                      onPressed: () => _loadMissions(),
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
                if (_isLoading)
                  const Center(child: Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: CircularProgressIndicator(),
                  ))
                else if (_missions.isEmpty)
                  const Center(child: Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Text(
                      "No missions available yet.",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ))
                else
                  RepaintBoundary(
                    child: Column(
                      children: _missions.map((m) => _buildMissionCard(
                        context,
                        m,
                        _completedMissionIds.contains(m['id']),
                      )).toList(),
                    ),
                  ),
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
          _showCompletionModal(mission);
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
