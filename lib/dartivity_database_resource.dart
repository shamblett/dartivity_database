/*
 * Package : dartivity
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 28/09/2015
 * Copyright :  S.Hamblett 2015
 */

part of dartivity_database;

class DartivityResource {
  /// Unique identifier
  String _id;

  String get id => _id;

  /// Provider
  Provider _provider = Provider.unknown;

  Provider get provider => _provider;

  /// Database revision
  String revision;

  /// The actual resource from the provider
  dynamic _resource;

  dynamic get resource => _resource;

  /// fromIotivity
  DartivityResource.fromIotivity(DartivityIotivityResource resource,
      String clientId) {
    _id = clientId + '-' + resource.identifier;
    _provider = resource.provider;
    _resource = resource;
  }

  /// toString
  String toString() {
    return "Id : ${id}, Provider : ${provider.toString()}";
  }

  /// equals ovverride
  bool operator ==(DartivityResource other) {
    bool state = false;
    this.id == other.id ? state = true : null;
    return state;
  }
}
