import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_page.dart';
import 'signUp.dart';
import 'otp_verification_page.dart';
import 'user.dart';
import 'biometric_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final BiometricService _biometricService = BiometricService();
  
  bool _isLoading = false;
  bool _biometricAvailable = false;
  bool _checkingBiometric = true;
  String? _savedEmail;
  bool _hasBiometricCredentials = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadSavedEmail();
    _biometricAvailable = await _biometricService.isBiometricAvailable();
    
    if (_savedEmail != null) {
      _hasBiometricCredentials = await _biometricService.hasCredentials(_savedEmail!);
    }
    
    setState(() {
      _checkingBiometric = false;
    });
  }

  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    _savedEmail = prefs.getString('last_email');
    if (_savedEmail != null) {
      emailController.text = _savedEmail!;
    }
  }

  Future<void> _saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_email', email);
    _savedEmail = email;
  }

  Future<void> _login(BuildContext context, String email, String password, {bool isBiometricLogin = false}) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> requestBody = {
        "email": email,
        "password": password,
        "biometricLogin": isBiometricLogin,
      };

      final response = await http.post(
        Uri.parse("http://10.10.1.149:1052/auth/login"), // Replace with your API
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveEmail(email);

        // Handle 2FA redirect
        if (data['requires_2fa'] == true) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpVerificationPage(
                userId: data['user_id'],
                method: data['method'] ?? 'email',
                contact: data['contact'] ?? email,
              ),
            ),
          );
          return;
        }

        // Token-based login
        if (data['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("token", data['token']);

          // Biometric setup after login
          if (!isBiometricLogin && _biometricAvailable) {
            final hasCreds = await _biometricService.hasCredentials(email);
            if (!hasCreds) {
              _showBiometricSetupDialog(context, email, password);
              return;
            }
          }

          _showSuccessDialog(context, data['user']);
        }
      } else {
        final errorData = jsonDecode(response.body);
        final errorMsg = errorData['error'] ?? 'Login failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: $errorMsg"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error: $e"), backgroundColor: Colors.orange),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showBiometricSetupDialog(BuildContext context, String email, String password) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enable Biometric Login"),
        content: const Text("Do you want to enable fingerprint/face unlock for faster login?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _setupBiometric(context, email, password);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE655A8)),
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  Future<void> _setupBiometric(BuildContext context, String email, String password) async {
    final authenticated = await _biometricService.authenticate();
    if (authenticated) {
      await _biometricService.saveCredentials(email, password);
      setState(() => _hasBiometricCredentials = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Biometric login enabled!"), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Biometric setup failed"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _biometricLogin(BuildContext context) async {
    if (_savedEmail == null) return;
    final authenticated = await _biometricService.authenticate();
    if (authenticated) {
      final credentials = await _biometricService.getCredentials(_savedEmail!);
      if (credentials != null) {
        await _login(context, credentials['email']!, credentials['password']!, isBiometricLogin: true);
      }
    }
  }

  void _showSuccessDialog(BuildContext context, dynamic userJson) {
    final loggedInUser = User.fromJson(userJson, userJson['token']);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => DashboardPage(loggedInUser: loggedInUser)),
          );
        });

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Color(0xFFE655A8), size: 60),
              SizedBox(height: 16),
              Text(
                "Login Successful!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text("Welcome back to Pulmo Check"),
            ],
          ),
        );
      },
    );
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
              // Background Image
              SizedBox(
                height: screenHeight * 0.35,
                width: screenWidth,
                child: Image.asset('assets/backgroundLogin.jpeg', fit: BoxFit.cover),
              ),

              // Login Card
              Positioned(
                top: screenHeight * 0.30,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        const Text('Welcome Back!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                        const SizedBox(height: 6),
                        const Text('Log in to your Pulmo Check account.', style: TextStyle(fontSize: 15, color: Color(0xFF666666))),
                        const SizedBox(height: 28),

                        // Email Field
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFE655A8)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            filled: true,
                            fillColor: const Color(0xFFFDF1F6),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFE655A8)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            filled: true,
                            fillColor: const Color(0xFFFDF1F6),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Login + Biometric Button Row
                        Row(
                          children: [
                            if (_biometricAvailable && _hasBiometricCredentials)
                              Container(
                                width: 60,
                                height: 60,
                                margin: const EdgeInsets.only(right: 12),
                                child: ElevatedButton(
                                  onPressed: () => _biometricLogin(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4285F4),
                                    padding: const EdgeInsets.all(12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  ),
                                  child: const Icon(Icons.fingerprint, color: Colors.white, size: 28),
                                ),
                              ),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : () async {
                                        final email = emailController.text.trim();
                                        final password = passwordController.text.trim();
                                        if (email.isEmpty || password.isEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text("Please fill all fields")));
                                          return;
                                        }
                                        await _login(context, email, password);
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE655A8),
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Text('Log In', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Sign Up
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account? ", style: TextStyle(color: Color(0xFF666666))),
                            TextButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpPage()));
                              },
                              child: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE655A8))),
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
}