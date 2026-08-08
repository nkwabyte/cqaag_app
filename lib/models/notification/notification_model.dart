import 'package:cloud_firestore/cloud_firestore.dart';

class SystemNotification {
  final String id;
  final String title;
  final String body;
  final String target;
  final DateTime? createdAt;
  final bool isRead;

  const SystemNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.target,
    this.createdAt,
    this.isRead = false,
  });

  factory SystemNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    DateTime? parsedDate;
    if (data['created_at'] != null) {
      if (data['created_at'] is Timestamp) {
        parsedDate = (data['created_at'] as Timestamp).toDate();
      } else if (data['created_at'] is String) {
        parsedDate = DateTime.tryParse(data['created_at']);
      }
    }

    return SystemNotification(
      id: doc.id,
      title: data['title'] as String? ?? 'System Notification',
      body: data['body'] as String? ?? '',
      target: data['target'] as String? ?? 'all',
      createdAt: parsedDate ?? DateTime.now(),
      isRead: false,
    );
  }

  SystemNotification copyWith({
    String? id,
    String? title,
    String? body,
    String? target,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return SystemNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      target: target ?? this.target,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
