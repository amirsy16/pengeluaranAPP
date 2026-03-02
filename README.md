<div align="center">

<img src="public/mylogo.png" alt="Wolftrack Logo" width="100" height="100" style="border-radius: 20px;" />

# 💸 Expense Tracker

**A clean & beautiful personal finance tracker built with Flutter**

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Hive](https://img.shields.io/badge/Hive-Local%20DB-FF7043?style=for-the-badge&logo=hive&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

</div>

---

## ✨ Features

- 📊 **Dashboard** — Quick overview of your balance, income & expenses
- ➕ **Add Transactions** — Log income or expenses with category, amount & notes
- 📈 **Charts** — Visual breakdown of your spending habits with fl_chart
- 🗂️ **Transaction History** — Browse and filter all your transactions
- 🗑️ **Delete Transactions** — Remove individual entries with ease
- 🔄 **Reset Data** — Clear all income & expense data with one tap
- 💾 **Local Storage** — All data stored offline using Hive (no internet needed)
- 🤖 **Smart Receipt Scan** — Auto-extract transaction details from receipts using Gemini AI
- 🎨 **Material Design 3** — Clean, modern UI with smooth animations
- 🖼️ **Custom Logo** — Personalized branding on the dashboard

---

## 📱 Screenshots

> _Coming soon — run the app to see it in action._

---

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| [Flutter](https://flutter.dev) | UI Framework |
| [Dart](https://dart.dev) | Programming Language |
| [Hive](https://pub.dev/packages/hive) | Local NoSQL Database |
| [Provider](https://pub.dev/packages/provider) | State Management |
| [fl_chart](https://pub.dev/packages/fl_chart) | Charts & Graphs |
| [intl](https://pub.dev/packages/intl) | Currency & Date Formatting |
| [uuid](https://pub.dev/packages/uuid) | Unique Transaction IDs |
| [google_generative_ai](https://pub.dev/packages/google_generative_ai) | AI processing with Gemini |
| [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) | Environment configuration |

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   ├── transaction_model.dart   # Transaction data model
│   └── transaction_model.g.dart # Hive generated adapter
├── providers/
│   └── transaction_provider.dart # State management
├── screens/
│   ├── home_screen.dart         # Bottom navigation shell
│   ├── dashboard_screen.dart    # Main dashboard
│   ├── transactions_screen.dart # All transactions list
│   ├── charts_screen.dart       # Analytics & charts
│   └── add_transaction_screen.dart # Add new transaction
├── services/
│   ├── hive_service.dart        # Hive DB initialization
│   └── gemini_service.dart      # AI Receipt Scanning Service
├── theme/
│   └── app_theme.dart           # App theme & colors
└── widgets/
    ├── balance_card.dart        # Balance summary card
    ├── transaction_tile.dart    # Transaction list item
    └── empty_state.dart         # Empty state widget
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) `>=3.0.0`
- Android Studio / VS Code
- Android device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/amirsy16/pengeluaranAPP.git
   cd expense_tracker
   ```

2. **Set up Environment Variables**
   
   Create a `.env` file in the root directory and add your Gemini API Key:
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env`:
   ```env
   GEMINI_API_KEY=your_api_key_here
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Generate Hive adapters** _(if needed)_
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

---

## 🎨 Color Palette

| Color | Hex | Usage |
|---|---|---|
| 🟣 Primary | `#6750A4` | Brand color, buttons |
| 🟢 Income | `#06D6A0` | Income indicators |
| 🔴 Expense | `#FF6B6B` | Expense indicators |

---

## 📦 Dependencies

```yaml
dependencies:
  flutter_sdk
  hive: ^2.2.3          # Local database
  hive_flutter: ^1.1.0  # Flutter Hive integration
  provider: ^6.1.2      # State management
  fl_chart: ^0.69.0     # Charts
  intl: ^0.19.0         # Formatting
  uuid: ^4.5.1          # ID generation
  google_generative_ai: # Gemini AI SDK
  flutter_dotenv:       # Env variables
  image_picker:         # Camera & Gallery access
```

---

## 🤝 Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

Made with ❤️ using Flutter

⭐ **Star this repo if you found it helpful!**

</div>
