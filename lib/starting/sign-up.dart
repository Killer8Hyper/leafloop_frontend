import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leafloop/starting/log-in.dart';
// IMPORT the new page
import 'package:leafloop/starting/add-profile.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  
  bool get _isPasswordValid {
    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$');
    return passwordRegex.hasMatch(_passwordController.text);
  }

  bool get _isUsernameValid {
    // No spaces, minimum 3 characters
    final usernameRegex = RegExp(r'^\S{3,}$');
    return usernameRegex.hasMatch(_usernameController.text);
  }

  bool get _isPasswordMatch {
    return _passwordController.text.isNotEmpty && 
           _passwordController.text == _confirmPasswordController.text;
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
                child: Container(
                  width: screenWidth * 0.5,
                  height: screenWidth * 0.5,
                  padding: EdgeInsets.all(screenWidth * 0.07),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/logo/LeafLoop1.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              _buildLabel("First Name:", screenWidth),
              const SizedBox(height: 8),
              _buildTextField(controller: _firstNameController, hintText: "enter your first name"),

              const SizedBox(height: 20),

              _buildLabel("Middle Name (Optional):", screenWidth),
              const SizedBox(height: 8),
              _buildTextField(controller: _middleNameController, hintText: "enter your middle name"),

              const SizedBox(height: 20),

              _buildLabel("Last Name:", screenWidth),
              const SizedBox(height: 8),
              _buildTextField(controller: _lastNameController, hintText: "enter your last name"),

              const SizedBox(height: 20),

              _buildLabel("Date of Birth (MM/DD/YYYY):", screenWidth),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _dobController, 
                hintText: "MM/DD/YYYY",
                keyboardType: TextInputType.number,
                inputFormatters: [DateInputFormatter()],
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today, color: Color(0xFF3B5236)),
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

              const SizedBox(height: 20),

              _buildLabel("Username:", screenWidth),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _usernameController, 
                hintText: "enter username (ex. JuanDelaCruz)",
                onChanged: (val) => setState(() {}),
              ),
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    "Minimum 3 characters, no spaces allowed",
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: _usernameController.text.isEmpty 
                        ? Colors.grey[600] 
                        : (_isUsernameValid ? Colors.green : Colors.red),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              _buildLabel("Email Address:", screenWidth),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _emailController, 
                hintText: "enter email (ex. juan@email.com)",
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),

              _buildLabel("Password:", screenWidth),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _passwordController,
                hintText: "enter your password",
                isPassword: true,
                obscureText: _obscurePassword,
                onChanged: (val) => setState(() {}),
                onToggleVisibility: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    "Must be 8+ chars, 1 capital, 1 number, 1 symbol",
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: _passwordController.text.isEmpty 
                        ? Colors.grey[600] 
                        : (_isPasswordValid ? Colors.green : Colors.red),
                      fontWeight: _isPasswordValid ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              _buildLabel("Confirm Password:", screenWidth),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _confirmPasswordController,
                hintText: "re-enter password",
                isPassword: true,
                obscureText: _obscureConfirm,
                onChanged: (val) => setState(() {}),
                onToggleVisibility: () {
                  setState(() {
                    _obscureConfirm = !_obscureConfirm;
                  });
                },
              ),
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    _confirmPasswordController.text.isEmpty 
                      ? "" 
                      : (_isPasswordMatch ? "Passwords match!" : "Passwords do not match"),
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: _isPasswordMatch ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // UPDATED SIGN UP BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    String firstName = _firstNameController.text.trim();
                    String middleName = _middleNameController.text.trim();
                    String lastName = _lastNameController.text.trim();
                    String dob = _dobController.text.trim();
                    String username = _usernameController.text.trim();
                    String email = _emailController.text.trim();
                    String password = _passwordController.text;
                    String confirmPassword = _confirmPasswordController.text;

                    if (firstName.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Please enter your first name'),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.only(bottom: 50, left: 20, right: 20),
                        ),
                      );
                      return;
                    }

                    if (lastName.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Please enter your last name'),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.only(bottom: 50, left: 20, right: 20),
                        ),
                      );
                      return;
                    }

                    if (dob.isEmpty || dob.length < 10) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Please enter a valid date of birth (MM/DD/YYYY)'),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.only(bottom: 50, left: 20, right: 20),
                        ),
                      );
                      return;
                    }

                    if (username.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Please enter a username'),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.only(bottom: 50, left: 20, right: 20),
                        ),
                      );
                      return;
                    }

                    if (!_isUsernameValid) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Username must be at least 3 characters and contain no spaces'),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.only(bottom: 50, left: 20, right: 20),
                        ),
                      );
                      return;
                    }

                    // Simple Email Regex
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (email.isEmpty || !emailRegex.hasMatch(email)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Please enter a valid email address'),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.only(bottom: 50, left: 20, right: 20),
                        ),
                      );
                      return;
                    }

                    if (password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Please enter a password'),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.only(bottom: 50, left: 20, right: 20),
                        ),
                      );
                      return;
                    }

                    // Password Validation Regex: 8+ chars, 1 capital, 1 number, 1 symbol
                    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$');
                    if (!passwordRegex.hasMatch(password)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Password must be 8+ chars, with 1 capital, 1 number, and 1 symbol'),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.only(bottom: 50, left: 20, right: 20),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                      return;
                    }

                    if (password != confirmPassword) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Passwords do not match'),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.only(bottom: 50, left: 20, right: 20),
                        ),
                      );
                      return;
                    }

                    // Navigate to add-profile.dart and PASS the username
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => AddProfilePage(
                          // Pass the data to the next screen
                          username: username,
                          email: email,
                          password: password,
                          firstName: firstName,
                          middleName: middleName,
                          lastName: lastName,
                          dob: dob,
                        ),
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
                    "Sign Up",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: Text(
                  "Already registered? Go back and Log in!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFFD6A573),
                    decoration: TextDecoration.underline,
                    fontSize: screenWidth * 0.04,
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
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          border: InputBorder.none,
          hintText: hintText,
          suffixIcon: suffixIcon ?? (isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null),
        ),
      ),
    );
  }
}

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text;

    if (text.length < oldValue.text.length) {
      return newValue;
    }

    if (text.length > 10) {
      return oldValue;
    }

    String result = "";
    String cleanText = text.replaceAll('/', '');

    for (int i = 0; i < cleanText.length; i++) {
      if (i == 2 || i == 4) {
        result += "/";
      }
      result += cleanText[i];
    }

    // Edge case handling: if user types '1' and it's the end of the month part, 
    // and they type something that would trigger a slash, we could pad it.
    // However, usually masking works best by just adding slashes.
    
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}
