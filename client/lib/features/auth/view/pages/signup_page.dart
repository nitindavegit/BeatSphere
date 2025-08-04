import 'package:client/core/utils.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/features/auth/view/pages/login_page.dart';
import 'package:client/features/auth/view/widgets/auth_signup_button.dart';
import 'package:client/core/widgets/custom_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
    // Removed the problematic formKey.currentState!.validate() line
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      authViewModelProvider.select((val) => val?.isLoading == true),
    );

    ref.listen(authViewModelProvider, (_, next) {
      next?.when(
        data: (data) {
          showSnackBar(context, 'Account created Successfully! Please LogIn');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        },
        error: (error, st) {
          showSnackBar(context, error.toString());
        },
        loading: () {},
      );
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(),
      body: isLoading
          ? const Loader()
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Add some top spacing to center content better
                      SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                      
                      const Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Times New Roman',
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      CustomField(
                        hintText: 'Name', 
                        controller: nameController,
                      ),
                      const SizedBox(height: 15),
                      
                      CustomField(
                        hintText: 'Email', 
                        controller: emailController,
                      ),
                      const SizedBox(height: 15),
                      
                      CustomField(
                        hintText: 'Password',
                        controller: passwordController,
                        isObscure: true,
                      ),
                      const SizedBox(height: 20),
                      
                      AuthSignupButton(
                        buttonText: "Sign Up",
                        onTap: () async {
                          if (formKey.currentState!.validate()) {
                            await ref
                                .read(authViewModelProvider.notifier)
                                .signUpUser(
                                  name: nameController.text.trim(),
                                  email: emailController.text.trim(),
                                  password: passwordController.text,
                                );
                          } else {
                            showSnackBar(context, 'Missing fields');
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            text: "Already have an account? ",
                            style: Theme.of(context).textTheme.titleMedium,
                            children: [
                              TextSpan(
                                text: ' Sign In',
                                style: const TextStyle(
                                  color: Pallete.gradient2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Add bottom spacing to ensure content doesn't get cut off
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}