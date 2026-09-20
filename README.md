<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
	<img src="https://img.shields.io/badge/Status-BSc%20Thesis%20Prototype-5C2D91?style=for-the-badge" alt="Status: BSc Thesis Prototype" />
</p>
> Note: The current application UI is primarily in Hungarian.
>
> Firebase is used for email/password authentication, Cloud Firestore data storage, document storage, push notifications, and Cloud Functions. The project is no longer connected to the paid Blaze billing plan. Firebase normally downgrades a project to the no-cost Spark plan after Blaze billing is cancelled, but the exact current status should be checked in the Firebase Console. Storage and Cloud Functions may therefore be unavailable until an appropriate Firebase project and billing plan are configured.

---
# FAM-ILY

## Design and Development of a Mobile Application for Household Management

FAM-ILY is a Flutter mobile application developed as part of my BSc thesis. It is designed to help families and people sharing a household organize everyday information in one place and coordinate tasks together.

The Hungarian thesis title is **Háztartásvezetést támogató mobilalkalmazás tervezése és fejlesztése**.

## Project overview

The application is organized around shared family groups. A user can create a group and invite others with a generated group code, or join an existing group.

The current application includes:

- shared to-do lists with editable checklist items;
- a calendar for household events and date ranges;
- editable shared notes;
- shared contacts;
- document upload, listing, download, and deletion;
- group notifications when shared content is created;
- account and profile management.

The project combines a mobile frontend, a managed Firebase backend, and a small native Android integration for saving downloaded files to the public Downloads folder.

## Screenshots and demo


```html
<p align="center">
	<img src="docs/media/dashboard.png" width="30%" alt="FAM-ILY dashboard" />
	<img src="docs/media/calendar.png" width="30%" alt="FAM-ILY calendar" />
	<img src="docs/media/notes.png" width="30%" alt="FAM-ILY notes" />
</p>

<p align="center">
	<img src="docs/media/app-demo.gif" width="70%" alt="FAM-ILY app demo" />
</p>
```

## UX and product design direction

The project is supported by an ongoing UX planning process. This includes research through a Hungarian questionnaire, a Figma wireframe, and planned user-centered design work covering personas, user journeys, and requirements expressed as if-then statements. These materials are intended to connect implementation decisions with real household-management needs.

- [UX research questionnaire](https://forms.gle/fAYYGGz2DPR7Azof9)
- [Figma wireframes](https://www.figma.com/design/NFGXAXI9vOoHjW6TUtCGM6/Family-app?node-id=0-1&t=6Tx7UwJf526tytLA-1)

## Architecture

The Flutter application follows a layered structure:

```text
Flutter pages and widgets
		  |
		  v
Cubits for state and interaction flow
		  |
		  v
Services for Firebase and platform operations
		  |
		  +--> Firebase Authentication
		  +--> Cloud Firestore
		  +--> Firebase Storage
		  +--> Firebase Cloud Messaging
		  +--> Native Android APIs through MethodChannel
```

The main project layers are:

- `lib/pages/`: authentication, dashboard, feature, and profile screens;
- `lib/cubit/`: Cubit-based state management with loading, success, and error states;
- `lib/services/`: Firebase access, notifications, subscriptions, and document operations;
- `lib/model/`: application data models;
- `lib/design/`: reusable app bars, buttons, cards, colors, spacing, and text styles;
- `functions/`: TypeScript Cloud Functions that send group notifications;
- `android/`: Android configuration and the Kotlin Downloads integration.

## Technology stack

### Client

- Flutter and Dart
- Material Design
- `flutter_bloc` for Cubit-based state management
- `table_calendar` for calendar UI
- `file_picker` for document selection
- `path_provider` for temporary files
- `flutter_local_notifications` for foreground Android notifications

### Firebase and backend

- Firebase Authentication for email/password accounts
- Cloud Firestore for users, groups, and shared household data
- Firebase Storage for document files
- Firebase Cloud Messaging for group notifications
- Firebase Cloud Functions with TypeScript and Node.js 24

### Android integration

- Kotlin
- Flutter `MethodChannel`
- Android `MediaStore` for saving files to public Downloads
- Gradle Kotlin DSL

## Notable implementation decisions

- Group IDs are used to scope household data across notes, contacts, documents, calendar events, and todo lists.
- Todo lists and their items are updated with Firestore batches so related writes are handled together.
- Firebase topic messaging uses the current group ID to notify group members.
- Foreground FCM messages are displayed through local Android notifications because Firebase Messaging does not automatically show a system notification while the app is open.
- Documents are downloaded to a temporary file and passed to native Android code so they appear in the user's public Downloads folder rather than remaining in app-private storage.
- Validation, loading states, confirmation dialogs, search filtering, and error feedback are handled throughout the feature flows.

## Running the project locally

### Prerequisites

- Flutter SDK compatible with Dart `^3.9.2`;
- Android Studio or another working Android toolchain;
- a configured Android emulator or physical device;
- Node.js 24 if working with the Cloud Functions;
- access to the Firebase project for backend features.

### Flutter application

```powershell
flutter pub get
flutter run
```

Firebase configuration files are included for the configured project. Local execution may still be affected by the current Firebase billing plan, deployed security rules, device permissions, and backend availability.

### Cloud Functions

From the `functions/` directory:

```powershell
npm install
npm run build
```

Deploying or redeploying the functions requires the Firebase project to use the Blaze pay-as-you-go plan.

## Firebase billing and current project status

The project previously used the Firebase Blaze plan, but the billing account was cancelled. This has project-level consequences:

- Authentication, Firestore, and FCM can continue within their no-cost quotas;
- Firebase Storage requires the Blaze plan, so document upload and download are expected to be unavailable on Spark;
- Cloud Functions cannot be newly deployed or redeployed on Spark;
- existing notification functions should be tested rather than assumed to remain available;
- exceeding Spark quotas can temporarily disable the affected Firebase product for the billing period.

There is also a separate repository configuration issue to resolve before treating document storage as production-ready: [storage.rules](storage.rules) currently denies all reads and writes. Re-enabling Blaze alone will not override those rules.

## Project status and limitations

This repository is a thesis project and an evolving prototype rather than a production-ready household platform. Known areas for future work include:

- membership-based Firestore authorization instead of checking authentication only;
- production-ready Firebase Storage rules;
- automated unit, widget, and integration tests;
- broader notification behavior for updates and deletions;
- completing and evaluating the planned UX research activities;
- refining model validation and error handling for malformed backend data.

## Future plans

Potential future improvements for the project include:

- strengthening Firestore and Storage security rules with verified group membership and more granular permissions;
- making notifications smarter through configurable reminders, priorities, and more relevant group updates;
- modernizing and refining the user interface based on UX research and usability feedback;
- expanding the core household features with richer task, calendar, note, contact, and document workflows;
- adding personalization such as customizable categories, notification preferences, themes, and household settings;
- improving offline support, synchronization, accessibility, and cross-platform behavior;
- adding broader automated testing and monitoring for a more reliable production release.

## Thesis and research materials

The thesis is primarily written in Hungarian and is not included in this public repository. Any future publication of the full thesis, research responses, screenshots containing personal information, or other university material should be checked with the thesis consultant and the relevant institution first. Questionnaire data should also be reviewed for consent, anonymity, and privacy before being published.

## Related documentation

- [Detailed project analysis](docs/project_analysis.md)
- [Document download implementation note](docs/document_download_fix.md)
- [Foreground notification implementation note](docs/FCM_foreground_notification_fix.md)
- [Profile group-code loading implementation note](docs/profile_groupcode_loading_fix.md)
