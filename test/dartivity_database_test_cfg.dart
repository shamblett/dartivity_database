library dartivity_resource_database_test;

import 'package:dartivity_database/dartivity_database.dart';
import 'package:test/test.dart';
import 'dartivity_database_test_cfg.dart';

main() {
  /* Tests */

  /* Group 1 - DartivityResourceDatabase constructor tests */
  group("1. Constructor Tests - ", () {
    test("No hostname", () {
      try {
        DartivityResourceDatabase db = new DartivityResourceDatabase(null, "");
      } catch (e) {
        expect(e.runtimeType.toString(), 'WiltException');
        expect(e.toString(),
            "WiltException: Bad construction - some or all required parameters are null");
      }
    });
  });
}
