# FAM-ILY Project Analysis

## Project identity

**FAM-ILY** is the implementation project for Orsolya Szanto's BSc thesis:

> Design and Development of a Mobile Application for Household Management

The Hungarian thesis title in the repository is *Haztartasvezetest tamogato mobilalkalmazas tervezese es fejlesztese*.

The application is designed for people who manage a household or family together. It provides a shared space for everyday information and coordination instead of keeping lists, notes, dates, contacts, and documents in separate places.

## What the README says

The repository README provides:

- the thesis title in Hungarian and English;
- the basic local setup: `flutter pub get` followed by `flutter run`;
- a note that Firebase configuration is already included for a normal local run;
- a Hungarian Google Forms link, presumably related to user research or evaluation;
- a Figma wireframe link for the Family app design.

The README is intentionally short. The source code and the documents in `docs/` contain the more detailed technical decisions.

## Main application concept

The application organizes household information around a shared **family group**. A user can:

1. create a new family group and receive a generated six-character group code; or
2. join an existing group by entering its group code.

The group ID is then used as the main ownership boundary in Firestore. The shared features are:

- To-do lists with individual checked or unchecked items;
- a calendar with events, date ranges, descriptions, and optional recurrence data;
- editable notes;
- shared contacts with names and phone numbers;
- shared document upload, listing, download, and deletion;
- notifications when another group member creates shared content.

## Architecture

The project uses a layered Flutter architecture:

```text
Widgets / pages
        |
        v
Cubits (state and user interaction flow)
        |
        v
Services (Firebase and platform operations)
        |
        +--> Firestore documents and subcollections
        +--> Firebase Storage files
        +--> Firebase Authentication
        +--> Firebase Cloud Messaging
        +--> Native Android APIs through MethodChannel
```

### Presentation layer

The UI is under `lib/pages/`. There are separate areas for authentication, the dashboard, user settings, and each household feature. Reusable visual elements are kept in `lib/design/`, including app bars, buttons, cards, spacing, colors, and text styles.

The dashboard acts as the feature launcher. It opens each feature page and passes the current group ID and, where needed, the authenticated user's ID.

### State-management layer

The project uses `flutter_bloc`, specifically `Cubit` classes rather than event-based `Bloc` classes. The Cubits are in `lib/cubit/`:

- `UserBloc`: authentication, registration, profile operations, and current group initialization;
- `TodoBloc`: list loading, draft editing, item changes, saving, and deletion;
- `NoteBloc`: note CRUD operations;
- `DocumentBloc`: upload, list, delete, and document state transitions;
- `ContactBloc`: contact CRUD operations;
- `CalendarBloc`: event CRUD operations, day selection, range selection, and event grouping.

The common pattern is to emit a loading state, call a service asynchronously, then emit a success, loaded, or error state. Pages use `BlocBuilder` to render state and `BlocListener` or `BlocConsumer` for navigation, snackbars, and other side effects.

### Service layer

The services in `lib/services/` isolate backend and platform calls from the widgets:

- `UserService` handles Firebase Authentication and user/group documents;
- `TodoService` handles nested todo lists and items;
- `NoteService`, `ContactService`, and `CalendarService` implement feature CRUD;
- `DocumentService` combines Firebase Storage, Firestore metadata, local temporary files, and Android downloads;
- `NotificationService` configures Firebase Messaging and foreground local notifications;
- `UserSubscriptionService` keeps the user's FCM topic synchronized with the current group.

This separation makes the UI less dependent on Firebase APIs and gives the project a clear place for validation and data-access logic.

### Model layer

The data classes in `lib/model/` represent users, groups, notes, contacts, documents, calendar events, todo lists, and todo items. Most models are simple immutable-style value holders with final fields, while the user/group models are more mutable.

## Feature methods and implementation solutions

### Authentication and family groups

Authentication uses Firebase Email/Password Authentication. Registration performs local checks before creating the account:

- password must be at least eight characters;
- it must contain an uppercase letter and a number;
- a user joining an existing group must provide a non-empty group code.

When creating a group, the app generates a secure random six-character code containing uppercase letters and digits. It creates:

- a document in `group/{groupId}`;
- a document in `users/{userId}` containing the group ID and code;
- a member document in `group/{groupId}/members/{userId}`.

If group setup fails after the Firebase account is created, the service attempts to delete the newly created account. This is a cleanup solution for partial registration failure.

The app listens to `FirebaseAuth.instance.authStateChanges()` and switches between the authentication screen and dashboard based on the resulting state.

### To-do lists

To-do lists use a parent document with nested item documents:

```text
group/{groupId}/todoLists/{todoListId}
group/{groupId}/todoLists/{todoListId}/todoItems/{itemId}
```

Creating and editing a list uses a Firestore `WriteBatch`. This allows the parent list and its items to be written together. Editing also compares existing item IDs with incoming item IDs so that removed items are deleted, existing items are updated, and new items are inserted.

The Cubit keeps a temporary `TodoEditing` draft in memory. This supports adding, removing, renaming, and checking items before one save operation is sent to Firestore.

### Notes

Notes are stored in `group/{groupId}/notes`. They support creation, reading, editing, deletion, timestamps, and tracking of the creating/updating user IDs. Titles are trimmed and validated in the service layer.

The UI adds client-side title search and uses a separate create/edit screen for longer note content.

### Calendar

Calendar events are stored in `group/{groupId}/calendarEvents`. The service validates that the title is not empty and that the end date is not before the start date. Firestore timestamps are converted to Dart `DateTime` values in the model layer.

`CalendarBloc` normalizes dates to year/month/day keys and groups events by day. The UI uses `table_calendar` for month, day, and range-oriented calendar interaction.

The data model already includes recurrence and notification lead-time fields. The current create/edit UI primarily exposes title, description, and dates, so recurrence and per-event notification behavior may be considered future extension points.

### Contacts

Contacts are stored in `group/{groupId}/contacts`. Both name and phone number are required and trimmed before writing. The list page supports search, editing through a dialog, and swipe-to-delete with confirmation.

### Documents

Documents use a two-part data design:

- the binary file is stored in Firebase Storage under `group/{groupId}/documents/{fileName}`;
- searchable metadata is stored in Firestore under `group/{groupId}/documents/{documentId}`.

The metadata includes filename, uploader, upload time, size, type, and download URL. Upload first sends the file to Storage, then writes its metadata to Firestore. Delete removes both the Storage object and its Firestore metadata.

The download solution is a notable platform-integration example:

1. Flutter downloads the Storage object to a temporary local file using `path_provider`.
2. Flutter calls the Android side through the `familyapp/downloads` `MethodChannel`.
3. Kotlin uses `MediaStore` on Android 10 and newer to place the file in the public Downloads directory.
4. The temporary file is deleted after the handoff.

On older Android versions, the implementation uses the legacy public Downloads path. This avoids leaving a user-visible document inside an app-private directory.

### Notifications

The app uses group IDs as Firebase Cloud Messaging topics. After login or registration, the user subscribes to the topic for their current group. `UserSubscriptionService` listens for changes to the user's group ID and unsubscribes from the old topic before subscribing to the new one.

The Cloud Functions in `functions/src/index.ts` use Firestore `onDocumentCreated` triggers. They send a group-topic notification when a new note, contact, document, calendar event, or todo list is created.

When the app is in the foreground, Firebase Messaging receives the message but does not automatically display a system notification. `NotificationService` solves this with `flutter_local_notifications` by creating a high-importance Android channel and showing a local notification from the `onMessage` listener. It also requests Android notification permission and registers a background message handler.

## Technology stack

### Client

- Flutter and Dart
- Dart SDK constraint: `^3.9.2`
- Material Design widgets
- `flutter_bloc` for Cubit-based state management
- `table_calendar` for calendar presentation
- `file_picker` for selecting documents
- `path_provider` for temporary local file storage
- `fluttertoast` for toast-style feedback where used
- `flutter_local_notifications` for foreground notifications

### Firebase

- Firebase Core for initialization
- Firebase Authentication for email/password accounts
- Cloud Firestore for users, groups, shared data, and metadata
- Firebase Storage for uploaded files
- Firebase Cloud Messaging for group notifications
- Firebase Cloud Functions for server-side Firestore triggers

### Android and backend tooling

- Kotlin Android host code
- Flutter `MethodChannel` for Flutter-to-native communication
- Android `MediaStore` for public Downloads
- Gradle Kotlin DSL
- Android Google Services plugin and Firebase BoM
- Java/Kotlin 11 compatibility in the Android module
- Core library desugaring for notification-library compatibility
- TypeScript Cloud Functions running on Node.js 24
- Firebase CLI configuration in `firebase.json`

## Firebase billing-plan dependency

The project was previously connected to the Firebase **Blaze pay-as-you-go plan**, but the billing account was cancelled. This changes the available Firebase capabilities even if the source code remains unchanged.

### Services that remain usable on Spark

Firebase Authentication, Cloud Firestore, and Firebase Cloud Messaging can continue to work on the no-cost Spark plan within their applicable quotas. In this project, login, registration, group data, notes, contacts, calendar events, and todo lists may therefore continue to work during normal low-volume testing.

If a Spark quota is exceeded, Firebase can shut off that specific product for the remainder of the billing period instead of charging for extra usage. This can make a feature appear to fail suddenly even though its application code has not changed.

### Services affected in this project

**Firebase Storage:** the document feature uses Storage in `DocumentService` for upload, download, and deletion. Current Firebase documentation requires the Blaze plan for Cloud Storage for Firebase, including the default project bucket. Consequently, document upload/download should be expected to fail after downgrading to Spark, independently of the application code.

**Cloud Functions:** `functions/src/index.ts` defines Firestore-triggered notification functions for new notes, contacts, documents, calendar events, and todo lists. On Spark, new deployments and redeployments of Cloud Functions are blocked. Previously deployed functions may need to be tested in the Firebase console; their continued operation should not be assumed when the billing account has been removed.

**Local notifications:** `flutter_local_notifications` remains a client-side Android capability. It can display a notification when an FCM message reaches the app, but it cannot replace the server-side Cloud Functions that create the group notification messages.

### Practical project status after cancellation

| Project feature | Expected status on Spark |
|---|---|
| Login and registration | Usable within Authentication limits |
| Notes, contacts, calendar, and todos | Usable within Firestore limits |
| Group FCM delivery | Depends on the deployed Cloud Functions still running |
| Foreground local notification display | Still supported by the Android client |
| Document upload and download | Expected to fail because Storage requires Blaze |
| Cloud Functions deployment | Not available on Spark |

The Firebase plan applies to the whole `family-app-2025` project, not only the Android app. The current plan should be checked in **Firebase Console -> Project settings -> Usage and billing** before diagnosing backend errors.

For development or thesis demonstrations, Blaze can be re-enabled with budget alerts and spend caps. A billing change alone does not repair the repository's current Storage rule, which also contains `allow read, write: if false;` and therefore denies all Storage access when deployed.

## Data organization

The Firestore structure is group-centered:

```text
users/{userId}
group/{groupId}
group/{groupId}/members/{userId}
group/{groupId}/notes/{noteId}
group/{groupId}/contacts/{contactId}
group/{groupId}/documents/{documentId}
group/{groupId}/calendarEvents/{eventId}
group/{groupId}/todoLists/{todoListId}
group/{groupId}/todoLists/{todoListId}/todoItems/{itemId}
```

This structure supports shared household data and makes the group ID the common query parameter for each feature.

## Validation, feedback, and usability techniques

The implementation uses several practical interaction solutions:

- service-level validation for required titles, names, phone numbers, dates, and passwords;
- loading states that disable editing controls during asynchronous operations;
- error states rendered through snackbars or retry views;
- confirmation dialogs before destructive actions;
- swipe-to-delete for list-based content;
- search filtering on notes, contacts, documents, and todo lists;
- server timestamps for creation and update history;
- reusable app bars, buttons, cards, spacing, and color definitions;
- cleanup of `TextEditingController` objects in stateful pages.

## Current limitations and points to verify

These are observations about the current repository state and useful topics for testing or thesis discussion:

1. `firestore.rules` permits any authenticated user to read and write documents below any group. It does not currently check whether the authenticated user is a member of the requested group. Membership-based rules would provide a stronger authorization boundary.
2. `storage.rules` currently denies all Storage reads and writes. Even after restoring Blaze, deployed Storage rules must be updated and checked before treating document upload/download as production-ready.
3. The project previously used the Blaze plan. After cancellation, Cloud Storage requires Blaze and Cloud Functions cannot be deployed or redeployed on Spark. Firestore, Authentication, and FCM remain subject to Spark quotas.
4. Cloud Functions notify on creation only. Updates and deletions do not generate group notifications.
5. The code contains several nullable or dynamically typed Firestore conversions. Missing or malformed fields could cause runtime errors in some model constructors.
6. The dashboard creates feature-specific Cubits in addition to the app-level providers. This works, but provider ownership and lifecycle could be simplified in a future refactor.
7. The README still describes the package as a new Flutter project. The project description and version metadata could be updated for a finished thesis artifact.
8. There are no visible automated unit, widget, or integration tests in the repository structure. Manual testing and targeted tests would strengthen the evaluation section.

These points are documented for awareness; this notes file does not change the application behavior.

## Thesis-oriented interpretation

The project demonstrates a cross-platform mobile application approach with a managed cloud backend. Its central design decision is to model the household as a shared Firebase group and to make all feature data group-scoped. The main engineering contributions are:

- a reusable Flutter UI and Cubit/service architecture;
- a shared Firestore data model for several household workflows;
- atomic batch updates for nested todo data;
- asynchronous state and error handling around cloud operations;
- topic-based group notifications with both background and foreground handling;
- a Flutter/Kotlin integration for user-visible Android file downloads.

For the thesis, the strongest discussion areas are requirements and user research, information architecture, the group and permission model, the data model, asynchronous state management, notification delivery, Android storage restrictions, usability evaluation, and security/testing limitations.

## Local setup

The README lists the normal setup sequence:

```powershell
flutter pub get
flutter run
```

Firebase configuration files are present in the repository. Android development additionally depends on a local Flutter SDK path in `android/local.properties` and a working Android toolchain. Cloud Functions can be built separately from the `functions/` directory with `npm run build`.

Deploying the Cloud Functions requires the Firebase project to have Blaze billing enabled. Running the Flutter client locally does not by itself restore access to Storage or deploy the functions.

## Key files

- `README.md`: thesis title, setup, questionnaire, and Figma links;
- `pubspec.yaml`: Flutter dependencies and Dart SDK constraint;
- `lib/main.dart`: Firebase initialization, providers, authentication gate, and notification startup;
- `lib/cubit/`: Cubit state-management layer;
- `lib/services/`: Firebase and platform integration;
- `lib/model/`: application data models;
- `lib/pages/`: authentication, dashboard, feature, and profile UI;
- `functions/src/index.ts`: Firestore-triggered group notifications;
- `firestore.rules`: Firestore access rules;
- `storage.rules`: Firebase Storage access rules;
- `android/app/src/main/kotlin/com/example/familyapp/MainActivity.kt`: native Downloads bridge;
- `docs/`: implementation notes about document downloads, foreground notifications, and group-code loading.