/*
 * Package : dartivity_database
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 05/011/2015
 * Copyright :  S.Hamblett 2015
 */

library dartivity_database;

import 'dart:async';

import 'package:wilt/wilt.dart';
import 'package:wilt/wilt_server_client.dart';
import 'package:json_object/json_object.dart' as json;
import 'package:crypto/crypto.dart' show MD5, CryptoUtils;

part 'src/entities/dartivity_iotivity_resource.dart';

part 'src/entities/dartivity_resource.dart';

part 'src/databases/dartivity_resource_database.dart';

part 'src/databases/dartivity_cache.dart';

part 'src/drivers/dartivity_database_couchdb.dart';

part 'src/drivers/dartivity_database.dart';

/// Library globals

/// Providers
final String providerUnknown = "Unknown";
final String providerIotivity = "iotivity";
