import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/message_provider.dart';
import 'chat_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessageProvider>().loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final currentUserId =
        context.watch<AuthProvider>().user?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<MessageProvider>().loadConversations(),
          ),
        ],
      ),
      body: Consumer<MessageProvider>(
        builder: (_, prov, __) {
          if (prov.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (prov.conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 64, color: cs.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text('No conversations yet',
                      style: TextStyle(color: cs.onSurfaceVariant)),
                ],
              ),
            );
          }
          return ListView.separated(
            itemCount: prov.conversations.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final conv = prov.conversations[i];
              final msg = conv.lastMessage;
              final iMine = msg.senderId == currentUserId;
              final unread = !iMine && !msg.isRead;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      unread ? cs.primary : cs.primaryContainer,
                  child: Text(
                    conv.partnerName.isNotEmpty
                        ? conv.partnerName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                        color: unread
                            ? cs.onPrimary
                            : cs.onPrimaryContainer),
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        conv.displayName,
                        style: TextStyle(
                            fontWeight: unread
                                ? FontWeight.bold
                                : FontWeight.normal),
                      ),
                    ),
                    Text(
                      _formatTime(msg.createdAt),
                      style: TextStyle(
                          fontSize: 11,
                          color: unread ? cs.primary : cs.onSurfaceVariant),
                    ),
                  ],
                ),
                subtitle: Text(
                  '${iMine ? 'You: ' : ''}${msg.content}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontWeight:
                          unread ? FontWeight.w500 : FontWeight.normal,
                      color:
                          unread ? cs.onSurface : cs.onSurfaceVariant),
                ),
                onTap: () {
                  context.read<MessageProvider>().clearMessages();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        userId: conv.partnerId,
                        userName: conv.displayName,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final local = dt.toLocal();
    if (now.difference(local).inDays == 0) {
      return DateFormat('HH:mm').format(local);
    } else if (now.difference(local).inDays < 7) {
      return DateFormat('EEE').format(local);
    }
    return DateFormat('dd/MM').format(local);
  }
}
