import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'dashboard_page.dart';
import 'user.dart';

class OtpVerificationPage extends StatefulWidget {
  final int userId;
  final String method; // 'email' or 'phone'
  final String contact; // Email or phone number

  const OtpVerificationPage({
    super.key,
    required this.userId,
    required this.method,
    required this.contact,
  });

  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;
  bool canResend = true;
  int resendTimer = 30; // 30-second cooldown

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          if (resendTimer > 0) {
            resendTimer--;
            _startResendTimer();
          } else {
            canResend = true;
          }
        });
      }
    });
  }

 Future<void> verifyOtp() async {
  setState(() => isLoading = true);
  final url = Uri.parse("http://10.10.1.149:1052/auth/verify-otp");

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": widget.userId,
        "otp": otpController.text.trim(),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid response from server")),
        );
        return;
      }

      // Save token first
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token);

      // 🔥 NOW CALL /auth/me TO GET FULL USER
      final meResponse = await http.get(
        Uri.parse("http://10.10.1.149:1052/auth/me"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
      );

      if (meResponse.statusCode == 200) {
        final userData = jsonDecode(meResponse.body);

        final loggedInUser = User(
          id: userData['id'],
          name: userData['name'],
          email: userData['email'],
          token: token,
        );

        await prefs.setString("user", jsonEncode(loggedInUser.toJson()));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardPage(loggedInUser: loggedInUser),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch user info")),
        );
      }
    } else {
      final errorData = jsonDecode(response.body);
      final errorMsg = errorData['error'] ?? 'Invalid OTP';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Verification failed: $errorMsg")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  } finally {
    setState(() => isLoading = false);
  }
}

  Future<void> resendOtp() async {
    if (!canResend) return;
    setState(() => canResend = false);
    resendTimer = 30;

    final url = Uri.parse("http://10.10.1.149:1052/auth/generate-otp");

    final requestBody = {"userId": widget.userId, "user_id": widget.userId};

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP resent successfully")),
        );
        _startResendTimer();
      } else {
        final errorData = jsonDecode(response.body);
        final errorMsg = errorData['error'] ?? 'Failed to resend';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $errorMsg")));
        setState(() => canResend = true);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error resending OTP: $e")));
      setState(() => canResend = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF1F6),
      appBar: AppBar(
        title: const Text("Verify OTP"),
        backgroundColor: const Color(0xFFE655A8),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Enter the 6-digit code sent to your ${widget.method}",
              style: const TextStyle(fontSize: 16, color: Color(0xFF666666)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.contact,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 32),
            PinCodeTextField(
              appContext: context,
              length: 6,
              controller: otpController,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(8),
                fieldHeight: 50,
                fieldWidth: 40,
                activeFillColor: const Color(0xFFFDF1F6),
                inactiveFillColor: const Color(0xFFFDF1F6),
                selectedFillColor: const Color(0xFFFDF1F6),
                activeColor: const Color(0xFFE655A8),
                selectedColor: const Color(0xFFE655A8),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {},
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : verifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE655A8),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 32,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Verify",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: canResend ? resendOtp : null,
              child: Column(
                children: [
                  Text(
                    canResend ? "Resend OTP" : "Resend in $resendTimer seconds",
                    style: TextStyle(
                      fontSize: 16,
                      color: canResend ? const Color(0xFFE655A8) : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!canResend) const SizedBox(height: 4),
                  if (!canResend)
                    LinearProgressIndicator(
                      value: resendTimer / 30,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFE655A8),
                      ),
                      minHeight: 2,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
