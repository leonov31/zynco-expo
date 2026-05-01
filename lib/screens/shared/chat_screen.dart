
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';
import '../../models/app_models.dart';
import '../../providers/auth_provider.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  const ChatScreen({super.key, required this.chatId});
  @override State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  List<MessageModel> _messages = [];
  final _sb = Supabase.instance.client;
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _subscribeRealtime();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final res = await _sb.from('messages').select().eq('chat_id', widget.chatId).order('created_at');
    setState(() => _messages = (res as List).map((e) => MessageModel.fromJson(e)).toList());
    _scrollBottom();
  }

  void _subscribeRealtime() {
    _channel = _sb.channel('messages:${widget.chatId}')
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public', table: 'messages',
        filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'chat_id', value: widget.chatId),
        callback: (payload) {
          final msg = MessageModel.fromJson(payload.newRecord);
          setState(() => _messages.add(msg));
          _scrollBottom();
        },
      )
      .subscribe();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    final uid = context.read<AuthProvider>().user?.id;
    if (uid == null) return;
    _ctrl.clear();
    await _sb.from('messages').insert({'chat_id': widget.chatId, 'sender_id': uid, 'content': text});
    await _sb.from('chats').update({'last_message': text, 'last_message_at': DateTime.now().toIso8601String()}).eq('id', widget.chatId);
  }

  void _scrollBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().user?.id;
    return Scaffold(
      backgroundColor: ZyncoColors.background,
      appBar: AppBar(title: const Text('Chat'), backgroundColor: ZyncoColors.background),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (c, i) {
                final m = _messages[i];
                final isMe = m.senderId == uid;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(c).size.width * 0.75),
                    decoration: BoxDecoration(
                      gradient: isMe ? ZyncoColors.gradient : null,
                      color: isMe ? null : ZyncoColors.surface2,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 4), bottomRight: Radius.circular(isMe ? 4 : 16),
                      ),
                    ),
                    child: Text(m.content, style: const TextStyle(color: Colors.white)),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: ZyncoColors.surface, border: Border(top: BorderSide(color: ZyncoColors.border))),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(hintText: 'Type a message...', border: InputBorder.none, filled: false),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                  ),
                ),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(gradient: ZyncoColors.gradient, shape: BoxShape.circle),
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
