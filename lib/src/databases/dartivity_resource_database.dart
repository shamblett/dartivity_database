/*
 * Package : dartivity_database
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 05/011/2015
 * Copyright :  S.Hamblett 2015
 */

part of dartivity_database;

class DartivityResourceDatabase {
  /// This class implements the Dartivity resource database. The implementation
  /// is revisionless, regardless of what database driver is used, all operations
  /// occur on the latest revision of a resource.
  /// As of this release only the CouchDb database driver is available.

  DartivityResourceDatabase(String? hostname,
      [String? username, String? password]) {
    _db = _DartivityDatabaseCouchDB(hostname, dbName, '5984', 'http://');

    if ((username != null) && (password != null)) _db.login(username, password);
  }
  //
  /// Database
  late var _db;
  final String dbName = 'resource';

  /// Initialised
  bool? get initialised => _db.initialised;

  /// login
  void login(String user, String password) {
    _db.login(user, password);
  }

  /// get
  /// Returns a DartivityResource or null if none found.
  /// Always gets the latest revision
  Future<DartivityResource> get(String? key) async {
    final completer = Completer<DartivityResource>();
    final dynamic record = await _db.get(key);
    if (record == null) {
      completer.complete(null);
    } else {
      final res = DartivityResource.fromDbRecord(record);
      completer.complete(res);
    }
    return completer.future;
  }

  /// put
  /// Returns the resource with the update time updated.
  /// Null indicates the put failed.
  Future<DartivityResource> put(DartivityResource resource) async {
    final completer = Completer<DartivityResource>();
    resource.updated = DateTime.now();
    final dynamic res = await _db.put(resource.id, resource.toJsonObject());
    if (res != null) {
      if (res.ok) {
        completer.complete(resource);
      } else {
        completer.complete(null);
      }
    } else {
      completer.complete(null);
    }
    return completer.future;
  }

  /// delete
  /// Returns true if successful
  Future<bool> delete(DartivityResource resource) async {
    final completer = Completer<bool>();
    final bool res = await _db.delete(resource.id);
    if (res) {
      completer.complete(true);
    } else {
      completer.complete(false);
    }
    return completer.future;
  }

  /// all
  /// Gets all the resources in the resource database.
  Future<Map<String?, DartivityResource>> all() async {
    final completer = Completer<Map<String?, DartivityResource>>();
    final List<dynamic>? resList = await _db.all();
    if (resList != null) {
      final ret = <String?, DartivityResource>{};
      resList.forEach((row) {
        final res = DartivityResource.fromDbRecord(row);
        ret[res.id] = res;
      });
      completer.complete(ret);
    } else {
      completer.complete(null);
    }

    return completer.future;
  }

  /// putMany
  /// Bulk insert of resources.
  Future<List<DartivityResource>> putMany(
      List<DartivityResource?> resList) async {
    final completer = Completer<List<DartivityResource>>();
    final jsonList = <jsonobject.JsonObjectLite>[];
    for (var resource in resList) {
      resource!.updated = DateTime.now();
      jsonList.add(resource.toJsonObject());
    }
    final List<dynamic>? jsonRes = await _db.putMany(jsonList);
    if (jsonRes != null) {
      final retList = <DartivityResource>[];
      jsonRes.forEach((resource) {
        retList.add(DartivityResource.fromDbRecord(resource));
      });
      completer.complete(retList);
    } else {
      completer.complete(null);
    }

    return completer.future;
  }
}
