#!/usr/bin/env dart
// ignore_for_file: avoid_print
// Script to apply patches to pub dependencies
// Run with: dart tool/apply_patches.dart

import 'dart:io';

void main() async {
  final homeDir = Platform.environment['HOME'] ?? '';
  final patchesDir = Directory('patches');

  if (!patchesDir.existsSync()) {
    print('No patches directory found');
    return;
  }

  for (final file in patchesDir.listSync()) {
    if (file is File && file.path.endsWith('.patch')) {
      final fileName = file.uri.pathSegments.last;
      // Parse package name and version from filename: package+version.patch
      final parts = fileName.replaceAll('.patch', '').split('+');
      if (parts.length != 2) continue;

      final packageName = parts[0];
      final version = parts[1];

      final packagePath =
          '$homeDir/.pub-cache/hosted/pub.dev/$packageName-$version';

      if (!Directory(packagePath).existsSync()) {
        print('Package not found: $packagePath');
        continue;
      }

      print('Applying patch to $packageName-$version...');

      final result = await Process.run(
        'patch',
        ['-p1', '-d', packagePath, '-i', file.absolute.path],
        runInShell: true,
      );

      if (result.exitCode == 0) {
        print('✓ Successfully patched $packageName');
      } else {
        // Check if already applied
        final reverseResult = await Process.run(
          'patch',
          [
            '-p1',
            '-d',
            packagePath,
            '-i',
            file.absolute.path,
            '--reverse',
            '--dry-run'
          ],
          runInShell: true,
        );
        if (reverseResult.exitCode == 0) {
          print('✓ Patch already applied to $packageName');
        } else {
          print('✗ Failed to patch $packageName: ${result.stderr}');
        }
      }
    }
  }
}
