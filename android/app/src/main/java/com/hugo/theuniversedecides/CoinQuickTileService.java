package com.hugo.theuniversedecides;

public class CoinQuickTileService extends QuickActionTileService {
    @Override
    Class<?> getLaunchActivityClass() {
        return QuickCoinActivity.class;
    }

    @Override
    String getQuickAccessAction() {
        return QuickAccessContract.ACTION_COIN;
    }
}
