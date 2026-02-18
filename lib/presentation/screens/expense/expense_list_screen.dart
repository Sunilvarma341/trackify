import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/expense_categories.dart';
import '../../../domain/models/expense_model.dart';
import '../../../domain/models/user_model.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/expense/expense_bloc.dart';
import '../../bloc/expense/expense_event.dart';
import '../../bloc/expense/expense_state.dart';
import '../../../core/theme/app_theme.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  void _loadExpenses() {
    final user = context.read<AuthBloc>().state is AuthAuthenticated
        ? (context.read<AuthBloc>().state as AuthAuthenticated).user
        : null;

    if (user != null) {
      context.read<ExpenseBloc>().add(LoadExpensesRequested(user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthBloc, UserModel?>(
      (bloc) => bloc.state is AuthAuthenticated
          ? (bloc.state as AuthAuthenticated).user
          : null,
    );

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Expenses')),
        body: const Center(child: Text('User not authenticated')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Expenses'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => context.push('/expense-analytics'),
            tooltip: 'View Analytics',
          ),
        ],
      ),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ExpenseError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadExpenses,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ExpensesLoaded) {
            if (state.expenses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.receipt_long_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No expenses yet',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start tracking your expenses',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }

            return CustomScrollView(
              slivers: [
                // Category filter chips
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filter by Category',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Wrap(
                            spacing: 8,
                            children: [
                              FilterChip(
                                label: const Text('All'),
                                selected: _selectedCategory == null,
                                onSelected: (selected) {
                                  setState(
                                    () => _selectedCategory = selected
                                        ? null
                                        : _selectedCategory,
                                  );
                                  if (selected) {
                                    context.read<ExpenseBloc>().add(
                                      ClearFiltersRequested(user.id),
                                    );
                                  }
                                },
                              ),
                              ...ExpenseCategories.categories.map((category) {
                                return FilterChip(
                                  label: Text(
                                    '${ExpenseCategories.getIcon(category)} $category',
                                  ),
                                  selected: _selectedCategory == category,
                                  onSelected: (selected) {
                                    setState(
                                      () => _selectedCategory = selected
                                          ? category
                                          : null,
                                    );
                                    if (selected) {
                                      context.read<ExpenseBloc>().add(
                                        FilterByCategoryRequested(
                                          userId: user.id,
                                          category: category,
                                        ),
                                      );
                                    }
                                  },
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Total spending summary
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Spending',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '\$${state.totalSpending.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: 16),
                ),
                // Expenses list
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final expense = state.expenses[index];
                      return _ExpenseListItem(
                        expense: expense,
                        onEdit: () =>
                            context.push('/expense-edit/${expense.id}'),
                        onDelete: () =>
                            _showDeleteConfirmation(context, expense),
                      );
                    }, childCount: state.expenses.length),
                  ),
                ),
              ],
            );
          }

          if (state is ExpensesFiltered) {
            if (state.expenses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('No expenses in ${state.category}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadExpenses,
                      child: const Text('Show All'),
                    ),
                  ],
                ),
              );
            }

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: Text('${state.category} Expenses'),
                  floating: true,
                  snap: true,
                  forceElevated: true,
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final expense = state.expenses[index];
                      return _ExpenseListItem(
                        expense: expense,
                        onEdit: () =>
                            context.push('/expense-edit/${expense.id}'),
                        onDelete: () =>
                            _showDeleteConfirmation(context, expense),
                      );
                    }, childCount: state.expenses.length),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/expense-add'),
        tooltip: 'Add Expense',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ExpenseModel expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense?'),
        content: Text(
          'Are you sure you want to delete this expense?\n'
          '${ExpenseCategories.getIcon(expense.category)} ${expense.category} - \$${expense.amount}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ExpenseBloc>().add(
                DeleteExpenseRequested(expense.id),
              );
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ExpenseListItem extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExpenseListItem({
    required this.expense,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getCategoryColor(expense.category),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              ExpenseCategories.getIcon(expense.category),
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          '${expense.category} - ${expense.description}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          DateFormat('MMM dd, yyyy').format(expense.date),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${expense.amount.toStringAsFixed(2)}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        onTap: onEdit,
        onLongPress: onDelete,
      ),
    );
  }

  Color _getCategoryColor(String category) {
    const colors = {
      'Food': Color(0xFFFFB74D),
      'Transportation': Color(0xFF64B5F6),
      'Entertainment': Color(0xFFBA68C8),
      'Shopping': Color(0xFFEF9A9A),
      'Utilities': Color(0xFFFFD54F),
      'Healthcare': Color(0xFF81C784),
      'Education': Color(0xFF90CAF9),
      'Travel': Color(0xFFFFCC80),
      'Sports': Color(0xFF80DEEA),
      'Other': Color(0xFFB0BEC5),
    };
    return colors[category] ?? const Color(0xFFB0BEC5);
  }
}
