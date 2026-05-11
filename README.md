# ⚽ KooraSpot Platform

![.NET 8](https://img.shields.io/badge/.NET-8.0-512BD4?logo=dotnet)
![Flutter](https://img.shields.io/badge/Flutter-Mobile%20App-02569B?logo=flutter)
![SQL Server](https://img.shields.io/badge/Database-SQL%20Server-red)
![Architecture](https://img.shields.io/badge/Architecture-Full%20Stack-blue)

> [!NOTE]
> KooraSpot is a full-stack football field booking platform that allows players to discover football fields, book available time slots, pay online securely, and manage bookings.  
> Field owners can manage fields, bookings, earnings, and withdrawals through a complete management system.

---

# 🏗️ 1. System Architecture

KooraSpot is developed using a modern Full-Stack Architecture consisting of:

- Flutter Mobile Application
- ASP.NET Core Web API Backend
- SQL Server Database
- Stripe Payment Gateway
- JWT Authentication
- OTP Email Verification

---

## 📂 System Components

### 📱 Flutter Mobile Application

The mobile application provides two main user roles:

### Player Features
- Register & Login
- Email OTP Verification
- Browse football fields
- Search and filter fields
- View available slots
- Book football fields
- Stripe online payment
- Favorites system
- Booking history
- Profile management

### Owner Features
- Create football fields
- Upload field images
- Manage available slots
- Activate / deactivate fields
- View bookings
- Track earnings
- Withdraw wallet balance
- Manage profile

---

### ⚙️ ASP.NET Core Web API

The backend handles:

- Authentication & Authorization
- JWT Token generation
- OTP Email verification
- Password reset system
- Booking management
- Slot availability logic
- Stripe payment integration
- Wallet & withdrawal calculations
- Database operations
- REST API endpoints

---

### 🗄️ SQL Server Database

The database stores:

- Users
- Football fields
- Field images
- Time slots
- Bookings
- Payments
- Favorite fields
- Withdrawals
- OTP verification codes

---

# 🛠️ 2. Technology Stack & Frameworks

## Frontend Technologies
- Flutter
- Dart
- REST API Integration

## Backend Technologies
- ASP.NET Core Web API
- C#
- Entity Framework Core
- JWT Authentication
- BCrypt Password Hashing

## Database
- Microsoft SQL Server

## Payment Integration
- Stripe Checkout
- Stripe Webhooks

## Email Services
- Brevo Email API

## Development Tools
- Visual Studio 2022
- VS Code
- Postman
- Swagger
- SQL Server Management Studio
- GitHub

---

# 🔌 3. External Services

> [!IMPORTANT]
> The system depends on external services that require API keys and configuration.

| Service | Purpose |
|---|---|
| Stripe | Online payment processing |
| Brevo | OTP email verification |
| MonsterASP.NET | Backend hosting |
| SQL Server | Database hosting |

---

# 🔐 4. Authentication & Security

The platform includes:

- JWT Authentication
- Role-based Authorization
- BCrypt password hashing
- OTP Email Verification
- Password Reset OTP
- HTTPS Security

---

# 💳 5. Payment System

KooraSpot integrates Stripe payment gateway for secure online payments.

### Payment Flow

1. Player selects field and slot
2. Booking is created
3. Stripe checkout session starts
4. Payment is completed
5. Stripe webhook verifies payment
6. Booking becomes confirmed
7. Owner wallet balance is updated

---

# 💰 6. Wallet & Withdrawals System

The system includes an owner wallet feature:

- Owners receive booking earnings
- Platform commission is deducted automatically
- Withdrawal requests are stored in database
- Owners can track withdrawals history

---

# 🌐 7. API Modules Overview

The backend API is divided into multiple modules:

## Authentication Module
- Register
- Login
- Verify Email OTP
- Forgot Password
- Reset Password

## Fields Module
- Create field
- Update field
- Delete field
- Toggle field active state
- Get owner fields

## Slots Module
- Create slots
- Manage slot availability

## Bookings Module
- Create bookings
- Confirm bookings
- Booking history

## Favorites Module
- Add/remove favorites
- Retrieve favorite fields

## Payments Module
- Stripe checkout
- Stripe webhook verification

## Wallet Module
- Wallet summary
- Withdraw requests
- Earnings tracking

---

# 🚀 8. Setup and Run Instructions

## Prerequisites

### Backend Requirements
- .NET 8 SDK
- SQL Server
- Visual Studio 2022

### Flutter Requirements
- Flutter SDK
- Dart SDK
- Android Studio or VS Code

---

# 📦 9. Installation Steps

## Clone Repository

```bash
git clone https://github.com/your-username/KooraSpot.git
```

---

## Backend Setup

```bash
cd src/backend
dotnet restore
dotnet build
dotnet run
```

Swagger URL:

```text
https://localhost:7149/swagger
```

---

## Flutter Setup

```bash
cd src/flutter
flutter pub get
flutter run
```

---

# ⚙️ 10. Environment Configuration

Example `appsettings.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "YOUR_SQL_CONNECTION"
  },

  "Jwt": {
    "Key": "YOUR_SECRET_KEY",
    "Issuer": "KooraSpot",
    "Audience": "KooraSpotUsers"
  },

  "Stripe": {
    "SecretKey": "YOUR_STRIPE_SECRET"
  },

  "Brevo": {
    "ApiKey": "YOUR_BREVO_API_KEY"
  }
}
```

> [!WARNING]
> Do not upload real API keys or secrets to GitHub.

---

# 🗄️ 11. Database Structure

Main database tables:

- Users
- PasswordResetOtps
- Fields
- FieldImages
- TimeSlots
- FieldSlotAvailabilities
- Bookings
- Payments
- FavoriteFields
- Withdrawals

---

# 📱 12. APK & Executable

Release APK can be found inside:

```text
/exe/app-release.apk
```

Install on Android device to run the application.

---

# 🌍 13. Deployment

Backend deployment includes:

- MonsterASP.NET hosting
- SQL Server database hosting
- HTTPS enabled server
- Public REST API

---

# 🧪 14. Testing

The system was tested using:

- Postman
- Swagger
- Flutter debugging tools
- SQL Server queries
- Stripe test cards

---

# 🔮 15. Future Improvements

- Google Maps Integration
- Push Notifications
- Real-time booking updates
- Ratings & Reviews
- AI field recommendations
- Admin dashboard analytics

---

# 👨‍💻 Team Members

| Name | Role |
|---|---|
| Mohamed Samy | Backend Developer |
| Mohamed Ashraf | Backend Developer |
| George Nabil Awad | Flutter Developer |
| Omar Alaa | Flutter Developer |

---

# 🎓 Supervisor

- Dr. Hussein Akram

---

# ✅ Project Status

✔ Backend Completed  
✔ Flutter Application Completed  
✔ SQL Server Database Completed  
✔ Stripe Integration Completed  
✔ OTP Verification Completed  
✔ Wallet System Completed  
✔ Deployment Completed