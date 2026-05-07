import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controllers/friend_requests_controller.dart';
import 'package:myapp/models/friend_request_model.dart';
import 'package:myapp/models/user_model.dart';

class FriendRequestView extends GetView<FriendRequestsController> {
  const FriendRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),

      appBar: AppBar(
        title: const Text("Friend Requests"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),
          _buildTabs(),
          const SizedBox(height: 10),

          Expanded(
            child: Obx(() {
              if (controller.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.selectedTabIndex == 0) {
                return _buildReceivedList();
              } else {
                return _buildSentList();
              }
            }),
          ),
        ],
      ),
    );
  }

  // 🔘 TABS (LIKE SCREENSHOT)
  Widget _buildTabs() {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: [
              _tab("Received (${controller.receivedRequests.length})", 0),
              _tab("Sent (${controller.sentRequests.length})", 1),
            ],
          ),
        ),
      );
    });
  }

  Widget _tab(String text, int index) {
    final isSelected = controller.selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.deepPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 📥 RECEIVED LIST
  Widget _buildReceivedList() {
    if (controller.receivedRequests.isEmpty) {
      return const Center(child: Text("No requests"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.receivedRequests.length,
      itemBuilder: (context, index) {
        final request = controller.receivedRequests[index];
        return _requestCard(request, isReceived: true);
      },
    );
  }

  // 📤 SENT LIST
  Widget _buildSentList() {
    if (controller.sentRequests.isEmpty) {
      return const Center(child: Text("No sent requests"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.sentRequests.length,
      itemBuilder: (context, index) {
        final request = controller.sentRequests[index];
        return _requestCard(request, isReceived: false);
      },
    );
  }

  // 🎴 CARD UI (MATCH SCREENSHOT)
  Widget _requestCard(FriendRequestModel request, {required bool isReceived}) {
    final userId = isReceived ? request.senderId : request.receiverId;
    final UserModel? user = controller.getUser(userId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
          )
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // 👤 USER INFO
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.deepPurple.shade100,
                child: Text(
                  user?.displayName.substring(0, 1).toUpperCase() ?? "?",
                ),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? "Loading...",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.email ?? "",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              _statusBadge(request.status),
            ],
          ),

          const SizedBox(height: 12),

          // 🔘 ACTION BUTTONS
          if (isReceived && request.status == FriendRequestStatus.pending)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => controller.rejectRequest(request),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Decline"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.acceptRequest(request),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Accept"),
                  ),
                ),
              ],
            ),

          if (!isReceived && request.status == FriendRequestStatus.pending)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => controller.cancelRequest(request),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 🟢 STATUS BADGE
  Widget _statusBadge(FriendRequestStatus status) {
    Color color;
    IconData icon;
    String text;

    switch (status) {
      case FriendRequestStatus.accepted:
        color = Colors.green;
        icon = Icons.check_circle;
        text = "Accepted";
        break;
      case FriendRequestStatus.declined:
        color = Colors.red;
        icon = Icons.cancel;
        text = "Declined";
        break;
      default:
        color = Colors.orange;
        icon = Icons.hourglass_bottom;
        text = "Pending";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 12),
          ),
        ],
      ),
    );
  }
}