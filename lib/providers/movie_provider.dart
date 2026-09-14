import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/movie.dart';

class MovieNotifier extends Notifier<List<Movie>> {
  @override
  List<Movie> build() {
    return [
      Movie(
        id: '1',
        title: 'Inception (El Origen)',
        description:
            'Un ladrón que roba secretos corporativos a través del uso de tecnología para compartir sueños recibe la tarea inversa de implantar una idea en la mente de un CEO.',
        imageUrl:
            'https://image.tmdb.org/t/p/w500/edv5CZvWj09upOsy2Y6IwDhK8bt.jpg',
        director: 'Christopher Nolan',
        year: 2010,
        genre: 'Ciencia Ficción / Acción',
        rating: 8.8,
      ),
      Movie(
        id: '2',
        title: 'The Matrix',
        description:
            'Un hacker informático descubre la verdadera naturaleza de su realidad y su papel central en la guerra contra los controladores del mundo simulado.',
        imageUrl:
            'https://image.tmdb.org/t/p/w500/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg',
        director: 'Lana y Lilly Wachowski',
        year: 1999,
        genre: 'Ciencia Ficción / Acción',
        rating: 8.7,
      ),
      Movie(
        id: '3',
        title: 'Interstellar',
        description:
            'Un grupo de exploradores espaciales emprende un viaje a través de un agujero de gusano para asegurar la supervivencia y el futuro de la humanidad.',
        imageUrl:
            'https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
        director: 'Christopher Nolan',
        year: 2014,
        genre: 'Aventura / Drama / Ciencia Ficción',
        rating: 8.7,
      ),
    ];
  }

  void addMovie(Movie movie) {
    state = [...state, movie];
  }

  void editMovie(Movie updatedMovie) {
    state = [
      for (final movie in state)
        if (movie.id == updatedMovie.id) updatedMovie else movie,
    ];
  }

  void deleteMovie(String id) {
    state = state.where((movie) => movie.id != id).toList();
  }
}

final movieProvider = NotifierProvider<MovieNotifier, List<Movie>>(() {
  return MovieNotifier();
});
