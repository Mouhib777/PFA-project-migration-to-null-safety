import 'package:docu_diary/db/provider.dart';
import 'package:docu_diary/models/models.dart';
import 'package:sembast/sembast.dart';

class TokenDao {
  static const String TOKENS_STORE_NAME = 'tokens';
  // A Store with int keys and Map<String, dynamic> values.
  // This Store acts like a persistent map, values of which are Token objects converted to Map
  final _tokenStore = intMapStoreFactory.store(TOKENS_STORE_NAME);
  final DBProvider dbProvider = DBProvider();
  // Private getter to shorten the amount of code needed to get the
  // singleton instance of an opened database.
  Future<Database> get _db async => await dbProvider.ready;

  Future insert(Token token) async {
    await _tokenStore.add(await _db, token.toJson());
  }

  Future delete() async {
    await _tokenStore.delete(
      await _db,
    );
  }

  Future<Token> getToken() async {
    // Finder object can also sort data.
    final finder = Finder(sortOrders: [
      SortOrder('accessToken'),
    ]);

    final record = await _tokenStore.findFirst(
      await _db,
      finder: finder,
    );
    if (record != null) {
      return Token.fromJson(record.value);
    }
    return null;
  }
}
