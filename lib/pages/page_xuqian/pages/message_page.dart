import 'package:flutter/material.dart';

import '../../../services/chat_service.dart';
import 'auth/chat_detail_page.dart';


class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  late Future<Map<String, dynamic>> _chatData;

  @override
  void initState() {
    super.initState();
    _loadChatData();
  }

  void _loadChatData() {
    setState(() {
      _chatData = ChatService.getChat();
    });
  }

  String _formatTime(int timestamp) {
    final time = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();

    if (time.year == now.year &&
        time.month == now.month &&
        time.day == now.day) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (time.year == now.year &&
        time.month == now.month &&
        time.day == now.day - 1) {
      return '昨天';
    } else {
      return '${time.month}/${time.day}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '消息',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _chatData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('暂无聊天记录'));
          }

          final chat = snapshot.data!;
          // 明确指定类型为 Map<String, dynamic>
          final contact = chat['contact'] as Map<String, dynamic>;
          final lastMessage = chat['lastMessage'] as String;
          final lastTime = int.parse(chat['lastMessageTime'] as String);

          // 截断消息内容
          final displayMessage = lastMessage.length > 10
              ? '${lastMessage.substring(0, 10)}...'
              : lastMessage;

          return ListView(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage(contact['avatar'] as String),
                ),
                title: Text(contact['name'] as String),
                subtitle: Text(displayMessage),
                trailing: Text(_formatTime(lastTime)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailPage(
                        contact: contact,
                        onMessageSent: _loadChatData,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}