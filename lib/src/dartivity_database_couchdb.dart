/*
 * Package : dartivity_database
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 05/011/2015
 * Copyright :  S.Hamblett 2015
 */

part of dartivity_database;

class _DartivityDatabaseCouchDB {
  /// Wilt
  WiltServerClient _wilt;

  /// Initialised
  bool _initialised = false;

  bool get initialised => _initialised;

  /// Always the default port and HTTP.
  _DartivityDatabaseCouchDB(String hostname, String dbName,
      [String username = null, String password = null]) {
    _wilt = new WiltServerClient(hostname, "5984", "http://");
    _wilt.db = dbName;

    if ((username != null) && (password != null)) _wilt.login(
        username, password);

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
    var res = await _wilt.putDocument(key, record, rev);
    if (!res.error) {
      completer.complete(res.jsonCouchResponse);
    } else {
      completer.complete(null);
    }
    return completer.future;
  }

  /// get
  /// Returns a json object.
  /// Null indicates the operation has failed for whatever reason.
  Future<json.JsonObject> get(String key, [String rev = null]) async {
    if (!_initialised) return null;
    Completer completer = new Completer();
    var res = await _wilt.getDocument(key, rev);
    if (!res.error) {
      json.JsonObject doc = res.jsonCouchResponse;
      if (doc.id == key) {
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
  Future<bool> delete(String key, String rev) async {
    if (!_initialised) return false;
    Completer completer = new Completer();
    var res = await _wilt.deleteDocument(key, rev);
    if (!res.error) {
      json.JsonObject doc = res.jsonCouchResponse;
      if (doc.id == key) {
        completer.complete(true);
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
  Future<Map<String, json.JsonObject>> putMany(
      Map<String, json.JsonObject> records) async {
    if (!_initialised) return null;
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
          if (resp.containsKey('rev'))
            retMap[resp.rev] = resp;
        }
      });
      completer.complete(retMap);
    } else {
      completer.complete(false);
    }
    return completer.future;
  }

  /// getAll
  /// Gets all records in the input parameter set
  Future<json.JsonObject> getAll({bool includeDocs: false,
  int limit: null,
  String startKey: null,
  String endKey: null,
  List<String> keys: null,
  bool descending: false}) async {
    if (!_initialised) return null;
    Completer completer = new Completer();
    var res = await _wilt.getAllDocs(
        includeDocs: includeDocs,
        limit: limit,
        startKey: startKey,
        endKey: endKey,
        keys: keys,
        descending: descending);
    if (!res.error) {
      completer.complete(res.jsonCouchResponse);
    } else {
      completer.complete(false);
    }
    return completer.future;
  }

  /// getRevision
  // Gets the latest revision of a database record
  Future<String> getRevision(String key) async {
    if (!_initialised) return null;
    Completer completer = new Completer();

    String url = key;
    json.JsonObject res = await _wilt.head(url);
    json.JsonObject headers =
    new json.JsonObject.fromMap(res.allResponseHeaders);
    if (headers.containsKey('etag')) {
      String ver = headers.etag;
      ver = ver.substring(1, ver.length - 1);
      completer.complete(ver);
    } else {
      completer.complete(null);
    }
    return completer.future;
  }
}
