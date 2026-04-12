class MessageModel {
  final int id;
  final int senderId;
  final int receiverId;
  final String content;
  final String? createdAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.createdAt,
  });

  /// Parses the raw [createdAt] string into a local [DateTime], or null if missing.
  DateTime? get parsedCreatedAt {
    if (createdAt == null || createdAt!.isEmpty) return null;
    try {
      return DateTime.parse(createdAt!).toLocal();
    } catch (_) {
      return null;
    }
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as int,
      senderId: json['senderId'] as int,
      receiverId: json['receiverId'] as int,
      content: json['content'] as String,
      createdAt: json['created_at']?.toString(),
    );
  }
}
