# Trackify - Personal Expense Tracker

A modern Flutter application for tracking daily expenses with Firebase integration. Track spending patterns, manage expense records, and analyze your financial habits.

## Features Implemented

### 1. **Authentication System** ✅
- User registration with email validation
- Secure login with Firebase Authentication
- Password reset functionality
- Session persistence

### 2. **Expense Tracking** ✅
- **Add Expenses**: Create new expense entries with:
  - Category selection (10 predefined categories)
  - Amount and description
  - Custom date selection
  - Real-time validation

- **View Expenses**: 
  - List all expenses with category icons
  - Filter by category
  - Sort by date (newest first)
  - View total spending

- **Edit Expenses**: 
  - Modify amount, category, date, and description
  - Update Firestore in real-time
  - Visual confirmation

- **Delete Expenses**:
  - Remove expense records
  - Confirmation dialog before deletion
  - Immediate UI update

### 3. **Expense Analytics** ✅
- **Spending Summary**:
  - Total spending across all time
  - Current month spending
  - Daily average spending

- **Category Breakdown**:
  - Interactive pie chart showing spending distribution
  - Percentage breakdown for each category
  - Visual color coding

- **Recent Expenses Dashboard**:
  - View last 10 transactions
  - Quick transaction overview

### 4. **User Interface** ✅
- Clean Material Design 3 aesthetic
- Dark/Light theme support
- Responsive bottom navigation
- Intuitive category selection with emoji icons
- Smooth animations and transitions
- Loading states and error handling

### 5. **Data Persistence** ✅
- Cloud Firestore for real-time data storage
- User-specific data isolation
- Automatic sync across devices
- Offline capabilities (Firebase offline persistence)

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── expense_categories.dart
│   ├── routes/
│   │   └── app_router.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       ├── formatters.dart
│       └── validators.dart
├── data/
│   └── repositories/
│       ├── auth_repository.dart
│       └── expense_repository.dart
├── domain/
│   └── models/
│       ├── user_model.dart
│       └── expense_model.dart
├── presentation/
│   ├── bloc/
│   │   ├── auth/
│   │   │   ├── auth_bloc.dart
│   │   │   ├── auth_event.dart
│   │   │   └── auth_state.dart
│   │   ├── expense/
│   │   │   ├── expense_bloc.dart
│   │   │   ├── expense_event.dart
│   │   │   └── expense_state.dart
│   │   └── theme/
│   │       └── theme_cubit.dart
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   └── expense/
│   │       ├── expense_list_screen.dart
│   │       ├── add_expense_screen.dart
│   │       ├── edit_expense_screen.dart
│   │       └── expense_analytics_screen.dart
│   └── widgets/
└── main.dart
```

## Tech Stack

- **Frontend**: Flutter 3.10.7+
- **State Management**: BLoC Pattern with flutter_bloc
- **Backend**: Firebase
  - Firebase Authentication
  - Cloud Firestore
- **UI**: Material Design 3
- **Charts**: fl_chart
- **Navigation**: GoRouter
- **Additional Libraries**:
  - `equatable`: Value equality
  - `intl`: Date formatting
  - `uuid`: Unique ID generation
  - `google_fonts`: Typography
  - `lottie`: Animations

## Architecture

The app follows **Clean Architecture** principles:

```
Presentation Layer
├── Screens (UI)
├── Widgets (Reusable components)
└── BLoC (State management)
          ↕
Domain Layer (Business Logic)
├── Models
└── Repositories (Interfaces)
          ↕
Data Layer
├── Repositories (Implementation)
└── Data Sources (Firebase)
```

### State Management Pattern

Using the **BLoC Pattern** for robust state management:

- **ExpenseBloc**: Manages all expense-related operations
  - Events: LoadExpenses, AddExpense, UpdateExpense, DeleteExpense, LoadAnalytics, FilterByCategory
  - States: Loading, Loaded, Error, Analytics, Filtered, Success

- **AuthBloc**: Handles authentication
  - Events: SignUp, SignIn, SignOut, CheckAuth
  - States: Initial, Loading, Authenticated, Unauthenticated, Error

- **ThemeCubit**: Simple theme switching

## Setup Instructions

### Prerequisites
- Flutter SDK 3.10.7 or higher
- Dart SDK compatible with Flutter
- Firebase project with Firestore and Auth enabled
- Android SDK (for Android) or Xcode (for iOS)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd trackify
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Create a new project or use existing one
   - Enable Firestore Database (in production mode)
   - Enable Email/Password Authentication
   - Download google-services.json (Android) and GoogleService-Info.plist (iOS)
   - Add these files to your project

4. **Run the app**
   ```bash
   flutter run
   ```

## Firebase Setup

### Firestore Rules (Production)
```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;
      
      match /expenses/{expenseId} {
        allow read, write: if request.auth.uid == uid;
      }
    }
    
    match /expenses/{expenseId} {
      allow read, write: if request.auth.uid == resource.data.userId;
      allow create: if request.auth.uid == request.resource.data.userId;
    }
  }
}
```

### Firestore Collections Structure
```
users/
├── {userId}/
│   ├── email: string
│   ├── displayName: string
│   ├── photoUrl: string
│   ├── credits: number
│   ├── createdAt: timestamp
│   └── updatedAt: timestamp

expenses/
├── {expenseId}/
│   ├── userId: string
│   ├── category: string
│   ├── amount: number
│   ├── description: string
│   ├── date: timestamp
│   ├── createdAt: timestamp
│   └── updatedAt: timestamp
```

## Key Features Explanation

### 1. Expense Categories
```dart
'Food', 'Transportation', 'Entertainment', 'Shopping', 
'Utilities', 'Healthcare', 'Education', 'Travel', 'Sports', 'Other'
```
Each category has a unique emoji icon for quick visual identification.

### 2. Analytics Dashboard
- **Pie Chart**: Visual representation of spending distribution
- **Summary Cards**: Key metrics at a glance
- **Category Breakdown**: Detailed list with percentages
- **Recent Transactions**: Quick view of latest expenses

### 3. Real-time Updates
- Using Firestore streams for live data synchronization
- Automatic UI refresh when data changes
- Real-time analytics updates

### 4. Error Handling
- User-friendly error messages
- Retry mechanisms
- Validation before submission
- Network error handling

## Usage Guide

### Adding an Expense
1. Navigate to Expenses tab
2. Click the "+" FAB or use Quick Actions → "Add Expense"
3. Select category
4. Enter amount (required)
5. Add description (optional)
6. Select date (defaults to today)
7. Tap "Add Expense"

### Viewing Expenses
1. Go to Expenses tab
2. Browse all expenses
3. Filter by category using chips
4. Tap on expense to edit
5. Long-press to delete

### Analyzing Spending
1. Tap Analytics icon in Expenses header
2. View summary cards
3. Check pie chart for category distribution
4. Review recent transactions
5. See detailed category breakdown

## Performance Considerations

1. **Pagination**: Future enhancement for large datasets
2. **Caching**: Local BLoC state management reduces API calls
3. **Lazy Loading**: Uses streams for efficient data loading
4. **Image Optimization**: All assets are optimized
5. **Code Splitting**: Feature-based module structure

## Security Best Practices

1. **Authentication**: Email/password via Firebase Auth
2. **Data Isolation**: User-specific Firestore security rules
3. **Input Validation**: Client-side validation on all inputs
4. **Error Handling**: Graceful error messages without exposing sensitive info

## Roadmap (Future Enhancements)

- [ ] Recurring expenses
- [ ] Budget limits and alerts
- [ ] Multi-currency support
- [ ] Export to CSV/PDF
- [ ] Shared expenses (split bills)
- [ ] Push notifications for budget alerts
- [ ] Advanced filtering and search
- [ ] Monthly/yearly reports
- [ ] Screenshots and receipt uploads
- [ ] Social features (sharing achievements)

## Testing

```bash
# Run tests
flutter test

# Build APK
flutter build apk

# Build iOS
flutter build ios
```

## Troubleshooting

### Firebase Connection Issues
- Verify Firebase credentials are correct
- Check internet connection
- Ensure Firestore is enabled in Firebase Console

### Build Errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### State Management Issues
- Ensure BLoC providers are in the widget tree
- Check event is being triggered correctly
- Verify state is being emitted properly

## Code Quality

- **Null Safety**: Full null safety implementation
- **Equatable**: Used for value-based equality checks
- **Constants**: All magic strings are constants
- **Error Handling**: Comprehensive try-catch blocks
- **Comments**: Clear documentation throughout

## Database Schema

### Users Collection
```dart
{
  'email': 'user@example.com',
  'displayName': 'John Doe',
  'photoUrl': 'https://...',
  'credits': 1000.0,
  'createdAt': Timestamp,
  'updatedAt': Timestamp
}
```

### Expenses Collection
```dart
{
  'userId': 'user123',
  'category': 'Food',
  'amount': 25.50,
  'description': 'Lunch at restaurant',
  'date': Timestamp,
  'createdAt': Timestamp,
  'updatedAt': Timestamp
}
```

## Implementation Notes

### What Makes This Expense Tracker Excellent

1. **User-Centric Design**: Simple, intuitive interface that doesn't overwhelm users
2. **Real-Time Sync**: Firestore streams keep data synchronized instantly
3. **Offline Support**: Firebase offline persistence ensures app works without internet
4. **Clean Code**: Following Clean Architecture for maintainability
5. **Scalability**: Ready to add more features like recurring expenses, budgets, etc.
6. **Analytics**: Visual dashboard helps users understand spending patterns
7. **Security**: Firebase security rules prevent unauthorized data access

### Development Decisions

- **BLoC Pattern**: Chosen for its scalability and testability
- **Firestore**: Real-time database perfect for expense tracking
- **GoRouter**: Modern routing solution for Flutter
- **Material Design 3**: Latest design system for modern UI
- **Emoji Icons**: Simple, cross-platform way to identify categories

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## License

This project is licensed under the MIT License - see LICENSE file for details.

## Contact

For questions or support, please reach out through the GitHub repository.

---

**Built with ❤️ using Flutter and Firebase**
