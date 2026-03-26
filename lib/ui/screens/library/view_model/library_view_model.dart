import 'package:flutter/material.dart';
import '../../../../data/repositories/artist/artist_repository.dart';
import '../../../../model/artists/artist.dart';
import '../../../../data/repositories/songs/song_repository.dart';
import '../../../states/player_state.dart';
import '../../../../model/songs/song.dart';
import '../../../utils/async_value.dart';

class SongWithArtist {
  final Song song;
  final Artist? artist;

  SongWithArtist({required this.song, required this.artist});

  String get subtitle {
    final String duration = '${song.duration.inMinutes} mins';
    if (artist == null) {
      return '$duration · Unknown artist';
    }
    return '$duration · ${artist!.name} - ${artist!.genre}';
  }
}

class LibraryViewModel extends ChangeNotifier {
  final SongRepository songRepository;
  final ArtistRepository artistRepository;
  final PlayerState playerState;

  AsyncValue<List<SongWithArtist>> songsValue = AsyncValue.loading();

  LibraryViewModel({
    required this.songRepository,
    required this.artistRepository,
    required this.playerState,
  }) {
    playerState.addListener(notifyListeners);

    // init
    _init();
  }

  @override
  void dispose() {
    playerState.removeListener(notifyListeners);
    super.dispose();
  }

  void _init() async {
    fetchSong();
  }

  void fetchSong() async {
    // 1- Loading state
    songsValue = AsyncValue.loading();
    notifyListeners();

    try {
      final results = await Future.wait([
        songRepository.fetchSongs(),
        artistRepository.fetchArtists(),
      ]);

      final List<Song> songs = results[0] as List<Song>;
      final List<Artist> artists = results[1] as List<Artist>;
      final Map<String, Artist> artistsById = {
        for (final artist in artists) artist.id: artist,
      };

      final List<SongWithArtist> songsWithArtists = [];
      for(final song in songs) {
        songsWithArtists.add(SongWithArtist(
          song: song, 
          artist: artistsById[song.artistId]));
      }

      songsValue = AsyncValue.success(songsWithArtists);
    } catch (e) {
      songsValue = AsyncValue.error(e);
    }
     notifyListeners();

  }

  bool isSongPlaying(SongWithArtist songWithArtist) =>
      playerState.currentSong?.id == songWithArtist.song.id;

  void start(SongWithArtist songWithArtist) =>
      playerState.start(songWithArtist.song);
  void stop() => playerState.stop();
}
