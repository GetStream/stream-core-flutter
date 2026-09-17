import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

import '../../helpers/logger.dart';
import '../../helpers/ws_client_tester.dart';

void main() {
  group('what the logger sees', () {
    test('reaches every collaborator the client owns, each under its own tag', () {
      fakeAsync((async) {
        final handler = RecordingLogHandler();
        final tester = buildTester(recover: true);

        withStreamLogger(handler: handler, () {
          tester.client.connect().ignore();
          async.flushMicrotasks();
          // Far enough for the health monitor to ping at least once.
          async.elapse(const Duration(minutes: 1));
        });

        // Every collaborator holds its own logger, so a tag missing here means one of them is not
        // reporting what it does.
        expect(
          handler.records.map((it) => it.tag).toSet(),
          containsAll(['SC:WsClient', 'SC:WsClient:Auth', 'SC:WsClient:Health']),
        );
      });
    });

    test('tags a client and everything it owns from the tag it was given', () {
      fakeAsync((async) {
        final handler = RecordingLogHandler();
        final tester = buildTester(tag: 'SC:Ws2');

        withStreamLogger(handler: handler, () {
          tester.client.connect().ignore();
          async.flushMicrotasks();
        });

        // A second client is otherwise indistinguishable from the first in one log, and its
        // collaborators are tagged from it so one prefix still selects the whole family.
        expect(handler.tags, everyElement(startsWith('SC:Ws2')));
        expect(handler.tags, contains('SC:Ws2:Auth'));
      });
    });

    test('records the connection reaching Connected', () {
      fakeAsync((async) {
        final handler = RecordingLogHandler();
        final tester = buildTester();

        withStreamLogger(handler: handler, () {
          tester.client.connect().ignore();
          async.flushMicrotasks();
        });

        expect(tester.connectionState, isA<Connected>());
        expect(
          handler.records.where((it) => it.tag == 'SC:WsClient').map((it) => it.message),
          contains(contains('-> Connected')),
        );
      });
    });

    test('says nothing at all when no handler is installed', () {
      fakeAsync((async) {
        final tester = buildTester();

        final printed = capturePrints(() {
          tester.client.connect().ignore();
          async.flushMicrotasks();
        });

        expect(printed, isEmpty);
      });
    });
  });
}
