import 'package:flutter/foundation.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import '../models/wallpaper.dart';
import '../services/api_client.dart';
import '../services/storage_service.dart';
import '../services/wallpaper_manager.dart';

class AppState extends ChangeNotifier {
  final StorageService storage;
  final ApiClient _api = ApiClient();
  final WallpaperManager _manager;

  List<Wallpaper> _browseList = [];
  List<Wallpaper> _favoritesList = [];
  List<Wallpaper> _cacheList = [];
  bool _isLoading = false;
  late WallpaperSource _browseSource;

  AppState(this.storage) : _manager = WallpaperManager(storage) {
    _browseSource = storage.source;
    _init();
  }

  Future<void> _init() async {
    _favoritesList = await storage.loadFavorites();
    _cacheList = await storage.loadCache();
    notifyListeners();
    
    // Refresh browse list automatically
    refreshBrowse();
    
    if (storage.autoChange) {
      _manager.startAutoChange();
    }
  }

  // --- Getters ---

  List<Wallpaper> get browseList => _browseList;
  List<Wallpaper> get favoritesList => _favoritesList;
  List<Wallpaper> get cacheList => _cacheList;
  bool get isLoading => _isLoading;

  WallpaperSource get source => storage.source;
  WallpaperSource get browseSource => _browseSource;
  String get country => storage.country;
  int get periodMinutes => storage.periodMinutes;
  bool get autoChange => storage.autoChange;
  bool get autoStart => storage.autoStart;

  // --- Actions ---

  Future<void> refreshBrowse() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (browseSource == WallpaperSource.peapixBing) {
        _browseList = await _api.fetchPeapixBing(country: country);
      } else if (browseSource == WallpaperSource.peapixSpotlight) {
        _browseList = await _api.fetchPeapixSpotlight();
      } else if (browseSource == WallpaperSource.biturlBing) {
        final w = await _api.fetchBiturlBing();
        _browseList = w != null ? [w] : [];
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setSource(WallpaperSource value) async {
    storage.source = value;
    notifyListeners();
  }

  Future<void> setBrowseSource(WallpaperSource value) async {
    _browseSource = value;
    notifyListeners();
    await refreshBrowse();
  }

  void setCountry(String value) async {
    storage.country = value;
    notifyListeners();
    await refreshBrowse();
  }

  void setPeriodMinutes(int value) {
    storage.periodMinutes = value;
    notifyListeners();
    if (autoChange) {
      _manager.startAutoChange(); // Restart timer with new period
    }
  }

  void toggleAutoChange(bool value) {
    storage.autoChange = value;
    notifyListeners();
    if (value) {
      _manager.startAutoChange();
    } else {
      _manager.stopAutoChange();
    }
  }

  void toggleAutoStart(bool value) async {
    storage.autoStart = value;
    if (value) {
      await launchAtStartup.enable();
    } else {
      await launchAtStartup.disable();
    }
    notifyListeners();
  }

  Future<void> toggleFavorite(Wallpaper wallpaper) async {
    final isFav = _favoritesList.any((w) => w.id == wallpaper.id);
    if (isFav) {
      _favoritesList.removeWhere((w) => w.id == wallpaper.id);
    } else {
      _favoritesList.add(wallpaper.copyWith(isFavorite: true));
    }
    
    await storage.saveFavorites(_favoritesList);
    notifyListeners();
  }

  Future<bool> applyWallpaper(Wallpaper wallpaper) async {
    _isLoading = true;
    notifyListeners();
    
    final success = await _manager.applyWallpaper(wallpaper);
    
    if (success) {
      _cacheList = await storage.loadCache();
    }
    
    _isLoading = false;
    notifyListeners();
    return success;
  }

  bool isFavorite(String id) {
    return _favoritesList.any((w) => w.id == id);
  }
}
