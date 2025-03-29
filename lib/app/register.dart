import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final profilePictureController = TextEditingController();
  final passwordController = TextEditingController();
  final repasswordController = TextEditingController();

  final users = FirebaseFirestore.instance.collection('users');
  final auth = FirebaseAuth.instance;

  bool isLoading = false;
  List<bool> isObscureText = [true, true];

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> registor() async {
    setState(() {
      isLoading = true;
    });
    try {
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      final uid = userCredential.user!.uid;
      await users.doc(uid).set({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'profile_picture': profilePictureController.text.trim(),
        'created_at': DateTime.now(),
      });
      showMessage('Register success');
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      showMessage('Register fail: ${error.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    profilePictureController.dispose();
    passwordController.dispose();
    repasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: !isLoading),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 30),
                      Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 30),
                      TextFormField(
                        controller: nameController,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z ]'),
                          ),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please type username';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 32),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final emailRegex = RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                          );
                          if (value == null || value.trim().isEmpty) {
                            return 'Please type email';
                          } else if (!emailRegex.hasMatch(value)) {
                            return 'Please type email correctly';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 32),
                      TextFormField(
                        controller: profilePictureController,
                        keyboardType: TextInputType.url,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'URL Profile Picture',
                          prefixIcon: Icon(Icons.image_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please type username';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 32),
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.password),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                isObscureText[0] = !isObscureText[0];
                              });
                            },
                            icon: Icon(
                              isObscureText[0]
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                          border: OutlineInputBorder(),
                        ),
                        obscureText: isObscureText[0],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please type password';
                          } else if (value.length < 6) {
                            return 'Password length must be at least 6';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 32),
                      TextFormField(
                        controller: repasswordController,
                        decoration: InputDecoration(
                          labelText: 'Re-Password',
                          prefixIcon: Icon(Icons.password),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                isObscureText[1] = !isObscureText[1];
                              });
                            },
                            icon: Icon(
                              isObscureText[1]
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                          border: OutlineInputBorder(),
                        ),
                        obscureText: isObscureText[1],
                        validator: (value) {
                          if (passwordController.text.isEmpty) {
                            return null;
                          } else if (value == null || value.isEmpty) {
                            return 'Please type re-password';
                          } else if (passwordController.text != value) {
                            return 'Both password are not same';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              registor();
                            }
                          },
                          child: Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (isLoading)
            Stack(
              children: [
                ModalBarrier(dismissible: false, color: Color(0x7F000000)),
                Center(
                  child: SizedBox(
                    height: 64,
                    width: 64,
                    child: CircularProgressIndicator(strokeWidth: 8),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
