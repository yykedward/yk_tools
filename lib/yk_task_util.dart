/// 任务执行器 mixin
mixin TaskAction {
  /// 执行任务
  Future<void> execute(void Function() next);
}

/// 任务模型
class _YKTaskModel {
  final int sort;
  final TaskAction action;
  final String? taskName;

  const _YKTaskModel({
    required this.sort,
    required this.action,
    this.taskName,
  });
}

/// 任务工具类
class YKTaskUtil {
  final List<_YKTaskModel> _taskList = [];
  int _currentIndex = 0;
  int _lastExecutedIndex = 0;
  String? _lastError;

  /// 获取最后的错误信息
  String? get lastError => _lastError;

  /// 获取任务总数
  int get taskCount => _taskList.length;

  /// 获取当前执行的任务索引
  int get currentIndex => _currentIndex;

  /// 添加任务
  void addTask(
    TaskAction action, {
    String? taskName,
  }) {
    _taskList.add(_YKTaskModel(
      sort: _taskList.length + 1,
      action: action,
      taskName: taskName,
    ));

    _taskList.sort((a, b) => a.sort.compareTo(b.sort));
  }

  /// 执行第一个任务
  Future<void> executeFirstTask() async {
    _reset();
    await _nextTask();
  }

  /// 执行下一个任务（私有方法）
  Future<void> _nextTask() async {
    if (_currentIndex >= _taskList.length) {
      return;
    }

    try {
      final model = _taskList[_currentIndex];
      _lastExecutedIndex = _currentIndex;
      _currentIndex++;

      await model.action.execute(() async {
        // 任务内部调用此方法来执行下一个任务
        _nextTask();
      });
      
      _lastError = null;
    } catch (e) {
      _lastError = e.toString();
      rethrow;
    }
  }

  /// 回滚到上一个任务
  void rollBackToLastTask() {
    if (_currentIndex <= 0) return;
    
    _currentIndex = _lastExecutedIndex;
    _lastError = null;
  }

  /// 清除所有任务
  void clear() {
    _reset();
    _taskList.clear();
  }

  /// 重置状态
  void _reset() {
    _currentIndex = 0;
    _lastExecutedIndex = 0;
    _lastError = null;
  }

  /// 插入任务到指定位置
  void insertTask(
    int index,
    TaskAction action, {
    String? taskName,
  }) {
    if (index < 0 || index > _taskList.length) return;

    _taskList.insert(
      index,
      _YKTaskModel(
        sort: index + 1,
        action: action,
        taskName: taskName,
      ),
    );
    
    // 重新排序
    _updateTaskSort();
  }

  /// 移除指定位置的任务
  void removeTask(int index) {
    if (index < 0 || index >= _taskList.length) return;
    
    _taskList.removeAt(index);
    _updateTaskSort();
  }

  /// 更新任务排序
  void _updateTaskSort() {
    for (var i = 0; i < _taskList.length; i++) {
      final task = _taskList[i];
      _taskList[i] = _YKTaskModel(
        sort: i + 1,
        action: task.action,
        taskName: task.taskName,
      );
    }
  }
}