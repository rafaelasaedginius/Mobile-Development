import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteService {
  final CollectionReference _favorites = FirebaseFirestore.instance.collection('favorites');

  Future<void> addFavorite(String userId, String recipeId) async {
    await _favorites.add({
      'userId': userId,
      'recipeId': recipeId,
      'addedAt': Timestamp.now(),
    });
  }
  Stream<QuerySnapshot> getFavorites(String userId){
    return _favorites
        .where('userId', isEqualTo: userId)
        .orderBy('addedAt', descending:true)
        .snapshots();
  }
  Future<void> deleteFavorite(String id) async {
    await _favorites.doc(id).delete();
  }
  Future<bool> isfavorite(String userId, String recipeId) async{
    final isFavorites = await _favorites
        .where('userId', isEqualTo: userId)
        .where('recipeId', isEqualTo: recipeId)
        .get();
    return isFavorites.docs.isNotEmpty;
  }
}