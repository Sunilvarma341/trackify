import 'package:equatable/equatable.dart';
import '../../../domain/models/expense_model.dart';

abstract class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object?> get props => [];
}

// Initial state
class ExpenseInitial extends ExpenseState {
  const ExpenseInitial();
}

// Loading state
class ExpenseLoading extends ExpenseState {
  const ExpenseLoading();
}

// Expenses loaded successfully
class ExpensesLoaded extends ExpenseState {
  final List<ExpenseModel> expenses;
  final double totalSpending;

  const ExpensesLoaded({required this.expenses, required this.totalSpending});

  @override
  List<Object?> get props => [expenses, totalSpending];
}

// Error state
class ExpenseError extends ExpenseState {
  final String message;

  const ExpenseError(this.message);

  @override
  List<Object?> get props => [message];
}

// Analytics state with spending data
class ExpenseAnalyticsLoaded extends ExpenseState {
  final List<ExpenseModel> recentExpenses;
  final Map<String, double> spendingByCategory;
  final double totalSpending;
  final double averageDailySpending;
  final double monthlySpending;

  const ExpenseAnalyticsLoaded({
    required this.recentExpenses,
    required this.spendingByCategory,
    required this.totalSpending,
    required this.averageDailySpending,
    required this.monthlySpending,
  });

  @override
  List<Object?> get props => [
    recentExpenses,
    spendingByCategory,
    totalSpending,
    averageDailySpending,
    monthlySpending,
  ];
}

// Filtered expenses by category
class ExpensesFiltered extends ExpenseState {
  final List<ExpenseModel> expenses;
  final String category;
  final double totalSpending;

  const ExpensesFiltered({
    required this.expenses,
    required this.category,
    required this.totalSpending,
  });

  @override
  List<Object?> get props => [expenses, category, totalSpending];
}

// Success state for add/update/delete operations
class ExpenseOperationSuccess extends ExpenseState {
  final String message;

  const ExpenseOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
