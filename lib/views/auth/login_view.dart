import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controllers/auth_controller.dart';
import 'package:myapp/routes/app_routes.dart';
import 'package:myapp/theme/app_theme.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formkey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();
  bool _obsecurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Welcome Back!',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  "sign in to continue chatting with friends & fammily",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    hintText: 'Enter your email',
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your email';
                    }
                    if (!GetUtils.isEmail(value!)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obsecurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    hintText: 'Enter your password',
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obsecurePassword = !_obsecurePassword;
                        });
                      },
                      icon: Icon(
                        _obsecurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your password';
                    }
                    if(value!.length<6){
                       return 'Password must be Atleast 6 character';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                Obx(
                    ()=> SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(onPressed: _authController.isLoading ? null: () {
                        if(_formkey.currentState?.validate() ?? false){
                              _authController.signInWithEmailAndPassword(_emailController.text.trim(), _passwordController.text,);
                        }
                      },
                          child: _authController.isLoading ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                               color: Colors.white,
                              strokeWidth: 2,
                            ),

                          ): Text ("Sign In"),
                      ),
                    ),
                ),
                SizedBox(height: 16),
                Center(
                  child: TextButton(onPressed: (){
                    Get.toNamed(AppRoutes.forgotPassword);
                  }, child:
                  Text(
                       'forgot Password?',
                    style: TextStyle(color: AppTheme.primaryColor),
                  )
                  ),
                ),
                SizedBox(height:32),
                Row(
                   children: [
                     Expanded(child: Divider(color: AppTheme.borderColor)),
                     Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
                     child: Text('OR',
                     style: Theme.of(context).textTheme.bodySmall,
                     ),
                     ),
                     Expanded(child: Divider(color: AppTheme.borderColor)),
                   ],
                ),
                SizedBox(height: 32),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Text("D,ont have any account",
                      style: Theme.of(context).textTheme.bodyMedium,
                     ),
                     GestureDetector(onTap: () => Get.toNamed(AppRoutes.register),
                       child: Text('signup',
                         style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                           color: AppTheme.primaryColor,
                           fontWeight: FontWeight.w600,
                         ) ),
                     ),
                   ],
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}