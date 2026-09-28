import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/movie.dart';

final movieProvider = StateNotifierProvider<MovieNotifier, List<Movie>>((ref) {
  return MovieNotifier(FirebaseFirestore.instance);
});

class MovieNotifier extends StateNotifier<List<Movie>> {
  final FirebaseFirestore db;

  MovieNotifier(this.db) : super([]);

  Future<void> loadMovies() async {
    final docs = db.collection('movies').withConverter(
          fromFirestore: Movie.fromFirestore,
          toFirestore: (Movie movie, _) => movie.toFirestore(),
        );
    final movies = await docs.get();
    state = movies.docs.map((d) => d.data()).toList();
  }

  Future<void> addMovie(Movie movie) async {
    final docRef = db.collection('movies').doc(movie.id);
    try {
      await docRef.set(movie.toFirestore());
      await loadMovies(); // Refresh list to get the actual state from DB
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteMovie(String id) async {
    try {
      await db.collection('movies').doc(id).delete();
      await loadMovies(); // Refresh list
    } catch (e) {
      print(e);
    }
  }
}

