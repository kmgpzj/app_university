// lib/models/live_broadcast.dart
class LiveBroadcast {
  final int? id;
  final String title;
  final String location;
  final String date;
  final String time;
  final int views;
  final String postDate;
  final String imageUrl;

  LiveBroadcast({
    this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.time,
    required this.views,
    required this.postDate,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'date': date,
      'time': time,
      'views': views,
      'postDate': postDate,
      'imageUrl': imageUrl,
    };
  }

  factory LiveBroadcast.fromMap(Map<String, dynamic> map) {
    return LiveBroadcast(
      id: map['id'],
      title: map['title'] ?? '直播预告',
      location: map['location'] ?? '地点待定',
      date: map['date'] ?? '日期待定',
      time: map['time'] ?? '时间待定',
      views: _parseViews(map['views']),
      postDate: map['postDate'] ?? '1970-01-01',
      imageUrl: map['imageUrl'] ?? 'lib/assets/images/p2.jpg',
    );
  }

  static int _parseViews(dynamic views) {
    if (views is int) return views;
    if (views is String) {
      if (views.contains('万')) {
        return (double.parse(views.replaceAll('万', '')) * 10000).toInt();
      }
      return int.tryParse(views) ?? 0;
    }
    return 0;
  }

  String get formattedViews {
    if (views >= 10000) {
      return '${(views / 10000).toStringAsFixed(1)}万';
    }
    return views.toString();
  }
}