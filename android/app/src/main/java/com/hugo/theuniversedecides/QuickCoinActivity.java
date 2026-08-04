package com.hugo.theuniversedecides;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode;
import io.flutter.embedding.android.RenderMode;

public class QuickCoinActivity extends FlutterActivity {
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
