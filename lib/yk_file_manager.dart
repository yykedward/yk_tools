library ykftools;

import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class YKFileManager {
  static YKFileManager? _instance;

  factory YKFileManager._getInstance() {
    _instance ??= YKFileManager._();
    return _instance!;
  }

  YKFileManager._();

  Future<String> _getDocumentPath() async {
    try {
      var path = "";
      if (Platform.isAndroid) {
        path = ((await getExternalCacheDirectories())?.first)?.path ?? "";
      } else if (Platform.isIOS) {
        path = (await getApplicationDocumentsDirectory()).path;
      }

      final folderPath = "$path/YKF/Document/";
      final dir = Directory(folderPath);

      final isExists = await dir.exists();

      if (!isExists) {
        await dir.create(recursive: true);
      }

      return dir.path;
    } catch (e) {
      throw e;
    }
  }

  Future<String> _getCachePath() async {
    try {
      var path = "";
      if (Platform.isAndroid) {
        path = ((await getExternalCacheDirectories())?.first)?.path ?? "";
      } else if (Platform.isIOS) {
        path = (await getApplicationDocumentsDirectory()).path;
      }

      final folderPath = "$path/YKF/Cache/";
      final dir = Directory(folderPath);

      final isExists = await dir.exists();

      if (!isExists) {
        await dir.create(recursive: true);
      }

      return dir.path;
    } catch (e) {
      throw e;
    }
  }

  static Future<String> save(dynamic data, {String? fileName, bool isCache = true}) async {
    var fileN = "";
    if (fileName != null) {
      fileN = fileName;
    } else {
      fileN = "file.txt";
    }

    try {
      var file_path = "";

      if (isCache) {
        file_path = await YKFileManager._getInstance()._getCachePath();
      } else {
        file_path = await YKFileManager._getInstance()._getDocumentPath();
      }

      var path_path_url = "$file_path/$fileName";

      String fileName_base = path.basename(path_path_url);

      final result = path_path_url.replaceAll(fileName_base, "");

      final dic = await Directory(result);
      
      if (!dic.existsSync()) {
        dic.createSync(recursive: true);
      }
      final file= await File(path_path_url).create();
      file.writeAsBytes(data);

      return file.path;
    } catch (e) {
      throw e;
    }
  }

  static Future<dynamic> getDataWithFileName(String name) async {
    try {
      var cachePath = await YKFileManager._getInstance()._getCachePath();
      var filePath = "$cachePath/$name";

      final file = await File(filePath);
      final execte = await file.exists();
      if (execte) {
        return await file.readAsBytes();
      } else {
        var docPath = await YKFileManager._getInstance()._getDocumentPath();
        filePath = "$docPath/$name";

        final docFile = await File(filePath);
        final docExecte = await docFile.exists();

        if (docExecte) {
          return await docFile.readAsBytes();
        } else {
          return null;
        }
      }
    } catch (e) {
      throw e;
    }
  }

  static Future<String> createFilePath(String fileName) async {

    try {
      var doc_path = await YKFileManager._getInstance()._getDocumentPath();

      var path_path_url = "$doc_path/$fileName";

      String fileName_base = path.basename(path_path_url);

      final result = path_path_url.replaceAll(fileName_base, "");

      final dic = await Directory(result);
      if (!dic.existsSync()) {
        dic.createSync(recursive: true);
      }
      final file= await File(path_path_url).create();

      return file.path;
    } catch (e) {
      throw e;
    }
  }

  static Future<dynamic> getDataWithPath(String path) async {

    try {
      final docFile = File(path);
      final docFileEx = await docFile.exists();
      
      if (docFileEx) {
        return docFile.readAsBytes();
      } else {
        return null;
      }

    } catch (e) {
      throw e;
    }

  }
  
}
