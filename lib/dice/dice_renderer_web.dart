import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import 'dice_web_view.dart';

/// Asset key of the shared dice renderer, resolved through the engine so the
/// URL keeps working under the GitHub Pages sub-directory `--base-href`.
const _diceAssetKey = 'assets/dice/index.html';

/// Browser host for the dice renderer: the same HTML/JavaScript the mobile web
/// view loads, embedded in a same-origin iframe.
Widget buildDiceRenderer(DiceWebViewController controller) {
  return _WebDiceRenderer(controller: controller);
}

class _WebDiceRenderer extends StatefulWidget {
  const _WebDiceRenderer({required this.controller});

  final DiceWebViewController controller;

  @override
  State<_WebDiceRenderer> createState() => _WebDiceRendererState();
}

class _WebDiceRendererState extends State<_WebDiceRenderer> {
  /// Platform view factories cannot be replaced, so every renderer instance
  /// claims its own view type.
  static int _nextViewTypeSuffix = 0;

  late final String _viewType;
  late final web.HTMLIFrameElement _frame;
  late final JSFunction _onFrameLoad;

  @override
  void initState() {
    super.initState();
    _viewType = 'dice-renderer-${_nextViewTypeSuffix++}';
    _frame = web.HTMLIFrameElement()
      ..src = ui_web.assetManager.getAssetUrl(_diceAssetKey)
      ..title = 'Dice renderer'
      ..allowFullscreen = false;
    _frame.style
      ..border = 'none'
      ..width = '100%'
      ..height = '100%'
      ..backgroundColor = 'transparent'
      // Flutter owns every gesture on this screen; the frame only draws.
      ..pointerEvents = 'none';

    _onFrameLoad = _handleFrameLoad.toJS;
    _frame.addEventListener('load', _onFrameLoad);

    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) => _frame,
    );

    widget.controller.attachJavaScriptRunner(_runJavaScript);
  }

  @override
  void dispose() {
    _frame.removeEventListener('load', _onFrameLoad);
    super.dispose();
  }

  /// `bridge.js` emits its `ready` event while the document is still loading,
  /// before this side can install the channel, so the ready hand-off is
  /// re-created here. Every script in `index.html` is synchronous, which means
  /// `window.DiceBridge` already exists once `load` fires.
  void _handleFrameLoad(web.Event event) {
    final frameWindow = _frame.contentWindow;
    if (frameWindow == null) {
      return;
    }

    (frameWindow as JSObject).setProperty(
      'DiceBridgeChannel'.toJS,
      JSObject()..setProperty('postMessage'.toJS, _receiveBridgeMessage.toJS),
    );
    unawaited(widget.controller.handleBridgeMessage('{"type":"ready"}'));
  }

  void _receiveBridgeMessage(JSString message) {
    if (!mounted) {
      return;
    }
    unawaited(widget.controller.handleBridgeMessage(message.toDart));
  }

  /// The iframe is same-origin, so the bridge calls the mobile side sends over
  /// the platform channel can be evaluated directly in the frame's scope. That
  /// keeps a single script contract for both hosts.
  Future<void> _runJavaScript(String script) async {
    final frameWindow = _frame.contentWindow;
    if (frameWindow == null) {
      return;
    }
    (frameWindow as JSObject).callMethod<JSAny?>('eval'.toJS, script.toJS);
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}
