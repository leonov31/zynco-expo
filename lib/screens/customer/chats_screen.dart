
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';
import '../../models/app_models.dart';
import '../../providers/auth_provider.dart';
import '../shared/chat_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});
  @override State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  List<ChatModel> _chats = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final uid = context.read<AuthProvider>().user?.id;
    if (uid == null) return;
    try {
      final res = await Supabase.instance.client.from('chats').select().eq('customer_id', uid).order('last_message_at', ascending: false);
      setState(() { _chats = (res as List).map((e) => ChatModel.fromJson(e)).toList(); _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZyncoColors.background,
      appBar: AppBar(title: const Text('Messages'), backgroundColor: ZyncoColors.background),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: ZyncoColors.primary))
        : _chats.isEmpty
          ? const Center(child: Text('No messages yet', style: TextStyle(color: ZyncoColors.textSecondary)))
          : ListView.builder(
              itemCount: _chats.length,
              itemBuilder: (c, i) {
                final chat = _chats[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: ZyncoColors.primary,
                    child: Text((chat.otherUserName ?? 'P')[0], style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(chat.otherUserName ?? 'Provider', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  subtitle: Text(chat.lastMessage ?? '', style: const TextStyle(color: ZyncoColors.textSecondary),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (chat.lastMessageAt != null)
                        Text(DateFormat('HH:mm').format(chat.lastMessageAt!), style: const TextStyle(color: ZyncoColors.textSecondary, fontSize: 11)),
                      if (chat.unreadCustomer > 0)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: ZyncoColors.primary, shape: BoxShape.circle),
                          child: Text('${chat.unreadCustomer}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                        ),
                    ],
                  ),
                  onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => ChatScreen(chatId: chat.id))),
                );
              },
            ),
    );
  }
}
