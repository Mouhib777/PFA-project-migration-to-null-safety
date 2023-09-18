class SynchronizeSingleton {
  static SynchronizeSingleton _instance;
  bool synchronize;
  SynchronizeSingleton._internal() {
    synchronize = false;
    _instance = this;
  }

  factory SynchronizeSingleton() =>
      _instance ?? SynchronizeSingleton._internal();

  void startSynchronize() {
    if (synchronize == true) throw new Exception('ANOTHER_SYNC_IS_IN_PROGRESS');
    synchronize = true;
  }

  void finishSynchronize() {
    synchronize = false;
  }
}
