import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../theme.dart';
import '../../services/supabase_service.dart';
import '../../widgets/zynco_avatar.dart';

class ProviderChatsScreen extends StatefulWidget {
  const ProviderChatsScreen({super.key});
  @override State<ProviderChatsScreen> createState() => _ProviderChatsScreenState();
}

class _ProviderChatsScreenState extends State<ProviderChatsScreen> {
  List<Map<String, dynamic>> _chats = [];
  bool _loading = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final data = await SupabaseService.getChats('provider');
    if (mounted) setState(() { _chats = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZyncoColors.background,
      appBar: AppBar(title: const Text('Messages')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: ZyncoColors.primary))
          : _chats.isEmpty
              ? const Center(child: Text('No conversations yet', style: TextStyle(color: ZyncoColors.textSecondary)))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    itemCount: _chats.length,
                    itemBuilder: (_, i) {
                      final chat = _chats[i];
                      final user = chat['users'] as Map<String, dynamic>? ?? {};
                      final unread = (chat['unread_provider'] ?? 0) as int;
                      final lastAt = chat['last_message_at'] != null ? DateTime.tryParse(chat['last_message_at']) : null;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: ZyncoAvatar(url: user['avatar_url'], name: user['display_name'] ?? '?', size: 48),
                        title: Text(user['display_name'] ?? 'Customer', style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(chat['last_message'] ?? 'No messages', style: const TextStyle(color: ZyncoColors.textSecondary, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                          if (lastAt != null) Text(timeago.format(lastAt), style: const TextStyle(color: ZyncoColors.textSecondary, fontSize: 11)),
                          if (unread > 0) ...[const SizedBox(height: 4), Container(width: 18, height: 18, decoration: const BoxDecoration(color: ZyncoColors.primary, shape: BoxShape.circle), child: Center(child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))))],
                        ]),
                        onTap: () => context.push('/chat/${chat['id']}'),
                      );
                    },
                  ),
                ),
    );
  }
}
