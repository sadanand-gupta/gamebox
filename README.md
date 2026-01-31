# GameBox – Flutter Games Demo App

A Flutter demo application showcasing mock authentication and a games dashboard built using local JSON data.

---

## 🎯 Overview
This app demonstrates:
- Mock authentication (Email & WhatsApp)
- Local data storage using shared_preferences
- Games dashboard with search and pagination
- JSON asset loading and performance-aware rendering

This project is built strictly for evaluation and demo purposes.

---

## 🚀 Features

### 1. Registration
- Register with Email (email + password)
- Register with WhatsApp (phone number)
- Input validation (email format, password length, phone format)
- No backend required

### 2. Login
- Email login using stored credentials
- WhatsApp login with mocked OTP flow
- Fixed OTP for testing: `123456`

### 3. Games Dashboard
- Games loaded from local JSON asset
- Incremental loading (20 items at a time) for performance
- Search by:
  - Game name
  - Category
  - Group name
- Each game card shows:
  - Thumbnail
  - Name
  - Category & group
  - Provider
  - Min & Max amounts
- Logout functionality

---

## 🧱 Tech Stack
- Flutter (latest stable)
- shared_preferences (mock local storage)
- Material Design
- JSON assets

---

## 🔐 Mock Authentication Notes
- No backend or real APIs
- Credentials stored locally using shared_preferences
- OTP is mocked (always `123456`)
- This approach is **demo-only** and not suitable for production

---

## 📊 JSON Data
Games are loaded from:
