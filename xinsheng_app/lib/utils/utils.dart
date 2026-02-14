import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

// Format time
String formatTime(DateTime dateTime) {
  final now = DateTime.now();
  final diff = now.difference(dateTime);

  if (diff.inDays > 365) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  } else if (diff.inDays > 7) {
    return DateFormat('MM-dd').format(dateTime);
  } else if (diff.inDays > 0) {
    return '${diff.inDays}天前';
  } else if (diff.inHours > 0) {
    return '${diff.inHours}小时前';
  } else if (diff.inMinutes > 0) {
    return '${diff.inMinutes}分钟前';
  } else {
    return '刚刚';
  }
}

// Format date
String formatDate(DateTime dateTime) {
  return DateFormat('yyyy年MM月dd日').format(dateTime);
}

// Format number
String formatNumber(int number) {
  if (number >= 10000) {
    return '${(number / 10000).toStringAsFixed(1)}w';
  } else if (number >= 1000) {
    return '${(number / 1000).toStringAsFixed(1)}k';
  }
  return number.toString();
}

// Validate phone
bool isValidPhone(String phone) {
  return RegExp(r'^1[3-9]\d{9}$').hasMatch(phone);
}

// Validate username
bool isValidUsername(String username) {
  return RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(username);
}

// Validate password
bool isValidPassword(String password) {
  return password.length >= 6;
}

// Mask phone
String maskPhone(String phone) {
  if (phone.length != 11) return phone;
  return '${phone.substring(0, 3)}****${phone.substring(7)}';
}

// Truncate text
String truncateText(String text, int maxLength) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength)}...';
}

// Constants
const int maxNoteLength = 50;
const int maxCommentLength = 100;
