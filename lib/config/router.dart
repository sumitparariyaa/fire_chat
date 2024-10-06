
import 'package:flutter/material.dart';

import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/chat/chat_list_screen.dart';
import '../views/profile/profile_screen.dart';

class AppRoutes {
  static const String register = '/register';
  static const String login = '/login';
  static const String chatList = '/chatList';
  static const String userProfile = '/userProfile';
  static const String chatScreen = '/chatScreen';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case chatList:
        return MaterialPageRoute(builder: (_) => const ChatListScreen());
      case userProfile:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => UserProfileScreen(user: args['user']),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
