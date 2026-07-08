# Trivialy

A beautifully responsive, minimalist trivia application built using the Flutter framework. This project focuses on high-quality visual polish, clean state tracking, and fluid user interactions without overcomplicating the underlying architecture.

## Features

- Live Trivia Stream:Dynamically pulls fresh, categorized questions across multiple topics (Science, History, Sports, General Knowledge) using the free Open Trivia Database API.
- Beat the Clock: Every question features an intense 15-second countdown timer, driven by a reactive progress bar using asynchronous Dart streams.
- Localized Persistence: Keeps users engaged by caching their personal best scores directly to device memory, ensuring high scores persist across app restarts.
- Premium Minimalist UI:Designed with clean and simple UI

## Tech Stack & Packages

- Framework: Flutter & Dart
- UI Architecture: Material 3 (Custom Light Theme)
- State Management: Local State
- Networking: [http](https://pub.dev/packages/http) for REST API requests
- Local Caching: [shared_preferences](https://pub.dev/packages/shared_preferences) for high-score tracking
- Text Cleaning: [html_character_entities](https://pub.dev/packages/html_character_entities) to parse raw API text formats smoothly

### 📦 Installation & Setup

1. Clone the repository and navigate into the project directory:
git clone https://github.com/Tosin2510/Trivialy.git
cd Trivialy
