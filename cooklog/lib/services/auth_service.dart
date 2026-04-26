import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _users =
  FirebaseFirestore.instance.collection('users');

  Future<void> register(String name, String email, String password) async {
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user!.updateDisplayName(name);
    UserModel newUser = UserModel(
      userId: credential.user!.uid,
      name: name,
      email: email,
      photoUrl: null,
    );
    await _users.doc(credential.user!.uid).set(newUser.toMap());
  }
  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
  Future<void> logout() async {
    await _auth.signOut();
  }
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }
  Future<UserModel?> getCurrentUserData() async {
    String? uid = getCurrentUserId();
    if (uid == null) return null;
    DocumentSnapshot doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }
  String? getCurrentUserName() {
    return _auth.currentUser?.displayName;
  }

  Future<void> updateProfile({required String name, String? photoUrl}) async {
    final userId = getCurrentUserId();
    if (userId == null) return;
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'name': name,
      'photoUrl': photoUrl,
    });
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}