import 'dart:io';

class WallpaperSetterService {
  Future<bool> setWallpaper(String filePath) async {
    if (Platform.isWindows) {
      return await _setWindowsWallpaper(filePath);
    } else if (Platform.isLinux) {
      return await _setLinuxWallpaper(filePath);
    }
    return false;
  }

  Future<bool> _setWindowsWallpaper(String filePath) async {
    try {
      // Use PowerShell to call SystemParametersInfo
      final command = '''
\$code = @'
using System;
using System.Runtime.InteropServices;
public class WinAPI {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
'@
Add-Type -TypeDefinition \$code
[WinAPI]::SystemParametersInfo(20, 0, "$filePath", 3)
''';
      final result = await Process.run('powershell', ['-Command', command]);
      return result.exitCode == 0;
    } catch (e) {
      print('Error setting Windows wallpaper: $e');
      return false;
    }
  }

  Future<bool> _setLinuxWallpaper(String filePath) async {
    try {
      final desktop = Platform.environment['XDG_CURRENT_DESKTOP']?.toLowerCase() ?? '';
      
      if (desktop.contains('kde')) {
        return await _setKdeWallpaper(filePath);
      } else if (desktop.contains('gnome')) {
        return await _setGnomeWallpaper(filePath);
      } else {
        // Fallback or generic method
        return await _setGnomeWallpaper(filePath); // Many use gsettings
      }
    } catch (e) {
      print('Error setting Linux wallpaper: $e');
      return false;
    }
  }

  Future<bool> _setKdeWallpaper(String filePath) async {
    // Modern KDE (Plasma 5.24+)
    final result = await Process.run('plasma-apply-wallpaperimage', [filePath]);
    if (result.exitCode == 0) return true;

    // Fallback to DBus script for older Plasma or if command fails
    final script = 'var allDesktops = desktops(); for (var i=0; i<allDesktops.length; i++) { var d = allDesktops[i]; d.wallpaperPlugin = "org.kde.image"; d.currentConfigGroup = Array("Wallpaper", "org.kde.image", "General"); d.writeConfig("Image", "file://$filePath"); }';
    final dbusResult = await Process.run('dbus-send', [
      '--session',
      '--dest=org.kde.plasmashell',
      '--type=method_call',
      '/PlasmaShell',
      'org.kde.PlasmaShell.evaluateScript',
      'string:$script'
    ]);
    return dbusResult.exitCode == 0;
  }

  Future<bool> _setGnomeWallpaper(String filePath) async {
    final result = await Process.run('gsettings', [
      'set',
      'org.gnome.desktop.background',
      'picture-uri',
      'file://$filePath'
    ]);
    // Also set dark mode background if applicable
    await Process.run('gsettings', [
      'set',
      'org.gnome.desktop.background',
      'picture-uri-dark',
      'file://$filePath'
    ]);
    return result.exitCode == 0;
  }
}
