import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import 'login.dart';
import 'edit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final users = FirebaseFirestore.instance.collection('users');

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<DocumentSnapshot> getUser() {
    return users.doc(LocalStorage.box.read('uid')).get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUser(),
      builder: (context, snapshot) {
        Map<String, dynamic> userData = {};
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData &&
            !snapshot.hasError) {
          userData = snapshot.data!.data() as Map<String, dynamic>;
        }
        return Scaffold(
          appBar: AppBar(
            title: Text('Welcome,  ${userData['name'] ?? ''}'),
            actions:
                userData['name'] == null
                    ? null
                    : [
                      IconButton(
                        tooltip: 'Edit',
                        onPressed: () async {
                          bool hasEdit =
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => EditScreen(
                                        documentReference: users.doc(
                                          LocalStorage.box.read('uid'),
                                        ),
                                        name: userData['name'],
                                        profilePicture:
                                            userData['profile_picture'],
                                      ),
                                ),
                              ) ??
                              false;
                          if (hasEdit) {
                            setState(() {});
                          }
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
                                        Navigator.pop(context);
                                        showMessage('Logout success');
                                        Navigator.push(
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
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          userData['profile_picture'],
                        ),
                        child: Icon(Icons.person),
                      ),
                      SizedBox(width: 10),
                      Text(userData['email']),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
