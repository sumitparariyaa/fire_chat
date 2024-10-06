import 'package:firechat_app/view_models/auth_view_model.dart';
import 'package:firechat_app/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class LoginScreen extends StatelessWidget {
  final void Function()? onTap;

  LoginScreen({super.key, this.onTap});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) =>
                  value!.isEmpty ? 'Enter your email' : null,
                  onSaved: (value) => authViewModel.setEmail(value!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) =>
                  value!.isEmpty ? 'Enter your password' : null,
                  onSaved: (value) => authViewModel.setPassword(value!),
                ),
                const SizedBox(height: 30),
                CommonButton(
                  onTap: (){
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      authViewModel.loginUser(context);
                    }
                  },
                    child: authViewModel.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Login'),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Not a member? ",style: TextStyle(color: Theme.of(context).colorScheme.primary),),
                    GestureDetector(
                        onTap: onTap,
                        child: Text("Register Now",style: TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).colorScheme.primary),)),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

