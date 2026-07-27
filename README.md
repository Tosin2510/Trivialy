# Trivialy

A beautifully responsive, minimalist trivia application built using the Flutter framework.This project features category-based quizzes, a weekly global challenge, a live leaderboard, achievements, and personal statistic tracking.

## Features

## Main Quiz Experience

- Category-based quizzes (General Knowledge, Science, History, Sports, Entertainment, Art, Geography, Music, Food, Drink), questions which are gotten from The Trivia API
- Multi-Category("Mixed Quiz") mode with select/ unselect all.
- Setting question count, difficulty as well as time limit per quiz.
- Previous/Next navigation between questions within a quiz session.
- Countdown-timer and an auto-submit feature upon timeout.
- Post-quiz result screen with score ring, score breakdown(correct/wrong) and a full screen showing a review of the answers.

## Weekly Challenge

- 20 high-difficulty questions, generated once per week and shared identically across all players.
- One attempt per week for each user, enforced server-side via firebase security rules.
- Automatically reset weekly, with a countdown to the next reset date.

## Leaderboard and Profile

- Live weekly leaderboard with a podium and ranked list.
- Google Sign-In authentication
- Editable user profile, display name, profile picture and a fallback name initial.
- Personal statistics dashboard which shows total points, quizzes played, current day streak.
- Full quiz history with a bar-chart showing performance over time.
- Achievements system with progress bars for in-progress badges(streaks, milestones, perfect scores).

## Tech Stack & Packages

- Framework: Flutter(Dart)
- Backend: Firebase
  - Firebase Authentication(Google Sign-in)
  - Cloud Firestore(weekly challenges, leaderboard, quiz history, user profiles)
- Trivia data: The Trivia API
- Local Storage: shared_preferences(cached profile data), device file system(profile photos).
- Key Packages: firebase_auth, firebase_core, cloud_firestore, google_sign-in, image_picker, path_provider, html_character_entities, http

## Architecture Notes

- Weekly challenge questions are generate by the first user to open the challenge in a week, a fetch is triggered from The Trivia API and the fetched question is cached in firestore for subsequent users.
- User profile photos are stored locally and not uploaded to cloud storage.
- Achievements and stats are derived from the user's quiz history, each time the screen loads.
- Weekly challenge once per week is enforced at the security-rules level.

## Getting Started

## Prerequisites

- Flutter SDK installed
- A Firebase project with authentication and firestore enabled.
google-services.json(for Android) placed in android/app/

## Setup

1. Clone the repository
2. Run flutter pub get
3. Configure Firebase for the project:
    dart pub global activate flutterfire_cli
      flutterfire configure
4. Add your Android app's SHA-1 fingerprint to the Firebase Console(for Google Sign-in)
5. Deploy firestore security rules
6. Run the app:
    flutter run

## Building a release APK

flutter build apk --release --split-per-abi

## Limitations

- No profile photo sharing across devices
- No offline mode, quizzes, weekly challenge and leaderboard all require an internet connection.
- Works only on android devices (iOS has not been build-tested as it requires macOS/Xcode)

## Author

Built by Folarin Tosin, a Hack Club Macondo project.