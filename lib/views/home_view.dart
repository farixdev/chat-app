import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Colors.deepPurple;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Messages",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          )
        ],
      ),

      body: Column(
        children: [

          /// 🔍 SEARCH BAR (rounded like screenshot)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                onChanged: controller.updateSearch,
                decoration: const InputDecoration(
                  hintText: "Search conversations...",
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// 🔘 FILTER CHIPS
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                _chip("All", "all", primary),
                _chip("Unread (0)", "unread", primary),
                _chip("Recent (0)", "recent", primary),
                _chip("Active (0)", "active", primary),
              ],
            ),
          ),

          const SizedBox(height: 15),

          /// 💬 CONTENT
          Expanded(
            child: Obx(() {
              if (controller.chats.isEmpty) {
                return _emptyState(primary);
              }

              final chats = controller.chats;

              return ListView.builder(
                itemCount: chats.length,
                itemBuilder: (_, i) {
                  final chat = chats[i];
                  final user = controller.getOtherUser(chat);

                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(user?.displayName ?? "Unknown"),
                    subtitle: Text(chat.lastMessage ?? ""),
                    trailing: Text(
                      controller.formatLastMessageTime(chat.updatedAt),
                      style: const TextStyle(fontSize: 11),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),

      /// ➕ FLOAT BUTTON (like screenshot)
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primary,
        onPressed: () {},
        icon: Icon(Icons.chat,color: Colors.white,),
        label: Text("New Chat",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        ),
      ),
    );
  }

  /// 🔘 CHIP STYLE (rounded + purple fill)
  Widget _chip(String text, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Obx(() {
        final selected = controller.activeFilter == value;

        return ChoiceChip(
          label: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black,
            ),
          ),
          selected: selected,
          selectedColor: color,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          onSelected: (_) => controller.setFilter(value),
        );
      }),
    );
  }

  /// ❌ EMPTY STATE (MATCHED)
  Widget _emptyState(Color primary) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          /// ICON CIRCLE
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.chat_bubble_outline,
                size: 40, color: primary),
          ),

          const SizedBox(height: 20),

          const Text(
            "No conversations yet",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 8),

          const Text(
            "Connect with friends and start meaningful conversations",
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          /// PRIMARY BUTTON
          SizedBox(
            width: 220,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {},
              child:Text("Find People",
              style:TextStyle(
                 color: Colors.white,
              ) ,
                ),
            ),
          ),

          const SizedBox(height: 10),

          /// OUTLINE BUTTON
          SizedBox(
            width: 220,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {},
              child: const Text("View Friends"),
            ),
          ),
        ],
      ),
    );
  }
}