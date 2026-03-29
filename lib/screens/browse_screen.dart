import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/wallpaper.dart';
import '../widgets/wallpaper_card.dart';
import '../widgets/preview_dialog.dart';

class BrowseScreen extends StatelessWidget {
  const BrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Wallpapers'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SegmentedButton<WallpaperSource>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: WallpaperSource.peapixBing,
                  label: Text('Bing (Peapix)'),
                ),
                ButtonSegment(
                  value: WallpaperSource.peapixSpotlight,
                  label: Text('Spotlight (Peapix)'),
                ),
                ButtonSegment(
                  value: WallpaperSource.biturlBing,
                  label: Text('Bing (Biturl)'),
                ),
              ],
              selected: {state.browseSource},
              onSelectionChanged: (newSelection) {
                state.setBrowseSource(newSelection.first);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => state.refreshBrowse(),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, state, child) {
          if (state.isLoading && state.browseList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.browseList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.blueGrey),
                  const SizedBox(height: 16),
                  const Text('No wallpapers found'),
                  TextButton(
                    onPressed: () => state.refreshBrowse(),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => state.refreshBrowse(),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 5 : 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: state.browseList.length,
              itemBuilder: (context, index) {
                final wallpaper = state.browseList[index];
                final bool isFav = state.isFavorite(wallpaper.id);
                final updatedWallpaper = wallpaper.copyWith(isFavorite: isFav);

                return WallpaperCard(
                  wallpaper: updatedWallpaper,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => PreviewDialog(wallpaper: updatedWallpaper),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
