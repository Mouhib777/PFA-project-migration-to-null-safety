import 'package:docu_diary/db/provider.dart';
import 'package:docu_diary/models/models.dart';
import 'package:sembast/sembast.dart';

class ClassDao {
  static const String CLASSES_STORE_NAME = 'classes';
  // A Store with int keys and Map<String, dynamic> values.
  // This Store acts like a persistent map, values of which are Class objects converted to Map
  final _classStore = intMapStoreFactory.store(CLASSES_STORE_NAME);
  final DBProvider dbProvider = DBProvider();
  // Private getter to shorten the amount of code needed to get the
  // singleton instance of an opened database.
  Future<Database> get _db async => await dbProvider.ready;

  Future insertMany(List<Class> classes) async {
    await deleteAll();
    final Database db = await _db;
    await db.transaction((txn) async {
      classes.forEach((Class cls) async {
        await _classStore.add(db, cls.toJson());
      });
    });
  }

  Future deleteAll() async {
    await _classStore.delete(
      await _db,
    );
  }

  Future update(Class cls) async {
    // For filtering by key (ID), RegEx, greater than, and many other criteria,
    // we use a Finder.
    final finder = Finder(filter: Filter.equals('id', cls.id));
    await _classStore.update(
      await _db,
      cls.toJson(),
      finder: finder,
    );
  }

  Future<List<Class>> getClasses(String schoolYear) async {
    // Finder object can also sort data.
    final finder = Finder(
        sortOrders: [
          SortOrder('updatedAt', false),
          SortOrder('className', true),
        ],
        filter: Filter.equals('isDeleted', false) &
            Filter.equals('schoolYear', schoolYear));

    final recordSnapshots = await _classStore.find(
      await _db,
      finder: finder,
    );
    return recordSnapshots.map((snapshot) {
      return Class.fromJson(snapshot.value);
    }).toList();
  }

  Future<Class> getClass(String classId) async {
    final finder = Finder(filter: Filter.equals('id', classId));

    final record = await _classStore.findFirst(
      await _db,
      finder: finder,
    );
    if (record != null) {
      return Class.fromJson(record.value);
    }
    return null;
  }

  Future insert(Class cls) async {
    await _classStore.add(await _db, cls.toJson());
  }

  Future delete(Class cls) async {
    // For filtering by key (ID), RegEx, greater than, and many other criteria,
    // we use a Finder.
    final finder = Finder(
        filter: Filter.equals('className', cls.className) &
            Filter.equals('schoolYear', cls.schoolYear) &
            Filter.equals('isDeleted', false));
    await _classStore.delete(
      await _db,
      finder: finder,
    );
  }

  Future<Class> findFirst(String schoolYear) async {
    // Finder object can also sort data.
    final finder = Finder(
        sortOrders: [
          SortOrder('updatedAt', false),
        ],
        filter: Filter.equals('isDeleted', false) &
            Filter.equals('schoolYear', schoolYear));

    final record = await _classStore.findFirst(
      await _db,
      finder: finder,
    );
    if (record != null) {
      return Class.fromJson(record.value);
    }
    return null;
  }

  Future<Class> getClassByName({String schoolYear, String className}) async {
    final finder = Finder(
        filter: Filter.equals('className', className) &
            Filter.equals('schoolYear', schoolYear) &
            Filter.equals('isDeleted', false));

    final record = await _classStore.findFirst(
      await _db,
      finder: finder,
    );
    if (record != null) {
      return Class.fromJson(record.value);
    }
    return null;
  }

  Future<Class> findOnlineClass(String schoolYear) async {
    final finder = Finder(
        filter: Filter.equals('synchronize', false) &
            Filter.equals('schoolYear', schoolYear));

    final record = await _classStore.findFirst(
      await _db,
      finder: finder,
    );
    if (record != null) {
      return Class.fromJson(record.value);
    }
    return null;
  }

  Future<List<Class>> getClassesToSync() async {
    // Finder object can also sort data.
    final finder = Finder(filter: Filter.equals('synchronize', true));

    final recordSnapshots = await _classStore.find(
      await _db,
      finder: finder,
    );
    return recordSnapshots.map((snapshot) {
      return Class.fromJson(snapshot.value);
    }).toList();
  }
}
