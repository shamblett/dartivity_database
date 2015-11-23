/*
 * Package : dartivity_database
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 05/011/2015
 * Copyright :  S.Hamblett 2015
 */

part of dartivity_database;

class DartivityResourceDatabase {
  /// Database
  var _db;
  final String dbName = 'resource';

  /// Initialised
  bool get initialised => _db.initialised;

  DartivityResourceDatabase(String hostname,
      [String username = null, String password = null]) {
    _db = new _DartivityDatabaseCouchDB(hostname, dbName, "5984", "http://");

    if ((username != null) && (password != null)) _db.login(username, password);
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
    json.JsonObject res = await _db.put(resource.id, resource.toJsonObject());
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
    Completer completer = new Completer();
    bool res = await _db.delete(resource.id);
    if (res) {
      completer.complete(true);
    } else {
      completer.complete(false);
    }
    return completer.future;
  }

  /// all
  /// Gets all the resources in the resource database.
  Future<Map<String, DartivityResource>> all() async {
    Completer completer = new Completer();
    json.JsonObject resList = await _db.all();
    if (resList != null) {
      List rows = resList.rows;
      Map<String, DartivityResource> ret = new Map<String, DartivityResource>();
      rows.forEach((row) {
        DartivityResource res = new DartivityResource.fromDbRecord(row.doc);
        ret[res.id] = res;
      });
      completer.complete(ret);
    } else {
      completer.complete(null);
    }

    return completer.future;
  }

  /// putMany
  /// Bulk insert of resources, a list of actual updates performed is
  /// returned.
  Future<List<DartivityResource>> putMany(
      List<DartivityResource> resList) async {
    Completer completer = new Completer();
    List<json.JsonObject> jsonList = new List<json.JsonObject>();
    for (DartivityResource resource in resList) {
      resource.updated = new DateTime.now();
      jsonList.add(resource.toJsonObject());
    }
    List<json.JsonObject> jsonRes = await _db.putMany(jsonList);
    if (jsonRes != null) {
      List<DartivityResource> retList = new List<DartivityResource>();
      jsonRes.forEach((resource) {
        retList.add(new DartivityResource.fromDbRecord(resource));
      });
      completer.complete(retList);
    } else {
      completer.complete(null);
    }

    return completer.future;
  }
}
