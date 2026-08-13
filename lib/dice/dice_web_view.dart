import 'dart:convert';

import 'package:flutter/material.dart';

import 'dice_bridge_message.dart';
import 'dice_renderer_native.dart'
    if (dart.library.js_interop) 'dice_renderer_web.dart';
import 'dice_roll_request.dart';

typedef DiceRollCompleted = void Function(DiceBridgeMessage message);

class DiceWebViewController {
  DiceWebViewController({this.onRollCompleted});

  final DiceRollCompleted? onRollCompleted;
  Future<void> Function(String script)? _runJavaScript;
  String? _activeRequestId;
  bool _isReady = false;

  String? get activeRequestId => _activeRequestId;

  Future<void> roll(DiceRollRequest request) async {
    if (!_isReady || _runJavaScript == null) {
      return;
    }

    _activeRequestId = request.requestId;
    await _runJavaScript!(
      'window.DiceBridge.roll(${jsonEncode(request.toJson())});',
    );
  }

  Future<void> pause() => _runBridgeMethod('pause');

  Future<void> resume() => _runBridgeMethod('resume');

  Future<void> finishRoll(String requestId) async {
    if (requestId != _activeRequestId || !_isReady || _runJavaScript == null) {
      return;
    }

    await _runJavaScript!(
      'window.DiceBridge.finish(${jsonEncode(requestId)});',
    );
  }

  Future<void> handleBridgeMessage(String source) async {
    if (_isReadyMessage(source)) {
      _isReady = true;
      return;
    }

    final message = DiceBridgeMessage.parse(source);
    if (message == null || message.requestId != _activeRequestId) {
      return;
    }

    _activeRequestId = null;
    onRollCompleted?.call(message);
  }

  void attachJavaScriptRunner(Future<void> Function(String script) runner) {
    _runJavaScript = runner;
  }

  Future<void> _runBridgeMethod(String method) async {
    if (!_isReady || _runJavaScript == null) {
      return;
    }

    await _runJavaScript!('window.DiceBridge.$method();');
  }

  bool _isReadyMessage(String source) {
    try {
      final decoded = jsonDecode(source);
      return decoded is Map<String, dynamic> && decoded['type'] == 'ready';
    } on FormatException {
      return false;
    }
  }
}

/// Hosts `assets/dice/index.html` and wires it to [DiceWebViewController].
///
/// Mobile renders it inside a platform web view; the browser renders it inside
/// a same-origin iframe. Both hosts speak the identical `window.DiceBridge`
/// contract, so the roll rules stay in Dart and only the animation is
/// delegated to the shared HTML renderer.
class DiceWebView extends StatelessWidget {
  const DiceWebView({super.key, required this.controller});

  final DiceWebViewController controller;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: buildDiceRenderer(controller));
  }
}
