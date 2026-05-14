import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: SignUpPage()));
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String? errorMessage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fullNameController.addListener(_validateFields);
    emailController.addListener(_validateFields);
    phoneController.addListener(_validateFields);
    passwordController.addListener(_validateFields);
    confirmPasswordController.addListener(_validateFields);
  }

  void _validateFields() {
    setState(() {
      final name = fullNameController.text.trim();
      final email = emailController.text.trim();
      final phone = phoneController.text.trim();
      final password = passwordController.text;
      final confirmPassword = confirmPasswordController.text;

      final nameRegex = RegExp(r'^[a-zA-Z ]{3,}$');
      final emailRegex = RegExp(
        r'^[a-zA-Z][a-zA-Z0-9._-]*@[a-zA-Z]+\.[a-zA-Z]{2,}$',
      );
      final phoneRegex = RegExp(r'^\d{10,15}$');
      final strongPasswordRegex = RegExp(
        r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$',
      );

      if (!nameRegex.hasMatch(name)) {
        errorMessage =
            "Full Name should be at least 3 letters and only letters/spaces";
      } else if (!emailRegex.hasMatch(email)) {
        errorMessage = "Enter a valid email address";
      } else if (!phoneRegex.hasMatch(phone)) {
        errorMessage = "Phone number should be 10-15 digits";
      } else if (!strongPasswordRegex.hasMatch(password)) {
        errorMessage =
            "Password must be at least 8 characters, include uppercase, lowercase, number & special char";
      } else if (password != confirmPassword && confirmPassword.isNotEmpty) {
        errorMessage = "Passwords do not match";
      } else {
        errorMessage = null;
      }
    });
  }

  Future<void> registerUser() async {
    setState(() {
      isLoading = true;
    });

  final url = Uri.parse("http://10.10.1.149:1052/auth/register");
  final body = jsonEncode({
    "name": fullNameController.text,
    "email": emailController.text,
    "phonenumber": phoneController.text,
    "password": passwordController.text,
  });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              );
            });

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.check_circle, color: Color(0xFFE655A8), size: 60),
                  SizedBox(height: 16),
                  Text(
                    "Registration Successful!",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "You can now log in to your account.",
                    style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${response.body}")));
        
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to connect to backend")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF1F6),
      body: SafeArea(
        child: SizedBox(
          height: screenHeight,
          width: screenWidth,
          child: Stack(
            children: [
              // Top background image
              SizedBox(
                height: screenHeight * 0.35,
                width: screenWidth,
                child: Image.asset(
                  'assets/backgroundLogin.jpeg',
                  fit: BoxFit.cover,
                ),
              ),

              // Bottom white card with form
              Positioned(
                top: screenHeight * 0.30,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          "Create Your Account",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        _buildTextField(
                          Icons.person,
                          "Full Name",
                          fullNameController,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          Icons.email,
                          "Email Address",
                          emailController,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          Icons.phone,
                          "Phone Number",
                          phoneController,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          Icons.lock,
                          "Password",
                          passwordController,
                          isPassword: true,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          Icons.lock,
                          "Confirm Password",
                          confirmPasswordController,
                          isPassword: true,
                        ),
                        if (errorMessage != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            errorMessage!,
                            style: const TextStyle(
                              color: Color(0xFFE655A8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE655A8),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            if (errorMessage == null) registerUser();
                          },
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Already have an account? ",
                              style: TextStyle(color: Colors.black54),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LoginPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Log In",
                                style: TextStyle(
                                  color: Color(0xFFE655A8),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    IconData icon,
    String hintText,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: hintText.contains("Phone")
          ? TextInputType.phone
          : TextInputType.text,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFFE655A8)),
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
