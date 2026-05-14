import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:personal_health_assistant/homepage/user.dart';
import 'package:personal_health_assistant/homepage/dashboard_page.dart';

// ================= PREDICTION MODEL =================
class Prediction {
  final int id;
  final String diseaseName;
  final String predictionResult;
  final DateTime predictedAt;

  Prediction({
    required this.id,
    required this.diseaseName,
    required this.predictionResult,
    required this.predictedAt,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      diseaseName: json['diseaseName'] ?? json['disease_name'] ?? '',
      predictionResult:
          json['predictionResult'] ?? json['prediction_result'] ?? '',
      predictedAt: DateTime.parse(
        json['predictedAt'] ??
            json['predicted_at'] ??
            DateTime.now().toIso8601String(),
      ),
    );
  }
}

// ================= RECENT HISTORY PAGE =================
class RecentPage extends StatefulWidget {
  final User loggedInUser;

  const RecentPage({super.key, required this.loggedInUser});

  @override
  State<RecentPage> createState() => _RecentPageState();
}

class _RecentPageState extends State<RecentPage> {
  late Future<List<Prediction>> futurePredictions;

  @override
  void initState() {
    super.initState();
    futurePredictions = fetchPredictions();
  }

  // ================= FETCH PREDICTIONS =================
  Future<List<Prediction>> fetchPredictions() async {
    final response = await http.get(
      Uri.parse(
          'http://10.10.1.149:1052/api/history/${widget.loggedInUser.id}'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      List<Prediction> predictions =
          data.map((e) => Prediction.fromJson(e)).toList();

      predictions.sort((a, b) => b.predictedAt.compareTo(a.predictedAt));
      return predictions;
    } else {
      throw Exception('Failed to fetch predictions');
    }
  }

  // ================= DELETE PREDICTION =================
  Future<void> deletePrediction(int id) async {
    final response = await http.delete(
      Uri.parse('http://10.10.1.149:1052/api/history/$id'),
    );

    if (response.statusCode == 200) {
      setState(() {
        futurePredictions = fetchPredictions();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("History deleted successfully"),
          backgroundColor: Color(0xFFE655A8),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to delete history"),
          backgroundColor: Color(0xFFE655A8),
        ),
      );
    }
  }

  void confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete History"),
        content: const Text("Are you sure you want to delete this record?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE655A8),
              foregroundColor: Colors.white
            ),
            onPressed: () {
              Navigator.pop(context);
              deletePrediction(id);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const pink = Color(0xFFE655A8);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: pink,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    DashboardPage(loggedInUser: widget.loggedInUser),
              ),
            );
          },
        ),
        title: const Text(
          "Recent History",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: FutureBuilder<List<Prediction>>(
        future: futurePredictions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: pink),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Something went wrong",
                  style: TextStyle(color: Colors.grey)),
            );
          }

          final predictions = snapshot.data ?? [];

          if (predictions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 60, color: pink),
                  SizedBox(height: 12),
                  Text("No history available",
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: predictions.length,
            itemBuilder: (context, index) {
              final prediction = predictions[index];

              // ================= HANDLE GREEN/RED LOGIC =================
              bool isHealthy = false;

              // Pneumonia: "No Pneumonia" = healthy (green)
              if (prediction.diseaseName.toLowerCase() == "pneumonia") {
                isHealthy = prediction.predictionResult.toLowerCase() == "no pneumonia";
              }
              // Tuberculosis: "Negative" = healthy (green)
              else if (prediction.diseaseName.toLowerCase() == "tuberculosis") {
                isHealthy = prediction.predictionResult.toLowerCase() == "healthy";
              }

              final Color avatarBgColor =
                  isHealthy ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1);
              final IconData avatarIcon =
                  isHealthy ? Icons.check_circle : Icons.medical_services;
              final Color avatarIconColor = isHealthy ? Colors.green : Colors.red;

              final String formattedTime =
                  DateFormat('MMM d, yyyy • h:mm a').format(prediction.predictedAt);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: pink.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: avatarBgColor,
                      child: Icon(
                        avatarIcon,
                        color: avatarIconColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${prediction.diseaseName}: ${prediction.predictionResult}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            formattedTime,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.pinkAccent),
                      onPressed: () => confirmDelete(prediction.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}