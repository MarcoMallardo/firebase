class Movie {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String director;
  final int year;
  final String genre;
  final double rating;

  Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.director,
    required this.year,
    required this.genre,
    required this.rating,
  });

  Movie copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? director,
    int? year,
    String? genre,
    double? rating,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      director: director ?? this.director,
      year: year ?? this.year,
      genre: genre ?? this.genre,
      rating: rating ?? this.rating,
    );
  }
}
