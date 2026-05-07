import 'package:flutter/material.dart';
import 'package:leafloop/database/database_helper.dart';

class EditMissionsScreen extends StatefulWidget {
  const EditMissionsScreen({super.key});

  @override
  State<EditMissionsScreen> createState() => _EditMissionsScreenState();
}

class _EditMissionsScreenState extends State<EditMissionsScreen> {
  List<Map<String, dynamic>> _missions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMissions();
  }

  Future<void> _loadMissions() async {
    final missions = await DatabaseHelper().getAllMissions();
    setState(() {
      _missions = missions;
      _isLoading = false;
    });
  }

  void _showMissionDialog({Map<String, dynamic>? mission}) {
    final isEditing = mission != null;
    final titleController = TextEditingController(text: mission?['title'] ?? '');
    final descController = TextEditingController(text: mission?['description'] ?? '');
    final xpController = TextEditingController(text: mission?['xp_reward']?.toString() ?? '10');
    final iconController = TextEditingController(text: mission?['icon'] ?? '🌱');
    int difficulty = mission?['difficulty'] ?? 1;
    String category = mission?['category'] ?? 'energy';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? "Edit Mission" : "Add Mission"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: "Title")),
                TextField(controller: descController, decoration: const InputDecoration(labelText: "Description")),
                TextField(controller: xpController, decoration: const InputDecoration(labelText: "XP Reward"), keyboardType: TextInputType.number),
                TextField(controller: iconController, decoration: const InputDecoration(labelText: "Icon (Emoji)")),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: difficulty,
                  items: [1, 2, 3].map((d) => DropdownMenuItem(value: d, child: Text("Difficulty $d"))).toList(),
                  onChanged: (val) => setDialogState(() => difficulty = val!),
                  decoration: const InputDecoration(labelText: "Difficulty"),
                ),
                DropdownButtonFormField<String>(
                  value: category,
                  items: ['energy', 'water', 'plastic', 'transport', 'food', 'community']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase())))
                      .toList(),
                  onChanged: (val) => setDialogState(() => category = val!),
                  decoration: const InputDecoration(labelText: "Category"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                final data = {
                  'title': titleController.text,
                  'description': descController.text,
                  'difficulty': difficulty,
                  'category': category,
                  'xp_reward': int.tryParse(xpController.text) ?? 10,
                  'icon': iconController.text,
                };
                if (isEditing) {
                  await DatabaseHelper().updateMission(mission['id'], data);
                } else {
                  await DatabaseHelper().addMission(data);
                }
                Navigator.pop(context);
                _loadMissions();
              },
              child: Text(isEditing ? "Save" : "Add"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Missions"),
        backgroundColor: const Color(0xFF3B5236),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _missions.length,
              itemBuilder: (context, index) {
                final m = _missions[index];
                return ListTile(
                  leading: Text(m['icon'] ?? '', style: const TextStyle(fontSize: 24)),
                  title: Text(m['title'] ?? ''),
                  subtitle: Text("Diff: ${m['difficulty']} | XP: ${m['xp_reward']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showMissionDialog(mission: m)),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Delete Mission?"),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await DatabaseHelper().deleteMission(m['id']);
                            _loadMissions();
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMissionDialog(),
        backgroundColor: const Color(0xFF3B5236),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
