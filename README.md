# Travel Fleet

Travel Fleet is a full-stack travel business management system with:
- Flutter mobile app (Android + iOS)
- Node.js + Express backend
- MongoDB Atlas
- JWT auth + role-based access
- Billing with invoice PDF generation
- Fleet expiry/service reminders
- Notification center + optional FCM push notifications

## Repository Structure

- `backend/`: Express API server
- `flutter_app/`: Flutter app (Riverpod + Material 3)

## Features Implemented

- Authentication: Register / Login (Owner, Employee, Driver)
- Trip management: Schedule with customer name/mobile, driver+vehicle assignment, list, update, start, end, advance
- Billing: Create bill, automatic calculations, PDF invoice generation, list bills
- Vehicle management: Create/list vehicles with category and seat count, service and expiry reminder scheduler
- Driver management: Create/list driver, optional unique driver login linking, leave apply/approve, payroll summary endpoint
- Payment tracking: Create/list/update payment status, sync with bill status
- Notifications: In-app notifications and mark-as-read
- Owner dashboard: Add users (owner/employee/driver) from app menu
- Settings: Update own profile (name/email/password) and switch light/dark/system theme
- Trip operation controls: Driver bata assignment done separately from trip creation and auto-credited after trip completion
- Bata management: Owner/Employee can set driver bata per vehicle category (sedan/suv/mvp/van/hatchback/luxury/mini_bus/other)
- Driver operations: Leave request/approval workflow and payroll summary with automatic salary+bata calculation

## Backend Setup

### 1. Install dependencies

```bash
cd backend
npm install
```

### 2. Configure environment

Copy `.env.example` to `.env` and fill values:

```env
PORT=5000
MONGO_URI=mongodb+srv://<username>:<password>@cluster0.xxxxx.mongodb.net/travel-fleet?retryWrites=true&w=majority
JWT_SECRET=your_strong_secret
JWT_EXPIRES_IN=7d
FCM_PROJECT_ID=
FCM_CLIENT_EMAIL=
FCM_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYOUR_KEY\n-----END PRIVATE KEY-----\n"
EXPIRY_ALERT_DAYS=15
SERVICE_ALERT_KM_BUFFER=500
```

### 3. Run backend

```bash
npm run dev
```

Server starts at `http://localhost:5000`.

Health check:

```bash
curl http://localhost:5000/health
```

## Flutter Setup

### 1. Create Flutter platform folders (if not already present)

```bash
cd flutter_app
flutter create .
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run app

Android emulator:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000/api
```

Note: this works only when an Android emulator/device is actually selected. If no Android target is connected, `flutter run` can launch Linux desktop by default.

Linux desktop:

```bash
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:5000/api
```

iOS simulator:

```bash
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:5000/api
```

## API Endpoints

### Auth
- `POST /register`
- `POST /login`
- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/users` (owner only)
- `GET /api/auth/profile`
- `PUT /api/auth/profile`

### Trips
- `POST /api/trip`
- `GET /api/trips`
- `PUT /api/trip/:id`
- `PUT /api/trip/:id/start`
- `PUT /api/trip/:id/end`
- `POST /api/trip/:id/advance`
- `PUT /api/trip/:id/bata`

### Billing
- `POST /api/bill`
- `GET /api/bills`
- `GET /api/bill/:id/pdf`

### Vehicles
- `POST /api/vehicle`
- `GET /api/vehicles`
- `PUT /api/vehicle/:id`
- `GET /api/vehicle-bata-rates`
- `PUT /api/vehicle-bata-rates/:category`

### Drivers
- `POST /api/driver`
- `GET /api/drivers`
- `POST /api/driver/:id/leave`
- `PUT /api/driver/:id/leave/approve`
- `GET /api/driver/:id/payroll`

### Payments
- `POST /api/payment`
- `GET /api/payments`
- `PUT /api/payment/:id`

### Notifications
- `GET /api/notifications`
- `PUT /api/notifications/:id/read`

## Billing Formula

- `totalKm = endKm - startKm`
- `kmCharge = totalKm * ratePerKm`
- `totalAmount = kmCharge + dayRent + hourRent + driverBata + tollCharges + permitCharges + parkingCharges`
- `payableAmount = totalAmount - advanceReceived`

## Roles

- Owner: full access including leave approvals and billing oversight
- Employee: trip, fleet, billing, payment operations and driver bata assignment per trip
- Driver: start/end trip, apply leave, add advances

## Test Credentials

Use these accounts created during setup/API verification:

- Owner
	- Name: `barath`
	- Email: `barath@gmail.com`
	- Password: `pass@123`
- Employee
	- Name: `vikraman`
	- Email: `vikraman@gmail.com`
	- Password: `pass@123`
- Driver
	- Name: `ajay`
	- Email: `ajay@gmail.com`
	- Password: `pass@123`

If these accounts were deleted, create them again from Register page or via `POST /api/auth/register`.

## Notes

- PDF invoices are generated at `backend/uploads/invoices/`
- Reminder scheduler runs every day at 8:00 AM server time.
- FCM push notifications are optional and become active when Firebase env variables are configured.
