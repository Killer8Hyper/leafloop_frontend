import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leafloop/starting/log-in.dart';
// IMPORT the new page
import 'package:leafloop/starting/add-profile.dart';
import 'package:leafloop/database/database_helper.dart';

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

  bool get _isEmailValid {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(_emailController.text.trim());
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
                onChanged: (val) => setState(() {}),
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
              const SizedBox(height: 10),
              _buildPasswordRequirements(screenWidth),
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
              const SizedBox(height: 20),

              const SizedBox(height: 50),

              // UPDATED SIGN UP BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                    onPressed: () async {
                      String firstName = _firstNameController.text.trim();
                      String middleName = _middleNameController.text.trim();
                      String lastName = _lastNameController.text.trim();
                      String dob = _dobController.text.trim();
                      String username = _usernameController.text.trim();
                      String email = _emailController.text.trim();
                      String password = _passwordController.text;
                      String confirmPassword = _confirmPasswordController.text;

                      // Granular Validations
                      if (firstName.isEmpty) {
                        _showSnackBar('Please enter your first name');
                        return;
                      }
                      if (lastName.isEmpty) {
                        _showSnackBar('Please enter your last name');
                        return;
                      }
                      if (dob.isEmpty) {
                        _showSnackBar('Please select your date of birth');
                        return;
                      }
                      if (username.isEmpty) {
                        _showSnackBar('Please enter a username');
                        return;
                      }
                      if (!_isUsernameValid) {
                        _showSnackBar('Username must be 3+ chars with no spaces');
                        return;
                      }
                      if (email.isEmpty) {
                        _showSnackBar('Please enter your email address');
                        return;
                      }
                      if (!_isEmailValid) {
                        _showSnackBar('Please enter a valid email address');
                        return;
                      }
                      if (password.isEmpty) {
                        _showSnackBar('Please enter a password');
                        return;
                      }
                      if (!_isPasswordValid) {
                        _showSnackBar('Password does not meet security standards');
                        return;
                      }
                      if (confirmPassword.isEmpty) {
                        _showSnackBar('Please confirm your password');
                        return;
                      }
                      if (!_isPasswordMatch) {
                        _showSnackBar('Passwords do not match');
                        return;
                      }

                      // Check if Username is already taken
                      bool usernameTaken = await DatabaseHelper().isUsernameTaken(username);
                      if (usernameTaken) {
                        _showSnackBar('This username is already taken. Please choose another.');
                        return;
                      }

                      // Check if Email is already taken
                      bool emailTaken = await DatabaseHelper().isEmailTaken(email);
                      if (emailTaken) {
                        _showSnackBar('This email is already registered. Try logging in.');
                        return;
                      }

                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => AddProfilePage(
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 50, left: 20, right: 20),
      ),
    );
  }

  Widget _buildPasswordRequirements(double screenWidth) {
    return ListenableBuilder(
      listenable: Listenable.merge([_passwordController, _confirmPasswordController]),
      builder: (context, _) {
        final password = _passwordController.text;
        final confirm = _confirmPasswordController.text;
        
        final hasLength = password.length >= 8;
        final hasUpper = RegExp(r'[A-Z]').hasMatch(password);
        final hasNumber = RegExp(r'[0-9]').hasMatch(password);
        final hasSymbol = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
        final matches = password.isNotEmpty && password == confirm;

        Widget rule(String text, bool met) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  met ? Icons.check_circle : (password.isEmpty ? Icons.circle_outlined : Icons.cancel),
                  size: 14,
                  color: met ? Colors.green : (password.isEmpty ? Colors.grey : Colors.red),
                ),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: screenWidth * 0.028,
                    color: met ? Colors.green[700] : (password.isEmpty ? Colors.grey[600] : Colors.red[700]),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F7FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF3B5236).withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Security Standards',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF3B5236)),
              ),
              const SizedBox(height: 4),
              const Text(
                'Strong passwords help protect your account.',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 20,
                children: [
                  rule('8+ characters', hasLength),
                  rule('Uppercase', hasUpper),
                  rule('Number', hasNumber),
                  rule('Symbol', hasSymbol),
                  rule('Match', matches),
                ],
              ),
            ],
          ),
        );
      },
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
