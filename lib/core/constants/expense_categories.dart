class ExpenseCategories {
  static const List<String> categories = [
    'Food',
    'Transportation',
    'Entertainment',
    'Shopping',
    'Utilities',
    'Healthcare',
    'Education',
    'Travel',
    'Sports',
    'Other',
  ];

  static const Map<String, String> categoryIcons = {
    'Food': '🍔',
    'Transportation': '🚗',
    'Entertainment': '🎬',
    'Shopping': '🛍️',
    'Utilities': '💡',
    'Healthcare': '⚕️',
    'Education': '📚',
    'Travel': '✈️',
    'Sports': '⚽',
    'Other': '📌',
  };

  static String getIcon(String category) {
    return categoryIcons[category] ?? '📌';
  }
}
