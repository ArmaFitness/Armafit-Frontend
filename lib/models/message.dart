class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final bool isRead;
  final DateTime createdAt;
  final String? senderName;
  final String? receiverName;

  const Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.isRead,
    required this.createdAt,
    this.senderName,
    this.receiverName,
  });

  factory Message.fromJson(Map<String, dynamic> j) => Message(
        id: j['id']?.toString() ?? '',
        senderId: j['senderId']?.toString() ?? '',
        receiverId: j['receiverId']?.toString() ?? '',
        content: j['content'] ?? '',
        isRead: j['isRead'] ?? false,
        createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
        senderName: j['sender']?['name'],
        receiverName: j['receiver']?['name'],
      );
}

class Conversation {
  final String partnerId;
  final String partnerName;
  final String partnerSurname;
  final Message lastMessage;

  const Conversation({
    required this.partnerId,
    required this.partnerName,
    required this.partnerSurname,
    required this.lastMessage,
  });

  factory Conversation.fromJson(Map<String, dynamic> j, String currentUserId) {
    final senderId = j['senderId']?.toString() ?? '';
    final bool iSent = senderId == currentUserId;

    final partnerId = iSent
        ? (j['receiverId']?.toString() ?? '')
        : senderId;
    final partnerName = iSent
        ? (j['receiver']?['name'] ?? j['receiverName'] ?? '')
        : (j['sender']?['name'] ?? j['senderName'] ?? '');
    final partnerSurname = iSent
        ? (j['receiver']?['surname'] ?? j['receiverSurname'] ?? '')
        : (j['sender']?['surname'] ?? j['senderSurname'] ?? '');

    return Conversation(
      partnerId: partnerId,
      partnerName: partnerName,
      partnerSurname: partnerSurname,
      lastMessage: Message.fromJson(j),
    );
  }

  String get displayName =>
      '$partnerName $partnerSurname'.trim().isNotEmpty
          ? '$partnerName $partnerSurname'.trim()
          : 'User $partnerId';
}
