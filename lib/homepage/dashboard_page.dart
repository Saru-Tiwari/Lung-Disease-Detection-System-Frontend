import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Pneumonia_Xray_page.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Tuberclosis_Xray_page.dart';
import 'user.dart';
import 'Chatbot/chatbot_page.dart';
import 'Recent/recent_page.dart';
import 'Settings/settings.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'user.dart'; // Make sure this is your User model

/* ===================== DASHBOARD PAGE ===================== */
class DashboardPage extends StatefulWidget {
  final User loggedInUser;
  const DashboardPage({super.key, required this.loggedInUser});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: DashboardContent(loggedInUser: widget.loggedInUser),
      ),
      bottomNavigationBar: _BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        loggedInUser: widget.loggedInUser,
      ),
    );
  }
}

/* ===================== DASHBOARD CONTENT ===================== */
class DashboardContent extends StatelessWidget {
  final User loggedInUser;
  const DashboardContent({super.key, required this.loggedInUser});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(loggedInUser: loggedInUser), // ✅ pass the user here
          const SizedBox(height: 24),
          _MainCard(loggedInUser: loggedInUser),
          const SizedBox(height: 20),
          _TBCard(loggedInUser: loggedInUser),
          const SizedBox(height: 24),
          RecentActivity(loggedInUser: loggedInUser),
          const SizedBox(height: 16),
          const Text(
            "* This tool is for screening assistance only and does not replace professional medical advice. Please consult a doctor for diagnosis.",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

/* ===================== HEADER ===================== */
class _Header extends StatelessWidget {
  final User loggedInUser;
  const _Header({required this.loggedInUser});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome back,",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              loggedInUser.name, // ✅ use the logged-in user object
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const _StatusChip(), // keep your status chip here
          ],
        ),
        Row(
          children: const [
            Icon(Icons.notifications_none, color: Colors.grey),
            SizedBox(width: 12),
            CircleAvatar(radius: 18, backgroundColor: Color(0xFFFFC1A1)),
          ],
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F8EF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.circle, size: 8, color: Colors.green),
          SizedBox(width: 6),
          Text(
            "System Status: Online",
            style: TextStyle(fontSize: 12, color: Colors.green),
          ),
        ],
      ),
    );
  }
}

/* ===================== BREATHING LUNGS ===================== */

class BreathingLungs extends StatefulWidget {
  const BreathingLungs({super.key});

  @override
  State<BreathingLungs> createState() => _BreathingLungsState();
}

class _BreathingLungsState extends State<BreathingLungs>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(
        begin: 0.9,
        end: 1.05,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: Color(0xFFFFEEF5),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.air_rounded,
          color: Color(0xFFE655A8),
          size: 28,
        ),
      ),
    );
  }
}

/* ===================== PNEUMONIA CARD ===================== */

class _MainCard extends StatelessWidget {
  final User loggedInUser;
  const _MainCard({super.key, required this.loggedInUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ❤️ LOTTIE (LEFT CORNER)
          Positioned(
            top: 240,
            left: 12,
            child: Lottie.asset(
              "assets/lottie/Covid Icon _ Pneumonia.json",
              height: 100,
              repeat: true,
            ),
          ),

          // 📄 CONTENT
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                const Text.rich(
                  TextSpan(
                    text: "Let's check your\n",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: "lung health",
                        style: TextStyle(color: Color(0xFFE655A8)),
                      ),
                      TextSpan(text: " today."),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEEF5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Lottie.asset(
                            "assets/lottie/Lungs.json",
                            repeat: true,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Pneumonia Detection",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFEEF5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "AI Powered",
                        style: TextStyle(
                          color: Color(0xFFE655A8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                const Text(
                  "Upload chest X-ray for instant analysis and early detection.",
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 16),

                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PneumoniaDetectPage(loggedInUser: loggedInUser),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFFE655A8),
                      ), // Pink border
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.upload_file,
                          color: Colors.pink, // Pink icon
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Detect\nPneumonia",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink, // Pink text
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ===================== TB CARD ===================== */

class _TBCard extends StatelessWidget {
  final User loggedInUser;
  const _TBCard({super.key, required this.loggedInUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Tuberculosis",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Detailed screening process for TB signs.",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TuberculosisDetectPage(loggedInUser: loggedInUser),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.pink),
                  ),
                  child: const Text(
                    "Detect TB",
                    style: TextStyle(color: Colors.pink),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              "assets/xray_holding.jpeg",
              height: 90,
              width: 90,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
/* -------------------- Prediction Model -------------------- */
class Prediction {
  final String diseaseName;
  final String predictionResult;
  final DateTime predictedAt;

  Prediction({
    required this.diseaseName,
    required this.predictionResult,
    required this.predictedAt,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      diseaseName: json['diseaseName'] ?? 'Unknown',
      predictionResult: json['predictionResult'] ?? 'Unknown',
      predictedAt: DateTime.parse(json['predictedAt']),
    );
  }
}
class RecentActivity extends StatefulWidget {
  final User loggedInUser;

  const RecentActivity({super.key, required this.loggedInUser});

  @override
  State<RecentActivity> createState() => _RecentActivityState();
}

class _RecentActivityState extends State<RecentActivity> {

  Key _futureKey = UniqueKey(); // used to refresh FutureBuilder

  Future<List<Prediction>> fetchPredictions() async {
    final response = await http.get(
      Uri.parse('http://10.10.1.149:1052/api/history/${widget.loggedInUser.id}'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      List<Prediction> predictions =
          data.map((e) => Prediction.fromJson(e)).toList();

      predictions.sort(
          (a, b) => b.predictedAt.compareTo(a.predictedAt));

      return predictions;
    } else {
      throw Exception('Failed to fetch predictions');
    }
  }

  void _refresh() {
    setState(() {
      _futureKey = UniqueKey(); // rebuilds FutureBuilder
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Prediction>>(
      key: _futureKey, // important
      future: fetchPredictions(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final predictions = snapshot.data ?? [];
        final lastThree = predictions.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ================= HEADER =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recent Activity",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),

                Row(
                  children: [

                    // 🔄 REFRESH ICON
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _refresh,
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecentPage(
                                loggedInUser:
                                    widget.loggedInUser),
                          ),
                        );
                      },
                      child: const Text(
                        "See All",
                        style: TextStyle(
                            color: Color(0xFFE655A8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ================= TILES =================
            ...lastThree.map((prediction) {

              bool success = false;

              if (prediction.diseaseName
                      .toLowerCase() ==
                  "pneumonia") {
                success = prediction
                        .predictionResult
                        .toLowerCase() ==
                    "no pneumonia";
              } else if (prediction
                      .diseaseName
                      .toLowerCase() ==
                  "tuberculosis") {
                success = prediction
                        .predictionResult
                        .toLowerCase() ==
                    "healthy";
              }

              final String formattedTime =
                  DateFormat('MMM d, h:mm a')
                      .format(prediction.predictedAt);

              return Padding(
                padding: const EdgeInsets.only(
                    bottom: 10),
                child: _ActivityTile(
                  title: prediction.diseaseName,
                  subtitle: formattedTime,
                  status:
                      prediction.predictionResult,
                  success: success,
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}

/* -------------------- Activity Tile -------------------- */
class _ActivityTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final bool success;

  const _ActivityTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.success,
  });

  @override
  Widget build(BuildContext context) {
    const pink = Color(0xFFE655A8);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: success ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: pink.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: success ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
            child: Icon(
              success ? Icons.check_circle : Icons.medical_services,
              color: success ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Text(status,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: success ? Colors.green : Colors.red)),
        ],
      ),
    );
  }
}

/* ===================== BOTTOM NAV ===================== */

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final User loggedInUser; // Pass this to DashboardPage or RecentPage

  const _BottomNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.loggedInUser,
  });

  @override
  Widget build(BuildContext context) {
    // Check if Recent tab is selected
    final isRecentSelected = currentIndex == 1;

    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: isRecentSelected
            ? [
                _navIcon(Icons.home_rounded, () {
                  onTap(0);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DashboardPage(loggedInUser: loggedInUser),
                    ),
                  );
                }),
                _navIcon(Icons.chat_bubble_rounded, () {
                  onTap(5); // mark active
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => ChatbotPage(loggedInUser: loggedInUser)),
                  );
                }),
                _navIcon(Icons.settings_rounded, () {
                  onTap(4);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) =>  SettingsPage(loggedInUser: loggedInUser)),
                  );
                }),
              ]
            : [
                _navIcon(Icons.home_rounded, () {
                  onTap(0);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DashboardPage(loggedInUser: loggedInUser),
                    ),
                  );
                }),
                _navIcon(Icons.history_rounded, () {
                  onTap(1);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecentPage(loggedInUser: loggedInUser),
                    ),
                  );
                }),
                _navIcon(Icons.chat_bubble_rounded, () {
                  onTap(5); // mark active
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => ChatbotPage(loggedInUser: loggedInUser)),
                  );
                }),
                _navIcon(Icons.settings_rounded, () {
                  onTap(4);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) =>  SettingsPage(loggedInUser: loggedInUser)),
                  );
                }),
              ],
      ),
    );
  }

  Widget _navIcon(IconData icon, VoidCallback onTapAction) {
    return GestureDetector(
      onTap: onTapAction,
      child: Icon(icon, size: 26, color: Colors.grey),
    );
  }
}
  