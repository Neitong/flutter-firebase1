import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/artist/artist_repository.dart';
import '../../../model/artists/artist.dart';
import '../../widgets/artist/comment_tile.dart';
import '../../widgets/song/song_tile.dart';
import 'view_model/artist_details_view_model.dart';

class ArtistDetailsScreen extends StatelessWidget {
  const ArtistDetailsScreen({super.key, required this.artist});

  final Artist artist;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ArtistDetailsViewModel(
        artistRepository: context.read<ArtistRepository>(),
        artistId: artist.id,
      ),
      child: _ArtistDetailsView(artist: artist),
    );
  }
}

class _ArtistDetailsView extends StatefulWidget {
  const _ArtistDetailsView({required this.artist});

  final Artist artist;

  @override
  State<_ArtistDetailsView> createState() => _ArtistDetailsViewState();
}

class _ArtistDetailsViewState extends State<_ArtistDetailsView> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ArtistDetailsViewModel>();

    return Scaffold(
      appBar: AppBar(title: Text(widget.artist.name)),
      body: vm.isLoading
          ? Center(child: CircularProgressIndicator())
          : vm.error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'error = ${vm.error}',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 42,
                            backgroundImage: NetworkImage(
                              widget.artist.imageUri.toString(),
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            widget.artist.name,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            widget.artist.genre,
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Songs',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    if (vm.songs.isEmpty)
                      _EmptyState(label: 'No songs for this artist yet.')
                    else
                      ...vm.songs.map(
                        (song) => SongTile(
                          song: song,
                          subtitle: '${song.duration.inMinutes} mins',
                          likeCount: song.likes,
                          // isLiked: false,
                          // onFavorite: () {},
                          isPlaying: false,
                          onTap: () {},
                        ),
                      ),
                    SizedBox(height: 16),
                    Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    if (vm.comments.isEmpty)
                      _EmptyState(label: 'No comments yet. Be the first one!')
                    else
                      ...vm.comments.map((comment) => CommentTile(comment: comment)),
                    SizedBox(height: 96),
                  ],
                ),
      bottomSheet: SafeArea(
        top: false,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Write a comment...',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  final String text = _commentController.text.trim();
                  if (text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Comment cannot be empty')),
                    );
                    return;
                  }

                  final bool success = await context
                      .read<ArtistDetailsViewModel>()
                      .addComment(text);

                  if (success) {
                    _commentController.clear();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to post comment')),
                    );
                  }
                },
                child: Text('Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(color: Colors.black54)),
    );
  }
}