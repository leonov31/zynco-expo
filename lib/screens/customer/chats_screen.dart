import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../theme.dart';
import '../../services/supabase_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/zynco_avatar.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});
  @override State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  List<Map<String, dynamic>> _chats = [];
  bool _loading = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final role = context.read<AuthProvider>().role ?? 'customer';
    final data = await SupabaseService.getChats(role);
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
                      final other = (chat['providers'] ?? chat['users']) as Map<String, dynamic>? ?? {};
                      final unread = (chat['unread_customer'] ?? 0) as int;
                      final lastAt = chat['last_message_at'] != null ? DateTime.tryParse(chat['last_message_at']) : null;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: ZyncoAvatar(url: other['avatar_url'], name: other['display_name'] ?? '?', size: 48),
                        title: Text(other['display_name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(chat['last_message'] ?? 'Start a conversation', style: const TextStyle(color: ZyncoColors.textSecondary, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                          if (lastAt != null) Text(timeago.format(lastAt), style: const TextStyle(color: ZyncoColors.textSecondary, fontSize: 11)),
                          if (unread > 0) ...[
                            const SizedBox(height: 4),
                            Container(
                              width: 18, height: 18,
                              decoration: const BoxDecoration(color: ZyncoColors.primary, shape: BoxShape.circle),
                              child: Center(child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                            ),
                          ],
                        ]),
                        onTap: () => context.push('/chat/${chat['id']}'),
                      );
                    },
                  ),
                ),
    );
  }
}
