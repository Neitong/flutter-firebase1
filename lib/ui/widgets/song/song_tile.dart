import 'package:flutter/material.dart';

import '../../../model/songs/song.dart';

class SongTile extends StatelessWidget {
  const SongTile({
    super.key,
    required this.song,
    required this.subtitle,
    required this.favorite,
    required this.isPlaying,
    required this.isLiked,
    required this.onFavorite,
    required this.onTap,
  });

  final Song song;
  final String subtitle;
  final int favorite;
  final bool isPlaying;
  final bool isLiked;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
          subtitle: Text(subtitle),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$favorite',
                style: TextStyle(color: Colors.blueGrey),
              ),
              SizedBox(width: 6),
              IconButton(
                onPressed: onFavorite,
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.blueGrey,
                ),
              ),
            ],
          ),
          selected: isPlaying,
          selectedTileColor: Colors.amber.withValues(alpha: 0.08),
        ),
      ),
    );
  }
}
