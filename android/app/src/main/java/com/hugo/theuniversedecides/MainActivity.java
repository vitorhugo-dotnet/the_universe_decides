package com.hugo.theuniversedecides;

import android.app.StatusBarManager;
import android.content.ComponentName;
import android.content.Intent;
import android.graphics.drawable.Icon;
import android.os.Build;

import androidx.annotation.NonNull;

import java.util.Map;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private EventChannel.EventSink quickAccessEventSink;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(),
                QuickAccessContract.METHOD_CHANNEL
        ).setMethodCallHandler(this::handleMethodCall);

        new EventChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(),
                QuickAccessContract.EVENT_CHANNEL
        ).setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                quickAccessEventSink = events;
            }

            @Override
            public void onCancel(Object arguments) {
                quickAccessEventSink = null;
            }
        });

        PlayGamesBridge.register(this, flutterEngine);
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        dispatchQuickAccessAction(intent);
    }

    private void handleMethodCall(MethodCall call, MethodChannel.Result result) {
        switch (call.method) {
            case "getInitialAction":
                result.success(consumeInitialQuickAccessAction());
                return;
            case "requestQuickAccessTile":
                requestQuickAccessTile(call, result);
                return;
            default:
                result.notImplemented();
        }
    }

    private String consumeInitialQuickAccessAction() {
        Intent intent = getIntent();
        String action = extractQuickAccessAction(intent);
        clearQuickAccessAction(intent);
        return action;
    }

    private void dispatchQuickAccessAction(Intent intent) {
        String action = extractQuickAccessAction(intent);
        if (action == null || quickAccessEventSink == null) {
            return;
        }

        quickAccessEventSink.success(action);
        clearQuickAccessAction(intent);
    }

    private void requestQuickAccessTile(MethodCall call, MethodChannel.Result result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            result.success("unsupported");
            return;
        }

        Object arguments = call.arguments;
        if (!(arguments instanceof Map<?, ?> argumentMap)) {
            result.error("invalid_arguments", "Expected a map with the tile action.", null);
            return;
        }

        Object actionValue = argumentMap.get(QuickAccessContract.ARG_ACTION);
        if (!QuickAccessContract.ACTION_COIN.equals(actionValue)) {
            result.error("invalid_action", "Unsupported quick access action.", null);
            return;
        }

        StatusBarManager statusBarManager = getSystemService(StatusBarManager.class);
        if (statusBarManager == null) {
            result.success("unsupported");
            return;
        }

        statusBarManager.requestAddTileService(
                new ComponentName(this, CoinQuickTileService.class),
                getString(R.string.quick_tile_coin_label),
                Icon.createWithResource(this, R.drawable.ic_quick_tile_coin),
                getMainExecutor(),
                addTileResult -> result.success(mapTileResult(addTileResult))
        );
    }

    private String mapTileResult(int addTileResult) {
        if (addTileResult == StatusBarManager.TILE_ADD_REQUEST_RESULT_TILE_ADDED) {
            return "added";
        }
        if (addTileResult == StatusBarManager.TILE_ADD_REQUEST_RESULT_TILE_ALREADY_ADDED) {
            return "alreadyAdded";
        }
        if (addTileResult == StatusBarManager.TILE_ADD_REQUEST_RESULT_TILE_NOT_ADDED) {
            return "cancelled";
        }
        return "unsupported";
    }

    private String extractQuickAccessAction(Intent intent) {
        if (intent == null) {
            return null;
        }

        String action = intent.getStringExtra(QuickAccessContract.EXTRA_ACTION);
        if (QuickAccessContract.ACTION_COIN.equals(action)) {
            return action;
        }
        return null;
    }

    private void clearQuickAccessAction(Intent intent) {
        if (intent != null) {
            intent.removeExtra(QuickAccessContract.EXTRA_ACTION);
        }
    }
}
