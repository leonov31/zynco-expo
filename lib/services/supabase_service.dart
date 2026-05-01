import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SupabaseService {
  static final client = Supabase.instance.client;

  static Future<AuthResponse> signIn(String email, String password) =>
      client.auth.signInWithPassword(email: email, password: password);

  static Future<AuthResponse> signUp(String email, String password) =>
      client.auth.signUp(email: email, password: password);

  static Future<void> createUser(String uid, String email, String name, String role) async {
    await client.from('users').insert({'id': uid, 'email': email, 'display_name': name, 'role': role});
    if (role == 'provider') {
      await client.from('providers').insert({
        'user_id': uid, 'display_name': name, 'is_hidden': false,
        'is_online': false, 'subscription_level': 0, 'gallery_urls': [], 'categories': [],
      });
    }
  }

  static Future<List<Map<String, dynamic>>> getProviders({String? category}) async {
    var query = client.from('providers').select().eq('is_hidden', false);
    if (category != null && category.isNotEmpty) {
      query = query.contains('categories', [category]);
    }
    return await query.order('rating', ascending: false);
  }

  static Future<Map<String, dynamic>> getProvider(String id) async =>
      await client.from('providers').select().eq('id', id).single();

  static Future<Map<String, dynamic>?> getMyProvider() async {
    final uid = client.auth.currentUser?.id;
    if (uid == null) return null;
    final res = await client.from('providers').select().eq('user_id', uid);
    return res.isNotEmpty ? res.first : null;
  }

  static Future<void> createBooking({required String providerId, required DateTime scheduledFor, String? note}) async {
    final uid = client.auth.currentUser!.id;
    await client.from('bookings').insert({
      'provider_id': providerId, 'customer_id': uid,
      'scheduled_for': scheduledFor.toIso8601String(), 'note': note, 'status': 'pending',
    });
  }

  static Future<List<Map<String, dynamic>>> getBookings({required String role, String? status}) async {
    final uid = client.auth.currentUser!.id;
    var query = client.from('bookings').select(
      role == 'customer' ? '*, providers(display_name, avatar_url)' : '*, users!customer_id(display_name, avatar_url)'
    );
    if (role == 'customer') {
      query = query.eq('customer_id', uid);
    } else {
      final p = await getMyProvider();
      if (p == null) return [];
      query = query.eq('provider_id', p['id']);
    }
    if (status != null) query = query.eq('status', status);
    return await query.order('scheduled_for', ascending: false);
  }

  static Future<void> updateBookingStatus(String id, String status) async =>
      await client.from('bookings').update({'status': status}).eq('id', id);

  static Future<String> getOrCreateChat(String providerId) async {
    final uid = client.auth.currentUser!.id;
    final ex = await client.from('chats').select().eq('customer_id', uid).eq('provider_id', providerId);
    if (ex.isNotEmpty) return ex.first['id'];
    final res = await client.from('chats').insert({
      'customer_id': uid, 'provider_id': providerId, 'unread_customer': 0, 'unread_provider': 0,
    }).select().single();
    return res['id'];
  }

  static Future<List<Map<String, dynamic>>> getChats(String role) async {
    final uid = client.auth.currentUser!.id;
    if (role == 'customer') {
      return await client.from('chats').select('*, providers(display_name, avatar_url)')
          .eq('customer_id', uid).order('last_message_at', ascending: false);
    } else {
      final p = await getMyProvider();
      if (p == null) return [];
      return await client.from('chats').select('*, users!customer_id(display_name, avatar_url)')
          .eq('provider_id', p['id']).order('last_message_at', ascending: false);
    }
  }

  static Future<List<Map<String, dynamic>>> getMessages(String chatId) async =>
      await client.from('messages').select().eq('chat_id', chatId).order('created_at');

  static Future<void> sendMessage(String chatId, String content) async {
    final uid = client.auth.currentUser!.id;
    await client.from('messages').insert({'chat_id': chatId, 'sender_id': uid, 'content': content, 'is_read': false});
    await client.from('chats').update({'last_message': content, 'last_message_at': DateTime.now().toIso8601String()}).eq('id', chatId);
  }

  static Future<List<Map<String, dynamic>>> getReviews(String providerId) async =>
      await client.from('reviews').select('*, users!user_id(display_name, avatar_url)')
          .eq('provider_id', providerId).eq('is_hidden', false).order('created_at', ascending: false);

  static Future<void> createReview({required String providerId, required int rating, required String comment}) async {
    final uid = client.auth.currentUser!.id;
    await client.from('reviews').insert({'provider_id': providerId, 'user_id': uid, 'rating': rating, 'comment': comment, 'is_hidden': false});
  }

  static Future<void> toggleFavorite(String providerId) async {
    final uid = client.auth.currentUser!.id;
    final ex = await client.from('favorites').select().eq('user_id', uid).eq('provider_id', providerId);
    if (ex.isNotEmpty) {
      await client.from('favorites').delete().eq('user_id', uid).eq('provider_id', providerId);
    } else {
      await client.from('favorites').insert({'user_id': uid, 'provider_id': providerId});
    }
  }

  static Future<List<Map<String, dynamic>>> getFavorites() async {
    final uid = client.auth.currentUser!.id;
    return await client.from('favorites')
        .select('*, providers(id, display_name, avatar_url, categories, rating, city)')
        .eq('user_id', uid);
  }
}
