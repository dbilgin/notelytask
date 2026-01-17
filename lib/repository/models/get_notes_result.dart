class GetNotesResult {
  final bool pinNeeded;
  final bool decryptionFailed;
  final String? notesString;

  GetNotesResult({
    this.pinNeeded = false,
    this.decryptionFailed = false,
    this.notesString,
  });
}
