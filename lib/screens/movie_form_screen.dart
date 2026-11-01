import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../core/supabase_storage_service.dart';
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
  late TextEditingController _descriptionController;

  XFile? _selectedImage;
  Uint8List? _imageBytes;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _directorController = TextEditingController();
    _yearController = TextEditingController();
    _genreController = TextEditingController();
    _ratingController = TextEditingController(text: '8.0');
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _directorController.dispose();
    _yearController.dispose();
    _genreController.dispose();
    _ratingController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImage = pickedFile;
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _saveMovie() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImage == null || _imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccioná una imagen para la película'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // 1. Subir imagen a Supabase Storage (compatible con Web y Móvil)
      final imageUrl = await SupabaseStorageService.uploadImage(
        bytes: _imageBytes!,
        fileName: _selectedImage!.name,
        mimeType: _selectedImage!.mimeType,
      );

      // 2. Solo si la imagen se subió exitosamente,
      //    crear el objeto Movie y guardarlo en Firebase
      final title = _titleController.text.trim();
      final director = _directorController.text.trim();
      final year =
          int.tryParse(_yearController.text.trim()) ?? DateTime.now().year;
      final genre = _genreController.text.trim();
      final rating = double.tryParse(_ratingController.text.trim()) ?? 0.0;
      final description = _descriptionController.text.trim();

      final newMovie = Movie(
        id: const Uuid().v4(),
        title: title,
        director: director,
        year: year,
        genre: genre,
        rating: rating,
        imageUrl: imageUrl,
        description: description,
        disabled: false,
      );
      await ref.read(movieProvider.notifier).addMovie(newMovie);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Película "$title" agregada exitosamente'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir la imagen: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
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

              // Selector de imagen
              OutlinedButton.icon(
                onPressed: _isUploading ? null : _pickImage,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(
                  _selectedImage == null
                      ? 'Seleccionar imagen del dispositivo'
                      : 'Cambiar imagen',
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(
                    color: _selectedImage == null
                        ? Colors.deepPurple
                        : Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Vista previa de imagen seleccionada (Compatible con Web y Móvil)
              if (_imageBytes != null)
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 120,
                        height: 180,
                        child: Image.memory(
                          _imageBytes!,
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
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle,
                                color: Colors.green, size: 28),
                            const SizedBox(height: 8),
                            const Text(
                              'Imagen seleccionada',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Se subirá al guardar la película',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
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

              // Botón Guardar (con indicador de carga)
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _saveMovie,
                icon: _isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _isUploading
                      ? 'Subiendo imagen y guardando...'
                      : 'Registrar Película',
                  style: const TextStyle(
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
