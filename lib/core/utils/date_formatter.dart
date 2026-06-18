import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String full(DateTime date) => DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
  static String short(DateTime date) => DateFormat('d MMM yyyy', 'id_ID').format(date);
}
