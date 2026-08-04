package com.hugo.theuniversedecides;

import android.app.PendingIntent;
import android.content.Intent;
import android.os.Build;
import android.service.quicksettings.TileService;

abstract class QuickActionTileService extends TileService {
    abstract String getQuickAccessAction();

    Class<?> getLaunchActivityClass() {
        return MainActivity.class;
    }

    @Override
    public void onClick() {
        super.onClick();

        Intent intent = new Intent(this, getLaunchActivityClass())
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP)
                .putExtra(QuickAccessContract.EXTRA_ACTION, getQuickAccessAction());

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            PendingIntent pendingIntent = PendingIntent.getActivity(
                    this,
                    getQuickAccessAction().hashCode(),
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
            );
            startActivityAndCollapse(pendingIntent);
            return;
        }

        startActivityAndCollapse(intent);
    }
}
