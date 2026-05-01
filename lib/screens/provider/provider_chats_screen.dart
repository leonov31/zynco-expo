
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';
import '../../models/app_models.dart';
import '../../providers/auth_provider.dart';
import '../shared/chat_screen.dart';

class ProviderChatsScreen extends StatefulWidget {
  const ProviderChatsScreen({super.key});
  @override State<ProviderChatsScreen> createState() => _ProviderChatsScreenState();
}

class _ProviderChatsScreenState extends State<ProviderChatsScreen> {
  List<ChatModel> _chats = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final prov = context.read<AuthProvider>().providerProfile;
    if (prov == null) return;
    try {
      final res = await Supabase.instance.client.from('chats').select().eq('provider_id', prov.id).order('last_message_at', ascending: false);
      setState(() { _chats = (res as List).map((e) => ChatModel.fromJson(e)).toList(); _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZyncoColors.background,
      appBar: AppBar(title: const Text('Messages'), backgroundColor: ZyncoColors.background),
      body: _loading ? const Center(child: CircularProgressIndicator(color: ZyncoColors.primary))
        : _chats.isEmpty ? const Center(child: Text('No messages yet', style: TextStyle(color: ZyncoColors.textSecondary)))
        : ListView.builder(
            itemCount: _chats.length,
            itemBuilder: (c, i) {
              final chat = _chats[i];
              return ListTile(
                leading: CircleAvatar(backgroundColor: ZyncoColors.primary, child: Text((chat.otherUserName ?? 'C')[0], style: const TextStyle(color: Colors.white))),
                title: Text(chat.otherUserName ?? 'Customer', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                subtitle: Text(chat.lastMessage ?? '', style: const TextStyle(color: ZyncoColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: chat.unreadProvider > 0
                  ? Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: ZyncoColors.primary, shape: BoxShape.circle),
                    child: Text('${chat.unreadProvider}', style: const TextStyle(color: Colors.white, fontSize: 11)))
                  : null,
                onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => ChatScreen(chatId: chat.id))),
              );
            },
          ),
    );
  }
}
