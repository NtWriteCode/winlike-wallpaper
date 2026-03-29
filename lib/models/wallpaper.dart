import 'package:crypto/crypto.dart';
import 'dart:convert';

enum WallpaperSource {
  peapixBing,
  peapixSpotlight,
  biturlBing,
}

class Wallpaper {
  final String id;
  final String title;
  final String copyright;
  final String fullUrl;
  final String thumbUrl;
  final WallpaperSource source;
  final bool isFavorite;
  final String? localPath;
  final DateTime? appliedAt;

  Wallpaper({
    required this.id,
    required this.title,
    required this.copyright,
    required this.fullUrl,
    required this.thumbUrl,
    required this.source,
    this.isFavorite = false,
    this.localPath,
    this.appliedAt,
  });

  factory Wallpaper.fromPeapix(Map<String, dynamic> json, WallpaperSource source) {
    // Generate a unique ID based on the imageUrl or thumbUrl
    final String urlToHash = json['imageUrl'] ?? json['fullUrl'] ?? '';
    final String id = md5.convert(utf8.encode(urlToHash)).toString();

    return Wallpaper(
      id: id,
      title: json['title'] ?? 'Untitled',
      copyright: json['copyright'] ?? 'Unknown',
      fullUrl: json['fullUrl'] ?? json['imageUrl'] ?? '',
      thumbUrl: json['thumbUrl'] ?? json['imageUrl'] ?? '',
      source: source,
    );
  }

  factory Wallpaper.fromBiturl(Map<String, dynamic> json) {
    final String url = json['url'] ?? '';
    final String id = md5.convert(utf8.encode(url)).toString();
    
    return Wallpaper(
      id: id,
      title: 'Bing Daily Wallpaper', // Biturl doesn't always provide a title
      copyright: json['copyright'] ?? '',
      fullUrl: url,
      thumbUrl: url, // Biturl doesn't provide a separate thumbUrl
      source: WallpaperSource.biturlBing,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'copyright': copyright,
      'fullUrl': fullUrl,
      'thumbUrl': thumbUrl,
      'source': source.index,
      'isFavorite': isFavorite,
      'localPath': localPath,
      'appliedAt': appliedAt?.toIso8601String(),
    };
  }

  factory Wallpaper.fromJson(Map<String, dynamic> json) {
    return Wallpaper(
      id: json['id'],
      title: json['title'],
      copyright: json['copyright'],
      fullUrl: json['fullUrl'],
      thumbUrl: json['thumbUrl'],
      source: WallpaperSource.values[json['source']],
      isFavorite: json['isFavorite'] ?? false,
      localPath: json['localPath'],
      appliedAt: json['appliedAt'] != null ? DateTime.parse(json['appliedAt']) : null,
    );
  }

  Wallpaper copyWith({
    bool? isFavorite,
    String? localPath,
    DateTime? appliedAt,
  }) {
    return Wallpaper(
      id: id,
      title: title,
      copyright: copyright,
      fullUrl: fullUrl,
      thumbUrl: thumbUrl,
      source: source,
      isFavorite: isFavorite ?? this.isFavorite,
      localPath: localPath ?? this.localPath,
      appliedAt: appliedAt ?? this.appliedAt,
    );
  }
}
