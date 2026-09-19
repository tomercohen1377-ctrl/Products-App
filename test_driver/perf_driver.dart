import 'package:flutter_driver/flutter_driver.dart' as driver;
import 'package:integration_test/integration_test_driver.dart';

/// Turns the timeline recorded by `deck_performance_test.dart` into a summary
/// (frame build and raster times, missed frames) under `build/`.
Future<void> main() => integrationDriver(
  responseDataCallback: (data) async {
    if (data == null) return;
    final timeline = driver.Timeline.fromJson(
      data['deck_timeline'] as Map<String, dynamic>,
    );
    await driver.TimelineSummary.summarize(
      timeline,
    ).writeTimelineToFile('deck_timeline', pretty: true, includeSummary: true);
  },
);
