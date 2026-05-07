import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:leafloop/screens/homepage.dart';
import 'package:leafloop/screens/eco_timeline.dart';
import 'package:leafloop/screens/missions.dart';
import 'package:leafloop/screens/profile.dart';
import 'package:leafloop/widgets/nav_menu.dart';
import 'package:leafloop/database/database_helper.dart';
import 'package:leafloop/services/local_auth_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  
  String? _currentImagePath;
  String? _newImagePath;
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    int? userId = LocalAuthService().currentUserId;
    if (userId != null) {
      var user = await DatabaseHelper().getUserById(userId);
      if (user != null) {
          setState(() {
            _firstNameController.text = user['first_name'] ?? "";
            _middleNameController.text = user['middle_name'] ?? "";
            _lastNameController.text = user['last_name'] ?? "";
            _usernameController.text = user['username'] ?? "";
            _dobController.text = user['date_of_birth'] ?? "";
            _currentImagePath = user['profile_image_path'];
            _isLoading = false;
          });
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/profile_edit_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(path);
      await file.writeAsBytes(await pickedFile.readAsBytes());
      
      setState(() {
        _newImagePath = path;
      });
    }
  }

  Future<void> _saveChanges() async {
    int? userId = LocalAuthService().currentUserId;
    if (userId == null) return;

    String firstName = _firstNameController.text.trim();
    String middleName = _middleNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    String username = _usernameController.text.trim();
    String dob = _dobController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || username.isEmpty || dob.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields except Middle Name are required")),
      );
      return;
    }

    await DatabaseHelper().updateUserProfile(
      userId: userId,
      firstName: firstName,
      middleName: middleName,
      lastName: lastName,
      username: username,
      dob: dob,
      profileImagePath: _newImagePath ?? _currentImagePath,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    String fullName = "${_firstNameController.text} ${_middleNameController.text} ${_lastNameController.text}".replaceAll(RegExp(r'\s+'), ' ').trim();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Theme.of(context).primaryColor,
                  backgroundImage: _newImagePath != null 
                    ? FileImage(File(_newImagePath!)) 
                    : (_currentImagePath != null ? FileImage(File(_currentImagePath!)) : null),
                  child: (_newImagePath == null && _currentImagePath == null) 
                    ? const Icon(Icons.person, size: 60, color: Colors.white) 
                    : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              fullName.isNotEmpty ? fullName : "Full Name",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 30),
          _buildTextField("First Name", _firstNameController),
          const SizedBox(height: 15),
          _buildTextField("Middle Name (Optional)", _middleNameController),
          const SizedBox(height: 15),
          _buildTextField("Last Name", _lastNameController),
          const SizedBox(height: 15),
          _buildTextField(
            "Date of Birth (MM/DD/YYYY)", 
            _dobController,
            keyboardType: TextInputType.number,
            inputFormatters: [DateInputFormatter()],
            suffixIcon: IconButton(
              icon: Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
              onPressed: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    _dobController.text = "${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}";
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 15),
          _buildTextField("Username", _usernameController),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildTextField(
    String label, 
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      onChanged: (val) => setState(() {}),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Theme.of(context).cardColor,
        suffixIcon: suffixIcon,
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
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, Icons.home_outlined, "Home", const HomePage()),
              _buildNavItem(context, Icons.access_time, "Timeline", const EcoTimeline()),
              const SizedBox(width: 50),
              _buildNavItem(context, Icons.track_changes, "Missions", const MissionsScreen()),
              _buildNavItem(context, Icons.person_outline, "Profile", const ProfileScreen()),
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
        decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
        child: ClipOval(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/images/logo/LeafLoop2.png'),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, Widget destination) {
    return GestureDetector(
      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => destination)),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFA5A5A5), size: 30),
          Text(label, style: const TextStyle(color: Color(0xFFA5A5A5), fontSize: 11)),
        ],
      ),
    );
  }
}

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;
    
    // Handle deletion
    if (text.length < oldValue.text.length) {
      return newValue;
    }

    // Auto-prefix single digit months with 0
    // If typing '2'-'9' at the very beginning, make it '0D/'
    if (text.length == 1 && int.tryParse(text) != null && int.parse(text) > 1) {
      text = '0$text/';
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }

    // Automatic Slash after Month (index 2)
    if (text.length == 2 && !text.contains('/')) {
      text = '$text/';
    }
    
    // Auto-prefix single digit days
    // If text is 'MM/' and next char is > 3, make it 'MM/0D/'
    if (text.length == 4 && text.endsWith('/') == false) {
      var parts = text.split('/');
      if (parts.length == 2) {
        var day = parts[1];
        if (int.tryParse(day) != null && int.parse(day) > 3) {
          text = '${parts[0]}/0$day/';
          return TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: text.length),
          );
        }
      }
    }

    // Automatic Slash after Day (index 5)
    if (text.length == 5 && text.split('/').length == 2 && !text.endsWith('/')) {
      text = '$text/';
    }

    // Limit to MM/DD/YYYY (10 chars)
    if (text.length > 10) {
      return oldValue;
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
