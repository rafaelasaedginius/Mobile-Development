import 'package:flutter/material.dart';
import '../services/recipe_service.dart';
import '../services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RecipeService _recipeService = RecipeService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  int _currentIndex = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, 'login');
    }
  }

  void navigateRecipeForm() {
    Navigator.pushNamed(context, 'recipe_form');
  }

  void navigateRecipeDetail(String recipeId) {
    Navigator.pushNamed(context, 'recipe_detail', arguments: recipeId);
  }

  void onTabTapped(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 1:
        Navigator.pushNamed(context, 'my_recipe');
        break;
      case 2:
        Navigator.pushNamed(context, 'favorite');
        break;
      case 3:
        Navigator.pushNamed(context, 'profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8733A),
        title: const Text(
          'CookLog',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon:
                const Icon(Icons.search, color: Color(0xFFE8733A)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.black38),
                  onPressed: () => _searchController.clear(),
                )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _recipeService.getAllRecipe(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final filtered = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final title =
                    (data['title'] ?? '').toString().toLowerCase();
                    return title.contains(_searchQuery);
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('No recipes found'));
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemBuilder: (context, index) {
                      final data =
                      filtered[index].data() as Map<String, dynamic>;
                      final recipeId = filtered[index].id;

                      return GestureDetector(
                        onTap: () => navigateRecipeDetail(recipeId),
                        child: Card(
                          color: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                child: data['imageUrl'] != null
                                    ? Image.network(
                                  data['imageUrl'],
                                  height: 110,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                                    : Container(
                                  height: 110,
                                  color: const Color(0xFFFFE0CC),
                                  child: const Center(
                                    child: Icon(Icons.restaurant,
                                        color: Color(0xFFE8733A),
                                        size: 40),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['title'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Color(0xFF2D2D2D),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      data['authorName'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.black45,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }
                return const Center(
                    child:
                    CircularProgressIndicator(color: Color(0xFFE8733A)));
              },
            ),
          ),
        ],
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
    );
  }
}