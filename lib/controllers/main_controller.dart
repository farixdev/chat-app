import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controllers/friends_controller.dart';
import 'package:myapp/controllers/home_controller.dart';
import 'package:myapp/controllers/profile_controller.dart';
import 'package:myapp/controllers/users_list_controller.dart';

class MainController extends GetxController {
  final RxInt _currentIndex = 0.obs;
  final PageController pageController = PageController();

  int get currentIndex => _currentIndex.value;

  @override
  void onInit() {
    super.onInit();

    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => FriendsController());
    Get.lazyPut(() => UserListController());
    Get.lazyPut(() => ProfileController());
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void changeTabIndex(int index) {
    _currentIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void onPageChanged(int index) {
    _currentIndex.value = index;
  }

  int getUnreadCount() {
    try {
      final homeController = Get.find<HomeController>();
      return homeController.totalUnreadCount;
    } catch (e) {
      return 0;
    }
  }

  int getNotificationCount() {
    try {
      final homeController = Get.find<HomeController>();
      return homeController.notifications
          .where((n) => n.isRead == false)
          .length;
    } catch (e) {
      return 0;
    }
  }
}