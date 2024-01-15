import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:IR_RESTAURANT/core/app_data.dart';
import 'package:IR_RESTAURANT/src/view/screen/cart_screen.dart';
import 'package:IR_RESTAURANT/src/view/screen/profile_screen.dart';
import 'package:IR_RESTAURANT/src/controller/food_controller.dart';
import 'package:IR_RESTAURANT/src/view/screen/favorite_screen.dart';
import 'package:IR_RESTAURANT/src/view/widget/page_transition.dart';
import 'package:IR_RESTAURANT/src/view/screen/food_list_screen.dart';
import './transaction.dart';

final FoodController controller = Get.put(FoodController());

class HomeScreen extends StatelessWidget {
  static const String routeName = '/home';
  HomeScreen({super.key});

  final List<Widget> screen = [
    const FoodListScreen(),
    const TransactionScreen(),
    const FavoriteScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => PageTransition(
          child: screen[controller.currentBottomNavItemIndex.value],
        ),
      ),
      bottomNavigationBar: Obx(() {
        return BottomNavigationBar(
          currentIndex: controller.currentBottomNavItemIndex.value,
          onTap: controller.switchBetweenBottomNavigationItems,
          selectedFontSize: 0,
          items: AppData.bottomNavigationItems.map(
            (element) {
              return BottomNavigationBarItem(
                icon: element.disableIcon,
                label: element.label,
                activeIcon: element.enableIcon,
              );
            },
          ).toList(),
        );
      }),
    );
  }
}
