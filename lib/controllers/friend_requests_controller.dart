import 'dart:async';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/models/friend_request_model.dart';
import 'package:myapp/models/user_model.dart';
import '../services/firestore_service.dart';

class FriendRequestsController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  final RxList<FriendRequestModel> _receivedRequests = <FriendRequestModel>[].obs;
  final RxList<FriendRequestModel> _sentRequests = <FriendRequestModel>[].obs;
  final RxMap<String, UserModel> _users = <String, UserModel>{}.obs;

  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxInt _selectedTabIndex = 0.obs;

  List<FriendRequestModel> get receivedRequests => _receivedRequests;
  List<FriendRequestModel> get sentRequests => _sentRequests;
  Map<String, UserModel> get users => _users;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  int get selectedTabIndex => _selectedTabIndex.value;

  StreamSubscription? _receivedSub;
  StreamSubscription? _sentSub;

  @override
  void onInit() {
    super.onInit();
    listenToRequests();
  }

  @override
  void onClose() {
    _receivedSub?.cancel();
    _sentSub?.cancel();
    super.onClose();
  }

  void changeTab(int index) {
    _selectedTabIndex.value = index;
  }

  void listenToRequests() {
    _isLoading.value = true;

    try {
      // ✅ Received Requests
      _receivedSub = _firestoreService
          .getFriendRequestsStream(currentUserId)
          .listen((requests) {
        _receivedRequests.assignAll(requests);
        _loadUsers(requests);
      });

      // ❗ FIX: your service has typo "friendsRequest"
      _sentSub = _firestoreService
          .getSentFriendRequestStream(currentUserId)
          .listen((requests) {
        _sentRequests.assignAll(requests);
        _loadUsers(requests);
      });

      _isLoading.value = false;
    } catch (e) {
      _error.value = 'Failed to load requests';
      _isLoading.value = false;
    }
  }

  Future<void> _loadUsers(List<FriendRequestModel> requests) async {
    for (var request in requests) {
      final otherUserId = request.senderId == currentUserId
          ? request.receiverId
          : request.senderId;

      if (!_users.containsKey(otherUserId)) {
        final user = await _firestoreService.getUser(otherUserId);
        if (user != null) {
          _users[otherUserId] = user;
        }
      }
    }
  }

  UserModel? getUser(String userId) {
    return _users[userId];
  }

  // ✅ ACCEPT REQUEST
  Future<void> acceptRequest(FriendRequestModel request) async {
    try {
      await _firestoreService.respondToFriendRequst(
        request.id,
        FriendRequestStatus.accepted,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to accept request');
    }
  }

  // ❌ REJECT REQUEST
  Future<void> rejectRequest(FriendRequestModel request) async {
    try {
      await _firestoreService.respondToFriendRequst(
        request.id,
        FriendRequestStatus.declined,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to reject request');
    }
  }

  // ❌ CANCEL SENT REQUEST
  Future<void> cancelRequest(FriendRequestModel request) async {
    try {
      await _firestoreService.cancelFriendRequest(request.id);
    } catch (e) {
      Get.snackbar('Error', 'Failed to cancel request');
    }
  }

  // 📤 SEND REQUEST
  Future<void> sendRequest(String receiverId) async {
    try {
      final request = FriendRequestModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: currentUserId,
        receiverId: receiverId,
        status: FriendRequestStatus.pending,
        createdAt: DateTime.now(),
      );

      await _firestoreService.sendFriendRequest(request);
    } catch (e) {
      Get.snackbar('Error', 'Failed to send request');
    }
  }

  Future<void> refresh() async {
    listenToRequests();
  }
}