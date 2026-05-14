import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:personal_health_assistant/homepage/login.dart';
import 'package:personal_health_assistant/homepage/user.dart';
import 'edit_profile_page.dart';
import 'change_password_page.dart';
import 'package:personal_health_assistant/homepage/dashboard_page.dart';

class SettingsPage extends StatelessWidget {
  final User loggedInUser;

  const SettingsPage({super.key, required this.loggedInUser});

  List<SettingsSection> _buildSections(BuildContext context) {
    return [
      SettingsSection(
        title: "PRIVACY & SECURITY",
        items: [
          SettingsItem(
            icon: Icons.lock,
            title: "Change Password",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangePasswordPage(user: loggedInUser),
                ),
              );
            },
          ),
          SettingsItem(
            icon: Icons.policy,
            title: "Privacy Policy",
            onTap: () => _showPrivacyPolicy(context),
          ),
        ],
      ),
      SettingsSection(
        title: "ABOUT US",
        items: [
          SettingsItem(
            icon: Icons.info,
            title: "About PulmoCheck",
            onTap: () => _showAboutDialog(context),
          ),
          SettingsItem(
            icon: Icons.person,
            title: "Developer",
            onTap: () => _showDeveloperDialog(context),
          ),
          SettingsItem(
            icon: Icons.support_agent,
            title: "Contact Support",
            onTap: () => _showContactDialog(context),
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final sections = _buildSections(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFDF1F6),
      appBar: AppBar(
        title: const Text("Settings"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => DashboardPage(loggedInUser: loggedInUser)),
            );
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildUserCard(context),
          const SizedBox(height: 24),
          ...sections.map((section) => _buildSection(section)),
          const SizedBox(height: 20),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xFFFFD6E8),
            child: Icon(Icons.person, color: Color(0xFFE655A8)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loggedInUser.name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text(loggedInUser.email,
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFFE655A8)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => EditProfilePage(user: loggedInUser)),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildSection(SettingsSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(section.title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        ...section.items.map((item) => _buildTile(item)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTile(SettingsItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _cardDecoration(),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFFFD6E8),
          child: Icon(item.icon, color: const Color(0xFFE655A8)),
        ),
        title: Text(item.title),
        trailing: const Icon(Icons.chevron_right),
        onTap: item.onTap,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        side: const BorderSide(color: Color(0xFFE655A8)),
      ),
      onPressed: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
          (route) => false,
        );
      },
      icon: const Icon(Icons.logout, color: Color(0xFFE655A8)),
      label: const Text("Logout",
          style: TextStyle(color: Color(0xFFE655A8))),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
        )
      ],
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text("Privacy Policy"),
        content: SingleChildScrollView(
          child: Text(
            "PulmoCheck values your privacy.\n\n"
            "• We never share your health data.\n"
            "• All data is encrypted.\n"
            "• Your medical images are processed securely.\n"
            "• We comply with all relevant data protection regulations.\n\n"
            "For more details, please visit our contact support.",
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text("About PulmoCheck"),
        content: Text(
            "PulmoCheck is an AI-powered lung health assistant.\n\nVersion 1.0.0\n\nOur mission is to empower individuals with early detection and insights for better lung health management."),
      ),
    );
  }

  void _showDeveloperDialog(BuildContext context) {
    final developers = [
      {
        "name": "Tirtha Singh Khadka Chhetri",
        "role":
            "Machine Learning Engineer & Flutter Developer & Backend Developer & Project Lead",
        "image": "assets/Tirtha.jpg"
      },
      {
        "name": "Saru Tiwari",
        "role": "Machine Learning Developer & Flutter Developer & Backend Developer",
        "image": "assets/Saru.jpg"
      },
      {
        "name": "Sushil Giri",
        "role": "UI/UX Designer",
        "image": "assets/sushil.png"
      },
      {
        "name": "Aashish Pandey",
        "role": "QA & Testing",
        "image": "assets/Ashish.jpg"
      },
    ];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Developers"),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: developers.map((dev) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage(dev["image"]!),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dev["name"]!,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dev["role"]!,
                              style: const TextStyle(color: Colors.grey),
                              softWrap: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text("Contact Support"),
        content: Text(
          "📧 ktirthasingh@gmail.com\n"
          "📧 sarutiwari04@gmail.com",
        ),
      ),
    );
  }
}

class SettingsSection {
  final String title;
  final List<SettingsItem> items;
  SettingsSection({required this.title, required this.items});
}

class SettingsItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  SettingsItem(
      {required this.icon, required this.title, required this.onTap});
}