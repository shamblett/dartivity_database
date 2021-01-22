library dartivity_resource_database_test;

import 'package:dartivity_database/dartivity_database.dart';
import 'package:test/test.dart';
import 'dartivity_database_test_cfg.dart' as cfg;

void main() {
  DartivityIotivityResource? iotivityResource1;
  DartivityIotivityResource? iotivityResource2;
  DartivityIotivityResource iotivityResource3;
  DartivityResource? dartivityResource1;
  DartivityResource? dartivityResource2;
  DartivityResource? dartivityResource3;
  DateTime? dartivityResource1Updated;

  /* Group 1 - DartivityIotivityResource tests */
  group('1. Dartivity Iotivity Resource - ', () {
    test('Construction', () {
      iotivityResource1 = DartivityIotivityResource(
          '/sample/simulator/light/1',
          '/sample/simulator/light/1',
          'localhost',
          ['res1', 'res2'],
          ['int1', 'int2'],
          true);
      expect(iotivityResource1!.id, '/sample/simulator/light/1');
      expect(iotivityResource1!.uri, '/sample/simulator/light/1');
      expect(iotivityResource1!.host, 'localhost');
      expect(iotivityResource1!.observable, true);
      expect(iotivityResource1!.resourceTypes, ['res1', 'res2']);
      expect(iotivityResource1!.interfaceTypes, ['int1', 'int2']);
    });

    test('Equality', () {
      iotivityResource2 = DartivityIotivityResource(
          '/sample/simulator/light/2',
          '/sample/simulator/light/1',
          'localhost',
          ['res1', 'res2'],
          ['int1', 'int2'],
          true);
      expect(iotivityResource1 == iotivityResource1, true);
      expect(iotivityResource1 == iotivityResource2, false);
    });

    test('To String', () {
      expect(iotivityResource1.toString(), '/sample/simulator/light/1');
    });

    test('To Map', () {
      final resmap = iotivityResource1!.toMap();
      expect(resmap['id'], '/sample/simulator/light/1');
      expect(resmap['uri'], '/sample/simulator/light/1');
      expect(resmap['host'], 'localhost');
      expect(resmap['observable'], true);
      expect(resmap['provider'], 'iotivity');
      expect(resmap['resourceTypes'], ['res1', 'res2']);
      expect(resmap['interfaceTypes'], ['int1', 'int2']);
    });

    test('To JsonObject', () {
      final dynamic jsonobj = iotivityResource1!.toJsonObject();
      expect(jsonobj.id, '/sample/simulator/light/1');
      expect(jsonobj.uri, '/sample/simulator/light/1');
      expect(jsonobj.host, 'localhost');
      expect(jsonobj.observable, true);
      expect(jsonobj.resourceTypes, ['res1', 'res2']);
      expect(jsonobj.interfaceTypes, ['int1', 'int2']);
      expect(jsonobj.provider, 'iotivity');
    });

    test('To Json', () {
      final jsonstr = iotivityResource1!.toJson();
      expect(jsonstr,
          "{'id':'/sample/simulator/light/1','uri':'/sample/simulator/light/1','host':'localhost','provider':'iotivity','observable':true,'resourceTypes':['res1','res2'],'interfaceTypes':['int1','int2']}");
    });
  });

  /* Group 2 - DartivityResource tests */
  group('2. Dartivity Resource - ', () {
    test('Construction - from Iotivity', () {
      dartivityResource1 =
          DartivityResource.fromIotivity(iotivityResource1!, cfg.clientId);
      expect(dartivityResource1!.id, '6ad1b60d34a3882a331376add8999ecd');
      expect(dartivityResource1!.clientId, cfg.clientId);
      expect(dartivityResource1!.provider, 'iotivity');
      expect(dartivityResource1!.resource, iotivityResource1);
      expect(dartivityResource1!.updated, isNotNull);
      dartivityResource1Updated = dartivityResource1!.updated;
    });

    test('To String - ', () {
      expect(dartivityResource1.toString(),
          'Id : 6ad1b60d34a3882a331376add8999ecd, Provider : iotivity');
    });

    test('Equality - ', () {
      expect(dartivityResource1 == dartivityResource2, false);
    });

    test('To JsonObject', () {
      final dynamic jsonobj = dartivityResource1!.toJsonObject();
      expect(jsonobj.id, '6ad1b60d34a3882a331376add8999ecd');
      expect(jsonobj.provider, 'iotivity');
      expect(jsonobj.clientId, cfg.clientId);
      expect(
          jsonobj.updated == dartivityResource1Updated!.millisecondsSinceEpoch,
          true);
      final tmp = DartivityIotivityResource.fromJsonObject(jsonobj.resource);
      expect(tmp == iotivityResource1, true);
    });
  });

  /* Group 3 - Dartivity Cache tests */
  group('3. Dartivity Cache - ', () {
    final cache = DartivityCache();

    test('Put/Get', () {
      cache.put(dartivityResource1!.id, dartivityResource1);
      final DartivityResource res = cache.get(dartivityResource1!.id);
      expect(res.id, dartivityResource1!.id);
      expect(cache.count(), 1);
    });

    test('Delete', () {
      cache.delete(dartivityResource1!.id);
      expect(cache.count(), 0);
    });

    test('All', () {
      dartivityResource2 =
          DartivityResource.fromIotivity(iotivityResource2!, cfg.clientId);
      cache.put(dartivityResource1!.id, dartivityResource1);
      cache.put(dartivityResource2!.id, dartivityResource2);
      expect(cache.count(), 2);
      final res = cache.all()!;
      expect(res.containsKey(dartivityResource1!.id), true);
      expect(res.containsKey(dartivityResource2!.id), true);
    });

    test('Keys', () {
      final res = cache.keys();
      expect(res[0] == dartivityResource1!.id, true);
      expect(res[1] == dartivityResource2!.id, true);
    });

    test('Clear', () {
      cache.clear();
      expect(cache.count(), 0);
    });

    test('Bulk', () {
      final resList = [dartivityResource2, dartivityResource1];
      cache.bulk(resList);
      expect(cache.count(), 2);
      final res = cache.all()!;
      expect(res.containsKey(dartivityResource1!.id), true);
      expect(res.containsKey(dartivityResource2!.id), true);
      cache.clear();
      expect(cache.count(), 0);
    });
  });

  /* Group 4 - DartivityResourceDatabase tests */
  group('4. Dartivity Resource Database - ', () {
    test('Invalid construction - no hostname', () {
      try {
        final db = DartivityResourceDatabase(null, '');
        expect(db, null);
      } catch (e) {
        expect(e.runtimeType.toString(), 'WiltException');
        expect(e.toString(),
            'WiltException: Bad construction - some or all required parameters are null');
      }
    });

    final db = DartivityResourceDatabase(cfg.hostname, cfg.user, cfg.password);

    test('Initialised ', () {
      expect(db.initialised, true);
    });

    test('Put Resource - initial', () async {
      final res = await db.put(dartivityResource1!);
      expect(res, isNotNull);
      expect(res.updated != dartivityResource1Updated, true);
      dartivityResource1Updated = res.updated;
    });

    test('Put Resource - subsequent', () async {
      final res = await db.put(dartivityResource1!);
      expect(res, isNotNull);
      expect(
          res.updated!.millisecondsSinceEpoch >
              dartivityResource1Updated!.millisecondsSinceEpoch,
          true);
      dartivityResource1Updated = res.updated;
      dartivityResource1 = res;
    });

    test('Get Resource ', () async {
      final res = await db.get(dartivityResource1!.id);
      expect(res, isNotNull);
      expect(res.id == dartivityResource1!.id, true);
      expect(
          res.updated!.millisecondsSinceEpoch ==
              dartivityResource1Updated!.millisecondsSinceEpoch,
          true);
    });

    test('Delete Resource ', () async {
      final res = await db.delete(dartivityResource1!);
      expect(res, true);
    });

    test('Get all Resources ', () async {
      final res1 = await db.put(dartivityResource1!);
      expect(res1, isNotNull);
      expect(
          res1.updated!.millisecondsSinceEpoch >
              dartivityResource1Updated!.millisecondsSinceEpoch,
          true);
      dartivityResource1Updated = res1.updated;
      dartivityResource1 = res1;
      iotivityResource2 = DartivityIotivityResource(
          '/sample/simulator/switch/2',
          '/sample/simulator/switch/2',
          'localhost',
          ['res1', 'res2'],
          ['int1', 'int2'],
          true);
      dartivityResource2 =
          DartivityResource.fromIotivity(iotivityResource2!, cfg.clientId);
      final res2 = await db.put(dartivityResource2!);
      expect(res2, isNotNull);
      final resAll = await db.all();
      expect(resAll, isNotNull);
      expect(resAll.length, 2);
      expect(resAll.containsKey(res1.id), true);
      expect(resAll.containsKey(res2.id), true);
      expect(resAll[res1.id] != resAll[res2.id], true);
      var res = await db.delete(dartivityResource1!);
      expect(res, true);
      res = await db.delete(dartivityResource2!);
      expect(res, true);
    });

    test('Bulk Insert - Create', () async {
      iotivityResource3 = DartivityIotivityResource(
          '/sample/simulator/light/3',
          '/sample/simulator/light/3',
          'localhost',
          ['res1', 'res2'],
          ['int1', 'int2'],
          true);
      dartivityResource3 =
          DartivityResource.fromIotivity(iotivityResource3, cfg.clientId);
      final resList = [
        dartivityResource1,
        dartivityResource2,
        dartivityResource3
      ];

      final List res = await db.putMany(resList);
      expect(res, isNotNull);
    });

    test('Bulk Insert - Update', () async {
      final resList = [
        dartivityResource1,
        dartivityResource2,
        dartivityResource3
      ];

      final List res = await db.putMany(resList);
      expect(res, isNotNull);
      expect(res.length, 3);
      // Check we have correct revs returned
      final res1 = await db.put(dartivityResource1!);
      expect(res1, isNotNull);

      // Delete the resources
      var res3 = await db.delete(dartivityResource1!);
      expect(res3, true);
      res3 = await db.delete(dartivityResource2!);
      expect(res3, true);
      res3 = await db.delete(dartivityResource3!);
      expect(res3, true);
    });
  });
}
