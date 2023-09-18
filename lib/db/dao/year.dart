import 'package:docu_diary/db/provider.dart';
import 'package:docu_diary/models/models.dart';
import 'package:sembast/sembast.dart';

class YearDao {
  static const String YEAR_STORE_NAME = 'years';
  // A Store with int keys and Map<String, dynamic> values.
  // This Store acts like a persistent map, values of which are Class objects converted to Map
  final _yearStore = intMapStoreFactory.store(YEAR_STORE_NAME);
  final DBProvider dbProvider = DBProvider();
  // Private getter to shorten the amount of code needed to get the
  // singleton instance of an opened database.
  Future<Database> get _db async => await dbProvider.ready;

  Future insertMany(List<PaidYears> classes) async {
    await deleteAll();
    final Database db = await _db;
    await db.transaction((txn) async {
      classes.forEach((PaidYears cls) async {
        await _yearStore.add(db, cls.toJson());
      });
    });
  }

  Future deleteAll() async {
    await _yearStore.delete(
      await _db,
    );
  }

  Future update(PaidYears cls) async {
    // For filtering by key (ID), RegEx, greater than, and many other criteria,
    // we use a Finder.
    final finder = Finder(filter: Filter.equals('_id', cls.sId));

    await _yearStore.update(
      await _db,
      cls.toJson(),
      finder: finder,
    );
  }

  Future<List<PaidYears>> getYears() async {
    // Finder object can also sort data.
    final finder = Finder(sortOrders: [
      SortOrder('updatedAt', false),
    ]);

    final recordSnapshots = await _yearStore.find(
      await _db,
      finder: finder,
    );
    return recordSnapshots.map((snapshot) {
      return PaidYears.fromJson(snapshot.value);
    }).toList();
  }

  Future<PaidYears> getYear(String sId) async {
    final finder = Finder(filter: Filter.equals('_id', sId));

    final record = await _yearStore.findFirst(
      await _db,
      finder: finder,
    );
    if (record != null) {
      return PaidYears.fromJson(record.value);
    }
    return null;
  }

  Future insert(PaidYears cls) async {
    await _yearStore.add(await _db, cls.toJson());
  }

  Future delete(PaidYears cls) async {
    // For filtering by key (ID), RegEx, greater than, and many other criteria,
    // we use a Finder.
    final finder = Finder(filter: Filter.equals('_id', cls.sId));
    await _yearStore.delete(
      await _db,
      finder: finder,
    );
  }

  Future<PaidYears> findFirst() async {
    // Finder object can also sort data.
    final finder = Finder(sortOrders: [
      SortOrder('updatedAt', false),
    ]);

    final record = await _yearStore.findFirst(
      await _db,
      finder: finder,
    );
    if (record != null) {
      return PaidYears.fromJson(record.value);
    }
    return null;
  }
}
