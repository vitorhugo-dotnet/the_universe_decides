package com.hugo.theuniversedecides;

import android.os.Build;
import android.os.Bundle;
import android.view.WindowManager;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode;
import io.flutter.embedding.android.RenderMode;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;

public class QuickCoinActivity extends FlutterActivity {
    private EventChannel.EventSink windowFocusEventSink;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Coin flips are safe to run while the device is locked, so this
        // activity is presented above the keyguard instead of unlocking it.
        // android:showWhenLocked in the manifest already covers API 34+;
        // these calls cover the full flutter.minSdkVersion range without
        // an overlay permission or any new runtime permission.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true);
        } else {
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED);
        }
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        // Reports whether this window owns the screen, so the quick coin can
        // hold its flip until the notification panel is out of the way.
        //
        // AppLifecycleState cannot answer that here. Flutter only leaves
        // "resumed" once onWindowFocusChanged(false) arrives, and this activity
        // is launched *behind* an open panel: the window never held focus, so
        // there is no focus change to report and the engine keeps assuming it
        // is focused. hasWindowFocus() is the real state rather than the
        // accumulated one, which is why the first event below reads it
        // directly instead of waiting for a callback.
        new EventChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(),
                QuickAccessContract.WINDOW_FOCUS_EVENT_CHANNEL
        ).setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                windowFocusEventSink = events;
                events.success(hasWindowFocus());
            }

            @Override
            public void onCancel(Object arguments) {
                windowFocusEventSink = null;
            }
        });
    }

    @Override
    public void onWindowFocusChanged(boolean hasFocus) {
        super.onWindowFocusChanged(hasFocus);

        if (windowFocusEventSink != null) {
            windowFocusEventSink.success(hasFocus);
        }
    }

    @NonNull
    @Override
    public String getInitialRoute() {
        return "/quick-coin";
    }

    @NonNull
    @Override
    public BackgroundMode getBackgroundMode() {
        return BackgroundMode.transparent;
    }

    @NonNull
    @Override
    public RenderMode getRenderMode() {
        return RenderMode.texture;
    }
}
