<<<<<<< HEAD
# 🚍 Travel Fleet Management

A comprehensive **offline-first** Flutter mobile app for managing a travel fleet — including cars, trips, billing, driver payroll, and leave management.

## Features

| Module | Description |
|--------|-------------|
| **Authentication** | Local login with role-based dashboards (Owner / Employee / Driver) |
| **Car Management** | Add/edit vehicles, track KM, highlight expired documents & service alerts |
| **Trip Booking** | Create bookings, assign car & driver, start/end trips with KM tracking |
| **Billing** | Auto-calculated bills with KM amount, driver bata, rent, charges, and advances |
| **Payments** | Track payment status (Paid / Pending) per bill |
| **Driver Payroll** | View total trips, working days, and bata earned per driver |
| **Leave Management** | Drivers apply leave; Owner approves/rejects |
| **Alerts** | FC, Insurance, PUC expiry warnings; Service KM nearing alerts |

## Default Login

| Role | Username | Password |
|------|----------|----------|
| Owner | `owner` | `owner123` |

> Add employees and drivers from the database or extend the UI with a user-management screen.

## Tech Stack

- **Flutter** (single codebase – Android & iOS)
- **SQLite** via `sqflite` (offline-first local database)
- **intl** for date formatting
- **Material Design** UI

## Project Structure

```
lib/
├── core/          # Constants, theme, routes
├── database/      # SQLite helper (db_helper.dart)
├── models/        # Data models (user, car, trip, bill, payment, leave, advance)
├── services/      # Business logic services
├── screens/       # UI screens organised by module
└── widgets/       # Reusable UI components
```

## Database Schema

| Table | Purpose |
|-------|---------|
| `users` | App users with roles |
| `cars` | Vehicle details and expiry dates |
| `trips` | Bookings with KM readings & charges |
| `advances` | Advance payments per trip |
| `bills` | Generated invoices |
| `payments` | Payment status tracking |
| `leaves` | Driver leave requests |
| `bata_config` | Configurable bata rates per vehicle type |

## Billing Formula

```
Total KM    = End KM − Start KM
KM Amount   = Total KM × Rate per KM
Driver Bata = Vehicle Bata per Day × Number of Days
Total       = KM Amount + Driver Bata + Rent + Charges
Payable     = Total − Advance
```

## Getting Started

```bash
flutter pub get
flutter run
```

### Build APK
```bash
flutter build apk --release
```

### Build iOS
```bash
flutter build ios --release
```
=======
# Travel_fleet
>>>>>>> 879a853110c4bbba03fefb55f453e0bb02643538
