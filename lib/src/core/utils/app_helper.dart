import 'package:intl/intl.dart';

class AppHelper {
  /// Converts a sentence to sentence case (each word's first letter capitalized)
  static String toSentenceCase(String input) {
    if (input.isEmpty) return input;

    return input
        .split(' ') // Split by space
        .map(
          (word) => word.isNotEmpty
              ? word[0].toUpperCase() + word.substring(1).toLowerCase()
              : '',
        ) // Capitalize first letter
        .join(' '); // Join back to a sentence
  }

  static String formatComplaintTimestamp(String rawTimestamp) {
    try {
      final dateTime = DateTime.parse(rawTimestamp).toLocal();
      final formatted = DateFormat("hh:mm a | dd MMM''yy").format(dateTime);
      return formatted;
    } catch (e) {
      return rawTimestamp; // fallback if parsing fails
    }
  }
}
