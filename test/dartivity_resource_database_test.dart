library dartivity_resource_database_test;

import 'package:json_object/json_object.dart' as json;
import 'package:dartivity_database/dartivity_database.dart';
import 'package:test/test.dart';
import 'dartivity_database_test_cfg.dart';

main() {
  DartivityIotivityResource iotivityResource1;
  DartivityIotivityResource iotivityResource2;
  DartivityResource dartivityResource;

  /* Group 1 - DartivityIotivityResource tests */
  group("1. Dartivity Iotivity Resource - ", () {
    test("Construction", () {
      iotivityResource1 =
      new DartivityIotivityResource('/sample/simulator/light/1',
          '/sample/simulator/light/1', 'localhost', ['res1', 'res2'],
          ['int1', 'int2'], true);
      expect(iotivityResource1.id, '/sample/simulator/light/1');
      expect(iotivityResource1.uri, '/sample/simulator/light/1');
      expect(iotivityResource1.host, 'localhost');
      expect(iotivityResource1.observable, true);
      expect(iotivityResource1.resourceTypes, ['res1', 'res2']);
      expect(iotivityResource1.interfaceTypes, ['int1', 'int2']);
    });

    test("Equality", () {
      iotivityResource2 =
      new DartivityIotivityResource('/sample/simulator/light/2',
          '/sample/simulator/light/1', 'localhost', ['res1', 'res2'],
          ['int1', 'int2'], true);
      expect(iotivityResource1 == iotivityResource1, true);
      expect(iotivityResource1 == iotivityResource2, false);
    });

    test("To String", () {
      expect(iotivityResource1.toString(), '/sample/simulator/light/1');
    });

    test("To Map", () {
      Map<String, dynamic> resmap = iotivityResource1.toMap();
      expect(resmap['id'], '/sample/simulator/light/1');
      expect(resmap['uri'], '/sample/simulator/light/1');
      expect(resmap['host'], 'localhost');
      expect(resmap['observable'], true);
      expect(resmap['provider'], 'iotivity');
      expect(resmap['resourceTypes'], ['res1', 'res2']);
      expect(resmap['interfaceTypes'], ['int1', 'int2']);
    });

    test("To JsonObject", () {
      json.JsonObject jsonobj = iotivityResource1.toJsonObject();
      expect(jsonobj.id, '/sample/simulator/light/1');
      expect(jsonobj.uri, '/sample/simulator/light/1');
      expect(jsonobj.host, 'localhost');
      expect(jsonobj.observable, true);
      expect(jsonobj.resourceTypes, ['res1', 'res2']);
      expect(jsonobj.interfaceTypes, ['int1', 'int2']);
      expect(jsonobj.provider, 'iotivity');
    });
  });

  /* Group 2 - DartivityResource tests */
  group("2. Dartivity Resource from Iotivity- ", () {
    test("Construction", () {


    });
  });

  /* Group 3 - DartivityResourceDatabase tests */
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
