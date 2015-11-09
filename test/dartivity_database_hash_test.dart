import 'dart:io' show exit, File;
import 'package:crypto/crypto.dart' show MD5, CryptoUtils;

int main(List<String> args) {
  String clientId = 'dell-base-d5dcb860-3ad8-5329-ab54-5c3c9c5f2242%625';
  String deviceId = '/sample/simulator/light/1';
  String id = clientId + deviceId;
  var hasher = new MD5();
  hasher.add(id.codeUnits);

  var hex = CryptoUtils.bytesToHex(hasher.close());
  print(hex);

  return 0;
}
