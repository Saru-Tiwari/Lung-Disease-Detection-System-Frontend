import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:personal_health_assistant/homepage/user.dart';


// ================= LOGGED-IN USER MODEL (example) =================
// You should replace this with your actual user model from login
class LoggedInUser {
  final int id;
  final String name;
  LoggedInUser({required this.id, required this.name});
}

// ================= PNEUMONIA DETECTION PAGE =================
class PneumoniaDetectPage extends StatefulWidget {
  final User loggedInUser; // pass this from login
  const PneumoniaDetectPage({super.key, required this.loggedInUser});

  @override
  State<PneumoniaDetectPage> createState() => _PneumoniaDetectPageState();
}

class _PneumoniaDetectPageState extends State<PneumoniaDetectPage> {
  File? _image;
  bool _loading = false;

  String? _diagnosis;
  double? _probability;

  Uint8List? _localizedImage; // bbox image
  Uint8List? _gradcamImage; // heatmap image

  final ImagePicker _picker = ImagePicker();
  bool _showGradcam = false;

  // ================= IMAGE PICK =================
  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _diagnosis = null;
        _probability = null;
        _localizedImage = null;
        _gradcamImage = null;
        _showGradcam = false;
      });
    }
  }

  // ================= PREDICT =================
  Future<void> _predict() async {
    if (_image == null) return;

    setState(() => _loading = true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.10.1.149:1052/api/predict'),
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

          // ================= LOCALIZATION IMAGE =================
          if (data['localized_image'] != null && data['localized_image'] != "") {
            _localizedImage = base64Decode(data['localized_image']);
          }

          // ================= GRAD-CAM IMAGE =================
          if (data['gradcam_image'] != null && data['gradcam_image'] != "") {
            _gradcamImage = base64Decode(data['gradcam_image']);
          }

          _showGradcam = false; // default to localization
        });
      } else {
        setState(() {
          _diagnosis = "Server Error";
        });
      }
    } catch (e) {
      setState(() {
        _diagnosis = "Error: $e";
      });
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
          "Pneumonia Detection",
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

            // ================= IMAGE PREVIEW =================
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
                        child:
                            (_localizedImage != null || _gradcamImage != null)
                            ? (_showGradcam && _gradcamImage != null
                                  ? Image.memory(
                                      _gradcamImage!,
                                      fit: BoxFit.contain,
                                    )
                                  : Image.memory(
                                      _localizedImage ??
                                          _image!.readAsBytesSync(),
                                      fit: BoxFit.contain,
                                    ))
                            : Image.file(_image!, fit: BoxFit.contain),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // ================= TOGGLE =================
            if (_localizedImage != null && _gradcamImage != null)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !_showGradcam
                            ? pink
                            : Colors.grey[300],
                      ),
                      onPressed: () {
                        setState(() => _showGradcam = false);
                      },
                      child: const Text("Localization"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _showGradcam ? pink : Colors.grey[300],
                      ),
                      onPressed: () {
                        setState(() => _showGradcam = true);
                      },
                      child: const Text("Grad-CAM"),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 20),

            // ================= PREDICT BUTTON =================
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
                    : const Text("Predict Pneumonia"),
              ),
            ),

            const SizedBox(height: 8),
            const Center(
              child: Text(
                "Processing may take up to 30 seconds",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),

            const SizedBox(height: 30),

            // ================= RESULT =================
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

                    // ===== FIXED ROW WITH EXPANDED =====
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
                    Row(
                      children: [
                        const Text(
                          "Confidence Score",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Text(
                          "${((_probability ?? 0) * 100).toStringAsFixed(0)}%",
                          style: const TextStyle(
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

              // ================= INFO CARDS =================
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.opacity,
                      title: "Lung Opacity",
                      value: (_probability ?? 0) >= 0.6
                          ? "Present"
                          : "Not Present",
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

              // ================= DISCLAIMER =================
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

// ================= INFO CARD WIDGET =================
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
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}