/*
 * Package : dartivity_database
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 05/011/2015
 * Copyright :  S.Hamblett 2015
 */

part of dartivity_database;

class DartivityResourceDatabase {
  /// Database
  _DartivityDatabase _db;
  final String dbName = 'resource';

  /// Revision cache
  DartivityCache _revision;

  /// Initialised
  bool get initialised => _db.initialised;

  DartivityResourceDatabase(String hostname,
      [String username = null, String password = null]) {
    _db = new _DartivityDatabase(hostname, dbName, "5984", "http://");

    if ((username != null) && (password != null)) _db.login(username, password);

    _revision = new DartivityCache();
  }

  /// login
  void login(String user, String password) {
    _db.login(user, password);
  }

  /// get
  /// Returns a DartivityResource or null if none found.
  /// Always gets the latest revision
  Future<DartivityResource> get(String key) async {
    Completer completer = new Completer();
    json.JsonObject record = await _db.get(key);
    if (record == null) {
      completer.complete(null);
    } else {
      DartivityResource res = new DartivityResource.fromDbRecord(record);
      String rev = WiltUserUtils.getDocumentRev(record);
      _revision.put(res.id, rev);
      completer.complete(res);
    }
    return completer.future;
  }

  /// put
  /// Returns the resource with the update time updated.
  /// Null indicates the put failed.
  Future<DartivityResource> put(DartivityResource resource) async {
    Completer completer = new Completer();
    resource.updated = new DateTime.now();
    String rev = _revision.get(resource.id);
    json.JsonObject res =
    await _db.put(resource.id, resource.toJsonObject(), rev);
    if (res != null) {
      if (res.ok) {
        _revision.put(res.id, res.rev);
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
  /// Returns true if sucessful
  Future<bool> delete(DartivityResource resource) async {
    String rev = _revision.get(resource.id);
    return await _db.delete(resource.id, rev);
  }
}
