import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../domain/models/expense_model.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository expenseRepository;

  ExpenseBloc({required this.expenseRepository})
    : super(const ExpenseInitial()) {
    on<LoadExpensesRequested>(_onLoadExpensesRequested);
    on<LoadExpensesByDateRangeRequested>(_onLoadExpensesByDateRangeRequested);
    on<AddExpenseRequested>(_onAddExpenseRequested);
    on<UpdateExpenseRequested>(_onUpdateExpenseRequested);
    on<DeleteExpenseRequested>(_onDeleteExpenseRequested);
    on<LoadAnalyticsRequested>(_onLoadAnalyticsRequested);
    on<FilterByCategoryRequested>(_onFilterByCategoryRequested);
    on<ClearFiltersRequested>(_onClearFiltersRequested);
  }

  Future<void> _onLoadExpensesRequested(
    LoadExpensesRequested event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(const ExpenseLoading());
    try {
      await emit.forEach<List<ExpenseModel>>(
        expenseRepository.getUserExpenses(event.userId),
        onData: (expenses) {
          double total = expenses.fold(
            0,
            (sum, expense) => sum + expense.amount,
          );
          return ExpensesLoaded(expenses: expenses, totalSpending: total);
        },
        onError: (error, _) => ExpenseError(error.toString()),
      );
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onLoadExpensesByDateRangeRequested(
    LoadExpensesByDateRangeRequested event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(const ExpenseLoading());
    try {
      await emit.forEach<List<ExpenseModel>>(
        expenseRepository.getExpensesByDateRange(
          event.userId,
          event.startDate,
          event.endDate,
        ),
        onData: (expenses) {
          double total = expenses.fold(
            0,
            (sum, expense) => sum + expense.amount,
          );
          return ExpensesLoaded(expenses: expenses, totalSpending: total);
        },
        onError: (error, _) => ExpenseError(error.toString()),
      );
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onAddExpenseRequested(
    AddExpenseRequested event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      final expenseToAdd = event.expense.copyWith(
        id: const Uuid().v4(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await expenseRepository.addExpense(expenseToAdd);
      emit(const ExpenseOperationSuccess('Expense added successfully'));
      add(LoadExpensesRequested(event.expense.userId));
    } catch (e) {
      emit(ExpenseError('Failed to add expense: $e'));
    }
  }

  Future<void> _onUpdateExpenseRequested(
    UpdateExpenseRequested event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      final expenseToUpdate = event.expense.copyWith(updatedAt: DateTime.now());
      await expenseRepository.updateExpense(expenseToUpdate);
      emit(const ExpenseOperationSuccess('Expense updated successfully'));
      add(LoadExpensesRequested(event.expense.userId));
    } catch (e) {
      emit(ExpenseError('Failed to update expense: $e'));
    }
  }

  Future<void> _onDeleteExpenseRequested(
    DeleteExpenseRequested event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      await expenseRepository.deleteExpense(event.expenseId);
      emit(const ExpenseOperationSuccess('Expense deleted successfully'));
    } catch (e) {
      emit(ExpenseError('Failed to delete expense: $e'));
    }
  }

  Future<void> _onLoadAnalyticsRequested(
    LoadAnalyticsRequested event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(const ExpenseLoading());
    try {
      await emit.forEach<List<ExpenseModel>>(
        expenseRepository.getUserExpenses(event.userId),
        onData: (expenses) {
          double totalSpending = expenses.fold(
            0,
            (sum, expense) => sum + expense.amount,
          );

          final averageDailySpending = expenses.isEmpty
              ? 0.0
              : totalSpending /
                    ((DateTime.now().difference(expenses.last.date).inDays) +
                        1);

          final recentExpenses = expenses.take(10).toList();

          return ExpenseAnalyticsLoaded(
            recentExpenses: recentExpenses,
            spendingByCategory: {},
            totalSpending: totalSpending,
            averageDailySpending: averageDailySpending,
            monthlySpending: 0.0,
          );
        },
        onError: (error, _) => ExpenseError('Failed to load analytics: $error'),
      );
    } catch (e) {
      emit(ExpenseError('Failed to load analytics: $e'));
    }
  }

  Future<void> _onFilterByCategoryRequested(
    FilterByCategoryRequested event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(const ExpenseLoading());
    try {
      await emit.forEach<List<ExpenseModel>>(
        expenseRepository.getExpensesByCategory(event.userId, event.category),
        onData: (expenses) {
          double total = expenses.fold(
            0,
            (sum, expense) => sum + expense.amount,
          );
          return ExpensesFiltered(
            expenses: expenses,
            category: event.category,
            totalSpending: total,
          );
        },
        onError: (error, _) => ExpenseError(error.toString()),
      );
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onClearFiltersRequested(
    ClearFiltersRequested event,
    Emitter<ExpenseState> emit,
  ) async {
    add(LoadExpensesRequested(event.userId));
  }
}
