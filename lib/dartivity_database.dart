/*
 * Package : dartivity_database
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 05/011/2015
 * Copyright :  S.Hamblett 2015
 */

library dartivity_database;

import 'dart:async';

import 'package:wilt/wilt_server_client.dart';
import 'package:json_object/json_object.dart' as json;

part 'dartivity_resource_database.dart';

part 'dartivity_database_iotivity_resource.dart';

part 'dartivity_database_resource.dart';
part 'src/dartivity_database.dart';

/// Library globals

/// Providers
final String providerUnknown = "Unknown";
final String providerIotivity = "iotivity";
