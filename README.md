# Zynco Connect

Local services marketplace app — Flutter + Supabase

## Architecture
- Flutter 3.19 (Dart)
- Supabase (Auth + PostgreSQL + Realtime + Storage)
- go_router (Navigation)
- Provider (State management)

## Screens
### Auth
- Age Verification (first launch only)
- Login + Register (with Customer/Provider role selection)
- Forgot Password

### Customer (6 tabs)
- Map — providers on map with location, filters, popups
- Explore — search + filter providers list
- Saved — favorite providers
- Bookings — all/pending/confirmed/completed
- Chats — realtime messaging
- Me — profile edit

### Provider (5 tabs)  
- Dashboard — stats, recent bookings, plan card
- Bookings — confirm/cancel with tabs
- Chats — customer messages
- Plan — subscription tiers + coming soon
- Me — profile

### Shared
- Provider Profile — gallery, reviews, booking dialog
- Chat Screen — realtime messages

## Build
```bash
flutter pub get
flutter build apk --release
flutter build ios --release --no-codesign
```

## CI/CD
GitHub Actions builds APK (Android) and IPA (iOS) on every push.
