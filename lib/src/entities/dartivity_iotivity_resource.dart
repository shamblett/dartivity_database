/*
 * Package : dartivity
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 28/09/2015
 * Copyright :  S.Hamblett 2015
 */

part of dartivity_database;

class DartivityIotivityResource {

  /// The Iotivity resource class.

  /// Client specific resource identifier, must
  /// be provided.
  String _id;

  String get id => _id;

  /// Host
  String _host;

  String get host => _host;

  /// Uri
  String _uri;

  String get uri => _uri;

  /// Provider
  final String provider = providerIotivity;

  /// Resource types
  List<String> _resourceTypes;

  List<String> get resourceTypes => _resourceTypes;

  /// Interface types
  List<String> _interfaceTypes;

  List<String> get interfaceTypes => _interfaceTypes;

  /// Observable
  bool _observable = false;

  bool get observable => _observable;

  /// Construction
  DartivityIotivityResource(String id, String uri, String host,
      List<String> resTypes, List<String> intTypes, bool observable) {
    _id = id;
    _uri = uri;
    _host = host;
    _observable = observable;
    _resourceTypes = resTypes;
    _interfaceTypes = intTypes;
  }

  DartivityIotivityResource.fromJsonObject(json.JsonObject record) {
    _id = record.id;
    _uri = record.uri;
    _host = record.host;
    _observable = record.observable;
    _resourceTypes = record.resourceTypes;
    _interfaceTypes = record.interfaceTypes;
  }

  /// toString
  String toString() {
    return _id;
  }

  /// Equality
  bool operator ==(DartivityIotivityResource other) {
    return (other.id == _id);
  }

  static const String MAP_IDENTIFIER = "id";
  static const String MAP_URI = "uri";
  static const String MAP_HOST = "host";
  static const String MAP_PROVIDER = "provider";
  static const String MAP_OBSERVABLE = "observable";
  static const String MAP_RESOURCE_TYPES = "resourceTypes";
  static const String MAP_INTERFACE_TYPES = "interfaceTypes";

  /// toMap
  Map<String, dynamic> toMap() {
    Map<String, dynamic> returnMap = new Map<String, dynamic>();

    returnMap[MAP_IDENTIFIER] = this._id;
    returnMap[MAP_URI] = this._uri;
    returnMap[MAP_HOST] = this._host;
    returnMap[MAP_PROVIDER] = this.provider;
    returnMap[MAP_OBSERVABLE] = this._observable;
    returnMap[MAP_RESOURCE_TYPES] = this._resourceTypes;
    returnMap[MAP_INTERFACE_TYPES] = this._interfaceTypes;

    return returnMap;
  }

  /// toJson
  String toJson() {
    json.JsonObject temp = new json.JsonObject.fromMap(toMap());
    return temp.toString();
  }

  /// toJsonObject
  json.JsonObject toJsonObject() {
    json.JsonObject temp = new json.JsonObject.fromMap(toMap());
    return temp;
  }
}
