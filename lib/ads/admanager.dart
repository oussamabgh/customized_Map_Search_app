import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io' show Platform;

class AppOpenAdManager {

  String adUnitId = 'ca-app-pub-3940256099942544/3419835294';

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;

  /// Load an AppOpenAd.
  void loadAd() {
    AppOpenAd.load(
      adUnitId: adUnitId,
      orientation: AppOpenAd.orientationPortrait,
      request: AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('AppOpenAd failed to load: $error');
          // Handle the error.
        },
      ),
    );
  }
   void showAdIfAvailable() {
    if (!isAdAvailable) {
      print('Tried to show ad before available.');
      loadAd();
      return;
    }
    if (_isShowingAd) {
      print('Tried to show ad while already showing an ad.');
      return;
    }
    // Set the fullScreenContentCallback and show the ad.
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        print('$ad onAdShowedFullScreenContent');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        print('$ad onAdDismissedFullScreenContent');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAd();
      },
    );
  }
  /// Whether an ad is available to be shown.
  bool get isAdAvailable {
    return _appOpenAd != null;
  }
}