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
  String _provider = providerUnknown;

  String get provider => _provider;

  /// Dartivity client id
  String _clientId;

  String get clientId => _clientId;

  /// The actual resource from the provider
  dynamic _resource;

  dynamic get resource => _resource;

  /// Lat updated
  DateTime updated;

  /// fromIotivity
  /// Creates a resource from an Iotivity resource
  DartivityResource.fromIotivity(DartivityIotivityResource resource,
      String clientId) {
    // Get the id as a hash from the client id and the device id
    String tmp = clientId + resource.id;
    var hasher = new MD5();
    hasher.add(tmp.codeUnits);
    _id = CryptoUtils.bytesToHex(hasher.close());

    _clientId = clientId;
    _provider = resource.provider;
    _resource = resource;
    updated = new DateTime.now();
  }

  /// fromDBRecord
  /// Creates a resource from a database record
  DartivityResource.fromDbRecord(json.JsonObject record) {
    _id = record.id;
    _provider = record.provider;
    _clientId = record.clientId;
    _resource = new DartivityIotivityResource.fromJsonObject(record.resource);
    updated = new DateTime.fromMillisecondsSinceEpoch(record.updated);
  }

  /// toString
  String toString() {
    return "Id : ${id}, Provider : ${provider}";
  }

  /// equals ovverride
  bool operator ==(DartivityResource other) {
    bool state = false;
    return this.id == other.id ? state = true : null;
  }

  /// toJsonObject
  json.JsonObject toJsonObject() {
    json.JsonObject ret = new json.JsonObject();

    ret.id = id;
    ret.provider = provider;
    ret.clientId = clientId;
    ret.resource = resource.toJsonObject();
    ret.updated = updated.millisecondsSinceEpoch;
    return ret;
  }
}
