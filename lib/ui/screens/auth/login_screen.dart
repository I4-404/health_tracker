import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health_tracker/ui/screens/auth/registration_screen.dart';
import 'package:health_tracker/shared/styles/themes.dart';
import 'package:health_tracker/ui/widgets/button_widget.dart';
import 'package:health_tracker/ui/widgets/snackbar_widget.dart';
import 'package:health_tracker/ui/widgets/textfield_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:animate_do/animate_do.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back,
            size: 30,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 40,
              vertical: 30,
            ),
            child: Form(
              key: _formKey,
              child: BounceInDown(
                duration: const Duration(milliseconds: 1500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: Theme.of(context)
                          .textTheme
                          .displayLarge
                          ?.copyWith(
                            fontSize: 20.sp,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                    ),

                    SizedBox(height: 1.5.h),

                    Text(
                      'Sign In To Continue !',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontSize: 12.sp,
                            letterSpacing: 2,
                          ),
                    ),

                    SizedBox(height: 10.h),

                    // EMAIL
                    MyTextfield(
                      hint: 'Email Address',
                      icon: Icons.email,
                      keyboardtype: TextInputType.emailAddress,

                      // لا يوجد تحقق حقيقي من الإيميل
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter something';
                        }
                        return null;
                      },

                      textEditingController: _emailController,
                    ),

                    SizedBox(height: 4.h),

                    // PASSWORD
                    MyTextfield(
                      hint: 'Password',
                      icon: Icons.password,
                      keyboardtype: TextInputType.text,
                      obscure: true,

                      // نقبل أي كلمة مرور
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter something';
                        }
                        return null;
                      },

                      textEditingController: _passwordController,
                    ),

                    SizedBox(height: 4.h),

                    // LOGIN
                    ButtonWidget(
                      color: MyThemes.primary,
                      width: 80.w,
                      title: 'Login',
                      func: () async {
                        await _fakeLogin();
                      },
                    ),

                    SizedBox(height: 2.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an Account ?',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontSize: 8.sp,
                                fontWeight: FontWeight.bold,
                              ),
                        ),

                        const SizedBox(width: 5),

                        InkWell(
                          onTap: () {
                            Navigator.pop(context);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SignUpScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Sign Up',
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(
                                  fontSize: 9.sp,
                                  color: MyThemes.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // تسجيل دخول تجريبي
  // ============================================================

  Future<void> _fakeLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      // إنشاء مستخدم Firebase مجهول
      UserCredential credential =
          await FirebaseAuth.instance.signInAnonymously();

      final User user = credential.user!;

      final String email =
          _emailController.text.trim();

      final String password =
          _passwordController.text;

      // حفظ البيانات في Firebase/Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'uid': user.uid,
          'email': email,
          'password': password,
          'username': email.split('@').first,
          'photoUrl':
              'https://i.stack.imgur.com/l60Hf.png',
          'bio': '',
          'followers': [],
          'following': [],
          'bookmarkedRecipes': [],
          'isDarkMode': true,
          'anonymous': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      // فتح التطبيق
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Login successful!',
          ),
          backgroundColor: MyThemes.primary,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      MySnackBar.error(
        message: e.message ?? 'Login failed',
        color: Colors.red,
        context: context,
      );
    } catch (e) {
      if (!mounted) return;

      MySnackBar.error(
        message: e.toString(),
        color: Colors.red,
        context: context,
      );
    }
  }
}