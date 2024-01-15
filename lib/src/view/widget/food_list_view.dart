import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:IR_RESTAURANT/core/app_style.dart';
import 'package:IR_RESTAURANT/src/model/food.dart';
import 'package:IR_RESTAURANT/core/app_color.dart';
import 'package:IR_RESTAURANT/core/app_extension.dart';
import 'package:IR_RESTAURANT/src/controller/food_controller.dart';
import 'package:IR_RESTAURANT/src/view/screen/food_detail_screen.dart';
import 'package:IR_RESTAURANT/src/view/widget/custom_page_route.dart';

final FoodController controller = Get.put(FoodController());

class FoodListView extends StatelessWidget {
  FoodListView({
    super.key,
    required this.foods,
    this.isReversedList = false,
    required this.favorite,
  });

  final List<Food> foods;
  final bool isReversedList;
  bool favorite = controller.favorite;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 20, left: 10),
        scrollDirection: Axis.horizontal,
        itemCount: isReversedList ? 3 : foods.length,
        itemBuilder: (_, index) {
          Food food =
              isReversedList ? foods.reversed.toList()[index] : foods[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                CustomPageRoute(
                    child: FoodDetailScreen(
                  food: food,
                  favorite: controller.favorite,
                )),
              );
            },
            child: Container(
              width: 180,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: controller.isLightTheme
                    ? Colors.white
                    : DarkThemeColor.primaryLight,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(food.image, scale: 6),
                    Text(
                      "\Rp.${food.price}",
                      style: h3Style.copyWith(color: LightThemeColor.accent),
                    ),
                    Text(
                      food.name,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ).fadeAnimation(0.7),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) {
          return const Padding(padding: EdgeInsets.only(right: 50));
        },
      ),
    );
  }
}
