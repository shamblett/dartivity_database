/*
 * Package : dartivity_database
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 05/011/2015
 * Copyright :  S.Hamblett 2015
 */

part of dartivity_database;

class _DartivityDatabaseCouchDB implements _DartivityDatabase {
  /// Wilt
  WiltServerClient _wilt;

  /// Revision cache
  DartivityCache _revision;

  /// Initialised
  bool _initialised = false;

  bool get initialised => _initialised;

  /// Etag Header
  static const ETAG = 'etag';

  /// Always the default port and HTTP.
  _DartivityDatabaseCouchDB(String hostname, String dbName,
      [String username = null, String password = null]) {
    _wilt = new WiltServerClient(hostname, "5984", "http://");
    _wilt.db = dbName;

    if ((username != null) && (password != null)) _wilt.login(
        username, password);

    _revision = new DartivityCache();

    _initialised = true;
  }

  /// login
  void login(String user, String password) {
    _wilt.login(user, password);
  }

  /// put
  /// Put a database record. Returns the database response or
  /// null on error.
  Future<json.JsonObject> put(String key, json.JsonObject record,
      [String rev = null]) async {
    if (!_initialised) return null;
    Completer completer = new Completer();
    String rev = await _getRevision(key);
    var res = await _wilt.putDocument(key, record, rev);
    if (!res.error) {
      completer.complete(res.jsonCouchResponse);
      String rev = WiltUserUtils.getDocumentRev(res);
      _revision.put(res.id, rev);
    } else {
      completer.complete(null);
    }
    return completer.future;
  }

  /// get
  /// Returns a json object.
  /// Null indicates the operation has failed for whatever reason.
  Future<json.JsonObject> get(String key) async {
    if (!_initialised) return null;
    Completer completer = new Completer();
    var res = await _wilt.getDocument(key);
    if (!res.error) {
      json.JsonObject doc = res.jsonCouchResponse;
      if (doc.id == key) {
        String rev = WiltUserUtils.getDocumentRev(doc);
        _revision.put(doc.id, rev);
        completer.complete(res.jsonCouchResponse);
      } else {
        completer.complete(null);
      }
    } else {
      completer.complete(null);
    }
    return completer.future;
  }

  /// delete
  /// False indicates the delete operation has failed, note
  /// a revision must be supplied.
  Future<bool> delete(String key) async {
    if (!_initialised) return false;
    Completer completer = new Completer();
    String rev = await _getRevision(key);
    var res = await _wilt.deleteDocument(key, rev);
    if (!res.error) {
      json.JsonObject doc = res.jsonCouchResponse;
      if (doc.id == key) {
        completer.complete(true);
        _revision.delete(key);
      } else {
        completer.complete(false);
      }
    } else {
      completer.complete(false);
    }
    return completer.future;
  }

  /// putMany
  /// Puts many records as a bulk insert/update
  Future<List<json.JsonObject>> putMany(List<json.JsonObject> records) async {
    if (!_initialised) return null;
    String rev = _revision.get(resource.id);
    if (rev == null) {
      futList.add(sync(resource.id).then((String rev) {
        String key = rev == null ? "norev" + resource.id : rev;
        resMap[key] = resource.toJsonObject();
      }));
    } else {
      String key = rev;
      resMap[key] = resource.toJsonObject();
    }
    List<json.JsonObject> resList = new List<json.JsonObject>();
    Completer completer = new Completer();
    records.forEach((String key, json.JsonObject res) {
      json.JsonObject tmp = new json.JsonObject.fromJsonString(
          WiltUserUtils.addDocumentId(res, res.id));
      if (!key.contains('norev')) tmp = new json.JsonObject.fromJsonString(
          WiltUserUtils.addDocumentRev(tmp, key));
      resList.add(tmp);
    });
    List<String> docString = new List<String>();
    resList.forEach((val) {
      docString.add(val.toString());
    });
    String bulk = WiltUserUtils.createBulkInsertString(docString);
    var res = await _wilt.bulkString(bulk);
    if (!res.error) {
      json.JsonObject response = res.jsonCouchResponse;
      Map<String, json.JsonObject> retMap = new Map<String, json.JsonObject>();
      response.forEach((resp) {
        if (resp != null) {
          _revision.put(res.id, key);
          if (resp.containsKey('rev')) retMap[resp.rev] = resp;
        }
      });
      completer.complete(retMap);
    } else {
      completer.complete(false);
    }
    return completer.future;
  }

  /// all
  /// Gets all records in the database
  Future<json.JsonObject> all() async {
    if (!_initialised) return null;
    Completer completer = new Completer();
    var res = await _wilt.getAllDocs(includeDocs: true);
    if (!res.error) {
      res.forEach((resource) {
        _revision.put(resource.id, WiltUserUtils.getDocumentRev(resource));
      });
      completer.complete(res.jsonCouchResponse);
    } else {
      completer.complete(false);
    }
    return completer.future;
  }

  /// getRevision
  /// Gets the latest revision of a database record either
  /// from the cache or from the database itself.
  Future<String> _getRevision(String key) async {
    if (!_initialised) return null;
    Completer completer = new Completer();

    String rev = _revision.get(key);
    if (rev == null) {
      String url = key;
      json.JsonObject res = await _wilt.head(url);
      json.JsonObject headers =
      new json.JsonObject.fromMap(res.allResponseHeaders);
      if (headers.containsKey(ETAG)) {
        String ver = headers.etag;
        ver = ver.substring(1, ver.length - 1);
        completer.complete(ver);
      } else {
        completer.complete(null);
      }
    } else {
      completer.complete(rev);
    }
    return completer.future;
  }
}
