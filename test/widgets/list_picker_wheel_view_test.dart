import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:theuniversedecides/controllers/list_picker_controller.dart';
import 'package:theuniversedecides/l10n/generated/app_localizations.dart';
import 'package:theuniversedecides/screens/list_picker_wheel_view.dart';
import 'package:theuniversedecides/services/random_org_service.dart';
import 'package:theuniversedecides/widgets/ritual_button.dart';

void main() {
  testWidgets('shows the hint and disables spinning with fewer than two items', (
    tester,
  ) async {
    final client = _PendingClient();
    final container = _containerFor(client);
    addTearDown(container.dispose);
    container.read(listPickerProvider.notifier).addItem('Only one');

    await _pumpWheel(tester, container);

    expect(find.text('Add at least two options, then give it a spin.'),
        findsNothing);
    expect(find.text('Add at least two options to begin.'), findsOneWidget);
    expect(
      tester.widget<RitualButton>(find.byType(RitualButton)).onPressed,
      isNull,
    );
  });

  testWidgets('renders with two or more items and allows spinning', (
    tester,
  ) async {
    final client = _PendingClient();
    final container = _containerFor(client);
    addTearDown(container.dispose);
    container.read(listPickerProvider.notifier).addItem('Pizza, Sushi, Tacos');

    await _pumpWheel(tester, container);

    expect(find.text('Add at least two options, then give it a spin.'),
        findsOneWidget);
    expect(find.text('Spin the wheel'), findsOneWidget);
  });

  testWidgets('circular drag rotates the dial with the pointer', (tester) async {
    final client = _PendingClient();
    final container = _containerFor(client);
    addTearDown(container.dispose);
    container.read(listPickerProvider.notifier).addItem('A, B, C');
    await _pumpWheel(tester, container);

    final dial = find.byKey(const ValueKey('list-wheel-dial'));
    final center = tester.getCenter(dial);
    final gesture = await tester.startGesture(center + const Offset(90, 0));
    await gesture.moveTo(center + const Offset(0, 90));
    await tester.pump();

    final transform = tester.widget<Transform>(
      find.byKey(const ValueKey('list-wheel-disc')),
    );
    final matrix = transform.transform.storage;
    expect(math.atan2(matrix[1], matrix[0]), closeTo(math.pi / 2, 0.05));

    await gesture.up();
  });

  testWidgets('a quick circular flick requests exactly one winner', (
    tester,
  ) async {
    final client = _PendingClient();
    final container = _containerFor(client);
    addTearDown(container.dispose);
    container.read(listPickerProvider.notifier).addItem('A, B, C');
    await _pumpWheel(tester, container, reduceMotion: true);

    final dial = find.byKey(const ValueKey('list-wheel-dial'));
    final center = tester.getCenter(dial);
    final gesture = await tester.startGesture(center + const Offset(90, 0));
    await gesture.moveTo(center + const Offset(0, 90),
        timeStamp: const Duration(milliseconds: 16));
    await gesture.up(timeStamp: const Duration(milliseconds: 20));
    await tester.pump();

    expect(client.requestCount, 1);

    client.complete('1');
    await tester.pumpAndSettle();
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('a small accidental drag does not request a winner', (
    tester,
  ) async {
    final client = _PendingClient();
    final container = _containerFor(client);
    addTearDown(container.dispose);
    container.read(listPickerProvider.notifier).addItem('A, B, C');
    await _pumpWheel(tester, container);

    final dial = find.byKey(const ValueKey('list-wheel-dial'));
    final center = tester.getCenter(dial);
    final gesture = await tester.startGesture(center + const Offset(90, 0));
    await gesture.moveBy(const Offset(0, 3));
    await gesture.up();
    await tester.pump();

    expect(client.requestCount, 0);
  });

  testWidgets('blocks a re-trigger while a spin is already in flight', (
    tester,
  ) async {
    final client = _PendingClient();
    final container = _containerFor(client);
    addTearDown(container.dispose);
    container.read(listPickerProvider.notifier).addItem('A, B, C');

    await _pumpWheel(tester, container, reduceMotion: true);

    await tester.tap(find.text('Spin the wheel'));
    await tester.pump();
    // Second tap while the fetch is still pending must not fire a request.
    await tester.tap(find.text('Spin the wheel'));
    await tester.pump();

    expect(client.requestCount, 1);

    client.complete('1');
    await tester.pumpAndSettle();
  });

  testWidgets(
    'reveals the winner returned by the randomness service, respecting reduced motion',
    (tester) async {
      final client = _PendingClient();
      final container = _containerFor(client);
      addTearDown(container.dispose);
      container.read(listPickerProvider.notifier).addItem('Pizza, Sushi, Tacos');

      await _pumpWheel(tester, container, reduceMotion: true);

      await tester.tap(find.text('Spin the wheel'));
      await tester.pump();
      client.complete('2'); // index 2 -> "Tacos"
      // Reduced motion skips the animation entirely, so a couple of pumps
      // (fetch future + celebratory sound future) settle it, with no need to
      // advance a 3.2s AnimationController.
      await tester.pump();
      await tester.pump();

      expect(find.text('Tacos'), findsOneWidget);
      expect(container.read(listPickerProvider).selectedIndex, 2);
    },
  );

  testWidgets('still reveals a winner when the service falls back locally', (
    tester,
  ) async {
    final container = _containerFor(_FailingClient());
    addTearDown(container.dispose);
    container.read(listPickerProvider.notifier).addItem('Heads, Tails');

    await _pumpWheel(tester, container, reduceMotion: true);

    await tester.tap(find.text('Spin the wheel'));
    await tester.pump();
    await tester.pump();
    await tester.pump();

    final winnerIndex = container.read(listPickerProvider).selectedIndex;
    expect(winnerIndex, anyOf(0, 1));
    expect(
      find.text(winnerIndex == 0 ? 'Heads' : 'Tails'),
      findsOneWidget,
    );
  });
}

ProviderContainer _containerFor(http.Client client) {
  final service = RandomOrgService(client: client);
  return ProviderContainer(
    overrides: [randomOrgServiceProvider.overrideWithValue(service)],
  );
}

Future<void> _pumpWheel(
  WidgetTester tester,
  ProviderContainer container, {
  bool reduceMotion = false,
}) {
  return tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: ListPickerWheelView()),
        ),
      ),
    ),
  );
}

class _PendingClient extends http.BaseClient {
  final Completer<http.Response> _response = Completer<http.Response>();
  var requestCount = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requestCount++;
    final response = await _response.future;
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
    );
  }

  void complete(String body) {
    _response.complete(http.Response(body, 200));
  }
}

class _FailingClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    throw Exception('network unavailable');
  }
}
