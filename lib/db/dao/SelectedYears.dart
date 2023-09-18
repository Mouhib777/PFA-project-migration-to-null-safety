import 'package:docu_diary/db/provider.dart';
import 'package:docu_diary/models/models.dart';
import 'package:sembast/sembast.dart';

class SelectedYearsDao {
  static const String SELECTEDYEAR_STORE_NAME = 'year';
  // A Store with int keys and Map<String, dynamic> values.
  // This Store acts like a persistent map, values of which are class objects converted to Map
  final _yeartore = intMapStoreFactory.store(SELECTEDYEAR_STORE_NAME);
  final DBProvider dbProvider = DBProvider();
  // Private getter to shorten the amount of code needed to get the
  // singleton instance of an opened database.
  Future<Database> get _db async => await dbProvider.ready;

  Future insert(PaidYears cls) async {
    await _yeartore.add(await _db, cls.toJson());
  }

  Future delete() async {
    await _yeartore.delete(
      await _db,
    );
  }

  Future<PaidYears> getYear() async {
    // Finder object can also sort data.

    final record = await _yeartore.findFirst(
      await _db,
    );

    if (record != null) {
      return PaidYears.fromJson(record.value);
    }
    return null;
  }

  Future deleteAll() async {
    await _yeartore.delete(
      await _db,
    );
  }

  Future update(PaidYears cls) async {
    await deleteAll();
    await _yeartore.add(await _db, cls.toJson());
  }
}
