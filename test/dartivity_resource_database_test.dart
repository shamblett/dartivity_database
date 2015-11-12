library dartivity_resource_database_test;

import 'package:json_object/json_object.dart' as json;
import 'package:dartivity_database/dartivity_database.dart';
import 'package:test/test.dart';
import 'dartivity_database_test_cfg.dart' as cfg;

main() {
  DartivityIotivityResource iotivityResource1;
  DartivityIotivityResource iotivityResource2;
  DartivityResource dartivityResource1;
  DartivityResource dartivityResource2;
  String savedRev;
  DateTime dartivityResource1Updated;

  /* Group 1 - DartivityIotivityResource tests */
  group("1. Dartivity Iotivity Resource - ", () {
    test("Construction", () {
      iotivityResource1 = new DartivityIotivityResource(
          '/sample/simulator/light/1',
          '/sample/simulator/light/1',
          'localhost',
          ['res1', 'res2'],
          ['int1', 'int2'],
          true);
      expect(iotivityResource1.id, '/sample/simulator/light/1');
      expect(iotivityResource1.uri, '/sample/simulator/light/1');
      expect(iotivityResource1.host, 'localhost');
      expect(iotivityResource1.observable, true);
      expect(iotivityResource1.resourceTypes, ['res1', 'res2']);
      expect(iotivityResource1.interfaceTypes, ['int1', 'int2']);
    });

    test("Equality", () {
      iotivityResource2 = new DartivityIotivityResource(
          '/sample/simulator/light/2',
          '/sample/simulator/light/1',
          'localhost',
          ['res1', 'res2'],
          ['int1', 'int2'],
          true);
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

    test("To Json", () {
      String jsonstr = iotivityResource1.toJson();
      expect(jsonstr,
          '{"id":"/sample/simulator/light/1","uri":"/sample/simulator/light/1","host":"localhost","provider":"iotivity","observable":true,"resourceTypes":["res1","res2"],"interfaceTypes":["int1","int2"]}');
    });
  });

  /* Group 2 - DartivityResource tests */
  group("2. Dartivity Resource - ", () {
    test("Construction - from Iotivity", () {

      dartivityResource1 =
      new DartivityResource.fromIotivity(iotivityResource1, cfg.clientId);
      expect(dartivityResource1.id, '6ad1b60d34a3882a331376add8999ecd');
      expect(dartivityResource1.clientId, cfg.clientId);
      expect(dartivityResource1.provider, 'iotivity');
      expect(dartivityResource1.revision, null);
      expect(dartivityResource1.resource, iotivityResource1);
      expect(dartivityResource1.updated, isNotNull);
      dartivityResource1Updated = dartivityResource1.updated;

    });

    test("To String - ", () {
      expect(dartivityResource1.toString(),
          'Id : 6ad1b60d34a3882a331376add8999ecd, Provider : iotivity');
    });

    test("Equality - ", () {
      expect(dartivityResource1 == dartivityResource2, false);
    });

    test("To JsonObject", () {
      json.JsonObject jsonobj = dartivityResource1.toJsonObject();
      expect(jsonobj.id, '6ad1b60d34a3882a331376add8999ecd');
      expect(jsonobj.provider, 'iotivity');
      expect(jsonobj.clientId, cfg.clientId);
      expect(jsonobj.revision, null);
      expect(
          jsonobj.updated == dartivityResource1Updated.millisecondsSinceEpoch,
          true);
      DartivityIotivityResource tmp = new DartivityIotivityResource
          .fromJsonObject(jsonobj.resource);
      expect(tmp == iotivityResource1, true);
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

    DartivityResourceDatabase db = new DartivityResourceDatabase(
        cfg.hostname, cfg.user, cfg.password);

    test("Initialised ", () {
      expect(db.initialised, true);
    });

    test("Put Resource - initial", () async {
      DartivityResource res = await db.put(dartivityResource1);
      expect(res, isNotNull);
      expect(res.revision, isNotNull);
      expect(res.updated != dartivityResource1Updated, true);
      dartivityResource1 = res;
    });

    test("Put Resource - subsequent", () async {
      DartivityResource res = await db.put(dartivityResource1);
      expect(res, isNotNull);
      expect(res.revision, isNotNull);
      expect(res.updated != dartivityResource1Updated, true);
      savedRev = res.revision;
      dartivityResource1Updated = res.updated;
    });

    test("Get Resource ", () async {
      DartivityResource res = await db.get(dartivityResource1.id);
      expect(res, isNotNull);
      expect(res.revision == savedRev, true);
      expect(res.id == dartivityResource1.id, true);
      expect(res.updated == dartivityResource1Updated, true);
    });

    test(" Delete Resource ", () async {
      bool res = await db.delete(dartivityResource1);
      expect(res, true);
    });

  });
}
