/*
 * Package : dartivity_database
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 05/011/2015
 * Copyright :  S.Hamblett 2015
 */

part of dartivity_database;

class DartivityCache {
  /// The cache
  Map<String, dynamic> _cache;

  DartivityCache() {
    _cache = new Map<String, dynamic>();
  }

  /// get
  dynamic get(String key) {
    if (_cache.containsKey(key)) {
      return _cache[key];
    } else {
      return null;
    }
  }

  /// put
  void put(String key, dynamic resource) {
    _cache[key] = resource;
  }

  /// delete
  void delete(String key) {
    if (_cache.containsKey(key)) {
      _cache.remove(key);
    }
  }

  /// clear
  void clear() {
    _cache.clear();
  }

  /// all
  Map<String, dynamic> all() {
    return _cache;
  }
}