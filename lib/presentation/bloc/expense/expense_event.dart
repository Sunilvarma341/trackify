import 'package:equatable/equatable.dart';
import '../../../domain/models/expense_model.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

// Load all expenses for the authenticated user
class LoadExpensesRequested extends ExpenseEvent {
  final String userId;

  const LoadExpensesRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

// Load expenses by date range
class LoadExpensesByDateRangeRequested extends ExpenseEvent {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadExpensesByDateRangeRequested({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [userId, startDate, endDate];
}

// Add a new expense
class AddExpenseRequested extends ExpenseEvent {
  final ExpenseModel expense;

  const AddExpenseRequested(this.expense);

  @override
  List<Object?> get props => [expense];
}

// Update an existing expense
class UpdateExpenseRequested extends ExpenseEvent {
  final ExpenseModel expense;

  const UpdateExpenseRequested(this.expense);

  @override
  List<Object?> get props => [expense];
}

// Delete an expense
class DeleteExpenseRequested extends ExpenseEvent {
  final String expenseId;

  const DeleteExpenseRequested(this.expenseId);

  @override
  List<Object?> get props => [expenseId];
}

// Load analytics data (spending by category, monthly totals, etc.)
class LoadAnalyticsRequested extends ExpenseEvent {
  final String userId;

  const LoadAnalyticsRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

// Filter expenses by category
class FilterByCategoryRequested extends ExpenseEvent {
  final String userId;
  final String category;

  const FilterByCategoryRequested({
    required this.userId,
    required this.category,
  });

  @override
  List<Object?> get props => [userId, category];
}

// Clear filters and show all expenses
class ClearFiltersRequested extends ExpenseEvent {
  final String userId;

  const ClearFiltersRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}
