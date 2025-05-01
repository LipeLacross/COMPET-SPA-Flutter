import 'package:intl/intl.dart';  // Adicione esta linha

class DateHelper {
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
