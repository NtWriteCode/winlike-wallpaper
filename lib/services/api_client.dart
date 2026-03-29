import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wallpaper.dart';

class ApiClient {
  static const String _peapixBingUrl = 'https://peapix.com/bing/feed';
  static const String _peapixSpotlightUrl = 'https://peapix.com/spotlight/feed';
  static const String _biturlBingUrl = 'https://bing.biturl.top';

  Future<List<Wallpaper>> fetchPeapixBing({String country = 'us', int n = 10}) async {
    try {
      final response = await http.get(Uri.parse('$_peapixBingUrl?country=$country&n=$n'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Wallpaper.fromPeapix(item, WallpaperSource.peapixBing)).toList();
      }
    } catch (e) {
      print('Error fetching Peapix Bing: $e');
    }
    return [];
  }

  Future<List<Wallpaper>> fetchPeapixSpotlight({int n = 10}) async {
    try {
      final response = await http.get(Uri.parse('$_peapixSpotlightUrl?n=$n'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Wallpaper.fromPeapix(item, WallpaperSource.peapixSpotlight)).toList();
      }
    } catch (e) {
      print('Error fetching Peapix Spotlight: $e');
    }
    return [];
  }

  Future<Wallpaper?> fetchBiturlBing({String resolution = 'UHD', String mkt = 'zh-CN'}) async {
    try {
      final response = await http.get(Uri.parse('$_biturlBingUrl/?resolution=$resolution&format=json&mkt=$mkt'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Wallpaper.fromBiturl(data);
      }
    } catch (e) {
      print('Error fetching Biturl Bing: $e');
    }
    return null;
  }
}
