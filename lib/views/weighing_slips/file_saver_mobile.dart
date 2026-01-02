import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileSaveResult {
  final bool success;
  final String message;
  final String? filePath;

  FileSaveResult({
    required this.success,
    required this.message,
    this.filePath,
  });
}

Future<FileSaveResult> saveFile(List<int> bytes, String filename) async {
  try {
    Directory? directory;
    
    // Request storage permission for Android
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        return FileSaveResult(
          success: false,
          message: 'Permission de stockage refusée',
        );
      }
      
      // Try to save to Downloads folder
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        directory = await getExternalStorageDirectory();
      }
    } 
    // For iOS, use application documents directory
    else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    }
    // For desktop platforms (Windows, macOS, Linux)
    else {
      directory = await getDownloadsDirectory();
      directory ??= await getApplicationDocumentsDirectory();
    }
    
    if (directory != null) {
      final filePath = '${directory.path}/$filename';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      
      return FileSaveResult(
        success: true,
        message: 'PDF enregistré: $filePath',
        filePath: filePath,
      );
    } else {
      return FileSaveResult(
        success: false,
        message: 'Impossible de trouver un répertoire de sauvegarde',
      );
    }
  } catch (e) {
    return FileSaveResult(
      success: false,
      message: 'Erreur lors de l\'enregistrement: ${e.toString()}',
    );
  }
}
