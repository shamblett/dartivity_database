/*
 * Package : dartivity_database
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 05/011/2015
 * Copyright :  S.Hamblett 2015
 */

part of dartivity_database;

class _DartivityDatabaseCouchDB implements _DartivityDatabase {

  /// The CouchDb database driver class. Implements the interface to
  /// CouchDb using the Wilt class and handles CouchDb revisions using
  /// an instance of the DartivityCache class and the getRevision method
  /// for direct database enquiries.

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
    String rev = await _wilt.getDocumentRevision(key);
    var res = await _wilt.putDocument(key, record, rev);
    if (!res.error) {
      completer.complete(res.jsonCouchResponse);
      String rev = WiltUserUtils.getDocumentRev(res);
      _revision.put(key, rev);
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
    String rev = await _wilt.getDocumentRevision(key);
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
    Completer completer = new Completer();
    var retRecords = records;
    List<json.JsonObject> newRec = new List<json.JsonObject>();
    // Condition the records
    newRec = await _conditionBulkInsert(records);
    // Do the insert/update
    List<String> docString = new List<String>();
    newRec.forEach((val) {
      docString.add(val.toString());
    });
    String bulk = WiltUserUtils.createBulkInsertString(docString);
    var res = await _wilt.bulkString(bulk);
    if (!res.error) {
      json.JsonObject response = res.jsonCouchResponse;
      response.forEach((resp) {
        if (resp != null) _revision.put(resp.id, resp.rev);
      });
      completer.complete(retRecords);
    } else {
      completer.complete(null);
    }
    ;
    return completer.future;
  }

  /// all
  /// Gets all records in the database
  Future<List<json.JsonObject>> all() async {
    if (!_initialised) return null;
    Completer completer = new Completer();
    var res = await _wilt.getAllDocs(includeDocs: true);
    if (!res.error) {
      var docRes = res.jsonCouchResponse;
      var rows = docRes.rows;
      List<json.JsonObject> retList = new List<json.JsonObject>();
      rows.forEach((row) {
        _revision.put(row.doc.id, WiltUserUtils.getDocumentRev(row.doc));
        retList.add(row.doc);
      });
      completer.complete(retList);
    } else {
      completer.complete(false);
    }
    return completer.future;
  }

  /// conditionBulkInsert
  /// Conditions bulk insert json objects.
  Future<List<json.JsonObject>> _conditionBulkInsert(
      List<json.JsonObject> records) async {
    if (!_initialised) return null;
    Completer completer = new Completer();

    // Add id and rev to the json objects
    int count = 0;
    List<json.JsonObject> newRec = new List<json.JsonObject>();
    records.forEach((record) async {
      String tmp = WiltUserUtils.addDocumentId(record, record.id);
      json.JsonObject jsonTmp = new json.JsonObject.fromJsonString(tmp);
      String rev = await _wilt.getDocumentRevision(record.id);
      if (rev != null) {
        tmp = WiltUserUtils.addDocumentRev(jsonTmp, rev);
        jsonTmp = new json.JsonObject.fromJsonString(tmp);
      }
      newRec.add(jsonTmp);
      ++count;
      if (count == records.length) {
        completer.complete(newRec);
      }
    });

    return completer.future;
  }
}
