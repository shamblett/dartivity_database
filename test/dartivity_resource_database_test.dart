library dartivity_resource_database_test;

import 'package:dartivity_database/dartivity_database.dart';
import 'package:test/test.dart';
import 'dartivity_database_test_cfg.dart';

main() {
  /* Tests */

  group("1. Dartivity Iotivity Resource - ", () {
    test("Invalid construction - no hostname", () {
      try {
        DartivityResourceDatabase db = new DartivityResourceDatabase(null, "");
      } catch (e) {
        expect(e.runtimeType.toString(), 'WiltException');
        expect(e.toString(),
            "WiltException: Bad construction - some or all required parameters are null");
      }
    });
  });

  group("2. Dartivity Resource - ", () {
    test("Invalid construction - no hostname", () {
      try {
        DartivityResourceDatabase db = new DartivityResourceDatabase(null, "");
      } catch (e) {
        expect(e.runtimeType.toString(), 'WiltException');
        expect(e.toString(),
            "WiltException: Bad construction - some or all required parameters are null");
      }
    });
  });

  /* Group 3 - DartivityResourceDatabase  tests */
  group("1. Dartivity Resource Database - ", () {
    test("Invalid construction - no hostname", () {
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
