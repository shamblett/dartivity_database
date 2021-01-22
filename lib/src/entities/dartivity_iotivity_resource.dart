/*
 * Package : dartivity
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 28/09/2015
 * Copyright :  S.Hamblett 2015
 */

part of dartivity_database;

class DartivityIotivityResource {
  /// The Iotivity resource class.

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

  DartivityIotivityResource.fromJsonObject(dynamic record) {
    _id = record.id;
    _uri = record.uri;
    _host = record.host;
    _observable = record.observable;
    _resourceTypes = record.resourceTypes;
    _interfaceTypes = record.interfaceTypes;
  }

  //
  /// Client specific resource identifier, must
  /// be provided.
  String? _id;

  String? get id => _id;

  /// Host
  String? _host;

  String? get host => _host;

  /// Uri
  String? _uri;

  String? get uri => _uri;

  /// Provider
  final String provider = providerIotivity;

  /// Resource types
  List<dynamic>? _resourceTypes;

  List<dynamic>? get resourceTypes => _resourceTypes;

  /// Interface types
  List<dynamic>? _interfaceTypes;

  List<dynamic>? get interfaceTypes => _interfaceTypes;

  /// Observable
  bool? _observable = false;

  bool? get observable => _observable;

  /// toString
  String toString() {
    return _id!;
  }

  /// Equality
  bool operator ==(dynamic other) {
    if (other is DartivityIotivityResource) {
      return (other.id == _id);
    }
    return false;
  }

  int get hashCode => int.tryParse(_id!)!;

  static const String mapIdentifier = "id";
  static const String mapUri = "uri";
  static const String mapHost = "host";
  static const String mapProvider = "provider";
  static const String mapObservable = "observable";
  static const String mapResourceTypes = "resourceTypes";
  static const String mapInterfaceTypes = "interfaceTypes";

  /// toMap
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> returnMap = new Map<String, dynamic>();

    returnMap[mapIdentifier] = this._id;
    returnMap[mapUri] = this._uri;
    returnMap[mapHost] = this._host;
    returnMap[mapProvider] = this.provider;
    returnMap[mapObservable] = this._observable;
    returnMap[mapResourceTypes] = this._resourceTypes;
    returnMap[mapInterfaceTypes] = this._interfaceTypes;

    return returnMap;
  }

  /// toJson
  String toJson() {
    return json.encode(toMap());
  }

  /// toJsonObject
  dynamic toJsonObject() {
    return new jsonobject.JsonObjectLite.fromJsonString(toJson());
  }
}
