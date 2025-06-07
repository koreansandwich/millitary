# MilDiary 🌟

MilDiary is a mobile diary application built with Flutter and Sqflite, designed for military units to log daily events, personal reflections, and access platoon-wide shared entries and meal schedules.

---

## 📚 Features

- ✏️ Write and save a daily diary in 3 lines (with optional image attachment)  
- 📆 Calendar-based diary browsing interface  
- 📁 Local storage with SQLite via sqflite  
- 🔎 View diaries written by fellow platoon members (if set to public)  
- 🍽️ Meal schedule viewer using CSV data fetched from Google Drive  
- 🚪 User authentication & session management  

---

## 🔄 Project Structure

```
lib/
├── db/
│   ├── diary_database.dart        # CRUD for diaries (with image & public flag)
│   └── user_database.dart         # CRUD for user accounts (username, platoon, etc)
├── screens/
│   ├── calendar_screen.dart       # Main calendar UI
│   ├── diary_screen.dart          # Write/edit a diary with image upload
│   ├── login_screen.dart          # Login UI
│   ├── signup_screen.dart         # Signup form
│   ├── meal_screen.dart           # Meal CSV loader and display
│   └── other_diaries_screen.dart  # List of other users' public diaries
└── main.dart                      # App entry point (initializes and wipes DB)
```

---

## 🧩 Data Model

### User

- `username`, `password`, `name`, `birthdate`  
- `platoon`, `battalion`, `company`  

### Diary

- `date`, `content` (<= 20 chars)  
- `imagePath`: optional image file  
- `isPublic`: public/private toggle  
- `userId`, `platoon`, `battalion`  

---

## ⚙️ Tech Stack

### Frontend  
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)  
![Material UI](https://img.shields.io/badge/Material--UI-0081CB?style=for-the-badge&logo=mui&logoColor=white)  
![TableCalendar](https://img.shields.io/badge/TableCalendar-%2312100E?style=for-the-badge&logo=googlecalendar&logoColor=white)  
![Image Picker](https://img.shields.io/badge/Image%20Picker-FFCC00?style=for-the-badge)

### Database  
![Sqflite](https://img.shields.io/badge/Sqflite-SQLite-003B57?style=for-the-badge&logo=sqlite&logoColor=white)

### Data Fetching  
![HTTP](https://img.shields.io/badge/HTTP_Package-00ADD8?style=for-the-badge)  
![Google Drive](https://img.shields.io/badge/Google%20Drive-4285F4?style=for-the-badge&logo=googledrive&logoColor=white)

### Architecture  
![StatefulWidget](https://img.shields.io/badge/StatefulWidget-009688?style=for-the-badge)  
![Custom DB Helper](https://img.shields.io/badge/Custom%20DB%20Helper-607D8B?style=for-the-badge)

---

## 🚀 How to Run

```bash
flutter pub get
flutter run
```

> **Note:** `main.dart` clears the database on app start for development convenience. Remove or modify for production use.

---

## 🏡 Use Case

This app was developed as a personal capstone-like project, targeting soldiers who want a lightweight and structured way to record their military life daily in under 3 lines. It includes:

- Community sharing (among platoon)  
- Privacy control  
- Contextual integration with meal information  

---

## 🔮 Future Improvements

- Firebase auth & Firestore for real backend integration  
- Notification feature for diary reminders  
- Expanded text support (currently limited to 20 characters)  
- UI optimization with Riverpod or BLoC  
