# Trackify - Integration Architecture Guide

## 🏗️ System Architecture Overview

```
┌──────────────────────────────────────────────────────────────────┐
│                      Presentation Layer                          │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │ Screens:                       │ BLoC:                     │  │
│  │ - ExpenseListScreen            │ - ExpenseBloc             │  │
│  │ - AddExpenseScreen             │ - AuthBloc               │  │
│  │ - EditExpenseScreen            │ - ThemeCubit             │  │
│  │ - ExpenseAnalyticsScreen       │                          │  │
│  │ - HomeScreen (updated)         │ Events & States          │  │
│  └────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────┘
                              ↕
┌──────────────────────────────────────────────────────────────────┐
│                       Domain Layer                               │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │ Models:                                                    │  │
│  │ - ExpenseModel (with Firestore serialization)             │  │
│  │ - UserModel                                               │  │
│  │                                                            │  │
│  │ Constants:                                                │  │
│  │ - ExpenseCategories (10 categories with emojis)           │  │
│  └────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────┘
                              ↕
┌──────────────────────────────────────────────────────────────────┐
│                        Data Layer                                │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │ Repositories:                                              │  │
│  │ - ExpenseRepository (Firestore CRUD operations)           │  │
│  │ - AuthRepository                                          │  │
│  │                                                            │  │
│  │ Data Source:                                               │  │
│  │ - Cloud Firestore (Real-time Database)                   │  │
│  │ - Firebase Authentication                                │  │
│  └────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────┘
```

## 📊 Data Flow Architecture

### Add Expense Flow
```
User Input (AddExpenseScreen)
    ↓
Validation (Amount, Category)
    ↓
Create ExpenseModel with userId
    ↓
AddExpenseRequested Event → ExpenseBloc
    ↓
ExpenseBloc executes handler
    ↓
ExpenseRepository.addExpense()
    ↓
Save to Firestore collection 'expenses'
    ↓
ExpenseOperationSuccess State
    ↓
ListenStream → ExpensesLoaded State
    ↓
UI Updates (List refreshes)
    ↓
Show in ExpenseListScreen
```

### Edit Expense Flow
```
User Taps Expense → EditExpenseScreen
    ↓
Load existing expense data
    ↓
User modifies fields
    ↓
Validation check
    ↓
UpdateExpenseRequested Event → ExpenseBloc
    ↓
ExpenseRepository.updateExpense()
    ↓
Update Firestore document
    ↓
Stream emits updated list
    ↓
ExpensesLoaded State with fresh data
    ↓
UI Updates automatically
```

### Analytics Flow
```
User Taps Analytics Icon
    ↓
LoadAnalyticsRequested Event → ExpenseBloc
    ↓
Parallel Operations:
├─ getUserExpenses() → Get all expenses
├─ getSpendingByCategory() → Aggregate by category
├─ getTotalSpending() → Sum all amounts
├─ getMonthlySpendings() → Current month total
└─ Calculate averageDailySpending
    ↓
ExpenseAnalyticsLoaded State with all data
    ↓
ExpenseAnalyticsScreen Displays:
├─ Summary Cards
├─ Pie Chart (fl_chart)
├─ Category Breakdown
└─ Recent Transactions
```

## 🔄 Real-Time Synchronization

```
Firestore Collection: 'expenses'
             ↓
Stream: expenseRepository.getUserExpenses(userId)
             ↓
BLoC Event Listener
             ↓
State Emission (ExpensesLoaded with fresh data)
             ↓
StreamBuilder/BlocBuilder re-renders
             ↓
UI Updates automatically
             ↓
Changes visible instantly across all screens
```

## 🎯 BLoC Event State Mapping

### ExpenseBloc Events & States

| Event | Handler | Emits | Next State |
|-------|---------|-------|-----------|
| LoadExpensesRequested | `_onLoadExpensesRequested` | ExpenseLoading → ExpensesLoaded | Show list |
| AddExpenseRequested | `_onAddExpenseRequested` | ExpenseLoading → Success → Reload | Refresh list |
| UpdateExpenseRequested | `_onUpdateExpenseRequested` | ExpenseLoading → Success → Reload | Show updated |
| DeleteExpenseRequested | `_onDeleteExpenseRequested` | ExpenseLoading → Success → Reload | Refresh list |
| LoadAnalyticsRequested | `_onLoadAnalyticsRequested` | ExpenseLoading → ExpenseAnalyticsLoaded | Show dashboard |
| FilterByCategoryRequested | `_onFilterByCategoryRequested` | ExpenseLoading → ExpensesFiltered | Show filtered |
| ClearFiltersRequested | `_onClearFiltersRequested` | - | Reload all |

## 🔐 User Data Isolation

```
User A (uid: user123)
    ├─ Auth verified by Firebase
    └─ Expenses where userId == 'user123'
            ↓
       Can view/edit/delete only own expenses
       
User B (uid: user456)
    ├─ Auth verified by Firebase
    └─ Expenses where userId == 'user456'
            ↓
       Cannot see User A's expenses
       (Firestore rules enforce this)
```

## 📱 Screen Hierarchy & Navigation

```
SplashScreen
    ↓
    ├─ (User not logged in) → LoginScreen
    │       ↓
    │       ├─ Navigate to Register
    │       │   ↓
    │       │   RegisterScreen → Back to Login
    │       │
    │       └─ Login → go to HomeScreen
    │
    └─ (User logged in) → HomeScreen
            ↓
            │
            ├─ Home Tab (Selected by default)
            │   ├─ Quick Actions
            │   ├─ Add Expense → AddExpenseScreen
            │   └─ Logout → LoginScreen
            │
            ├─ Expenses Tab
            │   ├─ List all expenses
            │   ├─ Filter by category
            │   ├─ Add Expense → AddExpenseScreen
            │   ├─ Edit Expense → EditExpenseScreen
            │   ├─ Delete confirmation
            │   └─ Analytics → ExpenseAnalyticsScreen
            │
            └─ Profile Tab (Future)
```

## 💾 Firestore Schema

### Collections Structure

```
firestore
├── users/
│   └── {userId}/
│       ├── email: String
│       ├── displayName: String
│       ├── photoUrl: String (optional)
│       ├── credits: double
│       ├── createdAt: Timestamp
│       └── updatedAt: Timestamp
│
└── expenses/
    └── {expenseId}/
        ├── userId: String (for querying)
        ├── category: String (Food, Travel, etc.)
        ├── amount: double
        ├── description: String
        ├── date: Timestamp
        ├── createdAt: Timestamp
        └── updatedAt: Timestamp
```

### Firestore Indexes

```
Collection: expenses
Queries optimized with indexes:
├─ userId (Ascending)
├─ date (Descending)
├─ category (Ascending)
└─ userId + date (Composite)
```

## 🔗 Dependency Injection Tree

```
main.dart
    ↓
MultiRepositoryProvider
    ├─ AuthRepository (Singleton)
    └─ ExpenseRepository (Singleton)
            ↓
MultiBlocProvider
    ├─ AuthBloc (uses AuthRepository)
    ├─ ExpenseBloc (uses ExpenseRepository)
    └─ ThemeCubit
            ↓
Screens access via:
├─ context.read<ExpenseBloc>()
├─ context.read<ExpenseRepository>()
└─ context.select<ExpenseBloc, T>()
```

## 🎨 UI Component Tree

### ExpenseListScreen Widget Tree
```
ExpenseListScreen
├─ Scaffold
│   ├─ AppBar
│   │   ├─ Title: 'My Expenses'
│   │   └─ Analytics Button
│   │
│   ├─ CustomScrollView
│   │   └─ SliverList
│   │       ├─ Category Filter Chips
│   │       ├─ Total Spending Card
│   │       └─ ExpenseListItems
│   │           ├─ Category Icon
│   │           ├─ Category + Description
│   │           ├─ Date
│   │           └─ Amount
│   │
│   └─ FAB: Add Expense
└─ BottomNavigationBar
```

### ExpenseAnalyticsScreen Widget Tree
```
ExpenseAnalyticsScreen
├─ Scaffold
│   ├─ AppBar: 'Spending Analytics'
│   │
│   └─ SingleChildScrollView
│       ├─ SummaryCards (3 cards)
│       │   ├─ Total Spending
│       │   ├─ This Month
│       │   └─ Daily Average
│       │
│       ├─ PieChart
│       │   └─ fl_chart visualization
│       │
│       ├─ CategoryBreakdown
│       │   └─ List with percentages
│       │
│       └─ RecentTransactions
│           └─ Last 10 expenses
```

## ⚡ Performance Optimization Points

### 1. Firestore Queries
```dart
// Indexed query for fast results
.where('userId', isEqualTo: userId)
.where('date', isGreaterThanOrEqualTo: startDate)
.orderBy('date', descending: true)
```

### 2. Stream Management
```dart
// Uses streams instead of polling
expenseRepository.getUserExpenses(userId).listen(...)
// Only updates when data changes
```

### 3. Widget Building
```dart
// CustomScrollView for efficient rendering
// SliverList for lazy loading
// BlocBuilder prevents unnecessary rebuilds
```

### 4. BLoC Caching
```dart
// State is cached in BLoC
// Prevents redundant Firestore queries
// Stream handles real-time updates
```

## 🛡️ Error Handling Flow

```
Operation (Add/Update/Delete)
    ↓
Try Block
├─ Execute Firestore operation
│   ├─ Success → Emit Success State
│   └─ Exception
│       ↓
├─ Catch Block
│   └─ Parse error message
│       ├─ Network error
│       ├─ Permission error
│       ├─ Validation error
│       └─ Unknown error
│           ↓
├─ Emit ExpenseError(message)
│   ↓
└─ UI Shows
    ├─ SnackBar with error
    ├─ Retry button
    └─ Clear error state
```

## 🔄 State Management Lifecycle

```
BLoC State Lifecycle
│
├─ Initial: ExpenseInitial()
│   └─ No data loaded yet
│
├─ Loading: ExpenseLoading()
│   └─ Fetching from Firestore
│
├─ Loaded: ExpensesLoaded(expenses, total)
│   ├─ Data available
│   ├─ AutoDisplay in UI
│   └─ Stream auto-updates
│
├─ Error: ExpenseError(message)
│   ├─ Show error to user
│   ├─ Provide retry option
│   └─ Clear after interaction
│
├─ Analytics: ExpenseAnalyticsLoaded(...)
│   ├─ Summary metrics
│   ├─ Category breakdown
│   └─ Recent expenses
│
├─ Filtered: ExpensesFiltered(expenses, category, total)
│   ├─ Filter applied
│   └─ Show filtered list
│
└─ Success: ExpenseOperationSuccess(message)
    ├─ Operation completed
    ├─ Show confirmation
    └─ Auto-reload data
```

## 🚀 Feature Integration Points

### How Expense Module Integrates with App

1. **Main.dart Integration**
   ```dart
   - Registers ExpenseRepository in MultiRepositoryProvider
   - Creates ExpenseBloc with flutter_bloc
   - Available to all widgets down the tree
   ```

2. **Router Integration**
   ```dart
   - 4 new routes added to GoRouter
   - Dynamic parameter for edit route (/expense-edit/:id)
   - Navigation with context.push()
   ```

3. **Home Screen Integration**
   ```dart
   - Expense tab in BottomNavigationBar
   - Quick action cards for Add & Analytics
   - Navigation to expense screens
   ```

4. **Theme Integration**
   ```dart
   - UI respects theme from ThemeCubit
   - Dark/light mode support
   - Proper color contrast
   ```

## 📈 Scalability Considerations

### Ready for Future Features
```
├─ Recurring Expenses
│   └─ Add recurring_expenses collection
│
├─ Budget Limits
│   └─ Add budgets collection
│
├─ Shared Expenses
│   └─ Add shared_expenses collection
│
├─ Receipt Images
│   └─ Firebase Storage integration
│
└─ Export/Reports
    └─ Data aggregation functions
```

### Code Extensibility
```
├─ Add new events to ExpenseEvent
├─ Add new states to ExpenseState
├─ Add new handlers in ExpenseBloc
├─ Create new repository methods
└─ Add new screens and routes
```

---

## ✅ Integration Verification

- [x] ExpenseBloc properly initialized in main.dart
- [x] ExpenseRepository singleton created
- [x] All routes registered in app_router.dart
- [x] HomeScreen navigation integrated
- [x] Real-time streams working
- [x] Error handling implemented
- [x] Data isolation working
- [x] UI responding to state changes
- [x] Firestore operations tested
- [x] User experience optimized

**All systems integrated and operational!** 🚀
