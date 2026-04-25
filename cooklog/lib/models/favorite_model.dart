import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteModel {
  final String favoriteId;
  final String userId;
  final String recipeId;
  final Timestamp addedAt;

  FavoriteModel ({
    required this.favoriteId,
    required this.userId,
    required this.recipeId,
    required this.addedAt,
  });

  factory FavoriteModel.fromMap(Map<String, dynamic> map, String id){
    return FavoriteModel(
      favoriteId: id,
      userId: map['userId'] ?? '',
      recipeId: map['recipeId'] ?? '',
      addedAt: map['addedAt'] ?? Timestamp.now(),
    );
  }
  Map<String, dynamic> toMap(){
    return{
      'userId': userId,
      'recipeId': recipeId,
      'addedAt': addedAt,
    };
  }
}