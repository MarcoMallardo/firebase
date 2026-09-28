import 'package:cloud_firestore/cloud_firestore.dart';

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

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'director': director,
      'year': year,
      'genre': genre,
      'rating': rating,
    };
  }

  static Movie fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Movie(
      id: data?['id'] ?? '',
      title: data?['title'] ?? '',
      description: data?['description'] ?? '',
      imageUrl: data?['imageUrl'] ?? '',
      director: data?['director'] ?? '',
      year: data?['year'] ?? 0,
      genre: data?['genre'] ?? '',
      rating: (data?['rating'] ?? 0.0).toDouble(),
    );
  }
}
