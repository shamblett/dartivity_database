/*
 * Package : dartivity_database
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 05/011/2015
 * Copyright :  S.Hamblett 2015
 */

part of dartivity_database;

abstract class _DartivityDatabase {
  /// Provides an interface all dartivity database drivers must supply
  /// as a minimum. This has been kept minimal by design, individual
  /// database drivers may of course add more to their interface if
  /// they wish.

  /// login
  void login(String user, String password);

  /// put
  /// Put a database record. Returns the updated record or
  /// null on error.
  Future<dynamic> put(String key, dynamic record);

  /// get
  /// Returns a database record or null.
  Future<dynamic> get(String key);

  /// delete
  /// False indicates the delete operation has failed.
  Future<bool> delete(String key);

  /// all
  /// Gets all the records in a database.
  Future<List<dynamic>?> all();

  /// putMany
  /// Puts many records as a single bulk insert/update
  /// Returns null if the operation fails.
  Future<List<dynamic>?> putMany(List<dynamic> records);
}
