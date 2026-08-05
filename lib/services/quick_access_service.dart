import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum QuickAccessAction {
  coin;

  int get tabIndex => switch (this) {
    QuickAccessAction.coin => 0,
  };

  String get value => switch (this) {
    QuickAccessAction.coin => 'coin',
  };

  static QuickAccessAction? fromValue(String? value) {
    return switch (value) {
      'coin' => QuickAccessAction.coin,
      _ => null,
    };
  }
}

enum QuickAccessTileRequestResult {
  added,
  alreadyAdded,
  cancelled,
  unsupported,
}

abstract class QuickAccessService {
  Future<QuickAccessAction?> getInitialAction();

  Stream<QuickAccessAction> get actions;

  Future<QuickAccessTileRequestResult> requestTile(QuickAccessAction action);
}

final quickAccessServiceProvider = Provider<QuickAccessService>(
  (_) => const MethodChannelQuickAccessService(),
);

final coinQuickAccessTriggerProvider =
    NotifierProvider<QuickAccessTriggerNotifier, int>(
      QuickAccessTriggerNotifier.new,
    );

class QuickAccessTriggerNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void trigger() {
    state++;
  }
}

class MethodChannelQuickAccessService implements QuickAccessService {
  const MethodChannelQuickAccessService();

  static const _methodChannel = MethodChannel(
    'theuniversedecides/quick_access',
  );
  static const _eventChannel = EventChannel(
    'theuniversedecides/quick_access/events',
  );

  @override
  Stream<QuickAccessAction> get actions {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return const Stream.empty();
    }

    return _eventChannel
        .receiveBroadcastStream()
        .map((event) {
          return QuickAccessAction.fromValue(event as String);
        })
        .where((action) => action != null)
        .cast<QuickAccessAction>();
  }

  @override
  Future<QuickAccessAction?> getInitialAction() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return null;
    }

    try {
      final action = await _methodChannel.invokeMethod<String>(
        'getInitialAction',
      );
      return QuickAccessAction.fromValue(action);
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  @override
  Future<QuickAccessTileRequestResult> requestTile(
    QuickAccessAction action,
  ) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return QuickAccessTileRequestResult.unsupported;
    }

    try {
      final result = await _methodChannel.invokeMethod<String>(
        'requestQuickAccessTile',
        {'action': action.value},
      );
      return switch (result) {
        'added' => QuickAccessTileRequestResult.added,
        'alreadyAdded' => QuickAccessTileRequestResult.alreadyAdded,
        'cancelled' => QuickAccessTileRequestResult.cancelled,
        _ => QuickAccessTileRequestResult.unsupported,
      };
    } on MissingPluginException {
      return QuickAccessTileRequestResult.unsupported;
    } on PlatformException {
      return QuickAccessTileRequestResult.unsupported;
    }
  }
}
