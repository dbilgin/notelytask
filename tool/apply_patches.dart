#!/usr/bin/env dart
// ignore_for_file: avoid_print
// Script to apply patches to pub dependencies
// Run with: dart tool/apply_patches.dart

import 'dart:io';

Future<String?> getPubCacheDir() async {
  // Use dart pub cache to get the actual cache directory
  final result =
      await Process.run('dart', ['pub', 'cache', 'list'], runInShell: true);

  if (result.exitCode == 0) {
    // The cache list output includes the cache directory
    // Parse from output or use environment
    final pubCache = Platform.environment['PUB_CACHE'];
    if (pubCache != null) return pubCache;

    final home = Platform.environment['HOME'] ?? '';
    return '$home/.pub-cache';
  }

  return null;
}

void main() async {
  final patchesDir = Directory('patches');

  if (!patchesDir.existsSync()) {
    print('No patches directory found');
    return;
  }

  // Get pub cache directory
  final pubCache = Platform.environment['PUB_CACHE'] ??
      '${Platform.environment['HOME']}/.pub-cache';

  final hostedDir = Directory('$pubCache/hosted/pub.dev');
  if (!hostedDir.existsSync()) {
    print('Pub cache not found at: $pubCache/hosted/pub.dev');
    print('PUB_CACHE env: ${Platform.environment['PUB_CACHE']}');
    print('HOME env: ${Platform.environment['HOME']}');
    return;
  }

  for (final file in patchesDir.listSync()) {
    if (file is File && file.path.endsWith('.patch')) {
      final fileName = file.uri.pathSegments.last;
      final parts = fileName.replaceAll('.patch', '').split('+');
      if (parts.length != 2) continue;

      final packageName = parts[0];
      final version = parts[1];
      final packagePath = '$pubCache/hosted/pub.dev/$packageName-$version';

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
