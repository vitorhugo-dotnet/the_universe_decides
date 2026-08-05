package com.hugo.theuniversedecides;

import android.os.Build;
import android.os.Bundle;
import android.view.WindowManager;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode;
import io.flutter.embedding.android.RenderMode;

public class QuickCoinActivity extends FlutterActivity {
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
