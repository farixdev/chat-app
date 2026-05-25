import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:myapp/models/user_model.dart';
import 'package:myapp/services/firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool _googleSignInInitialized = false;

  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        await _firestoreService.updateUserOnlineStatus(user.uid, true);
        return await _firestoreService.getUser(user.uid);
      }

      return null;
    } catch (e) {
      throw Exception("Login failed: ${e.toString()}");
    }
  }

  Future<UserModel?> registerWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        await user.updateDisplayName(displayName);

        final userModel = UserModel(
          id: user.uid,
          email: email,
          displayName: displayName,
          isOnline: true,
          lastSeen: DateTime.now(),
          createdAt: DateTime.now(),
        );

        await _firestoreService.createUser(userModel);
        return userModel;
      }

      return null;
    } catch (e) {
      throw Exception("failed to register: ${e.toString()}");
    }
  }

  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_googleSignInInitialized) {
      await _googleSignIn.initialize();
      _googleSignInInitialized = true;
    }
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      await _ensureGoogleSignInInitialized();
      final GoogleSignInAccount account = await _googleSignIn.authenticate();
      final GoogleSignInAuthentication auth = account.authentication;
      final String? idToken = auth.idToken;

      if (idToken == null) {
        throw Exception('Google sign-in failed: missing idToken.');
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return null;

      // Ensure Firestore user exists.
      final existing = await _firestoreService.getUser(user.uid);
      if (existing != null) {
        await _firestoreService.updateUserOnlineStatus(user.uid, true);
        return existing;
      }

      final String displayName =
          (user.displayName == null || user.displayName!.trim().isEmpty)
          ? 'Google User'
          : user.displayName!.trim();

      final userModel = UserModel(
        id: user.uid,
        email: user.email ?? '',
        displayName: displayName,
        isOnline: true,
        lastSeen: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await _firestoreService.createUser(userModel);
      return userModel;
    } catch (e) {
      throw Exception('Google sign-in failed: ${e.toString()}');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception("Password reset failed: ${e.toString()}");
    }
  }

  Future<void> signout() async {
    try {
      if (currentUserId != null) {
        await _firestoreService.updateUserOnlineStatus(currentUserId!, false);
      }
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      throw Exception("failed to signout: ${e.toString()}");
    }
  }

  Future<void> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestoreService.deleteUser(user.uid);
        await user.delete();
        await _googleSignIn.disconnect();
      }
    } catch (e) {
      throw Exception("failed to delete: ${e.toString()}");
    }
  }
}
