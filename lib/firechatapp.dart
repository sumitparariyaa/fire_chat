import 'package:firechat_app/view_models/auth_view_model.dart';
import 'package:firechat_app/view_models/chat_view_model.dart';
import 'package:firechat_app/views/auth/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/router.dart';

class FirechatApp extends StatelessWidget {
  const FirechatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ChatViewModel()),
      ],
      child: MaterialApp(
        title: 'Firechat app',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        home: const AuthGate(),
        onGenerateRoute: AppRoutes.generateRoute,
        // home: const RegisterScreen(),
      ),
    );
  }
}
