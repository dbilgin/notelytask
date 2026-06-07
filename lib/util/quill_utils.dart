import 'dart:convert';

/// Converts legacy plain/markdown text to Quill Delta JSON string.
/// If text is already a Delta JSON array, returns it unchanged.
String ensureQuillDelta(String text) {
  if (text.isEmpty) return '[{"insert":"\\n"}]';
  try {
    final decoded = jsonDecode(text);
    if (decoded is List) return text;
  } catch (_) {}
  final content = text.endsWith('\n') ? text : '$text\n';
  return jsonEncode([
    {'insert': content}
  ]);
}

/// Extracts plain text from a Quill Delta JSON string for preview use.
String extractPlainTextFromDelta(String text) {
  if (text.isEmpty) return '';
  try {
    final decoded = jsonDecode(text);
    if (decoded is List) {
      final buf = StringBuffer();
      for (final op in decoded) {
        if (op is Map && op['insert'] is String) buf.write(op['insert']);
      }
      final result = buf.toString();
      return result.endsWith('\n')
          ? result.substring(0, result.length - 1)
          : result;
    }
  } catch (_) {}
  return text;
}
