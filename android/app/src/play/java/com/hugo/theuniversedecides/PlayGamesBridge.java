package com.hugo.theuniversedecides;

import android.app.Activity;

import androidx.annotation.NonNull;

import com.google.android.gms.games.PlayGames;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

final class PlayGamesBridge {
    private static final String CHANNEL = "theuniversedecides/play_games";
    private static final String ARG_ID = "id";
    private static final String ARG_SCORE = "score";
    private static final int LEADERBOARD_REQUEST_CODE = 9004;

    private PlayGamesBridge() {
    }

    static void register(@NonNull Activity activity, @NonNull FlutterEngine flutterEngine) {
        new MethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(),
                CHANNEL
        ).setMethodCallHandler((call, result) -> handle(activity, call, result));
    }

    private static void handle(
            Activity activity,
            MethodCall call,
            MethodChannel.Result result
    ) {
        switch (call.method) {
            case "signIn":
                PlayGames.getGamesSignInClient(activity)
                        .signIn()
                        .addOnSuccessListener(ignored -> result.success(null))
                        .addOnFailureListener(error -> fail(result, "sign_in_failed", error));
                return;
            case "isSignedIn":
                PlayGames.getGamesSignInClient(activity)
                        .isAuthenticated()
                        .addOnSuccessListener(authenticationResult ->
                                result.success(authenticationResult.isAuthenticated()))
                        .addOnFailureListener(error -> fail(result, "auth_check_failed", error));
                return;
            case "unlock":
                String achievementId = requiredString(call, ARG_ID, result);
                if (achievementId == null) {
                    return;
                }
                PlayGames.getAchievementsClient(activity).unlock(achievementId);
                result.success(null);
                return;
            case "submitScore":
                String leaderboardId = requiredString(call, ARG_ID, result);
                Number score = call.argument(ARG_SCORE);
                if (leaderboardId == null) {
                    return;
                }
                if (score == null) {
                    result.error("invalid_arguments", "Missing score.", null);
                    return;
                }
                PlayGames.getLeaderboardsClient(activity)
                        .submitScore(leaderboardId, score.longValue());
                result.success(null);
                return;
            case "showLeaderboard":
                String visibleLeaderboardId = requiredString(call, ARG_ID, result);
                if (visibleLeaderboardId == null) {
                    return;
                }
                PlayGames.getLeaderboardsClient(activity)
                        .getLeaderboardIntent(visibleLeaderboardId)
                        .addOnSuccessListener(intent -> {
                            activity.startActivityForResult(intent, LEADERBOARD_REQUEST_CODE);
                            result.success(null);
                        })
                        .addOnFailureListener(error ->
                                fail(result, "leaderboard_failed", error));
                return;
            default:
                result.notImplemented();
        }
    }

    private static String requiredString(
            MethodCall call,
            String argument,
            MethodChannel.Result result
    ) {
        String value = call.argument(argument);
        if (value == null || value.isBlank()) {
            result.error("invalid_arguments", "Missing " + argument + ".", null);
            return null;
        }
        return value;
    }

    private static void fail(
            MethodChannel.Result result,
            String code,
            Exception error
    ) {
        result.error(code, error.getMessage(), null);
    }
}
