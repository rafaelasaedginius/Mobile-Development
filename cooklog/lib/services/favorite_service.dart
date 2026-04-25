import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteService {
  final CollectionReference _favorites =
  FirebaseFirestore.instance.collection('favorites');

  Future<String> addFavorite(String userId, String recipeId) async {
    final doc = await _favorites.add({
      'userId': userId,
      'recipeId': recipeId,
      'addedAt': Timestamp.now(),
    });
    return doc.id;
  }

  Stream<QuerySnapshot> getFavorites(String userId) {
    return _favorites
        .where('userId', isEqualTo: userId)
        .orderBy('addedAt', descending: true)
        .snapshots();
  }

  Future<void> deleteFavorite(String id) async {
    await _favorites.doc(id).delete();
  }

  Future<String?> getFavoriteDoc(String userId, String recipeId) async {
    final snapshot = await _favorites
        .where('userId', isEqualTo: userId)
        .where('recipeId', isEqualTo: recipeId)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.first.id;
  }
}