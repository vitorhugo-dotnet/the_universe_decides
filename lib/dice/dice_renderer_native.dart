import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'dice_web_view.dart';

/// Mobile host for the dice renderer: a platform web view loading the bundled
/// Flutter asset directly.
Widget buildDiceRenderer(DiceWebViewController controller) {
  return _NativeDiceRenderer(controller: controller);
}

class _NativeDiceRenderer extends StatefulWidget {
  const _NativeDiceRenderer({required this.controller});

  final DiceWebViewController controller;

  @override
  State<_NativeDiceRenderer> createState() => _NativeDiceRendererState();
}

class _NativeDiceRendererState extends State<_NativeDiceRenderer> {
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
    return WebViewWidget(controller: _webViewController);
  }
}
