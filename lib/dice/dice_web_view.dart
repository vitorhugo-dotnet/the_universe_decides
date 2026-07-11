import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'dice_bridge_message.dart';
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

class DiceWebView extends StatefulWidget {
  const DiceWebView({super.key, required this.controller});

  final DiceWebViewController controller;

  @override
  State<DiceWebView> createState() => _DiceWebViewState();
}

class _DiceWebViewState extends State<DiceWebView> {
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) => NavigationDecision.prevent,
        ),
      )
      ..addJavaScriptChannel(
        'DiceBridgeChannel',
        onMessageReceived: (message) {
          widget.controller.handleBridgeMessage(message.message);
        },
      )
      ..loadFlutterAsset('assets/dice/index.html');
    widget.controller.attachJavaScriptRunner(_webViewController.runJavaScript);
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: WebViewWidget(controller: _webViewController));
  }
}
