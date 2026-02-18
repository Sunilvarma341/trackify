import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/expense_categories.dart';
import '../../../domain/models/user_model.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/expense/expense_bloc.dart';
import '../../bloc/expense/expense_event.dart';
import '../../bloc/expense/expense_state.dart';

class ExpenseAnalyticsScreen extends StatefulWidget {
  const ExpenseAnalyticsScreen({super.key});

  @override
  State<ExpenseAnalyticsScreen> createState() => _ExpenseAnalyticsScreenState();
}

class _ExpenseAnalyticsScreenState extends State<ExpenseAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  void _loadAnalytics() {
    final user = context.read<AuthBloc>().state is AuthAuthenticated
        ? (context.read<AuthBloc>().state as AuthAuthenticated).user
        : null;

    if (user != null) {
      context.read<ExpenseBloc>().add(LoadAnalyticsRequested(user.id));
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
        appBar: AppBar(title: const Text('Analytics')),
        body: const Center(child: Text('User not authenticated')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Spending Analytics'), elevation: 0),
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
                    onPressed: _loadAnalytics,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ExpenseAnalyticsLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Cards
                  _buildSummaryCards(context, state),
                  const SizedBox(height: 24),

                  // Category Breakdown
                  _buildSectionTitle(context, 'Spending by Category'),
                  const SizedBox(height: 16),
                  _buildCategoryChart(state),
                  const SizedBox(height: 24),

                  // Category List
                  _buildSectionTitle(context, 'Category Breakdown'),
                  const SizedBox(height: 12),
                  _buildCategoryList(state),
                  const SizedBox(height: 24),

                  // Recent Expenses
                  _buildSectionTitle(context, 'Recent Expenses'),
                  const SizedBox(height: 12),
                  _buildRecentExpenses(state),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    ExpenseAnalyticsLoaded state,
  ) {
    return Column(
      children: [
        _buildSummaryCard(
          context,
          'Total Spending',
          '\$${state.totalSpending.toStringAsFixed(2)}',
          Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildSummaryCard(
          context,
          'This Month',
          '\$${state.monthlySpending.toStringAsFixed(2)}',
          Colors.green,
        ),
        const SizedBox(height: 12),
        _buildSummaryCard(
          context,
          'Daily Average',
          '\$${state.averageDailySpending.toStringAsFixed(2)}',
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildCategoryChart(ExpenseAnalyticsLoaded state) {
    if (state.spendingByCategory.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No expense data available',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    final entries = state.spendingByCategory.entries.toList();
    final colors = _getCategoryColors();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 300,
          child: PieChart(
            PieChartData(
              sections: List.generate(
                entries.length,
                (index) => PieChartSectionData(
                  color: colors[index % colors.length],
                  value: entries[index].value,
                  title:
                      '${(entries[index].value / state.totalSpending * 100).toStringAsFixed(1)}%',
                  radius: 80,
                ),
              ),
              sectionsSpace: 2,
              centerSpaceRadius: 0,
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getCategoryColors() {
    return [
      const Color(0xFFFFB74D),
      const Color(0xFF64B5F6),
      const Color(0xFFBA68C8),
      const Color(0xFFEF9A9A),
      const Color(0xFFFFD54F),
      const Color(0xFF81C784),
      const Color(0xFF90CAF9),
      const Color(0xFFFFCC80),
      const Color(0xFF80DEEA),
      const Color(0xFFB0BEC5),
    ];
  }

  Widget _buildCategoryList(ExpenseAnalyticsLoaded state) {
    final entries = state.spendingByCategory.entries.toList();
    final colors = _getCategoryColors();

    return Column(
      children: List.generate(
        entries.length,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entries[index].key,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '${(entries[index].value / state.totalSpending * 100).toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                '\$${entries[index].value.toStringAsFixed(2)}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentExpenses(ExpenseAnalyticsLoaded state) {
    if (state.recentExpenses.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No recent expenses',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    return Column(
      children: state.recentExpenses.map((expense) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  ExpenseCategories.getIcon(expense.category),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            title: Text('${expense.category} - ${expense.description}'),
            subtitle: Text(DateFormat('MMM dd, yyyy').format(expense.date)),
            trailing: Text(
              '\$${expense.amount.toStringAsFixed(2)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList(),
    );
  }
}
