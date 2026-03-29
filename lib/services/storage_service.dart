import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/wallpaper.dart';

class StorageService {
  static const String _favoritesFile = 'favorites.json';
  static const String _cacheFile = 'cache.json';
  
  static const String _settingSource = 'source';
  static const String _settingCountry = 'country';
  static const String _settingPeriod = 'period_minutes';
  static const String _settingAutoChange = 'auto_change';
  static const String _settingAutoStart = 'auto_start';

  final SharedPreferences _prefs;
  final Directory _appDir;

  StorageService(this._prefs, this._appDir);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    final appDir = await getApplicationSupportDirectory();
    if (!appDir.existsSync()) {
      appDir.createSync(recursive: true);
    }
    return StorageService(prefs, appDir);
  }

  // --- Settings ---

  WallpaperSource get source => WallpaperSource.values[_prefs.getInt(_settingSource) ?? 0];
  set source(WallpaperSource value) => _prefs.setInt(_settingSource, value.index);

  String get country => _prefs.getString(_settingCountry) ?? 'us';
  set country(String value) => _prefs.setString(_settingCountry, value);

  int get periodMinutes => _prefs.getInt(_settingPeriod) ?? 60;
  set periodMinutes(int value) => _prefs.setInt(_settingPeriod, value);

  bool get autoChange => _prefs.getBool(_settingAutoChange) ?? false;
  set autoChange(bool value) => _prefs.setBool(_settingAutoChange, value);

  bool get autoStart => _prefs.getBool(_settingAutoStart) ?? false;
  set autoStart(bool value) => _prefs.setBool(_settingAutoStart, value);

  // --- Favorites ---

  Future<List<Wallpaper>> loadFavorites() async {
    final file = File(p.join(_appDir.path, _favoritesFile));
    if (!file.existsSync()) return [];
    try {
      final String content = await file.readAsString();
      final List<dynamic> jsonList = json.decode(content);
      return jsonList.map((j) => Wallpaper.fromJson(j)).toList();
    } catch (e) {
      print('Error loading favorites: $e');
      return [];
    }
  }

  Future<void> saveFavorites(List<Wallpaper> favorites) async {
    final file = File(p.join(_appDir.path, _favoritesFile));
    final String content = json.encode(favorites.map((f) => f.toJson()).toList());
    await file.writeAsString(content);
  }

  // --- Cache & Persistence ---

  Future<List<Wallpaper>> loadCache() async {
    final file = File(p.join(_appDir.path, _cacheFile));
    if (!file.existsSync()) return [];
    try {
      final String content = await file.readAsString();
      final List<dynamic> jsonList = json.decode(content);
      return jsonList.map((j) => Wallpaper.fromJson(j)).toList();
    } catch (e) {
      print('Error loading cache: $e');
      return [];
    }
  }

  Future<void> saveCache(List<Wallpaper> cache) async {
    final file = File(p.join(_appDir.path, _cacheFile));
    final String content = json.encode(cache.map((w) => w.toJson()).toList());
    await file.writeAsString(content);
  }

  Future<String?> downloadWallpaper(Wallpaper wallpaper) async {
    try {
      final response = await http.get(Uri.parse(wallpaper.fullUrl));
      if (response.statusCode == 200) {
        final fileName = '${wallpaper.id}${p.extension(wallpaper.fullUrl).isEmpty ? '.jpg' : p.extension(wallpaper.fullUrl)}';
        final filePath = p.join(_appDir.path, 'wallpapers', fileName);
        
        final file = File(filePath);
        if (!file.parent.existsSync()) {
          file.parent.createSync(recursive: true);
        }
        
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      }
    } catch (e) {
      print('Error downloading wallpaper: $e');
    }
    return null;
  }
}
