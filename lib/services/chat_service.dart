import 'package:shared_preferences/shared_preferences.dart';

class ChatService {
  static const String _chatKey = 'single_chat_data';
  static const String _currentUser = 'me'; // 当前用户ID

  // 初始化默认聊天记录
  static Future<void> initDefaultChat() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_chatKey)) return;

    // 创建默认聊天记录
    final now = DateTime.now();
    final chatTime = DateTime(now.year, now.month, now.day, 12, 10); // 12:10

    final defaultChat = {
      'contact': {
        'id': 'chen',
        'name': '陈科学',
        'avatar': 'lib/assets/default_avatar.png',
      },
      'messages': [
        {
          'sender': 'chen',
          'content': '你去哪吃饭了',
          'time': chatTime.millisecondsSinceEpoch.toString(),
          'isMe': false,
        }
      ],
      'lastMessage': '你去哪吃饭了',
      'lastMessageTime': chatTime.millisecondsSinceEpoch.toString(),
    };

    await prefs.setString(_chatKey, _encodeChat(defaultChat));
  }

  // 获取聊天记录
  static Future<Map<String, dynamic>> getChat() async {
    final prefs = await SharedPreferences.getInstance();
    final chatData = prefs.getString(_chatKey);
    return chatData != null ? _decodeChat(chatData) : {};
  }

  // 发送消息
  static Future<void> sendMessage(String content) async {
    final prefs = await SharedPreferences.getInstance();
    final chat = await getChat();

    if (chat.isEmpty) return;

    final newMessage = {
      'sender': _currentUser,
      'content': content,
      'time': DateTime.now().millisecondsSinceEpoch.toString(),
      'isMe': true,
    };

    chat['messages'].add(newMessage);
    chat['lastMessage'] = content;
    chat['lastMessageTime'] = newMessage['time'];

    await prefs.setString(_chatKey, _encodeChat(chat));
  }

  // 私有方法：编码聊天数据
  static String _encodeChat(Map<String, dynamic> chat) {
    final contact = chat['contact'] as Map;
    final messages = chat['messages'] as List;

    final contactStr = '${contact['id']}|${contact['name']}|${contact['avatar']}';
    final messagesStr = messages.map((msg) {
      return '${msg['sender']}^${msg['content']}^${msg['time']}^${msg['isMe']}';
    }).join('~');

    return '$contactStr;${chat['lastMessage']};${chat['lastMessageTime']};$messagesStr';
  }

  // 私有方法：解码聊天数据
  static Map<String, dynamic> _decodeChat(String chatStr) {
    final parts = chatStr.split(';');
    final contactParts = parts[0].split('|');

    final messages = parts[3].split('~').map((msgStr) {
      final msgParts = msgStr.split('^');
      return {
        'sender': msgParts[0],
        'content': msgParts[1],
        'time': msgParts[2],
        'isMe': msgParts[3] == 'true',
      };
    }).toList();

    return {
      'contact': {
        'id': contactParts[0],
        'name': contactParts[1],
        'avatar': contactParts[2],
      },
      'messages': messages,
      'lastMessage': parts[1],
      'lastMessageTime': parts[2],
    };
  }
}