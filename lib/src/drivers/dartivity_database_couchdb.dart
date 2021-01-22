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
  _DartivityDatabaseCouchDB(String? hostname, String dbName,
      [String? username, String? password]) {
    _wilt = Wilt(hostname);
    _wilt.db = dbName;

    if ((username != null) && (password != null)) {
      _wilt.login(username, password);
    }
    _revision = DartivityCache();

    _initialised = true;
  }

  /// Wilt
  late Wilt _wilt;

  /// Revision cache
  late DartivityCache _revision;

  /// Initialised
  bool _initialised = false;

  bool get initialised => _initialised;

  /// login
  @override
  void login(String user, String password) {
    _wilt.login(user, password);
  }

  /// put
  /// Put a database record. Returns the database response or
  /// null on error.
  @override
  Future<dynamic> put(String key, dynamic record, [String? rev]) async {
    if (!_initialised) return null;
    final completer = Completer();
    final rev = await (_wilt.getDocumentRevision(key) as FutureOr<String>);
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
  @override
  Future<dynamic> get(String key) async {
    if (!_initialised) return null;
    final completer = Completer();
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
  @override
  Future<bool> delete(String key) async {
    if (!_initialised) return false;
    final completer = Completer<bool>();
    final rev = await (_wilt.getDocumentRevision(key) as FutureOr<String>);
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
  @override
  Future<List<jsonobject.JsonObjectLite>?> putMany(
      List<dynamic> records) async {
    if (!_initialised) return null;
    final completer = Completer<List<jsonobject.JsonObjectLite>>();
    final retRecords = records;
    // Condition the records
    final newRec = await (_conditionBulkInsert(
            records as List<jsonobject.JsonObjectLite<dynamic>>)
        as FutureOr<List<jsonobject.JsonObjectLite<dynamic>>>);
    // Do the insert/update
    final String bulk = WiltUserUtils.createBulkInsertStringJo(newRec);
    final res = await _wilt.bulkString(bulk);
    if (!res.error) {
      final jsonobject.JsonObjectLite resp = res.jsonCouchResponse;
      for (var t
          in resp.toList() as Iterable<jsonobject.JsonObjectLite<dynamic>?>) {
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
  @override
  Future<List<dynamic>?> all() async {
    if (!_initialised) return null;
    final completer = Completer<List<dynamic>>();
    final res = await _wilt.getAllDocs(includeDocs: true);
    if (!res.error) {
      final docRes = res.jsonCouchResponse;
      final rows = docRes.rows;
      final retList = <dynamic>[];
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
  Future<List<jsonobject.JsonObjectLite>?> _conditionBulkInsert(
      List<jsonobject.JsonObjectLite> records) async {
    if (!_initialised) return null;
    final completer = Completer<List<jsonobject.JsonObjectLite>>();

    // Add id and rev to the json objects
    var count = 0;
    final newRec = <jsonobject.JsonObjectLite>[];
    records.forEach((dynamic record) async {
      record = WiltUserUtils.addDocumentIdJo(record, record.id);
      final rev =
          await (_wilt.getDocumentRevision(record.id) as FutureOr<String?>);
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
