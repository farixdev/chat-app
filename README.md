<div align="center">

# 💬 Flutter Firebase Chat

**A modern real-time chat application built with Flutter & Firebase — fast, secure, and fully cross-platform.**

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=flat-square&logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat-square&logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Web-brightgreen?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)

</div>

---

## 📖 Overview

A clean, production-ready chat application demonstrating real-time messaging, user authentication, and cloud database integration using Flutter and Firebase. Built with clean architecture principles and a fully responsive UI that adapts seamlessly across Android, iOS, tablets, and web.

---

## ✨ Features

### 👤 User
- Email registration and login via Firebase Auth
- User profile management
- Online / offline status indicator
- Smooth navigation and animations

### 💬 Messaging
- Real-time one-to-one chat
- Message timestamps
- Instant message delivery via Cloud Firestore

### 🎨 UI & Design
- Responsive layout across all screen sizes
- Adaptive widgets for mobile, tablet, and web
- Clean, modern dark-friendly interface

### 🔒 Security
- Firebase Authentication for secure access
- Cloud-based data storage with Firestore rules

---

## 🔥 Firebase Services

| Service | Usage |
|---------|-------|
| Firebase Authentication | User login & registration |
| Cloud Firestore | Real-time message storage |
| Firebase Storage | Media and file uploads |
| Firebase Realtime Database | Live presence & online status |
| Firebase Cloud Messaging | Push notifications *(optional)* |

---

## 📱 Platform Support

| Platform | Supported |
|----------|-----------|
| Android | ✅ |
| iOS | ✅ |
| Tablet | ✅ |
| Web | ✅ |

---

## 🚀 Installation

### Prerequisites

- Flutter SDK `3.0+`
- Dart `2.17+`
- Firebase project set up at [console.firebase.google.com](https://console.firebase.google.com)

### Setup

```bash
# 1. Clone the repository
git clone https://github.com/farixdev/your-repo-name.git
cd your-repo-name

# 2. Install dependencies
flutter pub get

# 3. Configure Firebase
# Add your google-services.json (Android) and GoogleService-Info.plist (iOS)
# to the respective platform folders

# 4. Run the app
flutter run
```

---

## 📁 Project Structure

```
lib/
├── models/             # Data models (User, Message, etc.)
├── screens/            # App screens and pages
├── services/           # Firebase service logic
├── widgets/            # Reusable UI components
├── utils/              # Helper functions and constants
├── controllers/        # State and business logic
├── firebase/           # Firebase configuration
└── main.dart           # Entry point
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter |
| Language | Dart |
| Authentication | Firebase Auth |
| Database | Cloud Firestore |
| Realtime Sync | Firebase Realtime Database |
| Storage | Firebase Storage |
| Notifications | Firebase Cloud Messaging |

---

## 🤝 Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request.

---

## 📜 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

## 👤 Author

Made with 🖤 by **[Farisxdev](https://github.com/farixdev)**

---

<div align="center">

Found this useful? Drop a ⭐ on GitHub — it helps a lot!

</div>
