
import 'package:firechat_app/view_models/auth_view_model.dart';
import 'package:firechat_app/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  final void Function()? onTap;
  const RegisterScreen({super.key, this.onTap});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  void _registerUser(AuthViewModel authViewModel) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      authViewModel.registerUser(
        name: authViewModel.name,
        email: authViewModel.email,
        password: authViewModel.password,
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => authViewModel.pickImage(context),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: authViewModel.image == null
                          ? null
                          : FileImage(File(authViewModel.image!.path)),
                      child: authViewModel.image == null
                          ? const Icon(Icons.add_a_photo, size: 50)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) =>
                    value!.isEmpty ? 'Enter your name' : null,
                    onSaved: (value) => authViewModel.name = value!,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) =>
                    value!.isEmpty ? 'Enter your email' : null,
                    onSaved: (value) => authViewModel.email = value!,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) => value!.length < 6
                        ? 'Password should be at least 6 characters'
                        : null,
                    onSaved: (value) => authViewModel.password = value!,
                  ),
                  const SizedBox(height: 30),
                  CommonButton(
                    onTap:() => _registerUser(authViewModel),
                    child:  authViewModel.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : const Text('Register'),
                  ),
                  const SizedBox(height: 15,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account? ",style: TextStyle(color: Theme.of(context).colorScheme.primary),),
                      GestureDetector(
                          onTap:widget.onTap,
                          child: Text("Login Now",style: TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).colorScheme.primary),)),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
