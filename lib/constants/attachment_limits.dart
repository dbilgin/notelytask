const attachmentMaxFileSizeBytes = 10 * 1024 * 1024;
const attachmentMaxTotalSizeBytes = 250 * 1024 * 1024;

String formatAttachmentLimit(int bytes) {
  final mb = bytes / (1024 * 1024);
  if (mb == mb.roundToDouble()) {
    return '${mb.toInt()} MB';
  }
  return '${mb.toStringAsFixed(1)} MB';
}
