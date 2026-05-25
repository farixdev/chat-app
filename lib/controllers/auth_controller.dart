import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/routes/app_routes.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/models/user_model.dart';
import 'package:myapp/services/firestore_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  final Rx<User?> _user = Rx<User?>(null);
  final Rx<UserModel?> _userModel = Rx<UserModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isInitialized = false.obs;
  final RxString _error = ''.obs;

  User? get user => _user.value;
  UserModel? get userModel => _userModel.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  bool get isAuthenticated => _user.value != null; // Fixed: was isauthenticated
  bool get isInitialized => _isInitialized.value;

  @override
  void onInit() {
    super.onInit();
    _user.bindStream(_authService.authStateChanges);
    ever(_user, _handleAuthStateChanges);
  }

  void _handleAuthStateChanges(User? user) async {
    if (user == null) {
      _userModel.value = null;
      Get.offAllNamed(AppRoutes.login);
    } else {
      if (_isLoading.value) return;

      try {
        UserModel? model = await _firestoreService.getUser(user.uid);
        if (model != null) {
          _userModel.value = model;
          Get.offAllNamed(AppRoutes.main);
        } else {
          // Orphaned auth account — sign out
          await _authService.signout(); // Fixed: was signout()
        }
      } catch (e) {
        print("Error fetching user model: $e");
        Get.offAllNamed(AppRoutes.login);
      }
    }

    if (!_isInitialized.value) {
      _isInitialized.value = true;
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading.value = true;
      _error.value = '';
      UserModel? userModel = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );
      if (userModel != null) {
        _userModel.value = userModel;
        Get.offAllNamed(AppRoutes.main);
      }
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar("Error", "Failed to login");
      print(e);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _isLoading.value = true;
      _error.value = '';
      UserModel? userModel = await _authService.signInWithGoogle();
      if (userModel != null) {
        _userModel.value = userModel;
        Get.offAllNamed(AppRoutes.main);
      }
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar("Error", "Failed to sign in with Google");
      print(e);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> registerWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      _isLoading.value = true;
      _error.value = '';
      UserModel? userModel = await _authService.registerWithEmailAndPassword(
        email,
        password,
        displayName,
      );
      if (userModel != null) {
        _userModel.value = userModel;
        Get.offAllNamed(AppRoutes.main);
      }
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar("Error", e.toString(), duration: const Duration(seconds: 5));
      print(e);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signOut() async { // Fixed: was signout()
    try {
      _isLoading.value = true;
      await _authService.signout(); // Fixed: was signout()
      _userModel.value = null;
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar("Error", "Failed to sign out");
    } finally {
      _isLoading.value = false;
    }
  }

  // Keep old name as alias so other controllers don't break immediately
  Future<void> signout() => signOut();

  Future<void> deleteAccount() async {
    try {
      _isLoading.value = true;
      await _authService.deleteAccount();
      _userModel.value = null;
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar("Error", "Failed to delete account");
    } finally {
      _isLoading.value = false;
    }
  }

  void clearError() {
    _error.value = '';
  }
}
