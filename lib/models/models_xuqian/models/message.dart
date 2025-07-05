class Message {
  final String sender;
  final String content;
  final String time;
  final String avatarPath;

  Message({
    required this.sender,
    required this.content,
    required this.time,
    this.avatarPath = 'lib/assets/default_avatar.png',
  });
}