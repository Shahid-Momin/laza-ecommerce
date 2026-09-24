import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ProfileImageService {
  ProfileImageService._();

  static Future<Directory> _dir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/profile');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Copies the picked image into app storage and returns the local path.
  static Future<String> saveImage(String sourcePath, String uid) async {
    final dir = await _dir();
    final ext = sourcePath.split('.').last;
    final target = File('${dir.path}/$uid.$ext');
    await File(sourcePath).copy(target.path);
    return target.path;
  }

  /// Returns the saved profile image path for [uid] if it exists.
  static Future<String?> getImagePath(String uid) async {
    final dir = await _dir();
    if (!await dir.exists()) return null;
    final files = await dir.list().toList();
    for (final f in files) {
      if (f is File && f.path.contains('/$uid.')) {
        return f.path;
      }
    }
    return null;
  }

  static Future<void> deleteImage(String uid) async {
    final dir = await _dir();
    if (!await dir.exists()) return;
    final files = await dir.list().toList();
    for (final f in files) {
      if (f is File && f.path.contains('/$uid.')) {
        await f.delete();
      }
    }
  }
}