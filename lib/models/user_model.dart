class UserModel {
  final int id;
  final String name;
  final String email;
  final String? lastMessage;
  final String? lastMessageAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.lastMessage,
    this.lastMessageAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      lastMessage: json['lastMessage']?.toString(),
      lastMessageAt: json['lastMessageAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email};
}
