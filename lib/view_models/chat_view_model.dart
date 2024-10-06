import 'dart:io';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:firechat_app/widgets/video_player/video_player_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class ChatViewModel with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  User? _currentUser;

  ChatViewModel() {
    _currentUser = _auth.currentUser;
  }

  User? get currentUser => _currentUser;

  String getChatRoomId(String user1, String user2) {
    return user1.compareTo(user2) > 0 ? '$user1\_$user2' : '$user2\_$user1';
  }

  Future<void> sendMessage(String receiverId, {String? message, String? fileUrl, String messageType = 'text'}) async {
    if (message == null && fileUrl == null) return;

    var chatRoomId = getChatRoomId(receiverId, _currentUser!.uid);

    await _firestore.collection('messages').doc(chatRoomId).collection('chats').add({
      'senderId': _currentUser!.uid,
      'receiverId': receiverId,
      'messageType': messageType,
      'messageContent': fileUrl ?? message,
      'timestamp': FieldValue.serverTimestamp(),
    });

    notifyListeners();
  }

  Future<void> sendImage(String receiverId) async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      UploadTask uploadTask = _storage.ref().child('chat_images/$fileName').putFile(file);

      String fileUrl = await (await uploadTask).ref.getDownloadURL();
      await sendMessage(receiverId, fileUrl: fileUrl, messageType: 'image');
    }
  }

  Future<void> sendVideo(String receiverId) async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      UploadTask uploadTask = _storage.ref().child('chat_videos/$fileName').putFile(file);

      String fileUrl = await (await uploadTask).ref.getDownloadURL();
      await sendMessage(receiverId, fileUrl: fileUrl, messageType: 'video');
    }
  }

  Future<void> sendDocument(String receiverId) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      UploadTask uploadTask = _storage.ref().child('chat_docs/$fileName').putFile(file);

      String fileUrl = await (await uploadTask).ref.getDownloadURL();
      await sendMessage(receiverId, fileUrl: fileUrl, messageType: result.files.single.extension == 'pdf' ? 'pdf' : 'doc');
    }

  }

  Stream<QuerySnapshot> getMessages(String receiverId) {
    var chatRoomId = getChatRoomId(receiverId, _currentUser!.uid);
    return _firestore.collection('messages').doc(chatRoomId).collection('chats').orderBy('timestamp').snapshots();
  }

  Future<void> viewMedia(BuildContext context, String url, {bool isVideo = false}) async {
    if (isVideo) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VideoPlayerWidget(videoUrl: url)),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Image.network(url),
        ),
      );
    }
  }

  Future<void> openFile(BuildContext context, String fileUrl) async {
    try {
      PDFDocument doc = await PDFDocument.fromURL(fileUrl);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewer(document: doc),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to open PDF: $e")),
      );
    }
  }
}
