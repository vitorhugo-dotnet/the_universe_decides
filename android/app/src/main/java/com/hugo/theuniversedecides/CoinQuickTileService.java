package com.hugo.theuniversedecides;

import android.app.PendingIntent;
import android.content.Intent;
import android.os.Build;
import android.service.quicksettings.TileService;

public class CoinQuickTileService extends TileService {
    @Override
    public void onClick() {
        super.onClick();

        Intent intent = new Intent(this, QuickCoinActivity.class)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP)
                .putExtra(QuickAccessContract.EXTRA_ACTION, QuickAccessContract.ACTION_COIN);

        // QuickCoinActivity requests showWhenLocked, so the system presents
        // it above the keyguard without an unlock prompt when the device is
        // locked. The same startActivityAndCollapse call also preserves the
        // existing collapsed Quick Settings behavior when unlocked.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            PendingIntent pendingIntent = PendingIntent.getActivity(
                    this,
                    QuickAccessContract.ACTION_COIN.hashCode(),
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
            );
            startActivityAndCollapse(pendingIntent);
            return;
        }

        startActivityAndCollapse(intent);
    }
}
