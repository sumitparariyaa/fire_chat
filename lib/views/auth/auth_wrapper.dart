import 'package:firebase_auth/firebase_auth.dart';
import 'package:firechat_app/widgets/registerOrLoginToggle.dart';
import 'package:firechat_app/views/chat/chat_list_screen.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            return const ChatListScreen();
          }else{
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}