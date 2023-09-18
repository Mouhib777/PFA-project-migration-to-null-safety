import 'package:docu_diary/db/provider.dart';
import 'package:docu_diary/models/models.dart';
import 'package:sembast/sembast.dart';

class SelectedClassDao {
  static const String SELECTEDCLASS_STORE_NAME = 'class';
  // A Store with int keys and Map<String, dynamic> values.
  // This Store acts like a persistent map, values of which are class objects converted to Map
  final _classtore = intMapStoreFactory.store(SELECTEDCLASS_STORE_NAME);
  final DBProvider dbProvider = DBProvider();
  // Private getter to shorten the amount of code needed to get the
  // singleton instance of an opened database.
  Future<Database> get _db async => await dbProvider.ready;

  Future insert(Class cls) async {
    await _classtore.add(await _db, cls.toJson());
  }

  Future delete() async {
    await _classtore.delete(
      await _db,
    );
  }

  Future<Class> getClass() async {
    // Finder object can also sort data.

    final record = await _classtore.findFirst(
      await _db,
    );

    if (record != null) {
      return Class.fromJson(record.value);
    }
    return null;
  }

  Future deleteAll() async {
    await _classtore.delete(
      await _db,
    );
  }

  Future update(Class cls) async {
    await deleteAll();
    await _classtore.add(await _db, cls.toJson());
  }
}
