# Real-Time Vehicle Parts Inventory & Billing (Flutter + Firebase)

Dark theme (black/orange/white) app for vehicle parts management.

Features: Authentication (staff & customer), inventory CRUD, search/filtering, low-stock alerts, QR scanning & billing, simple sales reports, delivery status tracking.

## 1. Prerequisites
* Flutter SDK 3.x
* Android Studio emulator or real device
* Firebase project

## 2. Firebase Setup (Android)
1. Create project at https://console.firebase.google.com.
2. Add Android app with package name: `com.example.parts`.
3. Download `google-services.json` and copy to `android/app/`.
4. Enable Email/Password in Authentication.
5. Create Firestore (Production mode).
6. (Optional) Add initial collections: `users`, `parts`, `sales`, `orders`.

Security rules (basic dev example):
```
rules_version = '2';
service cloud.firestore {
	match /databases/{database}/documents {
		match /users/{uid} {
			allow read, write: if request.auth != null && request.auth.uid == uid;
		}
		match /parts/{id} {
			allow read: if true; // Everyone can view parts
			allow write: if request.auth != null; // Require login for writes
		}
		match /sales/{id} {
			allow read, write: if request.auth != null;
		}
		match /orders/{id} {
			allow read, write: if request.auth != null;
		}
	}
}
```

## 3. Install Packages
```powershell
flutter pub get
```

## 4. Run
```powershell
flutter run
```

## 5. Usage Flow
1. Register (choose role: customer or staff).
2. Staff: Add parts, edit quantities.
3. Anyone: View parts list; low stock shows a red warning icon.
4. Billing: Scan QR (uses part document ID); confirm cart & checkout.
5. Reports: View sales totals (today/week/month).
6. Delivery: Update order status.

## 6. Part Images
Add `imageUrl` with HTTPS link in part doc. Future improvement: integrate Firebase Storage upload (create a storage bucket, use `firebase_storage` plugin, upload file, store download URL).

## 7. Firestore Document Shapes
```
parts/{partId} => { name, category, price, quantity, lowStockThreshold, imageUrl?, qrData }
sales/{saleId} => { partIds:[], total, createdAt }
orders/{orderId} => { status, createdAt, items? }
users/{uid} => { email, role, createdAt }
```

## 8. Future Enhancements
* Firebase Storage for images
* Push notifications for low stock
* Role-based admin dashboard
* Offline caching
* AI-based stock prediction

## 9. Troubleshooting
If Firebase init fails: ensure `google-services.json` exists and run `flutter clean; flutter pub get`.

## 10. License
Academic / FYP usage.
