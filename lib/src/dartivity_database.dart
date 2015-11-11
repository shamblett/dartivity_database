/*
 * Package : dartivity_database
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 05/011/2015
 * Copyright :  S.Hamblett 2015
 */

part of dartivity_database;

class _DartivityDatabase {
  /// Wilt
  WiltServerClient _wilt;

  /// Initialised
  bool _initialised = false;

  bool get initialised => _initialised;

  /// Always the default port and HTTP.
  _DartivityDatabase(String hostname, String dbName,
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
  Future<json.JsonObject> putMany(List<json.JsonObject> records) async {
    if (!_initialised) return null;
    Completer completer = new Completer();
    var res = await _wilt.bulk(records);
    if (!res.error) {
      completer.complete(res.jsonCouchResponse);
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
}
