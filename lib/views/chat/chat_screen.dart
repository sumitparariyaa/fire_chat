import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firechat_app/view_models/chat_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const ChatScreen({required this.userId, required this.userName, super.key});
  
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final chatViewModel = Provider.of<ChatViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
        title: Text('Chat with ${widget.userName}'),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList(chatViewModel)),
          _buildMessageInput(chatViewModel),
        ],
      ),
    );
  }

  Widget _buildMessageList(ChatViewModel chatViewModel) {
    return StreamBuilder(
      stream: chatViewModel.getMessages(widget.userId),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          controller: _scrollController,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var message = snapshot.data!.docs[index];
            bool isMe = message['senderId'] == chatViewModel.currentUser!.uid;
            return _buildChatBubble(message, isMe, context, chatViewModel);
          },
        );
      },
    );
  }

  Widget _buildChatBubble(DocumentSnapshot message, bool isMe, BuildContext context, ChatViewModel chatViewModel) {
    String messageType = message['messageType'];
    String messageContent = message['messageContent'];
    Timestamp? timestamp = message['timestamp'];

    String formattedTime = timestamp != null
        ? DateFormat('h:mm a').format(timestamp.toDate())
        : '';
    
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(12),
      topRight: const Radius.circular(12),
      bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
      bottomRight: isMe ? Radius.zero : const Radius.circular(12),
    );

    final chatBubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.all(6),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75, 
      ),
      decoration: BoxDecoration(
        color: isMe ? Theme.of(context).primaryColor.withOpacity(0.3) : Theme.of(context).primaryColorLight,
        borderRadius: borderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMessageContent(messageType, messageContent, chatViewModel, context),
          const SizedBox(height: 4),
          Text(
            formattedTime,
            style: const TextStyle(fontSize: 10, color: Colors.black45),
          ),
        ],
      ),
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: chatBubble,
    );
  }

  Widget _buildMessageContent(String messageType, String messageContent, ChatViewModel chatViewModel, BuildContext context) {
    switch (messageType) {
      case 'image':
        return GestureDetector(
          onTap: () => chatViewModel.viewMedia(context, messageContent),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.25,
            width: MediaQuery.of(context).size.width * 0.55,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                messageContent,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      case 'video':
        return GestureDetector(
          onTap: () => chatViewModel.viewMedia(context, messageContent, isVideo: true),
          child: Icon(Icons.play_circle_fill, size: 50, color: Colors.grey[800]),
        );
      case 'pdf':
        return GestureDetector(
          onTap: () => chatViewModel.openFile(context, messageContent),
          child: const Icon(Icons.picture_as_pdf, size: 50, color: Colors.red),
        );
      default:
        return Text(messageContent, style: const TextStyle(color: Colors.black87));
    }
  }

  Widget _buildMessageInput(ChatViewModel chatViewModel) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.image), onPressed: () => chatViewModel.sendImage(widget.userId).then((_) => _scrollDown())),
          IconButton(icon: const Icon(Icons.videocam), onPressed: () => chatViewModel.sendVideo(widget.userId).then((_) => _scrollDown())),
          IconButton(icon: const Icon(Icons.attach_file), onPressed: () => chatViewModel.sendDocument(widget.userId).then((_) => _scrollDown())),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(hintText: 'Type a message'),
              focusNode: _focusNode,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              chatViewModel.sendMessage(widget.userId, message: _messageController.text).then((_) => _scrollDown());
              _messageController.clear();
            },
          ),
        ],
      ),
    );
  }

  void _scrollDown() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}






