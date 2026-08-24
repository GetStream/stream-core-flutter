import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

import '../helpers/logger.dart';

const _logger = StreamLogger('SF:Component');

void main() {
  group('StreamLogger.configure', () {
    tearDown(StreamLogger.reset);

    test('leaves the logger alone when there is no config', () {
      final installed = RecordingLogHandler();
      StreamLogger.handler = installed;
      StreamLogger.priority = StreamLogPriority.verbose;

      StreamLogger.configure(null);
      _logger.d(() => 'another SDK, still heard');

      // A client the app gave no logging must not decide it for the SDK beside it.
      expect(installed.messages, ['another SDK, still heard']);
    });

    test('writes to the console, given a priority and nowhere to put it', () {
      final printed = capturePrints(() {
        StreamLogger.configure(const StreamLogConfig(priority: StreamLogPriority.debug));
        _logger.d(() => 'to the console');
      });

      expect(printed.single, contains('to the console'));
    });

    test('hears warnings, given a handler and no priority', () {
      final mine = RecordingLogHandler();

      StreamLogger.configure(StreamLogConfig(handler: mine));
      _logger
        ..d(() => 'commentary')
        ..w(() => 'worth acting on');

      expect(mine.messages, ['worth acting on']);
    });

    test('silences everything when asked for none', () {
      final mine = RecordingLogHandler();

      StreamLogger.configure(
        StreamLogConfig(priority: StreamLogPriority.none, handler: mine),
      );
      _logger.e(() => 'not even an error');

      expect(mine.records, isEmpty);
    });

    test('holds one subsystem apart from the rest, given a filter', () {
      final mine = RecordingLogHandler();

      StreamLogger.configure(
        StreamLogConfig(
          handler: mine,
          filter: const StreamLogFilter.prefix({'SF:Ws': StreamLogPriority.verbose}),
        ),
      );
      const StreamLogger('SF:Ws').v(() => 'the subsystem I turned up');
      _logger.d(() => 'the commentary I did not');

      // The filter has to survive the config that carries it: `priority` sets the same field, so a
      // config applying both would flatten the rule it was given.
      expect(mine.messages, ['the subsystem I turned up']);
    });
    test('replaces a filter installed before it, even naming only a priority', () {
      final mine = RecordingLogHandler();
      StreamLogger.filter = const StreamLogFilter.prefix({'SF:Ws': StreamLogPriority.verbose});

      StreamLogger.configure(StreamLogConfig(priority: StreamLogPriority.debug, handler: mine));
      const StreamLogger('SF:Ws').v(() => 'below what the config asked for');

      // A config is the whole story: its priority and filter are one field underneath, so there is
      // no reading of it that keeps an earlier rule and the new threshold both.
      expect(mine.records, isEmpty);
    });
  });

  group('two Stream SDKs in one app', () {
    const feeds = StreamLogger('SF:Ws');
    const video = StreamLogger('SV:Call');

    tearDown(StreamLogger.reset);

    test('keep to their own records, each given a scope', () {
      final theirs = RecordingLogHandler();
      final mine = RecordingLogHandler();

      StreamLogger.configure(
        StreamLogConfig(priority: StreamLogPriority.debug, handler: mine),
        scope: 'SF:',
      );
      StreamLogger.configure(StreamLogConfig(handler: theirs), scope: 'SV:');
      feeds.d(() => 'feeds debug');
      video
        ..d(() => 'video debug')
        ..w(() => 'video warning');

      // Neither client decides for the other: feeds asked for debug and video did not, so video's
      // commentary stays out even though both were configured.
      expect(mine.messages, ['feeds debug']);
      expect(theirs.messages, ['video warning']);
    });

    test('do not silence one another, whichever was built last', () {
      final first = RecordingLogHandler();
      final second = RecordingLogHandler();

      StreamLogger.configure(StreamLogConfig(handler: first), scope: 'SF:');
      StreamLogger.configure(StreamLogConfig(handler: second), scope: 'SV:');
      feeds.w(() => 'feeds');
      video.w(() => 'video');

      // The complaint this scoping answers: configuring one client used to discard what the other
      // had installed, silently and by construction order.
      expect(first.messages, ['feeds']);
      expect(second.messages, ['video']);
    });

    test('leave a scope alone that no config named', () {
      StreamLogger.configure(const StreamLogConfig(priority: StreamLogPriority.debug), scope: 'SF:');
      final printed = capturePrints(() {
        feeds.d(() => 'feeds');
        video.e(() => 'video, never asked for');
      });

      // Video's error is louder than the threshold feeds asked for, and still goes nowhere.
      expect(printed.single, contains('feeds'));
    });

    test('write where the app installed a handler, rather than replacing it', () {
      final appWide = RecordingLogHandler();
      StreamLogger.handler = appWide;

      StreamLogger.configure(const StreamLogConfig(priority: StreamLogPriority.debug), scope: 'SF:');
      feeds.d(() => 'feeds');

      // A config naming only a priority must not take the records away from the destination the
      // app chose for everything.
      expect(appWide.messages, ['feeds']);
    });

    test('govern everything, given no scope at all', () {
      final mine = RecordingLogHandler();

      StreamLogger.configure(StreamLogConfig(priority: StreamLogPriority.debug, handler: mine));
      feeds.d(() => 'feeds');
      video.d(() => 'video');

      expect(mine.messages, ['feeds', 'video']);
    });

    test('decide their own records, over a rule the app set for everything', () {
      final mine = RecordingLogHandler();
      StreamLogger.handler = mine;
      StreamLogger.filter = const StreamLogFilter.always();

      StreamLogger.configure(const StreamLogConfig(), scope: 'SF:');
      feeds.v(() => 'below what the scope admits');
      video.v(() => 'still what the app asked for');

      // A scope is the narrower statement, so it settles its own tags. The app's rule keeps the
      // ones no scope claimed.
      expect(mine.messages, ['still what the app asked for']);
    });
  });
}
