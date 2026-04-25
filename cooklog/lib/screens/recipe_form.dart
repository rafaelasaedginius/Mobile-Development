import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/auth_service.dart';
import '../services/recipe_service.dart';
import '../services/image_service.dart';
import '../services/notification_service.dart';

class RecipeFormScreen extends StatefulWidget {
  const RecipeFormScreen({super.key});

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final RecipeService _recipeService = RecipeService();
  final AuthService _authService = AuthService();
  final ImageService _imageService = ImageService();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ingredientController = TextEditingController();
  final _stepController = TextEditingController();

  List<String> _ingredients = [];
  List<String> _steps = [];
  bool _isLoading = false;
  bool _isEdit = false;
  String? _recipeId;

  File? _imageFile;
  String? _existingImageUrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map) {
      _isEdit = true;
      _recipeId = args['recipeId'];
      _titleController.text = args['title'] ?? '';
      _descriptionController.text = args['description'] ?? '';
      _ingredients = List<String>.from(args['ingredients'] ?? []);
      _steps = List<String>.from(args['steps'] ?? []);
      _existingImageUrl = args['imageUrl'];
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFFE0CC),
                  child: Icon(Icons.photo_library, color: Color(0xFFE8733A)),
                ),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final file = await _imageService.pickFromGallery();
                  if (file != null) setState(() => _imageFile = file);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFFE0CC),
                  child: Icon(Icons.camera_alt, color: Color(0xFFE8733A)),
                ),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final file = await _imageService.pickFromCamera();
                  if (file != null) setState(() => _imageFile = file);
                },
              ),
              if (_imageFile != null || _existingImageUrl != null)
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFE0CC),
                    child: Icon(Icons.delete, color: Colors.redAccent),
                  ),
                  title: const Text('Remove Photo',
                      style: TextStyle(color: Colors.redAccent)),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _imageFile = null;
                      _existingImageUrl = null;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void addIngredient() {
    if (_ingredientController.text.isEmpty) return;
    setState(() {
      _ingredients.add(_ingredientController.text);
      _ingredientController.clear();
    });
  }

  void removeIngredient(int index) {
    setState(() => _ingredients.removeAt(index));
  }

  void addStep() {
    if (_stepController.text.isEmpty) return;
    setState(() {
      _steps.add(_stepController.text);
      _stepController.clear();
    });
  }

  void removeStep(int index) {
    setState(() => _steps.removeAt(index));
  }

  void save() async {
    if (_titleController.text.isEmpty) return;

    setState(() => _isLoading = true);

    String? imageUrl = _existingImageUrl;
    if (_imageFile != null) {
      imageUrl = await _imageService.uploadImage(_imageFile!, 'recipes');
    }

    final recipe = RecipeModel(
      recipeId: _recipeId ?? '',
      title: _titleController.text,
      description: _descriptionController.text,
      imageUrl: imageUrl,
      ingredients: _ingredients,
      steps: _steps,
      authorId: _authService.getCurrentUserId() ?? '',
      authorName: _authService.getCurrentUserName() ?? '',
      createdAt: Timestamp.now(),
    );

    if (_isEdit) {
      await _recipeService.updateRecipe(_recipeId!, recipe);
    } else {
      await _recipeService.addRecipe(recipe);
      await NotificationService().showRecipeAddedNotification(recipe.title);
    }

    setState(() => _isLoading = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8733A),
        title: Text(
          _isEdit ? 'Edit Recipe' : 'Add Recipe',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _showImageSourceSheet,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFFE8733A), width: 1.5),
                ),
                clipBehavior: Clip.hardEdge,
                child: _imageFile != null
                    ? Image.file(_imageFile!, fit: BoxFit.cover)
                    : _existingImageUrl != null
                    ? Image.network(_existingImageUrl!, fit: BoxFit.cover)
                    : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo,
                        color: Color(0xFFE8733A), size: 40),
                    SizedBox(height: 8),
                    Text('Tap to add photo',
                        style: TextStyle(color: Color(0xFFE8733A))),
                    SizedBox(height: 4),
                    Text('Gallery or Camera',
                        style: TextStyle(
                            fontSize: 12, color: Colors.black38)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Title',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Recipe title',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text('Description',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Short description',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text('Ingredients',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ingredientController,
                    decoration: InputDecoration(
                      hintText: 'Add ingredient',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: addIngredient,
                  icon: const Icon(Icons.add_circle,
                      color: Color(0xFFE8733A), size: 32),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...List.generate(
              _ingredients.length,
                  (index) => ListTile(
                dense: true,
                leading: const Icon(Icons.circle,
                    size: 8, color: Color(0xFFE8733A)),
                title: Text(_ingredients[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.close,
                      size: 18, color: Colors.black38),
                  onPressed: () => removeIngredient(index),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text('Steps',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _stepController,
                    decoration: InputDecoration(
                      hintText: 'Add step',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: addStep,
                  icon: const Icon(Icons.add_circle,
                      color: Color(0xFFE8733A), size: 32),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...List.generate(
              _steps.length,
                  (index) => ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 10,
                  backgroundColor: const Color(0xFFE8733A),
                  child: Text('${index + 1}',
                      style: const TextStyle(
                          fontSize: 10, color: Colors.white)),
                ),
                title: Text(_steps[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.close,
                      size: 18, color: Colors.black38),
                  onPressed: () => removeStep(index),
                ),
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8733A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2)
                    : Text(
                  _isEdit ? 'Update Recipe' : 'Save Recipe',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}