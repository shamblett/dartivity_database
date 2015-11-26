import 'dart:io' show exit, File;
import 'package:crypto/crypto.dart' show MD5, CryptoUtils;
import 'dartivity_database_test_cfg.dart' as cfg;

int main(List<String> args) {
  String clientId = cfg.clientId;
  String deviceId = '/sample/simulator/light/1';
  String id = clientId + deviceId;
  var hasher = new MD5();
  hasher.add(id.codeUnits);

  var hex = CryptoUtils.bytesToHex(hasher.close());
  print(hex);

  return 0;
}
