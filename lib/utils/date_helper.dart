//date_helper.dart
import 'package:intl/intl.dart';

class DateHelper {
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}

