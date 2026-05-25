import 'package:get/get.dart';
import 'package:myapp/controllers/auth_controller.dart';
import 'package:myapp/models/chat_model.dart';
import 'package:myapp/models/notification_model.dart';
import 'package:myapp/models/user_model.dart';
import 'package:myapp/services/firestore_service.dart';

class HomeController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthController _authController = Get.find<AuthController>();

  final RxList<ChatModel> _allChats = <ChatModel>[].obs;
  final RxList<NotificationModel> _notifications = <NotificationModel>[].obs;
  final RxMap<String, UserModel> _users = <String, UserModel>{}.obs;

  final RxString _searchQuery = ''.obs;
  final RxBool _isSearching = false.obs;
  final RxString _activeFilter = 'all'.obs;

  List<ChatModel> get chats => _getFilteredChats();
  List<ChatModel> get allChats => _allChats;
  List<NotificationModel> get notifications => _notifications;

  String get searchQuery => _searchQuery.value;
  String get activeFilter => _activeFilter.value;
  bool get isSearching => _isSearching.value;
  Map<String, UserModel> get users => _users;

  @override
  void onInit() {
    super.onInit();
    _loadChats();
    _loadUsers();
    _loadNotifications();
  }

  void _loadChats() {
    final currentUserId = _authController.user?.uid;
    if (currentUserId == null) return;
    _allChats.bindStream(_firestoreService.getUserChatsStream(currentUserId));
  }

  void _loadUsers() {
    _users.bindStream(
      _firestoreService.getAllUsersStream().map((userList) {
        final Map<String, UserModel> map = {};
        for (var user in userList) {
          map[user.id] = user;
        }
        return map;
      }),
    );
  }

  void _loadNotifications() {
    final currentUserId = _authController.user?.uid;
    if (currentUserId == null) return;
    _notifications.bindStream(
      _firestoreService.getNotificationsStream(currentUserId),
    );
  }

  UserModel? getOtherUser(ChatModel chat) {
    final currentUserId = _authController.user?.uid;
    if (currentUserId == null) return null;
    final otherId = chat.getOtherParticipant(currentUserId);
    return _users[otherId];
  }

  String formatLastMessageTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }

  List<ChatModel> _getFilteredChats() {
    List<ChatModel> list = List.from(_allChats);

    if (_searchQuery.value.isNotEmpty) {
      final q = _searchQuery.value.toLowerCase();
      list = list.where((chat) {
        final user = getOtherUser(chat);
        final name = user?.displayName.toLowerCase() ?? '';
        final lastMessage = chat.lastMessage?.toLowerCase() ?? '';
        return name.contains(q) || lastMessage.contains(q);
      }).toList();
    }

    switch (_activeFilter.value) {
      case 'unread':
        return _applyUnreadFilter(list);
      case 'recent':
        return _applyRecentFilter(list);
      case 'active':
        return _applyActiveFilter(list);
      default:
        return list;
    }
  }

  List<ChatModel> _applyUnreadFilter(List<ChatModel> list) {
    final currentUserId = _authController.user?.uid;
    if (currentUserId == null) return list;
    return list.where((chat) => chat.getUnreadCount(currentUserId) > 0).toList();
  }

  List<ChatModel> _applyRecentFilter(List<ChatModel> list) {
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  // Fixed: removed the extension that hardcoded isActive to always true.
  // isActive should come from ChatModel itself. If your ChatModel doesn't
  // have isActive, add it there. The filter below uses it safely with ?.
  List<ChatModel> _applyActiveFilter(List<ChatModel> list) {
    return list.where((chat) => chat.isActive == true).toList();
  }

  void updateSearch(String query) {
    _searchQuery.value = query;
    _isSearching.value = query.isNotEmpty;
  }

  void clearSearch() {
    _searchQuery.value = '';
    _isSearching.value = false;
  }

  void setFilter(String filter) => _activeFilter.value = filter;

  void clearAllFilters() {
    _activeFilter.value = 'all';
    clearSearch();
  }

  int get totalUnreadCount {
    final currentUserId = _authController.user?.uid;
    if (currentUserId == null) return 0;
    return _allChats.fold(0, (sum, chat) => sum + chat.getUnreadCount(currentUserId));
  }

  Future<void> refreshChats() async {
    final currentUserId = _authController.user?.uid;
    if (currentUserId == null) return;
    clearAllFilters();
    _allChats.bindStream(_firestoreService.getUserChatsStream(currentUserId));
  }

  Future<void> deleteChat(String chatId) async {
    final currentUserId = _authController.user?.uid;
    if (currentUserId == null) return;
    _allChats.removeWhere((chat) => chat.id == chatId);
    await _firestoreService.deleteChatForUser(chatId, currentUserId);
  }

  int getUnreadCount(ChatModel chat) {
    final userId = _authController.user?.uid;
    if (userId == null) return 0;
    return chat.getUnreadCount(userId);
  }
}

// REMOVED: the broken extension that hardcoded isActive to always return true.
// Add `bool get isActive` to your ChatModel class instead.
