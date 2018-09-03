import 'package:crypto/crypto.dart';
import 'dartivity_database_test_cfg.dart' as cfg;
import 'package:test/test.dart';

int main() {
  group("Hash tests ", () {
    test("/sample/simulator/light/1", () {
      final String clientId = cfg.clientId;
      final String deviceId = '/sample/simulator/light/1';
      final String id = clientId + deviceId;
      final hasher = md5;
      final digest = hasher.convert(id.codeUnits);
      expect(digest.toString(), "6ad1b60d34a3882a331376add8999ecd");
    });
  });

  return 0;
}
