import 'package:flutter/material.dart';
import '../services/recipe_service.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyRecipeScreen extends StatefulWidget {
  const MyRecipeScreen({super.key});

  @override
  State<MyRecipeScreen> createState() => _MyRecipeScreenState();
}

class _MyRecipeScreenState extends State<MyRecipeScreen> {
  final RecipeService _recipeService = RecipeService();
  final AuthService _authService = AuthService();
  int _currentIndex = 1;

  void navigateRecipeDetail(String recipeId) {
    Navigator.pushNamed(context, 'recipe_detail', arguments: recipeId);
  }

  void navigateRecipeForm() {
    Navigator.pushNamed(context, 'recipe_form');
  }

  void deleteRecipe(String id) async {
    await _recipeService.deleteRecipe(id);
  }

  void onTabTapped(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, 'home');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, 'favorite');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, 'profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = _authService.getCurrentUserId() ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8733A),
        title: const Text(
          'My Recipes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE8733A),
        onPressed: navigateRecipeForm,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFFE8733A),
        unselectedItemColor: Colors.black38,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: onTabTapped,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined), label: 'My Recipe'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline), label: 'Favorite'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _recipeService.getMyRecipe(userId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final recipes = snapshot.data!.docs;
            if (recipes.isEmpty) {
              return const Center(child: Text('No recipes yet, add one!'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final data = recipes[index].data() as Map<String, dynamic>;
                final recipeId = recipes[index].id;

                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: data['imageUrl'] != null
                          ? Image.network(data['imageUrl'],
                          width: 56, height: 56, fit: BoxFit.cover)
                          : Container(
                        width: 56,
                        height: 56,
                        color: const Color(0xFFFFE0CC),
                        child: const Icon(Icons.restaurant,
                            color: Color(0xFFE8733A)),
                      ),
                    ),
                    title: Text(
                      data['title'] ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Text(
                      data['description'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                      const TextStyle(fontSize: 12, color: Colors.black45),
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                            value: 'delete', child: Text('Delete')),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.pushNamed(context, 'recipe_form',
                              arguments: {
                                'recipeId': recipeId,
                                'title': data['title'],
                                'description': data['description'],
                                'ingredients': data['ingredients'],
                                'steps': data['steps'],
                              });
                        } else if (value == 'delete') {
                          deleteRecipe(recipeId);
                        }
                      },
                    ),
                    onTap: () => navigateRecipeDetail(recipeId),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE8733A)));
        },
      ),
    );
  }
}