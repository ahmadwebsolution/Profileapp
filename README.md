# Profile App 📱

A Flutter application built with Firebase that allows users to authenticate, manage their profiles, upload profile pictures, and create and manage personal notes in real time.

## ✨ Features

### 🔐 Authentication
- Email and Password Sign Up
- Email and Password Login
- Google Sign-In
- Authentication State Management
- Login and Logout Functionality

### 👤 User Profile
- Display User Profile Information
- Upload Profile Picture
- Store Images in Firebase Cloud Storage
- Save Profile Picture URL in Cloud Firestore

### 📝 Notes Management
- Create Notes
- Read and Display Notes
- Update Existing Notes
- Delete Notes
- Real-Time Firestore Updates
- Query and Filter Notes

### 🔒 Security
- Firebase Authentication
- Cloud Firestore Security Rules
- Firebase Storage Security Rules
- Restrict User Data Access to Authorized Users

## 🛠️ Tech Stack

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Firebase Cloud Storage
- Firebase Cloud Messaging (FCM)

## 🚀 Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or a compatible IDE
- Firebase Account

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/ahmadwebsolution/Profileapp.git
   ```

2. Open the project directory:

   ```bash
   cd Profileapp
   ```

3. Install dependencies:

   ```bash
   flutter pub get
   ```

4. Configure Firebase for your Flutter application:

   ```bash
   flutterfire configure
   ```

5. Enable Email/Password authentication and Google Sign-In in the Firebase Console.

6. Configure Cloud Firestore and Firebase Storage.

7. Run the application:

   ```bash
   flutter run
   ```

## 📂 Project Structure

```text
lib/
├── main.dart
├── models/
├── services/
├── providers/
├── screens/
└── widgets/
```

*The folder structure may vary depending on the actual project implementation.*

## 🎯 Learning Objectives

- Integrating Firebase with Flutter
- Implementing authentication flows
- Performing Firestore CRUD operations
- Uploading images using Firebase Storage
- Managing real-time data
- Implementing Firebase security rules

## 👨‍💻 Developer

Developed as a hands-on Flutter and Firebase learning assignment.

## 📄 License

For learning and educational purposes.
