import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../model/songs/song.dart';
import '../../states/settings_state.dart';

class SongTile extends StatelessWidget {
  const SongTile({
    super.key,
    required this.song,
    required this.subtitle,
    required this.likeCount,
    required this.isLiked,
    required this.onFavorite,
    required this.isPlaying,
    required this.onTap,
  });

  final Song song;
  final String subtitle;
  final int likeCount;
  final bool isLiked;
  final VoidCallback onFavorite;
  final bool isPlaying;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    
    // Read the global state to get the theme color for the like button
    final settingsState = context.watch<AppSettingsState>();
    final Color themeColor = settingsState.theme.color;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15)
        ),
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            backgroundImage: NetworkImage(song.imageUri.toString()),
          ),
          title: Text(song.title),
          subtitle: Text('$subtitle  ·  $likeCount likes'),
          trailing: IconButton(
            onPressed: onFavorite,
            icon: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked
                  ? themeColor
                  : themeColor.withValues(alpha: 0.6),
            ),
          ),
          selected: isPlaying,
          selectedTileColor: Colors.amber.withValues(alpha: 0.08),
        ),
      ),
    );
  }
}
