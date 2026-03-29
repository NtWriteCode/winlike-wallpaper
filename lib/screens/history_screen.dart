import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/wallpaper_card.dart';
import '../widgets/preview_dialog.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Download History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              // Option to clear history/cache could be added here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Clear history not yet implemented')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: state.cacheList.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.blueGrey),
                  SizedBox(height: 16),
                  Text('No history of applied wallpapers yet'),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 5 : 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: state.cacheList.length,
              itemBuilder: (context, index) {
                final wallpaper = state.cacheList[index];
                return WallpaperCard(
                  wallpaper: wallpaper,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => PreviewDialog(wallpaper: wallpaper),
                    );
                  },
                );
              },
            ),
    );
  }
}
