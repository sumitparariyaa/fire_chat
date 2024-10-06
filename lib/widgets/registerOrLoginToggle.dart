import 'package:firechat_app/views/auth/login_screen.dart';
import 'package:firechat_app/views/auth/register_screen.dart';
import 'package:flutter/material.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {

  bool showLoginScreen = true;

  void toggleScreens(){
    setState(() {
      showLoginScreen = !showLoginScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginScreen){
      return LoginScreen(onTap: toggleScreens);
    }else{
      return RegisterScreen(onTap:toggleScreens);
    }
  }
}





