import 'package:flutter/material.dart';

import '../../../../data/repositories/artist/artist_repository.dart';
import '../../../../model/artists/comment.dart';
import '../../../../model/songs/song.dart';

class ArtistDetailsViewModel extends ChangeNotifier {
  final ArtistRepository artistRepository;
  final String artistId;

  bool isLoading = false;
  Object? error;
  List<Song> songs = [];
  List<Comment> comments = [];

  ArtistDetailsViewModel({
    required this.artistRepository,
    required this.artistId,
  }) {
    fetchData();
  }

  Future<void> fetchData() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        artistRepository.fetchArtistSongs(artistId),
        artistRepository.fetchArtistComments(artistId),
      ]);

      songs = results[0] as List<Song>;
      comments = results[1] as List<Comment>;
    } catch (e) {
      error = e;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> addComment(String message) async {
    final String trimmed = message.trim();
    if (trimmed.isEmpty) {
      return false;
    }

    try {
      final comment = await artistRepository.postArtistComment(
        artistId: artistId,
        message: trimmed,
      );
      comments = [comment, ...comments];
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}