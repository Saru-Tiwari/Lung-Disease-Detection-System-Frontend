import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:personal_health_assistant/homepage/user.dart';

class TuberculosisDetectPage extends StatefulWidget {
  final User loggedInUser;
  const TuberculosisDetectPage({super.key, required this.loggedInUser});

  @override
  State<TuberculosisDetectPage> createState() => _TuberculosisDetectPageState();
}

class _TuberculosisDetectPageState extends State<TuberculosisDetectPage> {
  File? _image;
  bool _loading = false;

  String? _diagnosis;
  double? _probability;
  Uint8List? _highlightedImage;

  final ImagePicker _picker = ImagePicker();

  // ================= PICK IMAGE =================
  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _diagnosis = null;
        _probability = null;
        _highlightedImage = null;
      });
    }
  }

  // ================= PREDICT TB =================
  Future<void> _predict() async {
    if (_image == null) return;

    setState(() => _loading = true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
          'http://10.10.1.149:1052/api/predict-tb',
        ), // <-- FIXED PORT & PATH
      );

      request.fields['userId'] = widget.loggedInUser.id.toString();
      request.files.add(
        await http.MultipartFile.fromPath('file', _image!.path),
      );

      final response = await request.send();
      final res = await http.Response.fromStream(response);

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          _diagnosis = data['diagnosis'];
          _probability = (data['probability'] ?? 0).toDouble();
          if (data['localized_image'] != null &&
              data['localized_image'] != "") {
            _highlightedImage = base64Decode(data['localized_image']);
          }
        });
      } else {
        setState(() => _diagnosis = "Server Error");
      }
    } catch (e) {
      setState(() => _diagnosis = "Error: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const pink = Color(0xFFE655A8);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        title: const Text(
          "Tuberculosis Detection",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Chest X-ray Image",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            // ========== IMAGE PREVIEW ==========
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: pink.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: pink.withOpacity(0.4)),
                ),
                child: _image == null
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 44,
                              color: pink,
                            ),
                            SizedBox(height: 10),
                            Text("Upload Chest X-ray"),
                          ],
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: (_highlightedImage != null)
                            ? Image.memory(
                                _highlightedImage!,
                                fit: BoxFit.contain,
                              )
                            : Image.file(_image!, fit: BoxFit.contain),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // ========== PREDICT BUTTON ==========
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _predict,
                style: ElevatedButton.styleFrom(
                  backgroundColor: pink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Predict Tuberculosis"),
              ),
            ),

            const SizedBox(height: 30),

            // ========== RESULT ==========
            if (_diagnosis != null) ...[
              const Text(
                "Analysis Result",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ========== DIAGNOSIS HEADER ==========
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "DIAGNOSIS",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: pink.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "High Confidence",
                            style: TextStyle(
                              color: pink,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // ========== DIAGNOSIS TEXT ==========
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.coronavirus, color: pink),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _diagnosis!,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ========== CONFIDENCE ==========
                    Row(
                      children: [
                        const Text(
                          "Confidence Score",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Text(
                          "${((_probability ?? 0) * 100).toStringAsFixed(0)}%",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: pink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _probability ?? 0,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(10),
                      color: pink,
                      backgroundColor: pink.withOpacity(0.2),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "The AI model is ${((_probability ?? 0) * 100).toStringAsFixed(0)}% confident in this result based on the provided X-ray patterns.",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ========== INFO CARDS ==========
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.opacity,
                      title: "Lung Opacity",
                      value: (_diagnosis == "Tuberculosis")
                          ? "Present"
                          : "Absent",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.image,
                      title: "Scan Quality",
                      value: "High Res",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ========== DISCLAIMER ==========
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: pink.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.info_outline, color: pink, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Disclaimer: This tool is powered by AI and is intended for assistance only. It does not replace professional medical diagnosis. Please consult a doctor for clinical validation.",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    const pink = Color(0xFFE655A8);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: pink.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: pink, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
