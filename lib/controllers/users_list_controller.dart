import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controllers/auth_controller.dart';
import 'package:myapp/models/friend_request_model.dart';
import 'package:myapp/models/friendship_model.dart';
import 'package:myapp/models/user_model.dart';
import 'package:myapp/routes/app_routes.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:uuid/uuid.dart';

enum UserRelationshipStatus {
  none,
  friendRequestSent,
  friendRequestReceived,
  friends,
  blocked,
}

class UserListController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService(); // Fixed: removed redundant late final
  final AuthController _authController = Get.find<AuthController>();
  final Uuid _uuid = const Uuid();

  final RxList<UserModel> _users = <UserModel>[].obs;
  final RxList<UserModel> _filteredUsers = <UserModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _searchQuery = ''.obs;
  final RxString _error = ''.obs;

  final RxMap<String, UserRelationshipStatus> _userRelationships =
      <String, UserRelationshipStatus>{}.obs;

  final RxList<FriendRequestModel> _sentRequests = <FriendRequestModel>[].obs;
  final RxList<FriendRequestModel> _receivedRequests = <FriendRequestModel>[].obs;
  final RxList<FriendshipModel> _friendships = <FriendshipModel>[].obs;

  List<UserModel> get users => _users;
  List<UserModel> get filteredUsers => _filteredUsers;
  bool get isLoading => _isLoading.value;
  String get searchQuery => _searchQuery.value;
  String get error => _error.value;
  Map<String, UserRelationshipStatus> get userRelationships => _userRelationships;

  @override
  void onInit() {
    super.onInit();
    _loadUsers();
    _loadRelationships();
    debounce(_searchQuery, (_) => _filterUsers(),
        time: const Duration(milliseconds: 300));
  }

  void _loadUsers() {
    _users.bindStream(_firestoreService.getAllUsersStream());

    ever(_users, (List<UserModel> userList) {
      final currentUserId = _authController.user?.uid;
      final otherUsers = userList.where((u) => u.id != currentUserId).toList();

      if (_searchQuery.value.isEmpty) {
        _filteredUsers.value = otherUsers;
      } else {
        _filterUsers();
      }
    });
  }

  void _loadRelationships() {
    final currentUserId = _authController.user?.uid;
    if (currentUserId == null) return;

    // Fixed: _sentRequests and _receivedRequests were both bound to the same stream.
    // Sent requests use getSentFriendRequestStream; received use getFriendRequestsStream.
    _sentRequests.bindStream(
      _firestoreService.getSentFriendRequestStream(currentUserId),
    );

    _receivedRequests.bindStream(
      _firestoreService.getFriendRequestsStream(currentUserId),
    );

    _friendships.bindStream(
      _firestoreService.getFriendsStream(currentUserId).cast<List<FriendshipModel>>(),
    );

    ever(_sentRequests, (_) => _updateAllRelationshipStatuses());
    ever(_receivedRequests, (_) => _updateAllRelationshipStatuses());
    ever(_friendships, (_) => _updateAllRelationshipStatuses());
    ever(_users, (_) => _updateAllRelationshipStatuses());
  }

  void _updateAllRelationshipStatuses() {
    final currentUserId = _authController.user?.uid;
    if (currentUserId == null) return;

    for (var user in _users) {
      if (user.id != currentUserId) {
        _userRelationships[user.id] = _calculateStatus(user.id);
      }
    }
  }

  UserRelationshipStatus _calculateStatus(String userId) {
    final currentUserId = _authController.user?.uid;
    if (currentUserId == null) return UserRelationshipStatus.none;

    final friendship = _friendships.firstWhereOrNull(
      (f) =>
          (f.user1Id == currentUserId && f.user2Id == userId) ||
          (f.user1Id == userId && f.user2Id == currentUserId),
    );

    if (friendship != null) {
      return friendship.isBlocked
          ? UserRelationshipStatus.blocked
          : UserRelationshipStatus.friends;
    }

    final sent = _sentRequests.firstWhereOrNull(
      (r) => r.receiverId == userId && r.status == FriendRequestStatus.pending,
    );
    if (sent != null) return UserRelationshipStatus.friendRequestSent;

    final received = _receivedRequests.firstWhereOrNull(
      (r) => r.senderId == userId && r.status == FriendRequestStatus.pending,
    );
    if (received != null) return UserRelationshipStatus.friendRequestReceived;

    return UserRelationshipStatus.none;
  }

  void _filterUsers() {
    final currentUserId = _authController.user?.uid;
    final query = _searchQuery.value.toLowerCase();

    _filteredUsers.value = _users.where((user) {
      if (user.id == currentUserId) return false;
      if (query.isEmpty) return true;
      return user.displayName.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query);
    }).toList();
  }

  void updateSearchQuery(String query) => _searchQuery.value = query;
  void clearSearch() => _searchQuery.value = '';

  Future<void> sendFriendRequest(UserModel user) async {
    try {
      _isLoading.value = true;
      final currentUserId = _authController.user?.uid;
      if (currentUserId == null) return;

      final request = FriendRequestModel(
        id: _uuid.v4(),
        senderId: currentUserId,
        receiverId: user.id,
        status: FriendRequestStatus.pending, // Fixed: was missing status field
        createdAt: DateTime.now(),
      );

      _userRelationships[user.id] = UserRelationshipStatus.friendRequestSent;
      await _firestoreService.sendFriendRequest(request);
      Get.snackbar('Success', 'Friend request sent to ${user.displayName}');
    } catch (e) {
      _userRelationships[user.id] = UserRelationshipStatus.none;
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to send friend request');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> cancelFriendRequest(UserModel user) async {
    try {
      _isLoading.value = true;
      final currentUserId = _authController.user?.uid;
      if (currentUserId == null) return;

      final request = _sentRequests.firstWhereOrNull(
        (r) => r.receiverId == user.id && r.status == FriendRequestStatus.pending,
      );

      if (request != null) {
        _userRelationships[user.id] = UserRelationshipStatus.none;
        await _firestoreService.cancelFriendRequest(request.id);
        Get.snackbar('Success', 'Friend request cancelled');
      }
    } catch (e) {
      _userRelationships[user.id] = UserRelationshipStatus.friendRequestSent;
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to cancel friend request');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> acceptFriendRequest(UserModel user) async {
    try {
      _isLoading.value = true;
      final currentUserId = _authController.user?.uid;
      if (currentUserId == null) return;

      final request = _receivedRequests.firstWhereOrNull(
        (r) => r.senderId == user.id && r.status == FriendRequestStatus.pending,
      );

      if (request != null) {
        _userRelationships[user.id] = UserRelationshipStatus.friends;
        await _firestoreService.respondToFriendRequst(
            request.id, FriendRequestStatus.accepted);
        Get.snackbar('Success', 'Friend request accepted');
      }
    } catch (e) {
      _userRelationships[user.id] = UserRelationshipStatus.friendRequestReceived;
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to accept friend request');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> declineFriendRequest(UserModel user) async {
    try {
      _isLoading.value = true;
      final currentUserId = _authController.user?.uid;
      if (currentUserId == null) return;

      final request = _receivedRequests.firstWhereOrNull(
        (r) => r.senderId == user.id && r.status == FriendRequestStatus.pending,
      );

      if (request != null) {
        _userRelationships[user.id] = UserRelationshipStatus.none;
        await _firestoreService.respondToFriendRequst(
            request.id, FriendRequestStatus.declined);
        Get.snackbar('Success', 'Friend request declined');
      }
    } catch (e) {
      _userRelationships[user.id] = UserRelationshipStatus.friendRequestReceived;
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to decline friend request');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> startChat(UserModel user) async {
    try {
      _isLoading.value = true;
      final currentUserId = _authController.user?.uid;
      if (currentUserId == null) {
        Get.snackbar('Error', 'User not logged in');
        return;
      }

      final status = _userRelationships[user.id] ?? UserRelationshipStatus.none;
      if (status != UserRelationshipStatus.friends) {
        Get.snackbar('Info',
            'You can only chat with friends. Please send a friend request first');
        return;
      }

      final String chatId =
          await _firestoreService.createOrGetChat(currentUserId, user.id);

      Get.toNamed(AppRoutes.chat, arguments: {
        'chatId': chatId,
        'otherUser': user,
      });
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to start chat');
    } finally {
      _isLoading.value = false;
    }
  }

  UserRelationshipStatus getUserRelationshipStatus(String userId) {
    return _userRelationships[userId] ?? UserRelationshipStatus.none;
  }

  void handleRelationshipAction(UserModel user) {
    final status = getUserRelationshipStatus(user.id);
    switch (status) {
      case UserRelationshipStatus.none:
        sendFriendRequest(user);
        break;
      case UserRelationshipStatus.friendRequestSent:
        cancelFriendRequest(user);
        break;
      case UserRelationshipStatus.friendRequestReceived:
        acceptFriendRequest(user);
        break;
      case UserRelationshipStatus.friends:
        startChat(user);
        break;
      case UserRelationshipStatus.blocked:
        Get.snackbar('Blocked', 'You cannot interact with this user');
        break;
    }
  }

  String getRelationshipButtonText(UserRelationshipStatus status) {
    switch (status) {
      case UserRelationshipStatus.none: return 'Add';
      case UserRelationshipStatus.friendRequestSent: return 'Requested';
      case UserRelationshipStatus.friendRequestReceived: return 'Accept';
      case UserRelationshipStatus.friends: return 'Message';
      case UserRelationshipStatus.blocked: return 'Blocked';
    }
  }

  IconData getRelationshipButtonIcon(UserRelationshipStatus status) {
    switch (status) {
      case UserRelationshipStatus.none: return Icons.person_add;
      case UserRelationshipStatus.friendRequestSent: return Icons.access_time;
      case UserRelationshipStatus.friendRequestReceived: return Icons.check;
      case UserRelationshipStatus.friends: return Icons.chat_bubble_outline;
      case UserRelationshipStatus.blocked: return Icons.block;
    }
  }

  Color getRelationshipButtonColor(UserRelationshipStatus status) {
    switch (status) {
      case UserRelationshipStatus.none: return Colors.blue;
      case UserRelationshipStatus.friendRequestSent: return Colors.orange;
      case UserRelationshipStatus.friendRequestReceived: return Colors.green;
      case UserRelationshipStatus.friends: return Colors.blue;
      case UserRelationshipStatus.blocked: return Colors.redAccent;
    }
  }

  String getLastSeenText(UserModel user) {
    if (user.isOnline) return 'Online';
    if (user.lastSeen == null) return 'Offline';

    final diff = DateTime.now().difference(user.lastSeen!);
    if (diff.inSeconds < 60) return 'Last seen just now';
    if (diff.inMinutes < 60) return 'Last seen ${diff.inMinutes} min ago';
    if (diff.inHours < 24) return 'Last seen ${diff.inHours} hr ago';
    if (diff.inDays == 1) return 'Last seen yesterday';
    return 'Last seen ${user.lastSeen!.day}/${user.lastSeen!.month}/${user.lastSeen!.year}';
  }

  void clearError() => _error.value = '';
}
