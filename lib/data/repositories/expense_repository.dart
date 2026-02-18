import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/expense_model.dart';

class ExpenseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String expensesCollection = 'expenses';

  // Add a new expense
  Future<String> addExpense(ExpenseModel expense) async {
    try {
      final docRef = await _firestore
          .collection(expensesCollection)
          .add(expense.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add expense: $e');
    }
  }

  // Update an expense
  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      await _firestore
          .collection(expensesCollection)
          .doc(expense.id)
          .update(expense.toFirestore());
    } catch (e) {
      throw Exception('Failed to update expense: $e');
    }
  }

  // Delete an expense
  Future<void> deleteExpense(String expenseId) async {
    try {
      await _firestore.collection(expensesCollection).doc(expenseId).delete();
    } catch (e) {
      throw Exception('Failed to delete expense: $e');
    }
  }

  // Get all expenses for a user
  Stream<List<ExpenseModel>> getUserExpenses(String userId) {
    return _firestore
        .collection(expensesCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ExpenseModel.fromFirestore(doc))
              .toList();
        });
  }

  // Get expenses for a specific date range
  Stream<List<ExpenseModel>> getExpensesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _firestore
        .collection(expensesCollection)
        .where('userId', isEqualTo: userId)
        .where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        )
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ExpenseModel.fromFirestore(doc))
              .toList();
        });
  }

  // Get expenses by category
  Stream<List<ExpenseModel>> getExpensesByCategory(
    String userId,
    String category,
  ) {
    return _firestore
        .collection(expensesCollection)
        .where('userId', isEqualTo: userId)
        .where('category', isEqualTo: category)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ExpenseModel.fromFirestore(doc))
              .toList();
        });
  }

  // Get single expense
  Future<ExpenseModel?> getExpense(String expenseId) async {
    try {
      final doc = await _firestore
          .collection(expensesCollection)
          .doc(expenseId)
          .get();
      if (!doc.exists) return null;
      return ExpenseModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get expense: $e');
    }
  }

  // Calculate total spending
  Future<double> getTotalSpending(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(expensesCollection)
          .where('userId', isEqualTo: userId)
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        total += (data['amount'] as num).toDouble();
      }
      return total;
    } catch (e) {
      throw Exception('Failed to calculate total spending: $e');
    }
  }

  // Calculate spending by category
  Future<Map<String, double>> getSpendingByCategory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(expensesCollection)
          .where('userId', isEqualTo: userId)
          .get();

      final Map<String, double> categorySpending = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final category = data['category'] as String;
        final amount = (data['amount'] as num).toDouble();

        categorySpending[category] = (categorySpending[category] ?? 0) + amount;
      }
      return categorySpending;
    } catch (e) {
      throw Exception('Failed to get category spending: $e');
    }
  }

  // Get monthly total spending
  Future<double> getMonthlySpendings(String userId, int year, int month) async {
    try {
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0);

      final snapshot = await _firestore
          .collection(expensesCollection)
          .where('userId', isEqualTo: userId)
          .where(
            'date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
            isLessThanOrEqualTo: Timestamp.fromDate(endDate),
          )
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        total += (data['amount'] as num).toDouble();
      }
      return total;
    } catch (e) {
      throw Exception('Failed to get monthly spending: $e');
    }
  }
}
