class SynchronizeSingleton {
  static SynchronizeSingleton? _instance;
  late bool synchronize;

  // Private constructor
  SynchronizeSingleton._internal() {
    _instance = this; // Initialize _instance before setting synchronize
    synchronize = false;
  }

  // Factory constructor to return the singleton instance
  factory SynchronizeSingleton() =>
      _instance ?? SynchronizeSingleton._internal();

  void startSynchronize() {
    if (synchronize == true) throw Exception('ANOTHER_SYNC_IS_IN_PROGRESS');
    synchronize = true;
  }

  void finishSynchronize() {
    synchronize = false;
  }
}
