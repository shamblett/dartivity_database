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

  /// Always the default port and HTTP.
  _DartivityDatabaseCouchDB(String hostname, String dbName,
      [String username = null, String password = null]) {
    _wilt = new WiltServerClient(hostname, "5984", "http://");
    _wilt.db = dbName;

    if ((username != null) && (password != null))
      _wilt.login(username, password);

    _revision = new DartivityCache();

    _initialised = true;
  }

  /// Wilt
  WiltServerClient _wilt;

  /// Revision cache
  DartivityCache _revision;

  /// Initialised
  bool _initialised = false;

  bool get initialised => _initialised;

  /// Etag Header
  static const String etag = 'etag';

  /// login
  void login(String user, String password) {
    _wilt.login(user, password);
  }

  /// put
  /// Put a database record. Returns the database response or
  /// null on error.
  Future<dynamic> put(String key, dynamic record, [String rev = null]) async {
    if (!_initialised) return null;
    final Completer completer = new Completer();
    final String rev = await _wilt.getDocumentRevision(key);
    final res = await _wilt.putDocument(key, record, rev);
    if (!res.error) {
      completer.complete(res.jsonCouchResponse);
      final String rev = WiltUserUtils.getDocumentRev(res);
      _revision.put(key, rev);
    } else {
      completer.complete(null);
    }
    return completer.future;
  }

  /// get
  /// Returns a json object.
  /// Null indicates the operation has failed for whatever reason.
  Future<dynamic> get(String key) async {
    if (!_initialised) return null;
    final Completer completer = new Completer();
    final res = await _wilt.getDocument(key);
    if (!res.error) {
      final dynamic doc = res.jsonCouchResponse;
      if (doc.id == key) {
        final String rev = WiltUserUtils.getDocumentRev(doc);
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
    final Completer<bool> completer = new Completer<bool>();
    final String rev = await _wilt.getDocumentRevision(key);
    final res = await _wilt.deleteDocument(key, rev);
    if (!res.error) {
      final dynamic doc = res.jsonCouchResponse;
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
  Future<List<jsonobject.JsonObjectLite>> putMany(List<dynamic> records) async {
    if (!_initialised) return null;
    final Completer<List<jsonobject.JsonObjectLite>> completer =
        new Completer<List<jsonobject.JsonObjectLite>>();
    final retRecords = records;
    // Condition the records
    var newRec = await _conditionBulkInsert(records);
    // Do the insert/update
    final String bulk = WiltUserUtils.createBulkInsertStringJo(newRec);
    final res = await _wilt.bulkString(bulk);
    if (!res.error) {
      jsonobject.JsonObjectLite resp = res.jsonCouchResponse;
      for (jsonobject.JsonObjectLite t in resp.toList()) {
        final dynamic tmp = t as dynamic;
        if (tmp != null) _revision.put(tmp.id, tmp.rev);
      }
      completer.complete(retRecords as List<jsonobject.JsonObjectLite>);
    } else {
      completer.complete(null);
    }

    return completer.future;
  }

  /// all
  /// Gets all records in the database
  Future<List<dynamic>> all() async {
    if (!_initialised) return null;
    final Completer<List<dynamic>> completer = new Completer<List<dynamic>>();
    final res = await _wilt.getAllDocs(includeDocs: true);
    if (!res.error) {
      final docRes = res.jsonCouchResponse;
      final rows = docRes.rows;
      final List<dynamic> retList = new List<dynamic>();
      rows.forEach((row) {
        _revision.put(row.doc.id, WiltUserUtils.getDocumentRev(row.doc));
        retList.add(row.doc);
      });
      completer.complete(retList);
    } else {
      completer.complete(null);
    }
    return completer.future;
  }

  /// conditionBulkInsert
  /// Conditions bulk insert json objects.
  Future<List<jsonobject.JsonObjectLite>> _conditionBulkInsert(
      List<jsonobject.JsonObjectLite> records) async {
    if (!_initialised) return null;
    final Completer<List<jsonobject.JsonObjectLite>> completer =
        new Completer<List<jsonobject.JsonObjectLite>>();

    // Add id and rev to the json objects
    int count = 0;
    final List<jsonobject.JsonObjectLite> newRec =
        new List<jsonobject.JsonObjectLite>();
    records.forEach((dynamic record) async {
      record = WiltUserUtils.addDocumentIdJo(record, record.id);
      final String rev = await _wilt.getDocumentRevision(record.id);
      if (rev != null) {
        record = WiltUserUtils.addDocumentRevJo(record, rev);
      }
      newRec.add(record);
      ++count;
      if (count == records.length) {
        completer.complete(newRec);
      }
    });

    return completer.future;
  }
}
