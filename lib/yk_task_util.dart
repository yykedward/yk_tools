

class _YKTaskUtilModel {

  final void Function() action;
  final int sort;

  _YKTaskUtilModel(this.sort, this.action);
}

class YKTaskUtil {

  int _currentIndex = 0;
  int _saveIndex = 0;
  List<_YKTaskUtilModel> _list = [];

  void addTask(void Function() action) {

    _list.add(_YKTaskUtilModel(_list.length+1, action));

    _list.sort((a, b) => a.sort.compareTo(b.sort));

  }

  void nextTask() {
    if (_currentIndex > (_list.length -1)) {
      return;
    }
    var model = _list[_currentIndex];
    _saveIndex = _currentIndex;
    _currentIndex = _currentIndex + 1;
    model.action();

  }

  void executeFirstTask() {
    _currentIndex = 0;
    _saveIndex = 0;
    nextTask();
  }

  void rollBackLastTask() {
    if (_currentIndex <= 0) {
      return;
    }
    _currentIndex = _saveIndex;
  }

  void clear() {
    _currentIndex = 0;
    _saveIndex = 0;
    _list.clear();
  }
}