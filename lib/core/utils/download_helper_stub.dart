import 'dart:io';
import 'package:path_provider/path_provider.dart';

void downloadCsvFile(String csvContent, String filename) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsString('\uFEFF$csvContent');
  } catch (_) {}
}
