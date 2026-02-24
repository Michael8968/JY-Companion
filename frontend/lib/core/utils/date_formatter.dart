import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String relative(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    if (dateTime.year == now.year) {
      return DateFormat('M月d日').format(dateTime);
    }
    return DateFormat('yyyy年M月d日').format(dateTime);
  }

  static String full(DateTime dateTime) {
    return DateFormat('yyyy年M月d日 HH:mm').format(dateTime);
  }

  static String time(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  static String date(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }
}
