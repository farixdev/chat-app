import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controllers/users_list_controller.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/views/widgets/user_list_item.dart';

class FindPeopleView extends GetView<UserListController>{

     @override
      Widget build(BuildContext){
          return Scaffold(
             appBar: AppBar(
                  title: Text('find People'),
                  leading: SizedBox()),
            body: Column(
              children: [_buildSearchbar(),
                Expanded(child: Obx((){
                       if(controller.filteredUsers.isEmpty){
                             return _buildEmptyState();
                       }
                      return ListView.separated(
                        padding: EdgeInsets.all(16),
                          separatorBuilder: (context,index)=>SizedBox(height: 8),
                          itemCount: controller.filteredUsers.length,

                          itemBuilder: (context,index){
                               final user = controller.filteredUsers[index];
                               return UserListItem(
                                 user: user,
                                   onTap: ()=> controller.handleRelationshipAction(user),
                                   controller:controller,
                               );
                          },
                      );

                }))
              ],
            )
          );
     }
     Widget _buildSearchbar() {
       return Container(
         padding: const EdgeInsets.all(16),
         decoration: BoxDecoration(
           color: Theme.of(Get.context!).scaffoldBackgroundColor,
           border: Border(
                bottom: BorderSide(
                     color: AppTheme.borderColor.withOpacity(0.5),
                  width: 1,
                )
           )
         ),
           child: TextField(
             onChanged: controller.updateSearchQuery,
             decoration: InputDecoration(
               hintText: 'Search people',
               prefixIcon: Icon(Icons.search),
               suffixIcon: Obx((){
                     return controller.searchQuery.isNotEmpty
                         ? IconButton(
                           icon:Icon(Icons.clear),
                         onPressed: (){
                             controller.clearSearch();
                         },): SizedBox.shrink();
               }),
                 border: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(12),
                       borderSide: BorderSide(color: AppTheme.borderColor),
                 ),
                 enabledBorder: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(12),
                   borderSide: BorderSide(color: AppTheme.borderColor),
                 ),
                 focusedBorder: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(12),
                   borderSide: BorderSide(color: AppTheme.primaryColor,
                   width: 2
                   ),
                 ),
               filled: true,
               fillColor: AppTheme.cardColor,
               contentPadding: EdgeInsets.symmetric(vertical: 0,horizontal: 0),
             ),
           ),
       );
     }
     Widget _buildEmptyState() {
       return Center(
         child: Padding(
           padding: EdgeInsets.all(32),
           child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               Container(
                 width: 100,
                 height: 100,
                 decoration: BoxDecoration(
                   color: AppTheme.primaryColor.withOpacity(0.1),
                   borderRadius: BorderRadius.circular(50),
                 ),
                 child: Icon(
                     Icons.people_outline,
                     size: 50,
                   color: AppTheme.primaryColor,
                 ),
               ),
               SizedBox(height: 24),
               Text(
                 controller.searchQuery.isNotEmpty ?
                 'No People Found': 'No people found',
                 style: Theme.of(Get.context!).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.textPrimaryColor,
                   fontWeight: FontWeight.bold,
                 ),
               ),
               SizedBox(height: 8),
               Text(
                 controller.searchQuery.isNotEmpty ?
                 'No People Found': 'No people found',
                 style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                   color: AppTheme.textPrimaryColor,
                 ),
                 textAlign: TextAlign.center,
               ),
             ],
           ),
         ),
       );
     }
}