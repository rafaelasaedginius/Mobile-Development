import 'package:flutter/material.dart';
import '../services/recipe_service.dart';
import '../services/favorite_service.dart';
import '../services/auth_service.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final RecipeService _recipeService = RecipeService();
  final FavoriteService _favoriteService = FavoriteService();
  final AuthService _authService = AuthService();

  bool _isFavorite = false;
  String? _favoriteId;
  String? _recipeId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _recipeId = ModalRoute.of(context)?.settings.arguments as String?;
    if (_recipeId != null) checkFavorite();
  }

  void checkFavorite() async {
    final userId = _authService.getCurrentUserId();
    if (userId == null || _recipeId == null) return;

    final snapshot = await _favoriteService.getFavoriteDoc(userId, _recipeId!);
    if (snapshot != null) {
      setState(() {
        _isFavorite = true;
        _favoriteId = snapshot;
      });
    } else {
      setState(() {
        _isFavorite = false;
        _favoriteId = null;
      });
    }
  }

  void toggleFavorite(String userId) async {
    if (_isFavorite && _favoriteId != null) {
      await _favoriteService.deleteFavorite(_favoriteId!);
      setState(() {
        _isFavorite = false;
        _favoriteId = null;
      });
    } else {
      final docRef = await _favoriteService.addFavorite(userId, _recipeId!);
      setState(() {
        _isFavorite = true;
        _favoriteId = docRef;
      });
    }
  }

  void navigateEdit(Map<String, dynamic> data) {
    Navigator.pushNamed(context, 'recipe_form', arguments: {
      'recipeId': _recipeId,
      'title': data['title'],
      'description': data['description'],
      'ingredients': data['ingredients'],
      'steps': data['steps'],
      'imageUrl': data['imageUrl'],
    });
  }

  void deleteRecipe() async {
    await _recipeService.deleteRecipe(_recipeId!);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final userId = _authService.getCurrentUserId();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _recipeService.getRecipeById(_recipeId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFFE8733A)));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Recipe not found'));
          }

          final data = snapshot.data!;
          final List ingredients = data['ingredients'] ?? [];
          final List steps = data['steps'] ?? [];
          final bool isOwner = data['authorId'] == userId;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: const Color(0xFFE8733A),
                iconTheme: const IconThemeData(color: Colors.white),
                actions: [
                  if (isOwner) ...[
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () => navigateEdit(data),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: deleteRecipe,
                    ),
                  ],
                  IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_outline,
                      color: Colors.white,
                    ),
                    onPressed: userId != null
                        ? () => toggleFavorite(userId)
                        : null,
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: data['imageUrl'] != null
                      ? Image.network(data['imageUrl'], fit: BoxFit.cover)
                      : Container(
                    color: const Color(0xFFFFE0CC),
                    child: const Center(
                      child: Icon(Icons.restaurant,
                          size: 80, color: Color(0xFFE8733A)),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'] ?? '',
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2D2D)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'by ${data['authorName'] ?? ''}',
                        style: const TextStyle(
                            color: Colors.black45, fontSize: 13),
                      ),
                      if (data['description'] != null) ...[
                        const SizedBox(height: 16),
                        Text(data['description'],
                            style: const TextStyle(
                                fontSize: 14, color: Color(0xFF555555))),
                      ],
                      const SizedBox(height: 24),
                      const Text('Ingredients',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE8733A))),
                      const SizedBox(height: 12),
                      ...ingredients.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.circle,
                                size: 8, color: Color(0xFFE8733A)),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Text(item,
                                    style: const TextStyle(fontSize: 14))),
                          ],
                        ),
                      )),
                      const SizedBox(height: 24),
                      const Text('Steps',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE8733A))),
                      const SizedBox(height: 12),
                      ...steps.asMap().entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: const Color(0xFFE8733A),
                              child: Text('${entry.key + 1}',
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.white)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Text(entry.value,
                                    style:
                                    const TextStyle(fontSize: 14))),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}