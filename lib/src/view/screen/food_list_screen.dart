import 'package:get/get.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:IR_RESTAURANT/core/app_data.dart';
import 'package:IR_RESTAURANT/core/app_color.dart';
import 'package:IR_RESTAURANT/core/app_extension.dart';
import 'package:IR_RESTAURANT/src/model/food_category.dart';
import 'package:IR_RESTAURANT/src/controller/food_controller.dart';
import 'package:IR_RESTAURANT/src/view/widget/food_list_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './transaction.dart';
import './cart_screen.dart';

final FoodController controller = Get.put(FoodController());

class FoodListScreen extends StatelessWidget {
  const FoodListScreen({super.key});

  PreferredSizeWidget _appBar(BuildContext context) {
    int panjang = controller.getCartFoodLength();
    return AppBar(
      leading: IconButton(
        icon: const FaIcon(FontAwesomeIcons.dice),
        onPressed: controller.changeTheme,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "IR  ",
            style: TextStyle(
              color: Colors.orange,
              fontSize: 15,
              fontWeight:
                  FontWeight.w800, // Use FontWeight.w300 for light font weight
            ),
          ),
          Image.asset(
            'assets/images/logo.png',
            height: 30, // Sesuaikan dengan ukuran yang diinginkan
            color: LightThemeColor.accent,
          ),
          Text(
            " Restaurant",
            style: TextStyle(
              color: Colors.orange,
              fontSize: 15,
              fontWeight:
                  FontWeight.w500, // Use FontWeight.w300 for light font weight
            ),
          )
        ],
      ),
      actions: [
        Obx(() {
          int panjang = controller.getCartFoodLength();
          return IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
            },
            icon: Badge(
              badgeStyle: const BadgeStyle(badgeColor: LightThemeColor.accent),
              badgeContent: Text(
                panjang.toString(),
                style: TextStyle(color: Colors.white),
              ),
              position: BadgePosition.topStart(start: -3),
              child: const Icon(Icons.shopping_basket_outlined, size: 30),
            ),
          );
        }),
      ],
    );
  }

  Widget _searchBar() {
    TextEditingController searchController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: TextField(
        controller: searchController,
        onChanged: (query) {
          controller.filterFoodsBySearch(query);
        },
        decoration: InputDecoration(
          hintText: 'Search food',
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          contentPadding: EdgeInsets.all(20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String displayName = user?.displayName ?? "Guest";
    return Scaffold(
      appBar: _appBar(context),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Morning, $displayName",
                style: Theme.of(context).textTheme.headlineSmall,
              ).fadeAnimation(0.2),
              Text(
                "What do you want to eat \ntoday",
                style: Theme.of(context).textTheme.displayLarge,
              ).fadeAnimation(0.4),
              _searchBar(),
              Text(
                "Available for you",
                style: Theme.of(context).textTheme.displaySmall,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: SizedBox(
                  height: 40,
                  child: GetBuilder(
                    builder: (FoodController controller) {
                      return ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: AppData.categories.length,
                        itemBuilder: (_, index) {
                          FoodCategory category = AppData.categories[index];
                          return GestureDetector(
                            onTap: () {
                              controller.filterItemByCategory(category);
                            },
                            child: Container(
                              width: 100,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: category.isSelected
                                    ? LightThemeColor.accent
                                    : Colors.transparent,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(15),
                                ),
                              ),
                              child: Text(
                                category.type.name.toCapital,
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (_, __) {
                          return const Padding(
                            padding: EdgeInsets.only(right: 15),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              GetBuilder(
                builder: (FoodController controller) {
                  return FoodListView(
                    foods: controller.filteredFoods,
                    favorite: controller.favorite,
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 25, bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Best food of the week",
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Text(
                        "See all",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: LightThemeColor.accent,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              FoodListView(
                  foods: AppData.foodItems,
                  isReversedList: true,
                  favorite: controller.favorite),
            ],
          ),
        ),
      ),
    );
    controller.init_cart();
  }
}
