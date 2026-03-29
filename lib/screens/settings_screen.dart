import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/wallpaper.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader(context, 'Auto-set Wallpaper Source'),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Which source to use when automatically changing the wallpaper.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Card(
            child: Column(
              children: [
                RadioListTile<WallpaperSource>(
                  title: const Text('Bing (Peapix)'),
                  value: WallpaperSource.peapixBing,
                  groupValue: state.source,
                  onChanged: (v) => state.setSource(v!),
                ),
                RadioListTile<WallpaperSource>(
                  title: const Text('Spotlight (Peapix)'),
                  value: WallpaperSource.peapixSpotlight,
                  groupValue: state.source,
                  onChanged: (v) => state.setSource(v!),
                ),
                RadioListTile<WallpaperSource>(
                  title: const Text('Bing (Biturl)'),
                  value: WallpaperSource.biturlBing,
                  groupValue: state.source,
                  onChanged: (v) => state.setSource(v!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (state.source == WallpaperSource.peapixBing) ...[
            _buildSectionHeader(context, 'Region (Bing Only)'),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: state.country,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'au', child: Text('Australia')),
                      DropdownMenuItem(value: 'br', child: Text('Brazil')),
                      DropdownMenuItem(value: 'ca', child: Text('Canada')),
                      DropdownMenuItem(value: 'cn', child: Text('China')),
                      DropdownMenuItem(value: 'de', child: Text('Germany')),
                      DropdownMenuItem(value: 'fr', child: Text('France')),
                      DropdownMenuItem(value: 'in', child: Text('India')),
                      DropdownMenuItem(value: 'it', child: Text('Italy')),
                      DropdownMenuItem(value: 'jp', child: Text('Japan')),
                      DropdownMenuItem(value: 'es', child: Text('Spain')),
                      DropdownMenuItem(value: 'gb', child: Text('United Kingdom')),
                      DropdownMenuItem(value: 'us', child: Text('United States')),
                    ],
                    onChanged: (v) => state.setCountry(v!),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          _buildSectionHeader(context, 'Automation'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Auto-change Wallpaper'),
                  subtitle: const Text('Changes wallpaper periodically in the background'),
                  value: state.autoChange,
                  onChanged: (v) => state.toggleAutoChange(v),
                ),
                if (state.autoChange)
                  ListTile(
                    title: const Text('Change period'),
                    subtitle: Text('${state.periodMinutes} minutes'),
                    trailing: const Icon(Icons.timer),
                    onTap: () async {
                      final period = await _showPeriodDialog(context, state.periodMinutes);
                      if (period != null) {
                        state.setPeriodMinutes(period);
                      }
                    },
                  ),
                SwitchListTile(
                  title: const Text('Auto-start with OS'),
                  subtitle: const Text('Launch app when system starts'),
                  value: state.autoStart,
                  onChanged: (v) => state.toggleAutoStart(v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Future<int?> _showPeriodDialog(BuildContext context, int current) {
    return showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Change Period'),
        children: [
          _periodOption(context, '15 Minutes', 15),
          _periodOption(context, '30 Minutes', 30),
          _periodOption(context, '1 Hour', 60),
          _periodOption(context, '6 Hours', 360),
          _periodOption(context, '12 Hours', 720),
          _periodOption(context, '24 Hours', 1440),
        ],
      ),
    );
  }

  Widget _periodOption(BuildContext context, String label, int minutes) {
    return SimpleDialogOption(
      onPressed: () => Navigator.pop(context, minutes),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(label),
      ),
    );
  }
}
