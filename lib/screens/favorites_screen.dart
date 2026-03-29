import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/wallpaper_card.dart';
import '../widgets/preview_dialog.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
      ),
      body: state.favoritesList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_border, size: 64, color: Colors.blueGrey),
                  const SizedBox(height: 16),
                  const Text('No favorites yet'),
                  TextButton(
                    onPressed: () {
                      // Navigate back to Browse or just show a message
                    },
                    child: const Text('Browse Wallpapers'),
                  ),
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
              itemCount: state.favoritesList.length,
              itemBuilder: (context, index) {
                final wallpaper = state.favoritesList[index];
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
