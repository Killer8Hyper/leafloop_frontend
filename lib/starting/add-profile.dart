// lib/screens/add-profile.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // REQUIRED for Uint8List
import 'package:image_picker/image_picker.dart';
// IMPORT the new energy level screen
import 'package:leafloop/starting/energy_level.dart';

class AddProfilePage extends StatefulWidget {
  final String username;

  const AddProfilePage({super.key, required this.username});

  @override
  State<AddProfilePage> createState() => _AddProfilePageState();
}

class _AddProfilePageState extends State<AddProfilePage> {
  late TextEditingController _usernameController;
  Uint8List? _webImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        var imageBytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = imageBytes;
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _showSuccessDialog() {
    double screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: const Color(0xFFA1C694),
                  size: screenWidth * 0.25,
                ),
                const SizedBox(height: 20),
                Text(
                  "Sign up successful!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    color: const Color(0xFF5A5A5A),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: screenWidth * 0.4,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to final navigation hier navigation hier finally finally hier fully final navigation here final finally hier finally hierarchy hierarchy
                      print("Close dialog, navigating..."); // DEBUG
                      Navigator.of(context).pop(); // Close Dialog first

                      // Navigate to the next page, removing previous stack
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const EnergyLevelPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B5236),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Continue",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 80),
              Center(
                child: SizedBox(
                  width: screenWidth * 0.5,
                  child: Image.asset(
                    'assets/images/logo/LeafLoop_name.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              Text(
                "Choose your profile icon.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  color: const Color(0xFF5A5A5A),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 30),

              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: screenWidth * 0.55,
                      height: screenWidth * 0.55,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF3B5236),
                          width: 8,
                        ),
                      ),
                      child: ClipOval(
                        child: _webImage != null
                            ? Image.memory(_webImage!, fit: BoxFit.cover)
                            : Center(
                                child: Stack(
                                  alignment: Alignment.topCenter,
                                  children: [
                                    Icon(
                                      Icons.person,
                                      size: screenWidth * 0.4,
                                      color: const Color(0xFF3B5236),
                                    ),
                                    Positioned(
                                      top: 5,
                                      child: Icon(
                                        Icons.eco,
                                        color: const Color(0xFF90C152),
                                        size: screenWidth * 0.12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F4F0),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: const Color(0xFFA5A5A5),
                            size: screenWidth * 0.1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              _buildLabel("Username:", screenWidth),
              const SizedBox(height: 8),
              _buildTextField(controller: _usernameController, hintText: ""),

              const SizedBox(height: 50),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _showSuccessDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B5236),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, double screenWidth) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          color: const Color(0xFF5A5A5A),
          fontSize: screenWidth * 0.045,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          border: InputBorder.none,
          hintText: hintText,
        ),
      ),
    );
  }
}
