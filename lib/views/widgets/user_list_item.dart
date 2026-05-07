import 'dart:ui';

import 'package:myapp/controllers/users_list_controller.dart';
import 'package:myapp/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme/app_theme.dart';

class UserListItem extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;
  final UserListController controller;

  const UserListItem({
    super.key,
    required this.user,
    required this.onTap,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final relationshipStatus =
      controller.getUserRelationshipStatus(user.id);

      if (relationshipStatus == UserRelationshipStatus.friends) {
        return  SizedBox.shrink();
      }
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  user.displayName.isNotEmpty
                      ? user.displayName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                     color: Colors.white,
                     fontSize: 24,
                     fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  _buildActionButton(relationshipStatus),
                  if (relationshipStatus == UserRelationshipStatus.friendRequestReceived) ...[
                    const SizedBox(height: 4),
                    OutlinedButton.icon(
                      onPressed: () => controller.declineFriendRequest(user),
                      label: const Text('Decline', style: TextStyle(fontSize: 10)),
                      icon: const Icon(Icons.close, size: 14),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                        side: BorderSide(color: AppTheme.errorColor),
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 4,
                        ),
                        minimumSize: Size(0, 24),
                    ),
                    )],
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
  Widget _buildActionButton(UserRelationshipStatus relationshipStatus) {
    switch (relationshipStatus) {
      case UserRelationshipStatus.none:
        return ElevatedButton.icon(
          onPressed: () => controller.handleRelationshipAction(user),
          icon: Icon(
            controller.getRelationshipButtonIcon(relationshipStatus),
          ),
          label: Text(
            controller.getRelationshipButtonText(relationshipStatus),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor:
            controller.getRelationshipButtonColor(relationshipStatus),
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 8,
            ),
            minimumSize: const Size(0, 32),
          ),
        );
      case UserRelationshipStatus.friendRequestSent:
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                color: controller
                    .getRelationshipButtonColor(relationshipStatus)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: controller.getRelationshipButtonColor(relationshipStatus),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    controller.getRelationshipButtonIcon(relationshipStatus),
                    color: controller.getRelationshipButtonColor(relationshipStatus),
                  ),
                  SizedBox(width: 4),
                  Text(
                    controller.getRelationshipButtonText(relationshipStatus),
                    style: TextStyle(
                      color: controller.getRelationshipButtonColor(relationshipStatus),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
                ElevatedButton.icon(
                   onPressed: () => _showCancelRequestDialog(),
                   icon: Icon(Icons.cancel_outlined,size: 14),
               label: Text(
                 'cancel', style: TextStyle(fontSize: 10),
                ),
                style: ElevatedButton.styleFrom(
                 backgroundColor:
                  Colors.redAccent,
                  side: BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(
               vertical: 8,
              horizontal: 4,
    ),
    minimumSize: const Size(0, 24),
    ),
    ),

          ],
        );
      case UserRelationshipStatus.friendRequestReceived:
        return ElevatedButton.icon(
          onPressed: () => controller.handleRelationshipAction(user),
          icon: Icon(
            controller.getRelationshipButtonIcon(relationshipStatus),
          ),
          label: Text(
            controller.getRelationshipButtonText(relationshipStatus),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor:
            controller.getRelationshipButtonColor(relationshipStatus),
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 8,
            ),
            minimumSize: const Size(0, 32),
          ),
        );

        case UserRelationshipStatus.blocked:
          return Container(
            padding: EdgeInsets.symmetric(vertical: 8,horizontal: 12),
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withOpacity(0.1),
              border: Border.all(color: AppTheme.errorColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                   Icon(Icons.block,color: AppTheme.errorColor,),
                SizedBox(width: 4),
                Text(
                  'Blocked',
                  style: TextStyle(
                    color: AppTheme.errorColor,
                    fontWeight: FontWeight.w600,
                  ),
    ),
              ],
            ),
          );
          case UserRelationshipStatus.friends:
            return SizedBox.shrink();

    }
  }
    void _showCancelRequestDialog() {
                 Get.dialog(
                   AlertDialog(
                     title: Text('Cancel Friend Request'),
                     content: Text('Are you sure you want to cancel this friend request?${user.displayName}'),
                     actions: [
                       TextButton(
                         onPressed: ()=>
                           Get.back(),
                         child: Text('keep Request'),
                       ),
                       TextButton(
                            onPressed:(){ Get.back();
                            controller.cancelFriendRequest(user);},
                            style: TextButton.styleFrom(
                                 foregroundColor: Colors.redAccent,
                            ),
                         child: Text('Cancel Request'),

                       ),

                     ],
                   )
                 );
    }

   }
