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

  /// Revision cache
  DartivityCache _revision;

  /// Initialised
  bool get initialised => _db.initialised;

  DartivityResourceDatabase(String hostname,
      [String username = null, String password = null]) {
    _db = new _DartivityDatabaseCouchDB(hostname, dbName, "5984", "http://");

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
    if (rev == null) {
      rev = await sync(resource.id);
    }
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
  /// Returns true if successful
  Future<bool> delete(DartivityResource resource) async {
    Completer completer = new Completer();
    String rev = _revision.get(resource.id);
    if (rev == null) {
      rev = await sync(resource.id);
    }
    bool res = await _db.delete(resource.id, rev);
    if (res) {
      _revision.delete(resource.id);
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
    json.JsonObject resList = await _db.getAll(includeDocs: true);
    if (resList != null) {
      List rows = resList.rows;
      Map<String, DartivityResource> ret = new Map<String, DartivityResource>();
      rows.forEach((row) {
        DartivityResource res = new DartivityResource.fromDbRecord(row.doc);
        ret[res.id] = res;
        _revision.put(res.id, WiltUserUtils.getDocumentRev(row));
      });
      completer.complete(ret);
    } else {
      completer.complete(null);
    }

    return completer.future;
  }

  /// putMany
  /// Bulk insert of resources, note if one resource fails to
  /// create/update it does not stop the rest of the update being
  /// tried.
  Future<List<DartivityResource>> putMany(
      List<DartivityResource> resList) async {
    Completer completer = new Completer();
    Map<String, json.JsonObject> resMap = new Map<String, json.JsonObject>();
    resList.forEach((resource) async {
      resource.updated = new DateTime.now().millisecondsSinceEpoch;
      String rev = _revision.get(resource.id);
      if (rev == null) {
        rev = await sync(resource.id);
      }
      String key = rev == null ? "norev" : rev;
      resMap[key] = resource.toJsonObject();
      List<json.JsonObject> jsonRes = await _db.putMany(resMap);
      if (jsonRes != null) {


      } else {
        completer.complete(null);
      }
    });
    return completer.future;
  }


  /// sync
  /// Syncs the revision cache with the latest revision of a document
  /// from the database.
  Future<String> sync(String key) async {
    Completer completer = new Completer();
    String revision = await _db.getRevision(key);
    if (revision != null) {
      _revision.put(key, revision);
      completer.complete(revision);
    } else {
      completer.complete(null);
    }
    return completer.future;
  }
}
