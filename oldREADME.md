MilDiary 🌟

MilDiary is a mobile diary application built with Flutter and Sqflite, designed for military units to log daily events, personal reflections, and access platoon-wide shared entries and meal schedules.

📚 Features

✏️ Write and save a daily diary in 3 lines (with optional image attachment)

📆 Calendar-based diary browsing interface

📁 Local storage with SQLite via sqflite

🔎 View diaries written by fellow platoon members (if set to public)

🍽️ Meal schedule viewer using CSV data fetched from Google Drive

🚪 User authentication & session management

🔄 Project Structure

lib/
├── db/
│   ├── diary_database.dart   # CRUD for diaries (with image & public flag)
│   └── user_database.dart    # CRUD for user accounts (username, platoon, etc)
├── screens/
│   ├── calendar_screen.dart  # Main calendar UI
│   ├── diary_screen.dart     # Write/edit a diary with image upload
│   ├── login_screen.dart     # Login UI
│   ├── signup_screen.dart    # Signup form
│   ├── meal_screen.dart      # Meal CSV loader and display
│   └── other_diaries_screen.dart # List of other users' public diaries
└── main.dart              # App entry point (initializes and wipes DB)

📚 Data Model

User

username, password, name, birthdate

platoon, battalion, company

Diary

date, content (<= 20 chars)

imagePath: optional image file

isPublic: public/private toggle

userId, platoon, battalion

⚖️ Tech Stack

Frontend: Flutter (Material UI, TableCalendar, Image Picker)

Database: Sqflite (local SQLite)

Data Fetching: HTTP package, Google Drive CSV download

Architecture: StatefulWidget + custom DB helper classes

🚀 How to Run

flutter pub get
flutter run

Note: main.dart clears the database on app start for development convenience. Remove for production.

🏡 Use Case

This app was developed as a personal capstone-like project, targeting soldiers who want a lightweight and structured way to record their military life daily in under 3 lines. It includes community sharing (among platoon), privacy control, and contextual integration with meal information.

📅 Screenshots



🔑 Future Improvements

Firebase auth & Firestore for real backend integration

Notification feature for diary reminders

Expanded text support (currently limited to 20 characters)

UI optimization with Riverpod or BLoC

