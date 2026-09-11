# APP_NAME_PLACEHOLDER

A production-ready, highly scalable Flutter template implementing the **MVVM (Model-View-ViewModel)** architecture pattern. This project serves as a robust base for building cross-platform mobile apps with built-in state management, networking, themes, responsive layouts, and localization.

---

## 🚀 Key Features

*   **Architecture**: Structured clean MVVM pattern separating UI logic (Views) from business logic (ViewModels) and data layers (Models).
*   **State Management**: Configured with `provider` for clean and lightweight state propagation.
*   **Networking**: Pre-configured HTTP client using `dio` with custom interceptors for request/response logging, token handling, and robust error management.
*   **Responsive UI**: Integrated with `flutter_screenutil` and `responsive_framework` to automatically scale across phones, tablets, and desktops.
*   **Dynamic Theme**: Built-in dark/light mode toggle utilizing `adaptive_theme`.
*   **Localization**: Multi-language support out of the box using Flutter's native `l10n` tool.
*   **Secure Storage**: Local data persistence configured with `shared_preferences` and encrypted `flutter_secure_storage`.
*   **CI/CD Ready**: Configured with a one-click automated bootstrapper to generate new projects from this template.

---

## 📂 Project Structure

The codebase is organized logically into specific directories to isolate responsibilities:

```text
lib/
├── config/             # App configs, routes, and environment properties
├── features/           # UI features containing Views and ViewModels (e.g. splashscreen)
│   └── feature_name/
│       ├── view/       # UI Screens / Widgets
│       └── view_model/ # Feature-specific business logic
├── models/             # Data models and JSON serializers
├── providers/          # Global application state providers
├── services/           # Network API, databases, and third-party service abstractions
├── utils/              # UI theme configs, styles, colors, extensions, and localizations
└── widgets/            # Globally reusable UI components
```

---

## 🛠 Prerequisites

Ensure you have the following installed on your machine:
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (Supports Dart SDK `^3.3.0`)
*   Android Studio / Xcode (for emulation and build tools)

---

## 🏁 Getting Started

Follow these steps to run the application locally:

### 1. Retrieve Packages
Fetch all package dependencies defined in `pubspec.yaml`:
```bash
flutter pub get
```

### 2. Code Generation
Generate JSON serializers and localizations (if required by features/models):
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Run the App
Launch the app on a connected emulator or device:
```bash
flutter run
```

---

## ⚙️ Project Automation

This repository functions as a base template. You can automate new project setups from this template using our CI/CD workflow:

### Manual Setup via Script
Run the local setup script in the project root:
```bash
./scripts/bootstrap.sh \
  "main" \
  "your_project_name" \
  "Your App Name" \
  "com.yourcompany.app" \
  "390" \
  "844" \
  "https://github.com/your-username/your-repo.git"
```

### GitHub Actions Automation
Trigger project generation directly from the GitHub Actions UI:
1. Go to the **Actions** tab in your repository.
2. Select **Flutter Project Generator**.
3. Click **Run workflow**, fill out the configuration parameters (App Name, Bundle ID, Design Dimensions, etc.), and click **Run**.
4. The workflow will automatically generate your customized project and push it to your new target GitHub repository.

For more details on the automation parameters, refer to the [Setup Documentation](file:///Users/saikrishna/Documents/AufaitProjects/mvvm/flutter_mvvm/scripts/bootstrap_doc.MD).
