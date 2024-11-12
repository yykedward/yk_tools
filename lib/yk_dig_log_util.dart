
import 'dart:convert';
import 'dart:io';


class YkDigLogUtilDelegate {

  final Future<void> Function() setup;

  Future<String> Function(String event, String title, dynamic params)? handleData;

  Future<bool> Function(String data) uploadCallBack;

  Future<String> Function() saveDocumentPath;

  void Function(dynamic data)? logCallBack;

  YkDigLogUtilDelegate({required this.setup, required this.uploadCallBack, required this.saveDocumentPath, this.handleData, this.logCallBack});
}

class YkDigLogUtil {

  static YkDigLogUtil? _instance_;

  static YkDigLogUtil get instance {
    _instance_ ??= YkDigLogUtil._();
    return _instance_!;
  }

  YkDigLogUtil._();

  YkDigLogUtilDelegate? _delegate;

  String _currentFileName = "";

  bool _savingFile = false;

  List<String> _cacheList = [];

  static int maxFileLength = 1024 * 5;

  static Future<void> setup({required YkDigLogUtilDelegate delegate}) async {
    YkDigLogUtil.instance._delegate = delegate;
    return delegate.setup.call();
  }

  static void addDig({required String event, required String title, required dynamic params}) {
    YkDigLogUtil.instance._log(event: event, title: title, params: params);
  }

  static void archivedAndUpload() async {
    YkDigLogUtil.instance._archivedAndUpload();

  }

  void _log({required String event, required String title, required dynamic params}) async {

    final finalData = await _delegate?.handleData?.call(event, title, params) ?? "";

    _cacheList.add(finalData);

    _delegate?.logCallBack?.call({
      "event":event,
      "title":title,
      "params":"$params"
    });

    _writeFile();
  }

  void _archivedAndUpload() async {
    final dir = await _getDicPath();
    final files = dir.listSync();
    for (final file in files) {
      if (file.path.contains(".archived")) {

        File f = File(file.path);

        if (f.existsSync()) {
          _upload(file: f);
        }
      } else if (file.path.contains(".log")) {
        _currentFileName = "";
        _savingFile = false;

        file.rename(file.path.replaceAll(".log", ".archived")).then((v) {
          File f = File(v.path);

          if (f.existsSync()) {
            _upload(file: f);
          }
        });
      } else if (file.path.contains(".uploaded")) {

        file.deleteSync();
      }
    }

    _delegate?.logCallBack?.call("正在上传");
  }

  void _writeFile() async {

    if (_cacheList.isNotEmpty) {

      if (_savingFile) {
        Future.delayed(const Duration(microseconds: 200), () {
          _writeFile();
        });
        return;
      }

      _savingFile = true;

      final first = _cacheList.removeAt(0);

      if (_currentFileName.isEmpty) {
        _currentFileName = "${DateTime.now().millisecondsSinceEpoch ~/ 1000}";
      }

      _createPath(_currentFileName, extent: ".log").then((value) {
        return _createFile(value);
      }).then((value) {
        if (value == null) {
          _savingFile = false;
          _cacheList.add(first);
          _writeFile();
          return;
        }
        try {
          value.writeAsString("$first\n", mode: FileMode.writeOnlyAppend).then((value) async {
            final length = value.lengthSync();
            if (length > YkDigLogUtil.maxFileLength) {
              final newPath = value.path.replaceAll(".log", ".archived");
              value.rename(newPath).then((v) {
                _currentFileName = "";
                _savingFile = false;
                _writeFile();
              });
            } else {
              _savingFile = false;
              _cacheList.add(first);
              _writeFile();
            }
          });
        } catch (e) {
          _savingFile = false;
          _cacheList.add(first);
          _writeFile();
          return;
        }
      });


    }
  }

  Future<Directory> _getDicPath() async {

    final documentPath = await _delegate?.saveDocumentPath.call() ?? "";


    final dic = await Directory(documentPath);

    if (!dic.existsSync()) {
      dic.createSync(recursive: true);
    }

    return dic;
  }

  Future<String> _createPath(String fileName, {String extent = ".txt"}) async {
    try {

      final folderPath = await _getDicPath().then((v) {
        return v.path;
      });

      var path_path_url = "$folderPath$fileName$extent";

      return path_path_url;
    } catch (e) { return ""; }
  }

  Future<File?> _createFile(String path) async {

    try {
      final file= await File(path).create();


      return file;
    } catch (e) {
      return null;
    }
  }

  Future<bool> _upload({required File file}) async {

    final result = file.readAsStringSync();

    _delegate?.logCallBack?.call(result);

    final uploadResult = await _delegate?.uploadCallBack.call(result).then((v) async {
      if (v) {
        final isEx = await file.exists();
        if (isEx) {
          file.rename(file.path.replaceAll(".archived", ".uploaded"));
        }
      }
      return v;
    }) ?? false;

    return uploadResult;
  }

  void upload() {

  }
}
