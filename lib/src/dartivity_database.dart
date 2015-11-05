/*
 * Package : dartivity_database
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 05/011/2015
 * Copyright :  S.Hamblett 2015
 */

part of dartivity_database;

class DartivityDatabase {
  /// Wilt
  WiltServerClient _wilt;

  /// Database name
  static const String DB_NAME = "dartivity";

  /// Always the default port and HTTP, the database already exists, we
  /// do not create or delete it.
  DartivityDatabase(String hostname,
      [String username = null, String password = null]) {
    _wilt = new WiltServerClient(hostname, "5984", "http://");
    _wilt.db = DB_NAME;

    if ((username != null) && (password != null)) _wilt.login(
        username, password);
  }

  /// login
  void login(String user, String password) {
    _wilt.login(user, password);
  }

  /// put
  /// Put a database record, the resource parameter
  /// can be anything we can jsonify, in practice it will be a
  /// DartivityResource. False indicates the put operation has failed.
  Future<bool> put(String key, dynamic resource, [String rev = null]) async {
    Completer completer = new Completer();
    var res = await _wilt.putDocument(key, resource.toJsonObject(), rev);
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

  /// get
  /// Returns a json object, in practice this will be a DartivityResource.
  /// Null indicates the operation has failed for whatever reason.
  Future<json.JsonObject> get(String key, [String rev = null]) async {
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
  /// False indicates the delete operation has failed.
  Future<bool> delete(String key, String rev) async {
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
}
