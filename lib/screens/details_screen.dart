import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../entities/movie.dart';
import '../providers/movie_provider.dart';

class DetailsScreen extends ConsumerWidget {
  final Movie initialMovie;

  const DetailsScreen({super.key, required this.initialMovie});

  void _confirmDelete(BuildContext context, WidgetRef ref, Movie movie) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Película'),
        content: Text('¿Deseas eliminar "${movie.title}" de tu lista?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              ref.read(movieProvider.notifier).deleteMovie(movie.id);
              Navigator.of(dialogContext).pop();
              context.pop(); // Vuelve al HomeScreen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Película "${movie.title}" eliminada con éxito'),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtenemos la versión reactiva más reciente de la película desde Riverpod
    final movies = ref.watch(movieProvider);
    final movie = movies.cast<Movie?>().firstWhere(
          (m) => m?.id == initialMovie.id,
          orElse: () => null,
        );

    // Si la película ya fue eliminada, mostramos un mensaje o volvemos
    if (movie == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle')),
        body: const Center(child: Text('La película ya no existe.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
        actions: [
          IconButton(
            tooltip: 'Editar',
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push('/edit', extra: movie);
            },
          ),
          IconButton(
            tooltip: 'Eliminar',
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () => _confirmDelete(context, ref, movie),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner / Poster de la película
            Container(
              height: 320,
              color: Colors.black12,
              child: Image.network(
                movie.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.movie, size: 80, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Imagen no disponible',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título principal
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Chips informativos: Año, Género, Calificación
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.calendar_today, size: 16),
                        label: Text('Año: ${movie.year}'),
                        backgroundColor: Colors.deepPurple.shade50,
                      ),
                      Chip(
                        avatar: const Icon(Icons.category, size: 16),
                        label: Text(movie.genre),
                        backgroundColor: Colors.deepPurple.shade50,
                      ),
                      Chip(
                        avatar: const Icon(Icons.star, color: Colors.amber, size: 18),
                        label: Text(
                          '${movie.rating.toStringAsFixed(1)} / 10',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: Colors.amber.shade50,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Director
                  Row(
                    children: [
                      const Icon(Icons.person_pin, color: Colors.deepPurple),
                      const SizedBox(width: 8),
                      Text(
                        'Director: ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          movie.director,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // Sinopsis / Descripción
                  const Text(
                    'Sinopsis:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.description,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Botones de acción inferiores
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context.push('/edit', extra: movie);
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Editar Película'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _confirmDelete(context, ref, movie),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Eliminar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
