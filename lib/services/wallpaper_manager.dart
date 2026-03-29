import 'dart:async';
import 'dart:math';
import '../models/wallpaper.dart';
import 'api_client.dart';
import 'storage_service.dart';
import 'wallpaper_setter_service.dart';

class WallpaperManager {
  final ApiClient _api = ApiClient();
  final StorageService _storage;
  final WallpaperSetterService _setter = WallpaperSetterService();
  
  Timer? _timer;
  final _random = Random();

  WallpaperManager(this._storage);

  void startAutoChange() {
    _timer?.cancel();
    if (!_storage.autoChange) return;

    final duration = Duration(minutes: _storage.periodMinutes);
    _timer = Timer.periodic(duration, (_) => _tick());
    print('Auto-change started: every $duration');
  }

  void stopAutoChange() {
    _timer?.cancel();
    _timer = null;
    print('Auto-change stopped');
  }

  Future<void> _tick() async {
    print('Auto-change tick: fetching and applying new wallpaper');
    await fetchAndApplyNew();
  }

  Future<bool> fetchAndApplyNew() async {
    final source = _storage.source;
    List<Wallpaper> list = [];

    if (source == WallpaperSource.peapixBing) {
      list = await _api.fetchPeapixBing(country: _storage.country);
    } else if (source == WallpaperSource.peapixSpotlight) {
      list = await _api.fetchPeapixSpotlight();
    } else if (source == WallpaperSource.biturlBing) {
      final w = await _api.fetchBiturlBing();
      if (w != null) list = [w];
    }

    if (list.isEmpty) return false;

    // Pick a random one from the list (or the first if only one)
    final wallpaper = list[_random.nextInt(list.length)];
    return await applyWallpaper(wallpaper);
  }

  Future<bool> applyWallpaper(Wallpaper wallpaper) async {
    // Download if needed
    String? localPath = wallpaper.localPath;
    if (localPath == null) {
      localPath = await _storage.downloadWallpaper(wallpaper);
      if (localPath == null) return false;
    }

    final success = await _setter.setWallpaper(localPath);
    if (success) {
      // Update cache metadata
      final cache = await _storage.loadCache();
      final updated = wallpaper.copyWith(
        localPath: localPath,
        appliedAt: DateTime.now(),
      );
      
      final index = cache.indexWhere((w) => w.id == updated.id);
      if (index != -1) {
        cache[index] = updated;
      } else {
        cache.insert(0, updated);
      }
      
      await _storage.saveCache(cache);
    }
    return success;
  }
}
