import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat currency = NumberFormat.currency(
    symbol: '',
    decimalDigits: 0,
  );
  
  static final DateFormat dateTime = DateFormat('MMM dd, yyyy • HH:mm');
  static final DateFormat date = DateFormat('MMM dd, yyyy');
  static final DateFormat time = DateFormat('HH:mm');
  
  static String formatCredits(double credits) {
    return '${currency.format(credits)} credits';
  }
  
  static String formatDateTime(DateTime dateTime) {
    return Formatters.dateTime.format(dateTime);
  }
  
  static String formatDate(DateTime date) {
    return Formatters.date.format(date);
  }
  
  static String formatTime(DateTime time) {
    return Formatters.time.format(time);
  }
  
  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

