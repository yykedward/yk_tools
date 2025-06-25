import 'dart:io';

// 将 LogData 改为私有类，添加下划线前缀
class _LogData {
  final String event;
  final String title;
  final dynamic params;
  final DateTime timestamp;

  _LogData({
    required this.event,
    required this.title,
    required this.params,
  }) : timestamp = DateTime.now();

  const _LogData.withTimestamp({
    required this.event,
    required this.title,
    required this.params,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'event': event,
        'title': title,
        'params': params,
        'timestamp': timestamp.toIso8601String(),
      };
}

class YkDigLogUtilDelegate {
  final Future<void> Function() setup;
  final Future<bool> Function(String data) uploadCallBack;
  final Future<String> Function() saveDocumentPath;
  final Future<String> Function(String event, String title, dynamic params)? handleData;
  final void Function(dynamic data)? logCallBack;

  const YkDigLogUtilDelegate({
    required this.setup,
    required this.uploadCallBack,
    required this.saveDocumentPath,
    this.handleData,
    this.logCallBack,
  });
}

class YkDigLogUtil {
  // 单例实现
  static final YkDigLogUtil instance = YkDigLogUtil._();

  YkDigLogUtil._();

  YkDigLogUtilDelegate? _delegate;
  String _currentFileName = '';
  bool _isWriting = false;
  final List<String> _logQueue = [];

  // 将 const 改为 static 变量，使其可修改
  static int maxFileSize = 1024 * 5; // 默认值为 5KB
  static const String logExtension = '.log';
  static const String archivedExtension = '.archived';
  static const String uploadedExtension = '.uploaded';

  // 初始化方法
  static Future<void> setup({required YkDigLogUtilDelegate delegate}) async {
    instance._delegate = delegate;
    return delegate.setup();
  }

  // 添加日志
  static void addLog({
    required String event,
    required String title,
    required dynamic params,
  }) {
    instance._addLogEntry(event: event, title: title, params: params);
  }

  // 归档并上传
  static Future<void> archiveAndUpload() async {
    await instance._archiveAndUpload();
  }

  // 内部方法实现
  Future<void> _addLogEntry({
    required String event,
    required String title,
    required dynamic params,
  }) async {
    final logData = await _delegate?.handleData?.call(event, title, params) ?? '';

    _logQueue.add(logData);

    _delegate?.logCallBack?.call(_LogData(
      event: event,
      title: title,
      params: params,
    ).toJson());

    await _processLogQueue();
  }

  Future<void> _processLogQueue() async {
    if (_logQueue.isEmpty || _isWriting) return;

    _isWriting = true;
    try {
      final entry = _logQueue.removeAt(0);
      await _writeLogToFile(entry);
    } finally {
      _isWriting = false;
      if (_logQueue.isNotEmpty) {
        await _processLogQueue();
      }
    }
  }

  Future<void> _writeLogToFile(String logEntry) async {
    if (_currentFileName.isEmpty) {
      _currentFileName = DateTime.now().millisecondsSinceEpoch.toString();
    }

    final file = await _getLogFile(_currentFileName);
    if (file == null) {
      _logQueue.insert(0, logEntry);
      return;
    }

    try {
      await file.writeAsString('$logEntry\n', mode: FileMode.append);

      if (await file.length() > maxFileSize) {
        await _archiveCurrentFile(file);
        _currentFileName = '';
      }
    } catch (e) {
      _logQueue.insert(0, logEntry);
      _delegate?.logCallBack?.call('写入日志失败: $e');
    }
  }

  Future<void> _archiveAndUpload() async {
    final dir = await _getLogDirectory();
    final files = dir.listSync();

    for (final file in files) {
      final path = file.path;
      if (path.endsWith(uploadedExtension)) {
        await file.delete();
        continue;
      }

      if (path.endsWith(logExtension)) {
        final newPath = path.replaceAll(logExtension, archivedExtension);
        final archivedFile = await File(path).rename(newPath);
        await _uploadFile(archivedFile);
      } else if (path.endsWith(archivedExtension)) {
        await _uploadFile(File(path));
      }
    }
  }

  Future<void> _uploadFile(File file) async {
    if (!await file.exists()) return;

    try {
      final content = await file.readAsString();
      _delegate?.logCallBack?.call(content);

      final success = await _delegate?.uploadCallBack(content) ?? false;
      if (success) {
        final newPath = file.path.replaceAll(archivedExtension, uploadedExtension);
        await file.rename(newPath);
      }
    } catch (e) {
      _delegate?.logCallBack?.call('上传失败: $e');
    }
  }

  // 工具方法
  Future<Directory> _getLogDirectory() async {
    final path = await _delegate?.saveDocumentPath() ?? '';
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File?> _getLogFile(String fileName) async {
    try {
      final dir = await _getLogDirectory();
      final path = '${dir.path}$fileName$logExtension';
      return await File(path).create();
    } catch (e) {
      _delegate?.logCallBack?.call('创建日志文件失败: $e');
      return null;
    }
  }

  Future<void> _archiveCurrentFile(File file) async {
    try {
      if (await file.exists()) {
        final newPath = file.path.replaceAll(logExtension, archivedExtension);
        await file.rename(newPath);
        await _uploadFile(File(newPath));
      }
    } catch (e) {
      _delegate?.logCallBack?.call('归档文件失败: $e');
    }
  }
}
