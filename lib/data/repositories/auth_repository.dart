import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthRepository {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  AuthRepository({
    required AuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService;

  User? get currentUser => _authService.currentUser;
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  // EMAIL / PASSWORD
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _authService.signUpWithEmail(
      email: email,
      password: password,
    );

    await _authService.updateDisplayName(name);

    final user = UserModel(
      uid: credential.user!.uid,
      name: name,
      email: email,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _firestoreService.createUserDocument(user);

    return user;
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _authService.signInWithEmail(
      email: email,
      password: password,
    );

    final userDoc =
    await _firestoreService.getUserDocument(credential.user!.uid);

    if (userDoc == null) {
      final newUser = UserModel(
        uid: credential.user!.uid,
        name: credential.user!.displayName ?? 'User',
        email: email,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _firestoreService.createUserDocument(newUser);
      return newUser;
    }

    return userDoc;
  }

  // GOOGLE SIGN-IN
  Future<UserModel> signInWithGoogle() async {
    final credential = await _authService.signInWithGoogle();
    final firebaseUser = credential.user!;

    // Fetch existing Firestore doc, or create a new one
    var userDoc =
    await _firestoreService.getUserDocument(firebaseUser.uid);

    if (userDoc == null) {
      userDoc = UserModel(
        uid: firebaseUser.uid,
        name: firebaseUser.displayName ?? 'Google User',
        email: firebaseUser.email ?? '',
        profileImage: firebaseUser.photoURL,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _firestoreService.createUserDocument(userDoc);
    }

    return userDoc;
  }

  // SIGN OUT
  Future<void> signOut() async {
    await _authService.signOutGoogle(); // sign out Google first
    await _authService.signOut();       // then Firebase
  }

  // MISC
  Future<void> sendPasswordResetEmail(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  Future<UserModel?> getUserData(String uid) async {
    return await _firestoreService.getUserDocument(uid);
  }

  Stream<UserModel?> userStream(String uid) {
    return _firestoreService.userStream(uid);
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await _firestoreService.updateUserDocument(uid, data);
  }

  Future<void> saveFavoriteCategories(
      String uid,
      List<String> categories,
      ) async {
    await _firestoreService.updateFavoriteCategories(uid, categories);
  }
}