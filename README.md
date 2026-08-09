# Study Planner & Task Manager
## How to Run the App

1. Ensure Flutter is installed and added to your system's PATH.
2. Open a terminal in this project directory (`d:\Projects\Task Maneger(Mobile)`).
3. Run `flutter pub get` to download all dependencies.
4. Run `flutter run` to launch the app on an emulator or connected device.

## How to Create an APK

To generate an installable Android APK file:

1. Open your terminal in the project directory (`d:\Projects\Task Maneger(Mobile)`).
2. Run the build command:
   ```bash
   flutter build apk --release
   ```
3. Once the build finishes successfully, you can find your generated APK file at:
   ```
   build\app\outputs\flutter-apk\app-release.apk
   ```
4. Transfer this `.apk` file to your Android device and install it.

> [!NOTE]  
> If you want to create an App Bundle (AAB) for uploading to the Google Play Store, run `flutter build appbundle` instead.

## Features Implemented
- **Task Management**: Add, edit, delete, complete tasks with priority and due dates.
- **Assignments**: Track upcoming assignments, marks, and submission status.
- **Exams**: Keep track of upcoming and past exams.
- **Calendar**: A monthly view showing tasks, assignments, and exams on their respective dates.
- **Study Streak**: Automatically tracks your consecutive days of completing tasks, awarding badges.
- **Statistics**: Visual charts showing your completion progress.
- **Settings**: Dark/Light mode toggle and data reset options.
- **Offline Storage**: All data is stored locally using Hive for fast offline access.

## Architecture
This project uses **Riverpod** for state management and follows a clean architecture folder structure:
- `lib/models/`: Hive data models
- `lib/repositories/`: Data access layer
- `lib/providers/`: Riverpod state notifiers and providers
- `lib/screens/`: UI screens organized by feature
- `lib/themes/`: Material 3 theme configurations
