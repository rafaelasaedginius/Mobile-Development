import 'package:flutter/material.dart';
import '../services/favorite_service.dart';
import '../services/recipe_service.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // QuerySnapshot

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final FavoriteService _favoriteService = FavoriteService();
  final RecipeService _recipeService = RecipeService();
  final AuthService _authService = AuthService();
  int _currentIndex = 2;

  void navigateRecipeDetail(String recipeId) {
    Navigator.pushNamed(context, 'recipe_detail', arguments: recipeId);
  }

  void deleteFavorite(String favoriteId) async {
    await _favoriteService.deleteFavorite(favoriteId);
  }

  void onTabTapped(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, 'home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, 'my_recipe');
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
          'Favorite Recipes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
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
        stream: _favoriteService.getFavorites(userId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final favorites = snapshot.data!.docs;
            if (favorites.isEmpty) {
              return const Center(child: Text('No favorite recipes yet!'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final favoriteData =
                favorites[index].data() as Map<String, dynamic>;
                final favoriteId = favorites[index].id;
                final recipeId = favoriteData['recipeId'] as String;

                // Fetch recipe detail by recipeId
                return FutureBuilder<Map<String, dynamic>?>(
                  future: _recipeService.getRecipeById(recipeId),
                  builder: (context, recipeSnapshot) {
                    if (recipeSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Card(
                        margin: EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: SizedBox(
                            width: 56,
                            height: 56,
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFFE8733A)),
                            ),
                          ),
                          title: Text('Loading...'),
                        ),
                      );
                    }

                    if (!recipeSnapshot.hasData || recipeSnapshot.data == null) {
                      return const SizedBox.shrink();
                    }

                    final data = recipeSnapshot.data!;

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
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black45),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.favorite,
                              color: Color(0xFFE8733A)),
                          onPressed: () => deleteFavorite(favoriteId),
                          tooltip: 'Remove from favorites',
                        ),
                        onTap: () => navigateRecipeDetail(recipeId),
                      ),
                    );
                  },
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