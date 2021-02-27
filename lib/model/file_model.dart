import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class FileUtils {
  static Future<File> getFile() async {
    final tempDir = await getApplicationDocumentsDirectory();
    return File("${tempDir.path}/dados.json");
  }

  static saveFile(list) async {
    var file = await getFile();

    String dados = json.encode(list);
    file.writeAsString(dados);
  }

  static readFile() async {
    try {
      final file = await getFile();
      return file.readAsString();
    } catch (e) {
      return e;
    }
  }
}
