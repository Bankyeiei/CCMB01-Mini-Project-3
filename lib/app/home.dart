import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import 'login.dart';
import 'edit.dart';
import 'ui/cat_grid_view.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final users = FirebaseFirestore.instance.collection('users');

  void showMessage(String message, BuildContext context) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Stream<DocumentSnapshot> getUser() {
    return users.doc(LocalStorage.box.read('uid')).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: getUser(),
      builder: (context, snapshot) {
        Map<String, dynamic> userData = {};
        if (snapshot.hasData && !snapshot.hasError) {
          userData = snapshot.data!.data() as Map<String, dynamic>;
        }
        return Scaffold(
          appBar: AppBar(
            title: Text('Welcome, ${userData['name']?.split(' ')[0] ?? ''}'),
            actions:
                userData['name'] == null
                    ? null
                    : [
                      IconButton(
                        tooltip: 'Edit',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => EditScreen(
                                    documentReference: users.doc(
                                      LocalStorage.box.read('uid'),
                                    ),
                                    name: userData['name'],
                                    profilePicture: userData['profile_picture'],
                                  ),
                            ),
                          );
                        },
                        icon: Icon(Icons.edit),
                      ),
                      SizedBox(width: 4),
                      IconButton(
                        tooltip: 'Logout',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: Text('Do you want to logout?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('No'),
                                    ),
                                    FilledButton(
                                      onPressed: () {
                                        LocalStorage.box.remove('uid');
                                        LocalStorage.box.write(
                                          'isLoggedIn',
                                          false,
                                        );
                                        Navigator.pop(context);
                                        showMessage('Logout success', context);
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => LoginScreen(),
                                          ),
                                        );
                                      },
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: Text('Yes'),
                                    ),
                                  ],
                                ),
                          );
                        },
                        icon: Icon(Icons.logout),
                      ),
                      SizedBox(width: 4),
                    ],
          ),
          body: Builder(
            builder: (context) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: SizedBox(
                    height: 64,
                    width: 64,
                    child: CircularProgressIndicator(strokeWidth: 8),
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error : ${snapshot.error}',
                    style: TextStyle(fontSize: 32),
                  ),
                );
              } else if (!snapshot.hasData) {
                return Center(
                  child: Text(
                    'User information not found',
                    style: TextStyle(fontSize: 32),
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 8),
                  CircleAvatar(
                    radius: 32,
                    foregroundImage: NetworkImage(
                      userData['profile_picture'] ?? '',
                    ),
                    child: Icon(Icons.person, size: 32),
                  ),
                  SizedBox(height: 8),
                  Text(userData['email'] ?? '', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 16),
                  Text(
                    'Cat API',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Expanded(child: CatGridView()),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
