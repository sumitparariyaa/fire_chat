import 'package:firebase_auth/firebase_auth.dart';
import 'package:firechat_app/view_models/auth_view_model.dart';
import 'package:firechat_app/views/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return PopScope(
      onPopInvokedWithResult: (result, set1) async{
        SystemNavigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
          title: const Text('Chat List'),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final users = snapshot.data!.docs.where((doc) => doc['uid'] != currentUser!.uid).toList();
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                var user = users[index];
                return ListTile(
                  leading: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UserProfileScreen(
                                user: user,
                              ),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      backgroundImage: user['imageUrl'] != ''
                          ? NetworkImage(user['imageUrl'])
                          : null,
                      child: user['imageUrl'] == '' ? const Icon(Icons.person) : null,
                    ),
                  ),
                  title: Text(user['name']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(userId: user['uid'],userName: user["name"],),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Provider.of<AuthViewModel>(context, listen: false).signOut().then((_) {
              Navigator.pushReplacementNamed(context, '/login');
            });
          },
          tooltip: 'Sign Out',
          child: const Icon(Icons.logout),
        ),
      ),
    );
  }
}
