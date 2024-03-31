import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:notelytask/cubit/github_cubit.dart';
import 'package:notelytask/cubit/notes_cubit.dart';
import 'package:notelytask/models/file_data.dart';
import 'package:notelytask/service/navigation_service.dart';
import 'package:notelytask/theme.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pinput/pinput.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:encrypt/encrypt.dart' as e;

import 'cubit/selected_note_cubit.dart';
import 'models/note.dart';

GetIt getIt = GetIt.instance;

bool isSmallScreen(BuildContext context) {
  MediaQueryData queryData = MediaQuery.of(context);
  return queryData.size.width <= 500;
}

void navigateToDetails({
  required BuildContext context,
  required bool isDeletedList,
  Note? note,
}) {
  if (isSmallScreen(context)) {
    getIt<NavigationService>().pushNamed(
      '/details',
      arguments: DetailNavigationParameters(
        note: note,
        withAppBar: true,
        isDeletedList: isDeletedList,
      ),
    );
  }
  context.read<SelectedNoteCubit>().setNoteId(note?.id);
}

void saveToRepoAlert({
  required BuildContext context,
  required Function(bool keepLocal) onPressed,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xff2a2a31),
        title: Text(
          'Github Connection',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'Would you like to keep your local data and overwrite your repo?',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            child: Text(
              'Yes',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            onPressed: () {
              getIt<NavigationService>().pop();
              onPressed(true);
            },
          ),
          TextButton(
            child: Text(
              'No',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            onPressed: () {
              getIt<NavigationService>().pop();
              onPressed(false);
            },
          ),
          TextButton(
            child: Text(
              'Cancel',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            onPressed: () => getIt<NavigationService>().pop(),
          ),
        ],
      );
    },
  );
}

IconData getFileIcon(String fileName) {
  String extension = fileName.split('.').last.toLowerCase();

  switch (extension) {
    case 'pdf':
      return Icons.picture_as_pdf;
    case 'doc':
    case 'docx':
      return Icons.description;
    case 'xls':
    case 'xlsx':
      return Icons.table_chart;
    case 'ppt':
    case 'pptx':
      return Icons.slideshow;
    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'gif':
      return Icons.image;
    case 'mp3':
    case 'wav':
    case 'ogg':
      return Icons.music_note;
    case 'mp4':
    case 'avi':
    case 'mkv':
      return Icons.movie;
    case 'zip':
    case 'rar':
    case '7z':
      return Icons.archive;
    case 'txt':
      return Icons.text_snippet;
    default:
      return Icons.insert_drive_file;
  }
}

void showSnackBar(BuildContext context, String text) {
  final snackBar = SnackBar(
    content: Text(text),
    duration: const Duration(seconds: 1),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void showFileBottomSheet(BuildContext context, FileData file, String noteId) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.file_open),
            title: const Text('Open'),
            onTap: () async {
              await openFile(context, file);
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
          if (!kIsWeb)
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () async {
                final dir = await getTemporaryDirectory();
                await _shareFile('${dir.path}/${file.name}');
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete'),
            onTap: () async {
              await _deleteFile(context, file, noteId);
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<void> _deleteFile(
  BuildContext context,
  FileData file,
  String noteId,
) async {
  final fileDeleteResult =
      await context.read<NotesCubit>().deleteFileAndUpdate(noteId, file);
  if (!fileDeleteResult) {
    if (context.mounted) showSnackBar(context, 'File could not be deleted.');
  }
}

Future<void> _shareFile(String path) async {
  await Share.shareXFiles([XFile(path)]);
}

Future<void> openFile(BuildContext context, FileData file) async {
  kIsWeb ? _openLink(context, file) : await _openFileWithData(context, file);
}

Future<void> _openFileWithData(BuildContext context, FileData file) async {
  try {
    final filePath =
        await context.read<NotesCubit>().getFileLocalPath(file.name);

    if (filePath != null) {
      var res = await OpenFilex.open(filePath);
      if (!context.mounted) return;

      if (res.message.contains('does not exist')) {
        showSnackBar(context, 'File could not be found.');
      }
    }
  } catch (e) {
    if (!context.mounted) return;
    showSnackBar(context, 'File error.');
  }
}

Future<void> _openLink(BuildContext context, FileData file) async {
  try {
    final ownerRepo = context.read<GithubCubit>().state.ownerRepo;
    if (ownerRepo == null) {
      showSnackBar(context, 'Credential error.');
      return;
    }

    final fileUri = Uri.parse(
      'https://github.com/$ownerRepo/blob/master/${file.name}?raw=true',
    );
    if (await canLaunchUrl(fileUri)) {
      await launchUrl(fileUri);
    } else if (context.mounted) {
      showSnackBar(context, 'File could not be found.');
    }
  } catch (e) {
    if (!context.mounted) return;
    showSnackBar(context, 'File error.');
  }
}

Future<void> uploadFile(BuildContext context, Note note) async {
  final isLoggedIn = context.read<NotesCubit>().isLoggedIn();
  if (!isLoggedIn) {
    showSnackBar(context, 'Please log in to upload files.');
    return;
  }

  FilePickerResult? result = await FilePicker.platform.pickFiles();
  if (result == null) return;

  Uint8List? imageBytes;
  String fileName;
  if (kIsWeb) {
    imageBytes = result.files.single.bytes;
    fileName = result.files.single.name;
  } else {
    final path = result.files.single.path;
    if (path == null) return;

    File file = File(path);
    imageBytes = await file.readAsBytes();
    fileName = file.uri.pathSegments.last;
  }

  if (!context.mounted || imageBytes == null) return;

  await context.read<NotesCubit>().uploadNewFileAndNotes(
        note.id,
        fileName,
        imageBytes,
      );
}

Future<String?> encryptionKeyDialog({
  required BuildContext context,
  required String title,
  required String text,
  bool isKeyRequired = false,
  Function(String)? onSubmit,
}) async {
  return showDialog<String?>(
    context: context,
    barrierDismissible: !isKeyRequired,
    builder: (BuildContext context) {
      String? encryptionKey;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 100,
                  child: Pinput(
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    submittedPinTheme: submittedPinTheme,
                    length: 4,
                    pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                    showCursor: true,
                    onChanged: (pin) => setState(() => (pin.length < 4)
                        ? encryptionKey = null
                        : encryptionKey = pin),
                  ),
                ),
              ],
            ),
            actions: [
              if (!isKeyRequired)
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              Opacity(
                opacity: encryptionKey == null ? 0.5 : 1.0,
                child: TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  onPressed: encryptionKey == null
                      ? null
                      : () {
                          if (onSubmit != null) {
                            onSubmit(encryptionKey!);
                          }
                          Navigator.of(context).pop(encryptionKey);
                        },
                  child: const Text('Set'),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

String encrypt(String text, String pin) {
  final notelyKey = dotenv.env['NOTELY_KEY'] ?? '';
  final key = e.Key.fromUtf8(notelyKey);
  e.Key.fromLength(32);
  final iv = e.IV.fromUtf8(pin);

  final encrypter = e.Encrypter(e.AES(key));

  final encrypted = encrypter.encrypt(text, iv: iv);
  return encrypted.base64;
}

String? decrypt(String encryptedText, String pin) {
  try {
    final notelyKey = dotenv.env['NOTELY_KEY'] ?? '';

    final key = e.Key.fromUtf8(notelyKey);
    e.Key.fromLength(32);
    final iv = e.IV.fromUtf8(pin);

    final encrypter = e.Encrypter(e.AES(key));

    final encrypted = e.Encrypted.fromBase64(encryptedText);
    final decrypted = encrypter.decrypt(encrypted, iv: iv);

    return decrypted;
  } catch (e) {
    return null;
  }
}

bool isEncrypted(String input) {
  if (input.isEmpty) {
    return false;
  }

  final firstChar = input[0];
  return firstChar != '{';
}

String nonExistentFileName({
  required String fileName,
  required List<Note> notes,
}) {
  var files = notes.expand((e) => e.fileDataList);
  var fileNames = files.map((e) => e.name);
  var exists = fileNames.contains(fileName);

  if (!exists) {
    return fileName;
  } else {
    int index = fileName.lastIndexOf('.');
    String withoutExtension = fileName.substring(0, index);
    String extension = fileName.substring(index);

    return nonExistentFileName(
      fileName: '${withoutExtension}_$extension',
      notes: notes,
    );
  }
}
