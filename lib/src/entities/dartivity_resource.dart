/*
 * Package : dartivity
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 28/09/2015
 * Copyright :  S.Hamblett 2015
 */

part of dartivity_database;

class DartivityResource {
  /// The Dartivity resource class. This class provides a generic interface
  /// to specific client resource data stuctures for use in the Dartivity suite.
  /// This class has its own database implementation. Each created resource is
  /// given a unique identifier derived from the client id and the embedded
  /// resource identifier, this makes individual Dartivity resources unique
  /// across the whole of the Dartivity suite.

  /// fromIotivity
  /// Creates a resource from an Iotivity resource
  DartivityResource.fromIotivity(
      DartivityIotivityResource resource, String clientId) {
    // Get the id as a hash from the client id and the device id
    final String tmp = clientId + resource.id;
    final hasher = md5;
    final digest = hasher.convert(tmp.codeUnits);
    _id = digest.toString();

    _clientId = clientId;
    _provider = resource.provider;
    _resource = resource;
    updated = new DateTime.now();
  }

  /// fromDBRecord
  /// Creates a resource from a database record
  DartivityResource.fromDbRecord(dynamic record) {
    _id = record.id;
    _provider = record.provider;
    _clientId = record.clientId;
    _resource = new DartivityIotivityResource.fromJsonObject(record.resource);
    updated = new DateTime.fromMillisecondsSinceEpoch(record.updated);
  }

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

  /// toString
  String toString() {
    return "Id : ${id}, Provider : ${provider}";
  }

  /// equals ovverride
  bool operator ==(dynamic other) {
    bool state = false;
    if (other is DartivityResource) {
      return this.id == other.id ? state = true : state;
    }
    return false;
  }

  int get hashCode => int.tryParse(_id);

  /// toJsonObject
  dynamic toJsonObject() {
    final dynamic ret = new jsonobject.JsonObjectLite();

    ret.id = id;
    ret.provider = provider;
    ret.clientId = clientId;
    ret.resource = resource.toJsonObject();
    ret.updated = updated.millisecondsSinceEpoch;
    return ret;
  }
}
