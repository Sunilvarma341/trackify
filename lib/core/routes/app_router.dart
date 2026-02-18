import 'package:go_router/go_router.dart';
import 'package:trackify/presentation/screens/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/expense/expense_list_screen.dart';
import '../../presentation/screens/expense/add_expense_screen.dart';
import '../../presentation/screens/expense/edit_expense_screen.dart';
import '../../presentation/screens/expense/expense_analytics_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/expenses',
        builder: (context, state) => const ExpenseListScreen(),
      ),
      GoRoute(
        path: '/expense-add',
        builder: (context, state) => const AddExpenseScreen(),
      ),
      GoRoute(
        path: '/expense-edit/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EditExpenseScreen(expenseId: id);
        },
      ),
      GoRoute(
        path: '/expense-analytics',
        builder: (context, state) => const ExpenseAnalyticsScreen(),
      ),
    ],
  );
}
