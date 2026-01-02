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
  throw UnimplementedError();
}