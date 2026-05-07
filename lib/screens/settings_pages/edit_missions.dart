import 'package:flutter/material.dart';
import 'package:leafloop/database/database_helper.dart';
import 'package:leafloop/screens/homepage.dart';

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

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(isEditing ? "Edit Mission" : "Add Mission", style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: "Title", hintText: "e.g., Plant a Tree"),
                    validator: (val) => val == null || val.trim().isEmpty ? "Title is required" : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: "Description", hintText: "What should the user do?"),
                    maxLines: 2,
                    validator: (val) => val == null || val.trim().isEmpty ? "Description is required" : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: xpController,
                    decoration: const InputDecoration(labelText: "XP Reward", hintText: "Enter points..."),
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.isEmpty) return "XP is required";
                      final n = int.tryParse(val);
                      if (n == null) return "Must be a number";
                      
                      if (difficulty == 1 && (n < 5 || n > 10)) return "Easy range: 5 - 10";
                      if (difficulty == 2 && (n < 15 || n > 25)) return "Medium range: 15 - 25";
                      if (difficulty == 3 && (n < 40 || n > 60)) return "Hard range: 40 - 60";
                      
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: iconController,
                    decoration: const InputDecoration(labelText: "Icon (Emoji)", hintText: "e.g., 🌱"),
                    validator: (val) => val == null || val.trim().isEmpty ? "Icon is required" : null,
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<int>(
                    value: difficulty,
                    items: const [
                      DropdownMenuItem(value: 1, child: Text("Easy")),
                      DropdownMenuItem(value: 2, child: Text("Medium")),
                      DropdownMenuItem(value: 3, child: Text("Hard")),
                    ],
                    onChanged: (val) => setDialogState(() => difficulty = val!),
                    decoration: const InputDecoration(labelText: "Difficulty"),
                  ),
                  const SizedBox(height: 10),
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
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final data = {
                    'title': titleController.text.trim(),
                    'description': descController.text.trim(),
                    'difficulty': difficulty,
                    'category': category,
                    'xp_reward': int.parse(xpController.text),
                    'icon': iconController.text.trim(),
                  };
                  if (isEditing) {
                    await DatabaseHelper().updateMission(mission['id'], data);
                  } else {
                    await DatabaseHelper().addMission(data);
                  }
                  if (mounted) {
                    Navigator.pop(context);
                    _loadMissions();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Mission successfully ${isEditing ? 'updated' : 'added'}!"), behavior: SnackBarBehavior.floating),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B5236), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text(isEditing ? "Save Changes" : "Create Mission", style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          ),
        ),
        title: const Text("Manage Missions", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF3B5236),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildLegend(),
                ..._missions.map((m) => _buildMissionTile(m)).toList(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMissionDialog(),
        backgroundColor: const Color(0xFF3B5236),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  Widget _buildLegend() {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("DIFFICULTY LEGEND", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLegendItem("Easy", "5-10 XP", Colors.green),
              _buildLegendItem("Medium", "15-25 XP", Colors.orange),
              _buildLegendItem("Hard", "40-60 XP", Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String xp, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
        ),
        const SizedBox(height: 4),
        Text(xp, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildMissionTile(Map<String, dynamic> m) {
    int diff = m['difficulty'] ?? 1;
    Color diffColor = diff <= 1 ? Colors.green : (diff == 2 ? Colors.orange : Colors.red);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50, height: 50,
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text(m['icon'] ?? '', style: const TextStyle(fontSize: 24))),
        ),
        title: Text(m['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: diffColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text("LVL $diff", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: diffColor)),
                ),
                const SizedBox(width: 8),
                Text("${m['xp_reward']} XP", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey)),
              ],
            ),
          ],
        ),
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
                    content: Text("Are you sure you want to remove \"${m['title']}\"?"),
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
      ),
    );
  }
}
