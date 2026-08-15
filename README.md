# 🫁 Lung Disease Detection System — Flutter Frontend

> **A Flutter-based mobile interface for an AI-powered chest X-ray analysis system for Pneumonia and Tuberculosis detection, localization, and explainable prediction.**

This repository contains the **Flutter frontend** of the Lung Disease Detection System.

The application provides a mobile interface through which users can select chest X-ray images, submit them to a **Flask-based AI backend**, and visualize the resulting disease prediction, confidence score, and localization/explainability output.

The deep learning models, training pipeline, datasets, and backend implementation are maintained separately.

---

## 🔬 Project Overview

The complete system combines:

```text
┌──────────────────────────┐
│     Flutter Frontend     │
│                          │
│ • X-Ray Selection        │
│ • Image Preview          │
│ • API Communication      │
│ • Prediction UI          │
│ • Result Visualization   │
└─────────────┬────────────┘
              │
              │ HTTP / REST API
              ▼
┌──────────────────────────┐
│      Flask Backend       │
│                          │
│ • Image Preprocessing    │
│ • Model Inference        │
│ • Disease Prediction     │
│ • Localization           │
│ • Grad-CAM               │
└─────────────┬────────────┘
              │
              ▼
┌──────────────────────────┐
│    Deep Learning Models  │
│                          │
│ • DenseNet121            │
│ • ResNet50-U-Net         │
│ • MobileNetV2-U-Net      │
└──────────────────────────┘
```

The frontend is designed to make the research models accessible through a simple mobile workflow.

---

# 🎯 Objectives

The Flutter application was developed to:

* Provide a simple interface for chest X-ray analysis
* Allow users to select X-ray images from a mobile device
* Communicate with the AI backend through REST APIs
* Display model predictions in an understandable format
* Display prediction confidence
* Present localization results
* Present explainability visualizations such as Grad-CAM
* Provide a foundation for future mobile/edge AI deployment

---

# 🧠 AI System

The Flutter application is the client layer of a larger AI system.

The backend currently supports research involving:

* 🫁 Pneumonia detection
* 🦠 Tuberculosis detection
* 🎯 Abnormality localization
* 🔥 Grad-CAM explainability
* 🧠 CNN-based image classification

### Deep Learning Models

The backend/research component includes models such as:

* **DenseNet121**
* **ResNet50-U-Net**
* **MobileNetV2-U-Net**

The frontend does **not** train these models. Instead, it communicates with the trained models through the Flask API.

---

# 📱 Application Workflow

The application follows the following workflow:

```text
Launch Application
       │
       ▼
Select Chest X-Ray
       │
       ▼
Preview Image
       │
       ▼
Send Image to Backend
       │
       ▼
Flask API
       │
       ▼
Deep Learning Inference
       │
       ▼
Receive JSON Response
       │
       ▼
Display Prediction
       │
       ├───────────────┐
       ▼               ▼
 Confidence       Localization
                       │
                       ▼
                 Grad-CAM /
                Visual Output
```

---

# ✨ Features

## 🩻 Chest X-Ray Upload

Users can select a chest X-ray image from their mobile device.

The frontend handles:

* Image selection
* Image preview
* Image validation
* Upload preparation

---

## 🤖 AI Prediction

The selected X-ray is sent to the Flask backend for inference.

The backend returns the model prediction, which is then displayed by the Flutter application.

Example:

```text
Prediction
──────────────
Pneumonia

Confidence
──────────────
94%
```

---

## 🎯 Localization

When localization information is returned by the backend, the application can visualize the relevant region of the X-ray.

This allows the application to present more information than a simple classification label.

---

## 🔥 Explainable AI Visualization

The system supports visualization of model explanations such as **Grad-CAM**.

Conceptually:

```text
Original X-Ray
      │
      ▼
AI Model
      │
      ▼
Prediction
      │
      ▼
Grad-CAM
      │
      ▼
Heatmap Visualization
      │
      ▼
Flutter Result Screen
```

This helps communicate which image regions contributed to the model prediction.

> Grad-CAM visualizations are intended for model interpretation and research purposes and should not be treated as clinical evidence.

---

# 🏗️ Frontend Architecture

The Flutter frontend follows a client-side architecture in which the application is responsible for presentation, user interaction, and communication with the AI API.

```text
┌─────────────────────────────────────┐
│              Flutter                │
│                                     │
│  Presentation Layer                 │
│  ├── Home Screen                    │
│  ├── Image Selection                │
│  ├── Image Preview                  │
│  └── Result Screen                  │
│                                     │
│  API / Service Layer                │
│  ├── HTTP Requests                  │
│  ├── Image Upload                   │
│  └── Response Handling              │
│                                     │
│  Data / Result Handling             │
│  ├── Prediction                     │
│  ├── Confidence                     │
│  └── Localization / Heatmap         │
└─────────────────┬───────────────────┘
                  │
                  │ REST API
                  ▼
          ┌───────────────┐
          │ Flask Backend │
          └───────────────┘
```

---

# 🌐 Backend Integration

The frontend communicates with a separate Flask backend.

### Communication

```text
Flutter
   │
   │ POST image
   ▼
Flask API
   │
   │ Model inference
   ▼
TensorFlow / Keras
   │
   │ Prediction
   ▼
Flask API
   │
   │ JSON response
   ▼
Flutter
```

### Example Request

```http
POST /predict
Content-Type: multipart/form-data
```

The image is sent to the backend as a multipart file.

### Example Response

```json
{
  "prediction": "Pneumonia",
  "confidence": 0.94
}
```

The exact API endpoint and response format depend on the backend implementation.

---

# 🔗 Related Repositories

The complete project is divided into separate components.

### 🧠 AI / Backend Repository

The backend contains:

* Flask API
* Deep learning inference
* Model loading
* Image preprocessing
* Prediction
* Localization
* Grad-CAM
* AI experimentation

➡️ **Backend Repository:** `YOUR_BACKEND_REPOSITORY_LINK`

### 📱 Flutter Frontend

This repository contains:

* Flutter UI
* Image selection
* API integration
* Result presentation
* Prediction visualization
* Mobile application logic

---

# 🛠️ Technology Stack

## Frontend

* **Flutter**
* **Dart**

## Backend Integration

* REST API
* HTTP
* JSON
* Multipart image upload

## AI Backend

* Python
* Flask
* TensorFlow
* Keras
* OpenCV
* NumPy

## AI Models

* DenseNet121
* ResNet50
* MobileNetV2
* U-Net
* Grad-CAM

---

# 📦 Flutter Dependencies

The project may use packages such as:

```yaml
dependencies:
  flutter:
    sdk: flutter

  http:
  image_picker:
```

Additional dependencies should be listed according to the actual `pubspec.yaml`.

Install dependencies with:

```bash
flutter pub get
```

---

# ⚙️ Requirements

Before running the application, install:

* Flutter SDK
* Dart SDK
* Android Studio or another Flutter-supported IDE
* Android SDK / emulator or physical Android device
* Git

Verify the Flutter installation:

```bash
flutter doctor
```

---

# 🚀 Installation

## 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/YOUR_FRONTEND_REPOSITORY.git
```

Navigate into the project:

```bash
cd YOUR_FRONTEND_REPOSITORY
```

---

## 2. Install Dependencies

```bash
flutter pub get
```

---

## 3. Configure Backend URL

The Flutter application must point to the running Flask backend.

For example:

```dart
const String baseUrl = "http://YOUR_BACKEND_IP:5000";
```

For Android emulator testing, the backend may need a different host address depending on the development environment.

For a physical device, the phone and development machine generally need to be able to communicate over the same network when using a local backend.

> Do not hard-code production credentials or private API keys into the Flutter application.

---

# ▶️ Run the Application

Connect an Android device or start an emulator.

Then execute:

```bash
flutter run
```

The application should launch on the selected device.

---


# 🎨 User Interface Flow

The application is designed around a simple workflow:

### Step 1 — Select Image

The user selects a chest X-ray from the device.

### Step 2 — Preview

The selected image is displayed before submission.

### Step 3 — Analyze

The image is uploaded to the Flask API.

### Step 4 — AI Inference

The backend performs preprocessing and deep learning inference.

### Step 5 — Display Results

The Flutter application receives the response and displays:

* Predicted disease
* Confidence
* Localization
* Explainability visualization

---

# 📊 Example Result
<img width="1344" height="2992" alt="d2c2870c86f634a199332765848c30ad" src="https://github.com/user-attachments/assets/a9065282-5471-4409-b5b7-7cc9fcb870d4" />


# 📁 Project Structure

The exact structure may vary, but a recommended organization is:

```text
lung-disease-flutter/
│
├── android/
│
├── ios/
│
├── lib/
│   │
│   ├── main.dart
│   │
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── upload_screen.dart
│   │   └── result_screen.dart
│   │
│   ├── services/
│   │   └── api_service.dart
│   │
│   ├── models/
│   │   └── prediction.dart
│   │
│   ├── widgets/
│   │   ├── image_preview.dart
│   │   └── result_card.dart
│   │
│   └── utils/
│
├── assets/
│   └── images/
│
├── screenshots/
│
├── test/
│
├── pubspec.yaml
└── README.md
```

---

# 🧪 Testing

The frontend should be tested for:

* Image selection
* Invalid image handling
* API connectivity
* Backend errors
* Empty responses
* Prediction rendering
* Localization rendering
* Different screen sizes

# 🔐 Error Handling

The application should gracefully handle cases such as:

```text
No Internet Connection
        ↓
Connection Error Message

Backend Unavailable
        ↓
Server Error Message

Invalid Image
        ↓
Validation Message

Invalid API Response
        ↓
Unexpected Response Message
```

This prevents backend failures from causing unexpected application behavior.

---

# 🚀 Future Improvements

Potential frontend improvements include:

### 🎨 UI/UX

* Improved medical image viewer
* Interactive heatmap overlay
* Zoom and pan
* Side-by-side X-ray comparison
* Prediction history
* Improved accessibility

### 🔬 Research Visualization

* Confidence visualization
* Multiple model comparison
* Grad-CAM overlay controls
* Localization mask visualization

### 🌐 Production Architecture

* HTTPS
* Authentication
* Secure API communication
* Cloud deployment
* Backend monitoring
* Request logging

---

# 🔬 Research Relevance

Although this repository focuses on the **Flutter frontend**, it is part of a broader research-oriented medical AI system involving:

* Computer Vision
* Deep Learning
* Medical Image Analysis
* Healthcare AI
* Explainable AI
* Model Localization
* Mobile AI
* AI-assisted diagnostic research

The frontend demonstrates the integration of research models into an end-to-end usable application.

---

# ⚠️ Limitations

This application is currently intended for:

* Research
* Education
* Demonstration
* Experimental development

It is **not a clinical diagnostic tool**.

The predictions generated by the AI backend should not be used for medical diagnosis or treatment decisions.

The system has not been clinically validated or approved for medical use.

---

# 🩺 Medical Disclaimer

> **Important:** This application is a research and educational prototype. AI-generated predictions may contain errors and should not be considered professional medical advice, diagnosis, or treatment recommendations. Any suspected medical condition should be evaluated by a qualified healthcare professional.

---

# 👨‍💻 Author

## Saru Tiwari

**Computer Engineering | AI/ML | Computer Vision**

### Research Interests

* Artificial Intelligence
* Machine Learning
* Deep Learning
* Computer Vision
* Medical Image Analysis
* Explainable AI
* Healthcare AI
* Data Science


