import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangePasswordController extends GetxController {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>(); // Fixed: was fromKey (typo)

  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  final RxBool _obscureCurrentPassword = true.obs; // Fixed: was abscure (typo)
  final RxBool _obscureNewPassword = true.obs;
  final RxBool _obscureConfirmPassword = true.obs;

  bool get isLoading => _isLoading.value;
  String get error => _error.value;

  bool get obscureCurrentPassword => _obscureCurrentPassword.value;
  bool get obscureNewPassword => _obscureNewPassword.value;
  bool get obscureConfirmPassword => _obscureConfirmPassword.value;

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void toggleCurrentPasswordVisibility() {
    _obscureCurrentPassword.value = !_obscureCurrentPassword.value;
  }

  void toggleNewPasswordVisibility() {
    _obscureNewPassword.value = !_obscureNewPassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword.value = !_obscureConfirmPassword.value;
  }

  Future<void> changePassword() async {
    if (!formKey.currentState!.validate()) return; // Fixed: was fromKey

    try {
      _isLoading.value = true;
      _error.value = '';

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Re-authenticate before changing password (required by Firebase)
      final email = user.email;
      if (email == null) throw Exception('No email associated with account');

      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPasswordController.text,
      );
      await user.reauthenticateWithCredential(credential);

      // Now safe to update password
      await user.updatePassword(newPasswordController.text);

      Get.snackbar(
        'Success',
        'Password changed successfully',
        backgroundColor: Colors.green.withValues(alpha: 0.1), // Fixed: withOpacity deprecated
        duration: const Duration(seconds: 3),
      );

      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'wrong-password':
          errorMessage = 'Current password is incorrect';
          break;
        case 'weak-password':
          errorMessage = 'New password is too weak';
          break;
        case 'requires-recent-login':
          errorMessage = 'Please sign out and sign in again before changing password';
          break;
        default:
          errorMessage = 'Failed to change password: ${e.message}';
      }
      _error.value = errorMessage;
      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      _error.value = 'Failed to change password';
      Get.snackbar(
        'Error',
        _error.value,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 4),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  String? validateCurrentPassword(String? value) {
    if (value?.isEmpty ?? true) return 'Please enter your current password';
    return null;
  }

  String? validateNewPassword(String? value) {
    if (value?.isEmpty ?? true) return 'Please enter a new password';
    if (value!.length < 6) return 'Password must be at least 6 characters';
    if (value == currentPasswordController.text) {
      return 'New password must be different from current password';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value?.isEmpty ?? true) return 'Please confirm your new password';
    if (value != newPasswordController.text) return 'Passwords do not match';
    return null;
  }

  void clearError() {
    _error.value = '';
  }
}
