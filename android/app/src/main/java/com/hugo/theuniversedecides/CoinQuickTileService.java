package com.hugo.theuniversedecides;

import android.app.PendingIntent;
import android.content.Intent;
import android.os.Build;
import android.service.quicksettings.Tile;
import android.service.quicksettings.TileService;

public class CoinQuickTileService extends TileService {
    @Override
    public void onStartListening() {
        super.onStartListening();

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            return;
        }

        Tile tile = getQsTile();
        if (tile == null) {
            return;
        }

        // Hands the launch over to the system instead of running it from
        // onClick. System UI then starts QuickCoinActivity through its own
        // activity starter — the same path a notification tap takes — which is
        // the path OEM skins actually honor when dismissing the shade. One UI
        // ignores the collapse that startActivityAndCollapse asks for, leaving
        // the panel on top of the coin.
        //
        // Trade-off worth measuring on a device: that starter also dismisses
        // the keyguard, so a locked phone may prompt for unlock instead of
        // showing the coin above the lock screen the way QuickCoinActivity's
        // showWhenLocked does today.
        tile.setActivityLaunchForClick(buildCoinPendingIntent());
        tile.updateTile();
    }

    @Override
    public void onClick() {
        super.onClick();

        // From Android 14 on, the Activity set in onStartListening takes
        // precedence and this is never called. The branch below stays for
        // older releases, and as a fallback for a skin that keeps delivering
        // clicks to the service anyway — startActivityAndCollapse(Intent)
        // throws on API 34+, so it must not be reached there.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startActivityAndCollapse(buildCoinPendingIntent());
            return;
        }

        // QuickCoinActivity requests showWhenLocked, so the system presents
        // it above the keyguard without an unlock prompt when the device is
        // locked. The same startActivityAndCollapse call also preserves the
        // existing collapsed Quick Settings behavior when unlocked.
        startActivityAndCollapse(buildCoinIntent());
    }

    private PendingIntent buildCoinPendingIntent() {
        return PendingIntent.getActivity(
                this,
                QuickAccessContract.ACTION_COIN.hashCode(),
                buildCoinIntent(),
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
        );
    }

    private Intent buildCoinIntent() {
        return new Intent(this, QuickCoinActivity.class)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP)
                .putExtra(QuickAccessContract.EXTRA_ACTION, QuickAccessContract.ACTION_COIN);
    }
}
