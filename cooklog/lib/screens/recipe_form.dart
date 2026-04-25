import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/auth_service.dart';
import '../services/recipe_service.dart';
import '../services/notification_service.dart';

class RecipeFormScreen extends StatefulWidget {
  const RecipeFormScreen({super.key});

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final RecipeService _recipeService = RecipeService();
  final AuthService _authService = AuthService();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ingredientController = TextEditingController();
  final _stepController = TextEditingController();

  List<String> _ingredients = [];
  List<String> _steps = [];
  bool _isLoading = false;
  bool _isEdit = false;
  String? _recipeId;

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
    }
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

    final recipe = RecipeModel(
      recipeId: _recipeId ?? '',
      title: _titleController.text,
      description: _descriptionController.text,
      imageUrl: null,
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
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Title', style: TextStyle(fontWeight: FontWeight.w600)),
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
            const Text('Description', style: TextStyle(fontWeight: FontWeight.w600)),
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
            const Text('Ingredients', style: TextStyle(fontWeight: FontWeight.w600)),
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
                  icon: const Icon(Icons.add_circle, color: Color(0xFFE8733A), size: 32),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...List.generate(_ingredients.length, (index) => ListTile(
              dense: true,
              leading: const Icon(Icons.circle, size: 8, color: Color(0xFFE8733A)),
              title: Text(_ingredients[index]),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 18, color: Colors.black38),
                onPressed: () => removeIngredient(index),
              ),
            )),
            const SizedBox(height: 16),
            const Text('Steps', style: TextStyle(fontWeight: FontWeight.w600)),
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
                  icon: const Icon(Icons.add_circle, color: Color(0xFFE8733A), size: 32),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...List.generate(_steps.length, (index) => ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 10,
                backgroundColor: const Color(0xFFE8733A),
                child: Text('${index + 1}', style: const TextStyle(fontSize: 10, color: Colors.white)),
              ),
              title: Text(_steps[index]),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 18, color: Colors.black38),
                onPressed: () => removeStep(index),
              ),
            )),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8733A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : Text(
                  _isEdit ? 'Update Recipe' : 'Save Recipe',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}