import '../../../model/artists/artist.dart';
import '../../../model/artists/comment.dart';
import '../../../model/songs/song.dart';

abstract class ArtistRepository {
  Future<List<Artist>> fetchArtists();
  
  Future<Artist?> fetchArtistById(String id);

  Future<List<Song>> fetchArtistSongs(String artistId);

  Future<List<Comment>> fetchArtistComments(String artistId);

  Future<Comment> postArtistComment({
    required String artistId,
    required String message,
  });
}
