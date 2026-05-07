import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controllers/auth_controller.dart';
import 'package:myapp/models/friendship_model.dart';
import 'package:myapp/models/user_model.dart';
import 'package:myapp/routes/app_routes.dart';
import 'package:myapp/services/firestore_service.dart';

class FriendsController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthController _authController = Get.find<AuthController>();

  final RxList<FriendshipModel> _friendships = <FriendshipModel>[].obs;
  final RxList<UserModel> _friends = <UserModel>[].obs;

  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxString _searchQuery = ''.obs;
  final RxList<UserModel> _filteredFriends = <UserModel>[].obs;

  StreamSubscription? _friendshipsStreamSubscription;

  List<FriendshipModel> get friendships => _friendships.toList();
  List<UserModel> get friends => _friends;
  List<UserModel> get filteredFriends => _filteredFriends;
  bool get isLoading => _isLoading.value;
  String get searchQuery => _searchQuery.value;

  @override
  void onInit() {
    super.onInit();
    _loadFriends();

    debounce(_searchQuery, (_) => _filterFriends(),
        time: Duration(milliseconds: 300));
  }

  @override
  void onClose() {
    _friendshipsStreamSubscription?.cancel();
    super.onClose();
  }

  void _loadFriends() {
    final currentUserId = _authController.user?.uid;

    if (currentUserId != null) {
      _friendshipsStreamSubscription?.cancel();

      _friendshipsStreamSubscription =
          _firestoreService.getFriendsStream(currentUserId).listen(
                (friendshipList) {
              _friendships.value = friendshipList;
              _loadFriendDetails(currentUserId, friendshipList);
            },
          );
    }
  }

  Future<void> _loadFriendDetails(
      String currentUserId,
      List<FriendshipModel> friendshipList,
      ) async {
    try {
      _isLoading.value = true;

      List<UserModel> friendUsers = [];

      final futures = friendshipList.map((friendship) async {
        String friendId =
        friendship.getOtherUserId(currentUserId);
        return await _firestoreService.getUser(friendId);
      }).toList();

      final results = await Future.wait(futures);

      for (var friend in results) {
        if (friend != null) {
          friendUsers.add(friend);
        }
      }

      _friends.value = friendUsers;
      _filterFriends();
    } catch (e) {
      _error.value=e.toString();
    }
    finally{
        _isLoading.value = false;
    }
  }
  void _filterFriends(){
       final query=_searchQuery.value.toLowerCase();

       if(query.isEmpty){
         _filteredFriends.value=_friends;
       } else {
         _filteredFriends.value = _friends.where((friend) {
           return friend.displayName.toLowerCase().contains(query) ||
               friend.email.toLowerCase().contains(query);
         }).toList();
       }

  }
  void updateSearchQuery(String query){
      _searchQuery.value=query;
  }
  void clearSearch(){
    _searchQuery.value='';
  }
  Future<void> refreshFriend() async{
    final currentUserId=_authController.user?.uid;
    if(currentUserId != null){
         _loadFriends();
    }
  }
  
  Future<void> removeFriend(UserModel friend)async{
             try{
                 final result =await Get.dialog<bool>(
                     AlertDialog(
                       title: Text('Remove Friend'),
                       content: Text('Are you sure to remove your friend${friend.displayName}'),
                       actions: [
                             TextButton(onPressed: ()=>Get.back(result: false),
                                 child: Text('cancel'),
                             ),
                         TextButton(onPressed: ()=>Get.back(result: true),
                             style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                             child: Text('Remove'))
                       ],
                     )
                 );
                 if(result==true){
                       final currentUserId=_authController.user?.uid;
                       if(currentUserId!=null){
                            await _firestoreService.removeFriendShip(currentUserId, friend.id);
                            Get.snackbar('success', 'friend removed${friend.displayName}',
                              backgroundColor: Colors.green.withOpacity(0.1),
                              colorText: Colors.green,
                              duration: Duration(seconds: 4),
                            );
                       }

                 }
             }  catch (e){
                    Get.snackbar('Error',
                        'failed to remove Friend',
                      backgroundColor: Colors.redAccent,
                      colorText: Colors.redAccent,
                      duration: Duration(seconds: 4),
                    );
                    print(e.toString());
             }
             finally{
                    _isLoading.value=false;
             }
  }

  Future<void> blockFriend(UserModel friend) async {
    try {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Block user'),
          content: Text(
            'Are you sure to block user ${friend.displayName}? you are no longer friend',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Block'),
            ),
          ],
        ),
      );

      if (result == true) {
        final currentUserId = _authController.user?.uid;
        if (currentUserId != null) {
          await _firestoreService.blockUser(currentUserId, friend.id);
          Get.snackbar(
            'Success',
            '${friend.displayName}User blocked successfully',
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green,
            duration: const Duration(seconds: 4),
          );
        }
      }
    } catch (e) {
           Get.snackbar(
             'Error',
             'Failed to block user',
             backgroundColor: Colors.redAccent,
             colorText: Colors.redAccent,
             duration: const Duration(seconds: 4),
           );
           print(e.toString());
    }
         finally{
                _isLoading.value=false;
         }
  }
    Future<void> startChat(UserModel friend) async{
                try{
                  _isLoading.value=true;
                  final currentUserId=_authController.user?.uid;
                  if(currentUserId!=null){
                      Get.toNamed(
                          AppRoutes.chat,
                          arguments: {
                           'chatId':null,
                           'otherUser':friend,
                           'isNewChat':true,
                          }
                      );
                  }

                } catch(e){
                          Get.snackbar('Error',
                              'failed to start chat',
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.redAccent,
                            duration: Duration(seconds: 4),
                          );
                          print(e.toString());
                } finally{
                   _isLoading.value=false;
                }
    }
  String getLastSeenText(UserModel user) {
    if (user.isOnline) {
      return 'Online';
    } else {
      if (user.lastSeen == null) {
        return 'Offline';
      }

      final now = DateTime.now();
      final difference = now.difference(user.lastSeen!);

      if (difference.inSeconds < 60) {
        return 'Last seen just now';
      } else if (difference.inMinutes < 60) {
        return 'Last seen ${difference.inMinutes} min ago';
      } else if (difference.inHours < 24) {
        return 'Last seen ${difference.inHours} hr ago';
      } else if (difference.inDays == 1) {
        return 'Last seen yesterday';
      } else {

        return 'Last seen ${user.lastSeen!.day}/${user.lastSeen!.month}/${user.lastSeen!.year}';
      }
    }
  }
   void openFriendRequests(){
           Get.toNamed(AppRoutes.friendRequests);
   }

   void clearError(){
       _error.value='';
   }
}