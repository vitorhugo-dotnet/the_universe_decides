import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theuniversedecides/l10n/generated/app_localizations.dart';
import 'package:theuniversedecides/screens/list_picker_screen.dart';
import 'package:theuniversedecides/services/random_org_service.dart';
import 'package:theuniversedecides/widgets/snack_bar_custom.dart';

void main() {
  // SnackBarCustom keeps static overlay state so it can dedupe repeated
  // messages across the app; reset it between tests so one test's shown
  // message doesn't suppress an identical message in the next test.
  tearDown(SnackBarCustom.hideCurrentSnackBar);

  testWidgets(
    'adding a case/whitespace duplicate shows feedback and does not insert it',
    (tester) async {
      final container = _container();
      addTearDown(container.dispose);

      await _pumpListScreen(tester, container);

      await tester.enterText(find.byType(TextField), 'Viagem');
      await tester.tap(find.text('+'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '  viagem  ');
      await tester.tap(find.text('+'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 260));

      expect(find.text('Viagem'), findsOneWidget);
      expect(
        find.text('This item already exists in the list.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('multi-word items are unaffected and treated as one item', (
    tester,
  ) async {
    final container = _container();
    addTearDown(container.dispose);

    await _pumpListScreen(tester, container);

    await tester.enterText(find.byType(TextField), 'Viajar para Roma');
    await tester.tap(find.text('+'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Viajar para Paris');
    await tester.tap(find.text('+'));
    await tester.pumpAndSettle();

    expect(find.text('Viajar para Roma'), findsOneWidget);
    expect(find.text('Viajar para Paris'), findsOneWidget);
    expect(
      find.text('This item already exists in the list.'),
      findsNothing,
    );
  });

  testWidgets('"Nova York" and "nova york" are treated as duplicates', (
    tester,
  ) async {
    final container = _container();
    addTearDown(container.dispose);

    await _pumpListScreen(tester, container);

    await tester.enterText(find.byType(TextField), 'Nova York');
    await tester.tap(find.text('+'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'nova york');
    await tester.tap(find.text('+'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 260));

    expect(find.text('Nova York'), findsOneWidget);
    expect(
      find.text('This item already exists in the list.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'comma-separated batch still splits into items when none duplicate',
    (tester) async {
      final container = _container();
      addTearDown(container.dispose);

      await _pumpListScreen(tester, container);

      await tester.enterText(
        find.byType(TextField),
        'Nova York, comprar café, filme de terror',
      );
      await tester.tap(find.text('+'));
      await tester.pumpAndSettle();

      expect(find.text('Nova York'), findsOneWidget);
      expect(find.text('comprar café'), findsOneWidget);
      expect(find.text('filme de terror'), findsOneWidget);
    },
  );

  testWidgets(
    'batch add inserts only the new items, in order, and reports the discarded count',
    (tester) async {
      final container = _container();
      addTearDown(container.dispose);

      await _pumpListScreen(tester, container);

      await tester.enterText(find.byType(TextField), 'Roma');
      await tester.tap(find.text('+'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        'Paris, roma, Paris, Londres',
      );
      await tester.tap(find.text('+'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 260));

      final itemFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            (widget.data == 'Roma' ||
                widget.data == 'Paris' ||
                widget.data == 'Londres'),
      );
      expect(itemFinder, findsNWidgets(3));
      expect(find.text('2 duplicate items were skipped.'), findsOneWidget);
    },
  );
}

ProviderContainer _container() {
  return ProviderContainer(
    overrides: [
      randomOrgServiceProvider.overrideWithValue(RandomOrgService()),
    ],
  );
}

Future<void> _pumpListScreen(
  WidgetTester tester,
  ProviderContainer container,
) {
  return tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: ListPickerScreen()),
      ),
    ),
  );
}
