package com.hugo.theuniversedecides;

import android.app.Activity;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

final class PlayGamesBridge {
    private static final String CHANNEL = "theuniversedecides/play_games";

    private PlayGamesBridge() {
    }

    static void register(@NonNull Activity activity, @NonNull FlutterEngine flutterEngine) {
        new MethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(),
                CHANNEL
        ).setMethodCallHandler((call, result) -> {
            switch (call.method) {
                case "isSignedIn":
                    result.success(false);
                    return;
                case "signIn":
                case "unlock":
                case "submitScore":
                case "showLeaderboard":
                    result.success(null);
                    return;
                default:
                    result.notImplemented();
            }
        });
    }
}
