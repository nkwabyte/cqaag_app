# CQAAG Mobile Application

[![Flutter](https://img.shields.io/badge/Flutter-%5E3.10.1-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%5E3.10.1-0175C2?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-Private-red)](#license)

The official field inspection and portal mobile application for the **Ghana Cashew Quality Analysts' Association (CQAAG)**. Built with Flutter, Riverpod, and Firebase to empower quality analysts, farmers, inspectors, and administrators across Ghana with real-time cashew nut quality assessment, GPS farm location tagging, PDF certificate generation, QR traceability, and membership management.

---

## Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Technology Stack](#technology-stack)
- [Project Architecture & Organization](#project-architecture--organization)
- [Quality Calculation Engine](#quality-calculation-engine)
- [Setup & Installation](#setup--installation)
- [Environment Configuration](#environment-configuration)
- [Code Generation & Build Commands](#code-generation--build-commands)
- [CI/CD & Automated Releases](#cicd--automated-releases)
- [License & Support](#license--support)

---

## Overview

The CQAAG mobile application serves as a comprehensive digital field assistant for cashew quality inspection and member governance in Ghana. Analysts can perform standardized quality evaluations directly in cashew farms and warehouses—even in remote areas with offline data caching—to determine Kernel Output Ratio (KOR), Nut Count, Defect Rate, and Moisture Content.

The app also provides a full portal for association members to manage their profiles, track membership applications, access association documents (Constitution, Code of Ethics, Quality Standards), view regional chapters, and participate in events.

---

## Key Features

### 🔍 Field Quality Inspection Wizard
- **5-Step Inspection Workflow**:
  1. **Basic Details**: Record farmer/supplier details, lot size, bag count, and origin location (Region, District, Town).
  2. **Farm Location**: Capture precise GPS coordinates using device location services.
  3. **Quality Measurement**: Input sample weight, defect weight, sound kernel weight, nut count, and moisture percentage to calculate **Kernel Output Ratio (KOR)** automatically.
  4. **Photo Documentation**: Upload high-resolution evidence photos directly to Cloudinary.
  5. **Result & Traceability**: Generate digital inspection certificates, export PDF reports, and generate unique QR codes for lot origin tracking.

### 👤 Member & Portal Services
- **Firebase Authentication**: Secure sign-in and registration with email verification and password recovery.
- **Guest Explorer Mode**: Unauthenticated access to association background, quality standards, events, and public resources.
- **Membership Application**: Multi-step registration including ID verification document upload, digital signature agreement, and Mobile Money / bank payment proof submission.
- **Digital Member Profile & ID**: Member credential display, profile editing, and role badge tracking.

### 🛡️ Admin Console
- **Application Review Workflow**: Review pending membership applications, inspect uploaded verification documents, and approve or reject candidates.
- **User Management**: Monitor user roles, member IDs, and verification statuses.
- **Inspection Analytics**: View historical quality assessments aggregated by district and town across Ghana.

### 📚 Association Resources & Governance
- **Quality Standards Reference Guide**: Interactive guide detailing Grade A–C raw cashew nut parameters.
- **Governance Documents**: Full texts of the CQAAG Constitution, Code of Ethics, Terms & Conditions, and Privacy Policy.
- **Regional Chapters & Events**: Information on local chapters (Bono, Ahafo, Ashanti, Northern, Eastern, Volta, etc.), upcoming workshops, and partner organizations.

### 📶 Offline Persistence & Security
- **Offline Firestore Persistence**: Unlimited offline cache (`CACHE_SIZE_UNLIMITED`) for seamlessly saving field inspections in areas without network coverage.
- **Environment Security**: Encrypted configuration management via `flutter_dotenv`.

---

## Technology Stack

| Layer | Library / Framework | Purpose |
| :--- | :--- | :--- |
| **Framework** | Flutter (Dart ^3.10.1) | Cross-platform iOS, Android, and Web application |
| **State Management** | Hooks Riverpod (`flutter_riverpod`, `flutter_hooks`, `riverpod_annotation`) | Reactive, testable state management and dependency injection |
| **Navigation** | `go_router` | Declarative routing with dynamic authentication & guest guards |
| **Backend & DB** | Firebase Core, Auth, Cloud Firestore | User authentication and real-time database with offline support |
| **Media Storage** | Cloudinary (`cloudinary_api`, `cloudinary_url_gen`) | Cloud storage for inspection photo proof and identity documents |
| **Forms & Input** | `flutter_form_builder`, `form_builder_validators` | Complex multi-step form state management and input validation |
| **Location & Maps** | `geolocator` | Real-time GPS coordinate acquisition for farm location tagging |
| **QR & Scanning** | `qr_flutter`, `mobile_scanner` | QR code generation and barcode/QR scanning for lot traceability |
| **PDF & Export** | `pdf`, `printing`, `share_plus`, `open_filex` | PDF inspection certificate generation, printing, and file sharing |
| **UI & Design System**| `flutter_screenutil`, `adaptive_theme`, Google Fonts, `flutter_animate` | Responsive screen scaling, light/dark mode, Montserrat/Poppins typography |

---

## Project Architecture & Organization

The codebase follows a modular, feature-oriented structure with clear separation between state controllers, models, services, and views:

```
cqaag_app/
├── android/                 # Native Android configuration & build files
├── ios/                     # Native iOS Xcode project & configuration
├── assets/                  # Logos, icons, SVGs, and static assets
├── lib/
│   ├── main.dart            # Application entry point, Firebase init & ProviderScope
│   ├── controllers/         # Riverpod state logic and AsyncNotifiers
│   │   ├── auth/            # Auth state and session handlers
│   │   ├── inspection/      # Quality inspection wizard & history controllers
│   │   ├── membership/      # Application & payment verification logic
│   │   ├── subscription/    # Dues & subscription management
│   │   └── user/            # User profile controllers
│   ├── core/                # Global theme tokens, constants, and custom styles
│   ├── generated/           # Auto-generated files (Riverpod, Freezed, JSON)
│   ├── models/              # Data models & Freezed classes
│   │   ├── inspection/      # Inspection, QualityResult models
│   │   ├── membership/      # MembershipApplication, ID Verification models
│   │   ├── user/            # AppUser, MemberRole models
│   │   └── event/           # Association Event models
│   ├── router/              # GoRouter router configuration & route guards
│   │   └── app_router.dart  # Main route definitions & redirect rules
│   ├── services/            # Remote & local API data adapters
│   │   ├── api_service.dart # HTTP client service
│   │   ├── auth/            # Firebase Auth service wrapper
│   │   ├── cloudinary/      # Cloudinary image upload service
│   │   ├── inspection/      # Firestore Inspection CRUD service
│   │   ├── location/        # Device GPS location service
│   │   └── payment/         # Payment verification adapter
│   ├── utils/               # Formatters, KOR calculators, and validators
│   └── views/               # Screen widgets & UI layouts
│       ├── auth/            # Login, Register, Forgot Password screens
│       ├── components/      # Reusable UI cards, headers, and dialogs
│       ├── dashboard/       # Main dashboard layout (Home, History, Profile, Admin)
│       │   ├── admin/       # Admin console & application review screens
│       │   ├── history/     # Inspection history & regional breakdown screens
│       │   ├── home/        # Inspector home screen & quality wizard flow
│       │   └── profile/     # User profile, ID card, settings screens
│       ├── onboarding/      # Onboarding carousel & splash intro
│       ├── screens/         # Public informational screens (About, Standards, Chapters)
│       └── widgets/         # Shared input widgets and buttons
├── pubspec.yaml             # Flutter project dependencies & asset registrations
├── env.template             # Environment configuration blueprint
├── firebase.json            # Firebase CLI setup file
└── README.md                # Project documentation
```

---

## Quality Calculation Engine

The inspection engine computes cashew quality parameters based on Ghana Cashew Quality Analysts' Association standards:

$$\text{Kernel Output Ratio (KOR)} = \left( \frac{\text{Sound Weight (g)} + 0.5 \times \text{Useful Defect Weight (g)}}{\text{Sample Weight (g)}} \right) \times 80$$

- **Sound Kernels**: Whole, healthy cashew kernels.
- **Useful Defects**: Slightly damaged or immature kernels calculated at 50% value.
- **Nut Count**: Total cashew nuts per 1 kg sample.
- **Moisture Content**: Percentage moisture measured via moisture meter.

---

## Setup & Installation

### Prerequisites
- **Flutter SDK**: `^3.10.1` (or higher)
- **Dart SDK**: `^3.10.1`
- **CocoaPods**: Required for iOS dependencies (`pod install`)
- **Android Studio / Xcode / VS Code**: Configured with Flutter extensions

### Installation Steps

1. **Clone the repository**:
   ```bash
   git clone <repository_url>
   cd cqaag_app
   ```

2. **Configure Environment Variables**:
   Copy `env.template` to `.env` in the project root:
   ```bash
   cp env.template .env
   ```
   Fill in your Firebase keys and Cloudinary configuration in `.env` (see [Environment Configuration](#environment-configuration)).

3. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

4. **Run Code Generation**:
   Execute `build_runner` to generate Riverpod providers, Freezed models, and JSON serializers:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. **Launch Application**:
   - For Android:
     ```bash
     flutter run -d android
     ```
   - For iOS:
     ```bash
     flutter run -d ios
     ```

---

## Environment Configuration

The application requires environment keys set in `.env` for Firebase and Cloudinary services:

```ini
# Firebase Android
ANDROID_API_KEY=YOUR_ANDROID_API_KEY_HERE
ANDROID_APP_ID=YOUR_ANDROID_APP_ID_HERE
ANDROID_MESSAGING_SENDER_ID=YOUR_ANDROID_SENDER_ID_HERE
ANDROID_PROJECT_ID=YOUR_PROJECT_ID_HERE
ANDROID_STORAGE_BUCKET=YOUR_STORAGE_BUCKET_HERE

# Firebase iOS
IOS_API_KEY=YOUR_IOS_API_KEY_HERE
IOS_APP_ID=YOUR_IOS_APP_ID_HERE
IOS_MESSAGING_SENDER_ID=YOUR_IOS_SENDER_ID_HERE
IOS_PROJECT_ID=YOUR_PROJECT_ID_HERE
IOS_STORAGE_BUCKET=YOUR_STORAGE_BUCKET_HERE
IOS_CLIENT_ID=YOUR_IOS_CLIENT_ID_HERE
IOS_BUNDLE_ID=YOUR_IOS_BUNDLE_ID_HERE

# Cloudinary Storage
CLOUDINARY_CLOUD_NAME=YOUR_CLOUD_NAME_HERE
CLOUDINARY_API_KEY=YOUR_API_KEY_HERE
CLOUDINARY_API_SECRET=YOUR_API_SECRET_HERE
CLOUDINARY_UPLOAD_PRESET=YOUR_UPLOAD_PRESET_HERE
```

---

## Code Generation & Build Commands

### Code Generation & Watch
When modifying models (`@freezed`, `@JsonSerializable`) or Riverpod providers (`@riverpod`):

```bash
# One-time build
dart run build_runner build --delete-conflicting-outputs

# Watch mode during development
dart run build_runner watch --delete-conflicting-outputs
```

### Splash Screen Generation
```bash
dart run flutter_native_splash:create --path=flutter_native_splash.yaml
```

### Production Build
```bash
# Build Android APK / App Bundle
flutter build apk --release
flutter build appbundle --release

# Build iOS IPA
flutter build ipa --release
```

---

## CI/CD & Automated Releases

The repository is configured with a fully automated GitHub Actions pipeline (`.github/workflows/release.yml`) that builds, cryptographically signs, and publishes Android release APKs directly to GitHub Releases.

### 🚀 Triggering a Release

The release workflow is configured to run automatically only on the `main` branch:

#### Method 1: Merging a Pull Request or Pushing to `main` (Automated)
- Merging any Pull Request into the `main` branch automatically triggers the release workflow.
- Directly pushing commits to the `main` branch triggers the release workflow.
- Pushes to feature branches, `dev`, or other branches will **not** trigger a release build.

#### Method 2: Manual Workflow Dispatch
1. Navigate to **Actions** in the GitHub repository.
2. Select **Release Android APK** workflow.
3. Click **Run workflow** on `main`, specify an optional tag name (or leave blank to use `pubspec.yaml` version), and optionally select *Draft* or *Pre-release*.

---

### 📦 Release Assets Published

Each release automatically produces and publishes the following assets along with automated release notes and changelogs:

| Asset Name | Description | Recommended For |
| :--- | :--- | :--- |
| `cqaag-app-v<version>.apk` | Universal fat APK containing all CPU architectures | General distribution & manual install |
| `cqaag-app-universal.apk` | Fixed filename alias for the universal APK | Direct download link integration |
| `cqaag-app-arm64-v8a.apk` | Optimized 64-bit ARM APK (~40% smaller) | Modern Android devices (Android 8+) |
| `cqaag-app-armeabi-v7a.apk`| Optimized 32-bit ARM APK | Older Android devices |
| `cqaag-app-x86_64.apk` | Optimized x86_64 APK | Android emulators / ChromeOS |
| `SHA256SUMS.txt` | Cryptographic SHA256 checksums | Integrity and authenticity verification |

---

### 🔐 Keystore & GitHub Secrets Management

All production signing credentials and environment variables are securely stored in the private `secrets/` folder (ignored by git) and configured in GitHub Repository Secrets:

| GitHub Secret | Purpose | Local File Source |
| :--- | :--- | :--- |
| `KEYSTORE_BASE64` | Base64-encoded release `.jks` signing key | `secrets/cqaag-keystore.jks` |
| `KEYSTORE_PASSWORD`| Master keystore password | `secrets/key.properties` |
| `KEY_ALIAS` | Release key alias (`cqaag-key`) | `secrets/key.properties` |
| `KEY_PASSWORD` | Private key entry password | `secrets/key.properties` |
| `ENV_FILE_BASE64` | Base64-encoded environment configuration | `.env` or `secrets/.env` |

#### Updating or Rotating Secrets with GitHub CLI:
To update secrets using the GitHub CLI under the `nkwabyte` organization:

```bash
# Switch to nkwabyte account
gh auth switch --user nkwabyte

# Set Keystore & Environment Secrets
base64 -i secrets/cqaag-keystore.jks | gh secret set KEYSTORE_BASE64 --repo nkwabyte/cqaag_app
base64 -i .env | gh secret set ENV_FILE_BASE64 --repo nkwabyte/cqaag_app

# Set Credential Secrets
echo -n "<KEYSTORE_PASSWORD>" | gh secret set KEYSTORE_PASSWORD --repo nkwabyte/cqaag_app
echo -n "cqaag-key" | gh secret set KEY_ALIAS --repo nkwabyte/cqaag_app
echo -n "<KEY_PASSWORD>" | gh secret set KEY_PASSWORD --repo nkwabyte/cqaag_app
```

---

## License & Support

This project is proprietary software belonging to the **Ghana Cashew Quality Analysts' Association (CQAAG)**. Unauthorized distribution or reproduction is strictly prohibited.

For technical inquiries or app support, contact the CQAAG IT & Quality Assurance team.
