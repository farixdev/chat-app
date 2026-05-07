import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/services/auth_service.dart';

class ForgotPasswordController extends GetxController{
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final RxBool _emailSent = false.obs;
  final RxString _error = ''.obs;
  final Rx _isloading = false.obs;

  bool get isLoading => _isloading.value;
  String get error => _error.value;
  bool get emailSent => _emailSent.value;

  @override
  void onClose(){
    emailController.dispose();
    super.onClose();
  }

  Future<void> sentPasswordResetEmail() async{
    if(!formKey.currentState!.validate()) return;
    try{
      _isloading.value = true;
      _error.value = '';

      await _authService.sendPasswordResetEmail(emailController.text);
      _emailSent.value = true;

      Get.snackbar(
        'Success',
        'Password reset email sent to ${emailController.text}',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
        duration: Duration(seconds: 4),
      );

    } catch(e){
      _error.value = e.toString();

      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.redAccent,
        duration: Duration(seconds: 4),
      );
    } finally{
      _isloading.value = false;
    }
  }

  void goBackToLogin(){
    Get.back();
  }

  void resendEmail(){
    _emailSent.value = false;
    sentPasswordResetEmail();
  }
   String? validateEmail(String? value){
    if(value?.isEmpty ?? true){
       return 'Pleae enter your email';
    }
    if(!GetUtils.isEmail(value!)) {
      return 'please enter a valid email';
    }
    return null;
    }
    void _clearError (){
      _error.value='';
    }
   }
