class UserModel {
  final String id, email, displayName, role;
  final String? avatarUrl;
  UserModel({required this.id, required this.email, required this.displayName, this.avatarUrl, required this.role});
  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id: j['id'], email: j['email'] ?? '', displayName: j['display_name'] ?? '',
    avatarUrl: j['avatar_url'], role: j['role'] ?? 'customer');
}

class ProviderModel {
  final String id, userId, displayName;
  final double? lat, lng, rating;
  final String? city, avatarUrl, bio, galleryVideoUrl;
  final int subscriptionLevel;
  final bool isHidden, isOnline;
  final List<String> galleryUrls, categories;
  ProviderModel({required this.id, required this.userId, required this.displayName,
    this.lat, this.lng, this.city, this.avatarUrl, this.subscriptionLevel = 0,
    this.isHidden = false, this.galleryUrls = const [], this.galleryVideoUrl,
    this.categories = const [], this.bio, this.rating, this.isOnline = false});
  factory ProviderModel.fromJson(Map<String, dynamic> j) => ProviderModel(
    id: j['id'], userId: j['user_id'], displayName: j['display_name'] ?? '',
    lat: (j['lat'] as num?)?.toDouble(), lng: (j['lng'] as num?)?.toDouble(),
    city: j['city'], avatarUrl: j['avatar_url'],
    subscriptionLevel: j['subscription_level'] ?? 0,
    isHidden: j['is_hidden'] ?? false,
    galleryUrls: List<String>.from(j['gallery_urls'] ?? []),
    galleryVideoUrl: j['gallery_video_url'],
    categories: List<String>.from(j['categories'] ?? []),
    bio: j['bio'], rating: (j['rating'] as num?)?.toDouble(),
    isOnline: j['is_online'] ?? false);
}

class BookingModel {
  final String id, providerId, customerId, status;
  final DateTime scheduledFor, createdAt;
  final String? note;
  String? providerName, customerName;
  BookingModel({required this.id, required this.providerId, required this.customerId,
    required this.scheduledFor, this.note, required this.status, required this.createdAt,
    this.providerName, this.customerName});
  factory BookingModel.fromJson(Map<String, dynamic> j) => BookingModel(
    id: j['id'], providerId: j['provider_id'], customerId: j['customer_id'],
    scheduledFor: DateTime.parse(j['scheduled_for']),
    note: j['note'], status: j['status'] ?? 'pending',
    createdAt: DateTime.parse(j['created_at']));
}

class ChatModel {
  final String id, customerId, providerId;
  final int unreadCustomer, unreadProvider;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  String? otherUserName, otherUserAvatar;
  ChatModel({required this.id, required this.customerId, required this.providerId,
    this.unreadCustomer = 0, this.unreadProvider = 0, this.lastMessage,
    this.lastMessageAt, this.otherUserName, this.otherUserAvatar});
  factory ChatModel.fromJson(Map<String, dynamic> j) => ChatModel(
    id: j['id'], customerId: j['customer_id'], providerId: j['provider_id'],
    unreadCustomer: j['unread_customer'] ?? 0, unreadProvider: j['unread_provider'] ?? 0,
    lastMessage: j['last_message'],
    lastMessageAt: j['last_message_at'] != null ? DateTime.parse(j['last_message_at']) : null);
}

class MessageModel {
  final String id, chatId, senderId, content;
  final DateTime createdAt;
  final bool isRead;
  MessageModel({required this.id, required this.chatId, required this.senderId,
    required this.content, required this.createdAt, this.isRead = false});
  factory MessageModel.fromJson(Map<String, dynamic> j) => MessageModel(
    id: j['id'], chatId: j['chat_id'], senderId: j['sender_id'],
    content: j['content'], createdAt: DateTime.parse(j['created_at']),
    isRead: j['is_read'] ?? false);
}

class ReviewModel {
  final String id, providerId, userId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  String? userName;
  ReviewModel({required this.id, required this.providerId, required this.userId,
    required this.rating, this.comment, required this.createdAt, this.userName});
  factory ReviewModel.fromJson(Map<String, dynamic> j) => ReviewModel(
    id: j['id'], providerId: j['provider_id'], userId: j['user_id'],
    rating: j['rating'] ?? 5, comment: j['comment'],
    createdAt: DateTime.parse(j['created_at']));
}