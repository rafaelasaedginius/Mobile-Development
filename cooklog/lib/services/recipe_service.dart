import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe_model.dart';

class RecipeService {
  final CollectionReference _recipes = FirebaseFirestore.instance.collection('recipes');

  Future<void> addRecipe(RecipeModel recipe) async{
    await _recipes.add(recipe.toMap());
  }
  Stream<QuerySnapshot> getAllRecipe(){
    return _recipes.orderBy('createdAt', descending:true).snapshots();
  }
  Stream<QuerySnapshot> getMyRecipe(String userId){
    return _recipes
    .where('authorId', isEqualTo:userId)
    .orderBy('createdAt', descending:true)
    .snapshots();
  }
  Future<void> updateRecipe(String id, RecipeModel recipe) async {
    await _recipes.doc(id).update(recipe.toMap());
  }
  Future<void> deleteRecipe(String id) async {
    await _recipes.doc(id).delete();
    final favorites = await FirebaseFirestore.instance
        .collection('favorites')
        .where('recipeId', isEqualTo: id)
        .get();

    for (final doc in favorites.docs) {
      await doc.reference.delete();
    }
  }

  Future<Map<String, dynamic>?> getRecipeById(String id) async {
    final doc = await _recipes.doc(id).get();
    if(!doc.exists) return null;
    return doc.data() as Map<String, dynamic>;
  }
}