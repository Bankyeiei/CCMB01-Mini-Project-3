import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import 'login.dart';

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
        String title = '';
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData &&
            !snapshot.hasError) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          title = 'Welcome, ${data['name'].split(' ')[0]}';
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions:
                title.isEmpty
                    ? null
                    : [
                      IconButton(onPressed: () {}, icon: Icon(Icons.edit)),
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
              final userData = snapshot.data!.data() as Map<String, dynamic>;
              return Column(children: [Text(userData['email'])]);
            },
          ),
        );
      },
    );
  }
}
