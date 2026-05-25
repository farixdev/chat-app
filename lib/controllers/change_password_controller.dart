import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';



class ChangePasswordController extends GetxController {

  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final GlobalKey<FormState> fromKey = GlobalKey<FormState>();

  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  final RxBool _abscureCurrentPassword = true.obs;
  final RxBool _abscureNewPassword = true.obs;
  final RxBool _abscureConfirmPassword = true.obs;

  bool get isLoading => _isLoading.value;
  String get error => _error.value;

  bool get abscureCurrentPassword => _abscureCurrentPassword.value;
  bool get abscureNewPassword => _abscureNewPassword.value;
  bool get abscureConfirmPassword => _abscureConfirmPassword.value;

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void toggleCurrentPasswordVisibility() {
    _abscureCurrentPassword.value = !_abscureCurrentPassword.value;
  }

  void toggleNewPasswordVisibility() {
    _abscureNewPassword.value = !_abscureNewPassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    _abscureConfirmPassword.value = !_abscureConfirmPassword.value;
  }

  Future<void> changePassword() async {
    if (!fromKey.currentState!.validate()) return;

    try {
      _isLoading.value = true;
      _error.value = '';

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('no user Logged in');
      }


      await user.updatePassword(newPasswordController.text);
      Get.snackbar(
        'Success',
        'Password changed successfully',
        backgroundColor: Colors.green.withOpacity(0.1),
        duration: const Duration(seconds: 3),
      );

      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'wrong-password':
          errorMessage = 'Current Password is Incorrect';
          break;
        case 'weak-password':
          errorMessage = 'New Password is too weak';
          break;
        case 'requires-recent-login':
          errorMessage = 'Please sign out and sign in again before changing';
          break;
        default:
          errorMessage = 'Failed to change password';
      }

      _error.value = errorMessage;

      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      _error.value = 'Failed to change password';

      Get.snackbar(
        'Error',
        _error.value,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 4),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  String? validateCurrentPassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Please enter your current password';
    }
    return null;
  }

  String? validateNewPassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Please enter a new password';
    }
    if (value!.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (value == currentPasswordController.text) {
      return 'New password must be different from current password';
    }
    return null;
  }
  String? validateConfirmPassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Please confirm your new password';
    }
    if (value != newPasswordController.text) {
      return 'Password does not match';
    }
    return null;
  }
  void clearError(){
      _error.value='';
  }

}