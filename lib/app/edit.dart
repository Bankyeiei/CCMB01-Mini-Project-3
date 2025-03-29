import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'home.dart';

class EditScreen extends StatefulWidget {
  final DocumentReference documentReference;
  final String name;
  final String profilePicture;
  const EditScreen({
    super.key,
    required this.documentReference,
    required this.name,
    required this.profilePicture,
  });

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final profilePictureController = TextEditingController();

  bool isLoading = false;

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> edit() async {
    setState(() {
      isLoading = true;
    });
    try {
      await widget.documentReference.update({
        'name': nameController.text,
        'profile_picture': profilePictureController.text,
      });
      showMessage('Edit success');
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (error) {
      showMessage('Edit fail: ${error.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    nameController.text = widget.name;
    profilePictureController.text = widget.profilePicture;
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
                        'Edit',
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
                              edit();
                            }
                          },
                          child: Text(
                            'Edit',
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
