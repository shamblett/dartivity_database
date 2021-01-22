/*
 * Package : dartivity_database
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 05/011/2015
 * Copyright :  S.Hamblett 2015
 */

part of dartivity_database;

class DartivityCache {
  /// This class implements a general purpose key/value in memory cache.
  /// It is used by the database classes and can be used if needed by the
  /// Dartivity clients.

  /// The cache
  Map<String?, dynamic>? _cache;

  DartivityCache() {
    _cache = new Map<String?, dynamic>();
  }

  /// get
  dynamic get(String? key) {
    if (_cache!.containsKey(key)) {
      return _cache![key];
    } else {
      return null;
    }
  }

  /// put
  void put(String? key, dynamic resource) {
    _cache![key] = resource;
  }

  /// delete
  void delete(String? key) {
    if (_cache!.containsKey(key)) {
      _cache!.remove(key);
    }
  }

  /// clear
  void clear() {
    _cache!.clear();
  }

  /// all
  Map<String?, dynamic>? all() {
    return _cache;
  }

  /// count
  int count() {
    return _cache!.length;
  }

  /// keys
  List<String?> keys() {
    return _cache!.keys.toList();
  }

  /// bulk
  /// The resources must have an id getter.
  void bulk(List<dynamic> resources) {
    resources.forEach((resource) {
      put(resource.id, resource);
    });
  }
}
