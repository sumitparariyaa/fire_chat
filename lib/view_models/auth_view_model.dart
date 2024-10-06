import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AuthViewModel with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _isLoading = false;
  XFile? _image;
  String email = '', password = '', name = '';

  bool get isLoading => _isLoading;
  XFile? get image => _image;

  Future<void> pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      _image = pickedImage;
      notifyListeners();
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Profile Picture Required'),
          content: const Text('Please select an image for your profile.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                pickImage(context);
              },
              child: const Text('Choose Image'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    if (_image == null) {
      pickImage(context);
      return;
    }

    _setLoading(true);

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String? imageUrl;
      if (_image != null) {
        final ref = _storage.ref().child('user_images').child(userCredential.user!.uid + '.jpg');
        await ref.putFile(File(_image!.path));
        imageUrl = await ref.getDownloadURL();
      }

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': name,
        'email': email,
        'imageUrl': imageUrl ?? '',
      });

      Navigator.pushReplacementNamed(context, '/chatList');
    } catch (error) {
      _showErrorDialog(context, error);
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _showErrorDialog(BuildContext context, dynamic error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(error.toString()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void setPassword(String passwordLogin) {
    password = passwordLogin;
    notifyListeners();
  }

  void setEmail(String emailLogin){
    email = emailLogin;
    notifyListeners();
  }

  Future<void> loginUser(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Firebase Authentication login
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();

      Navigator.pushReplacementNamed(context, '/chatList');
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(error.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
