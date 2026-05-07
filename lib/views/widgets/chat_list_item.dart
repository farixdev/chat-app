import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controllers/home_controller.dart';
import 'package:myapp/models/chat_model.dart';
import 'package:myapp/models/user_model.dart';

class ChatListItem extends StatelessWidget {
  final ChatModel chat;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ChatListItem({
    super.key,
    required this.chat,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    final UserModel? user = controller.getOtherUser(chat);
    final unread = controller.getUnreadCount(chat);

    final name = user?.displayName ?? 'Unknown';
    final lastMsg = chat.lastMessage ?? '';
    final imageUrl = user?.photoURL ?? '';

    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,

      leading: CircleAvatar(
        radius: 25,
        backgroundImage: imageUrl.isNotEmpty
            ? NetworkImage(imageUrl)
            : null,
        child: imageUrl.isEmpty
            ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?')
            : null,
      ),

      title: Text(
        name,
        style: TextStyle(
          fontWeight: unread > 0 ? FontWeight.bold : FontWeight.normal,
        ),
      ),

      subtitle: Text(
        lastMsg,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.normal,
        ),
      ),

      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            controller.formatLastMessageTime(chat.updatedAt),
            style: const TextStyle(fontSize: 11),
          ),
          const SizedBox(height: 5),
          if (unread > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: Text(
                unread.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }
}