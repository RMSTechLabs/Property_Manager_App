import 'package:device_info_plus/device_info_plus.dart';
import 'package:intl/intl.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;

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

  // 🔥 Helper method to convert HTML content to plain text
  static String _stripHtmlTags(String htmlString) {
    if (htmlString.isEmpty) return '';

    try {
      // Parse HTML and extract text content
      final dom.Document document = parse(htmlString);
      final String plainText = document.body?.text ?? htmlString;

      // Clean up extra whitespaces and line breaks
      return plainText
          .replaceAll(
            RegExp(r'\s+'),
            ' ',
          ) // Replace multiple spaces with single space
          .trim(); // Remove leading/trailing spaces
    } catch (e) {
      // If parsing fails, return original string (fallback)
      return htmlString;
    }
  }

  // 🔥 Helper method to get preview text from HTML content
  static String getPreviewText(String htmlContent, {int maxLength = 150}) {
    final plainText = _stripHtmlTags(htmlContent);
    if (plainText.length <= maxLength) return plainText;

    // Find the last space before maxLength to avoid cutting words
    int cutIndex = maxLength;
    int lastSpace = plainText.lastIndexOf(' ', maxLength);
    if (lastSpace > maxLength * 0.8) {
      // Only use space if it's not too far back
      cutIndex = lastSpace;
    }

    return '${plainText.substring(0, cutIndex)}...';
  }

  static String stripHtmlTagsNew(String htmlString) {
    if (htmlString.isEmpty) return '';
    final RegExp exp = RegExp(
      r"<[^>]*>",
      multiLine: true,
      caseSensitive: false,
    );
    return htmlString.replaceAll(exp, '').trim();
  }

  static Future<bool> isAndroid13OrAbove() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt >= 33;
  }

  static Future<bool> isAndroid11OrAbove() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt >= 30;
  }
}
