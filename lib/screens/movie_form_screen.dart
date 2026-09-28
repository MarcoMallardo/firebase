import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../entities/movie.dart';
import '../providers/movie_provider.dart';

class MovieFormScreen extends ConsumerStatefulWidget {
  const MovieFormScreen({super.key});

  @override
  ConsumerState<MovieFormScreen> createState() => _MovieFormScreenState();
}

class _MovieFormScreenState extends ConsumerState<MovieFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _directorController;
  late TextEditingController _yearController;
  late TextEditingController _genreController;
  late TextEditingController _ratingController;
  late TextEditingController _imageUrlController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _directorController = TextEditingController();
    _yearController = TextEditingController();
    _genreController = TextEditingController();
    _ratingController = TextEditingController(text: '8.0');
    _imageUrlController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _directorController.dispose();
    _yearController.dispose();
    _genreController.dispose();
    _ratingController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveMovie() {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text.trim();
      final director = _directorController.text.trim();
      final year = int.tryParse(_yearController.text.trim()) ?? DateTime.now().year;
      final genre = _genreController.text.trim();
      final rating = double.tryParse(_ratingController.text.trim()) ?? 0.0;
      final imageUrl = _imageUrlController.text.trim();
      final description = _descriptionController.text.trim();

      // Alta de película
      final newMovie = Movie(
        id: const Uuid().v4(),
        title: title,
        director: director,
        year: year,
        genre: genre,
        rating: rating,
        imageUrl: imageUrl,
        description: description,
      );
      ref.read(movieProvider.notifier).addMovie(newMovie);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Película "$title" agregada exitosamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Película'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título de la película',
                  prefixIcon: Icon(Icons.movie_creation_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El título es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Director
              TextFormField(
                controller: _directorController,
                decoration: const InputDecoration(
                  labelText: 'Director',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El director es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Fila con Año y Calificación
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _yearController,
                      decoration: const InputDecoration(
                        labelText: 'Año de estreno',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Obligatorio';
                        }
                        final parsed = int.tryParse(value.trim());
                        if (parsed == null || parsed < 1888 || parsed > 2100) {
                          return 'Año inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _ratingController,
                      decoration: const InputDecoration(
                        labelText: 'Calificación (0 - 10)',
                        prefixIcon: Icon(Icons.star_outline),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Obligatorio';
                        }
                        final parsed = double.tryParse(value.trim());
                        if (parsed == null || parsed < 0.0 || parsed > 10.0) {
                          return 'Entre 0 y 10';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Género
              TextFormField(
                controller: _genreController,
                decoration: const InputDecoration(
                  labelText: 'Género (ej. Acción, Drama, Comedia)',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El género es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // URL de la Imagen
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: 'URL de la imagen o póster',
                  prefixIcon: const Icon(Icons.image_outlined),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Actualizar vista previa',
                    onPressed: () => setState(() {}),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La URL de la imagen es obligatoria';
                  }
                  if (!value.trim().startsWith('http://') &&
                      !value.trim().startsWith('https://')) {
                    return 'Debe ser una URL válida (http/https)';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),

              // Vista previa de imagen
              if (_imageUrlController.text.trim().isNotEmpty)
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 100,
                        height: 140,
                        child: Image.network(
                          _imageUrlController.text.trim(),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(Icons.broken_image,
                                  color: Colors.redAccent),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Vista previa de portada',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Descripción / Sinopsis
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción / Sinopsis',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La descripción es obligatoria';
                  }
                  if (value.trim().length < 10) {
                    return 'Ingresa una descripción de al menos 10 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),

              // Botón Guardar
              ElevatedButton.icon(
                onPressed: _saveMovie,
                icon: const Icon(Icons.save),
                label: const Text(
                  'Registrar Película',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
