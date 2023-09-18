import 'package:docu_diary/db/provider.dart';
import 'package:docu_diary/models/models.dart';
import 'package:sembast/sembast.dart';

class UserDao {
  static const String USERS_STORE_NAME = 'users';
  // A Store with int keys and Map<String, dynamic> values.
  // This Store acts like a persistent map, values of which are User objects converted to Map
  final _userStore = intMapStoreFactory.store(USERS_STORE_NAME);
  final DBProvider dbProvider = DBProvider();
  // Private getter to shorten the amount of code needed to get the
  // singleton instance of an opened database.
  Future<Database> get _db async => await dbProvider.ready;

  Future insert(User user) async {
    await _userStore.add(await _db, user.toJson());
  }

  Future delete() async {
    await _userStore.delete(
      await _db,
    );
  }

  Future<User> getUser() async {
    // Finder object can also sort data.
    final finder = Finder(sortOrders: [
      SortOrder('name'),
    ]);

    final record = await _userStore.findFirst(
      await _db,
      finder: finder,
    );
    if (record != null) {
      return User.fromJson(record.value);
    }
    return null;
  }
}
