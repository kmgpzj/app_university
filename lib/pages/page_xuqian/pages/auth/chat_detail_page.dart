import 'package:flutter/material.dart';

import 'dart:io';

import '../../../../services/chat_service.dart';
import '../../../../services/user_service.dart'; // 添加这行导入

class ChatDetailPage extends StatefulWidget {
  final Map<String, dynamic> contact;
  final VoidCallback onMessageSent;

  const ChatDetailPage({
    super.key,
    required this.contact,
    required this.onMessageSent,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late Future<Map<String, dynamic>> _chatData;
  late Future<Map<String, dynamic>> _userData;

  @override
  void initState() {
    super.initState();
    _loadChatData();
    _userData = UserService.getUserData();
  }

  void _loadChatData() {
    setState(() {
      _chatData = ChatService.getChat();
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    await ChatService.sendMessage(_messageController.text);
    _messageController.clear();
    _loadChatData();
    widget.onMessageSent();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(int timestamp) {
    final time = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(widget.contact['avatar'] as String),
            ),
            const SizedBox(width: 10),
            Text(widget.contact['name'] as String),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _chatData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return const Center(child: Text('加载聊天记录失败'));
                }

                final chat = snapshot.data!;
                final messages = chat['messages'] as List;

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[messages.length - 1 - index];
                    final isMe = message['isMe'] as bool;

                    return FutureBuilder<Map<String, dynamic>>(
                      future: _userData,
                      builder: (context, userSnapshot) {
                        final userAvatar = userSnapshot.hasData
                            ? userSnapshot.data!['avatar']
                            : 'lib/assets/default_avatar.png';

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: isMe
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            if (!isMe)
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: AssetImage(widget.contact['avatar']),
                              ),
                            const SizedBox(width: 8),
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.7,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.blue : Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    message['content'] as String,
                                    style: TextStyle(
                                      color: isMe ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatTime(int.parse(message['time'] as String)),
                                    style: TextStyle(
                                      color: isMe
                                          ? Colors.white.withOpacity(0.7)
                                          : Colors.grey[600],
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isMe)
                              const SizedBox(width: 8),
                            if (isMe)
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: userAvatar.startsWith('lib/assets/')
                                    ? AssetImage(userAvatar)
                                    : FileImage(File(userAvatar)) as ImageProvider,
                              ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: '输入消息...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}