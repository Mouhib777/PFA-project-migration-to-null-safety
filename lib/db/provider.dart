import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:synchronized/synchronized.dart';

class DBProvider {
  static const String dbName = 'docudiary.db';
  static const int kVersion1 = 1;
  final lock = Lock(reentrant: true);
  final DatabaseFactory dbFactory;
  late Database db;

  DBProvider()
      : this.dbFactory = kIsWeb ? databaseFactoryWeb : databaseFactoryIo;
  Future openPath(String path) async {
    db = await dbFactory.openDatabase(path, version: kVersion1);
  }

  Future<Database> get ready async => db ??= await lock.synchronized(() async {
        if (db == null) {
          await open();
        }
        return db;
      });

  Future open() async {
    await openPath(kIsWeb ? dbName : await fixPath(dbName));
  }

  Future<String> fixPath(String path) async {
    var dir = await getApplicationDocumentsDirectory();
    // make sure it exists
    await dir.create(recursive: true);
    // build the database path
    var dbPath = dir.path + '/' + path;
    return dbPath;
  }
}
