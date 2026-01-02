// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert' show base64Encode;

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
    final base64String = base64Encode(bytes);
    final dataUrl = 'data:application/pdf;base64,$base64String';
    
    final anchor = html.AnchorElement(href: dataUrl)
      ..setAttribute('download', filename)
      ..style.display = 'none';
    
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    
    return FileSaveResult(
      success: true,
      message: 'PDF téléchargé: $filename',
    );
  } catch (e) {
    return FileSaveResult(
      success: false,
      message: 'Erreur lors du téléchargement: ${e.toString()}',
    );
  }
}