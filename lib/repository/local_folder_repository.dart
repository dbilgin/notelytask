import 'dart:io';
import 'package:flutter/foundation.dart';

class LocalFile {
  LocalFile({this.content});
  final String? content;
}

class LocalFolderRepository {
  Future<LocalFile?> createNewFile(
    String folderPath,
    Uint8List content,
    String fileName,
  ) async {
    try {
      final filePath = '$folderPath/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(content, mode: FileMode.write);
      return LocalFile();
    } catch (e) {
      debugPrint('Error creating file: $e');
      return null;
    }
  }

  Future<bool> deleteFile(
    String folderPath,
    String fileName,
  ) async {
    try {
      final filePath = '$folderPath/$fileName';
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
      return true;
    } catch (e) {
      debugPrint('Error deleting file: $e');
      return false;
    }
  }

  Future<bool> createOrUpdateNotesFile(
    String folderPath,
    String stringifiedContent,
  ) async {
    try {
      final filePath = '$folderPath/notes.json';
      final file = File(filePath);
      await file.writeAsString(stringifiedContent, mode: FileMode.write);
      return true;
    } catch (e) {
      debugPrint('Error saving notes file: $e');
      return false;
    }
  }

  Future<File?> getFile(
    String folderPath,
    String fileName,
  ) async {
    try {
      final filePath = '$folderPath/$fileName';
      final file = File(filePath);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting file: $e');
      return null;
    }
  }

  Future<LocalFile?> getExistingNoteFile(
    String folderPath,
  ) async {
    try {
      final filePath = '$folderPath/notes.json';
      final file = File(filePath);
      if (await file.exists()) {
        final content = await file.readAsString();
        return LocalFile(content: content);
      }
      return null;
    } catch (e) {
      debugPrint('Error reading notes file: $e');
      return null;
    }
  }

  Future<bool> folderExists(String folderPath) async {
    try {
      final dir = Directory(folderPath);
      return await dir.exists();
    } catch (e) {
      return false;
    }
  }
}
