import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.isFromUser,
    required this.timestamp,
    this.productInfo,
  });

  final String id;
  final String text;
  final bool isFromUser;
  final DateTime timestamp;
  final ProductInfo? productInfo;

  @override
  List<Object?> get props => [id, text, isFromUser, timestamp, productInfo];
}

class ProductInfo extends Equatable {
  const ProductInfo({
    required this.name,
    required this.price,
    required this.imagePath,
  });

  final String name;
  final double price;
  final String imagePath;

  @override
  List<Object> get props => [name, price, imagePath];
}

class ChatContact extends Equatable {
  const ChatContact({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.timestamp,
    this.unreadCount = 0,
    this.isOnline = false,
  });

  final String id;
  final String name;
  final String lastMessage;
  final DateTime timestamp;
  final int unreadCount;
  final bool isOnline;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} дн назад';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ч назад';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} мин назад';
    } else {
      return 'только что';
    }
  }

  @override
  List<Object> get props =>
      [id, name, lastMessage, timestamp, unreadCount, isOnline];
}
