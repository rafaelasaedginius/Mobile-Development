import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeModel{
  final String recipeId;
  final String title;
  final String? description;
  final String? imageUrl;
  final List<String> ingredients;
  final List<String> steps;
  final String authorId;
  final String authorName;
  final Timestamp createdAt;

  RecipeModel({
    required this.recipeId,
    required this.title,
    this.description,
    this.imageUrl,
    required this.ingredients,
    required this.steps,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
  });

  factory RecipeModel.fromMap(Map<String, dynamic> map, String id){
    return RecipeModel(
      recipeId: id,
      title: map['title'] ?? '',
      description: map['description'],
      imageUrl: map['imageUrl'],
      ingredients: List<String>.from(map['ingredients'] ?? []),
      steps: List<String>.from(map['steps'] ?? []),
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'steps': steps,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': createdAt,
    };
  }
}