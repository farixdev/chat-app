import 'package:get/get.dart';
import 'package:myapp/routes/app_routes.dart';

import '../controllers/friend_requests_controller.dart';
import '../controllers/friends_controller.dart';
import '../controllers/main_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/users_list_controller.dart';
import '../views/auth/forgot_password_view.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/find_people_view.dart';
import '../views/friend_request_view.dart';
import '../views/friends_view.dart';
import '../views/main_view.dart';
import '../views/profile/change_password_view.dart';
import '../views/profile/profile_view.dart';
import '../views/splash_view.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(
       name: AppRoutes.splash,
       page: () => const SplashView(),
     ),
    GetPage(
       name: AppRoutes.login,
       page: () => const LoginView(),
     ),
    GetPage(
       name: AppRoutes.register,
       page: () => const RegisterView(),
     ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
    ),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordView(),
    ),
  //   GetPage(
  //     name: AppRoutes.home,
  //     page: () => const HomeView(),
  //     binding: BindingsBuilder(() {
  //       Get.put(HomeController());
  //     }),
  //   ),
    GetPage(
      name: AppRoutes.main,
      page: () => MainView(),
      binding: BindingsBuilder(() {
        Get.put(MainController());
      }),
     ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: BindingsBuilder(() {
        Get.put(ProfileController());
      }),
    ),
  //   GetPage(
  //     name: AppRoutes.chat,
  //     page: () => const ChatView(),
  //     binding: BindingsBuilder(() {
  //       Get.put(ChatController());
  //     }),
  //   ),
    GetPage(
      name: AppRoutes.usersList,
      page: () =>  FindPeopleView(),
      binding: BindingsBuilder(() {
        Get.put(UserListController());
      }),
    ),
    GetPage(
      name: AppRoutes.friends,
      page: () =>  FriendsView(),
      binding: BindingsBuilder(() {
        Get.put(FriendsController());
      }),
    ),
    GetPage(
      name: AppRoutes.friendRequests,
      page: () => FriendRequestView(),
      binding: BindingsBuilder(() {
        Get.put(FriendRequestsController());
      }),
    ),
  //   GetPage(
  //     name: AppRoutes.notifications,
  //     page: () => const NotificationsView(),
  //     binding: BindingsBuilder(() {
  //       Get.put(NotificationsController());
  //     }),
  //   ),
  ];
}