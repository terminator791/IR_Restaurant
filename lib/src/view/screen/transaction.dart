import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:IR_RESTAURANT/core/app_style.dart';
import 'package:IR_RESTAURANT/core/app_color.dart';
import 'package:IR_RESTAURANT/core/app_extension.dart';
import 'package:IR_RESTAURANT/src/view/widget/empty_widget.dart';
import 'package:IR_RESTAURANT/src/view/widget/counter_button.dart';
import 'package:IR_RESTAURANT/src/controller/food_controller.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_database/firebase_database.dart';

final FoodController controller = Get.put(FoodController());

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({Key? key}) : super(key: key);

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      title: Text(
        "Transaction History",
        style: Theme.of(context).textTheme.displayMedium,
      ),
    );
  }

  Widget buildSuccessSnackbar() {
    return Row(
      children: [
        Lottie.asset(
          'assets/loadings/Animation_success.json',
          width: 30,
          height: 30,
        ),
        SizedBox(width: 10),
        Text("Pembelian berhasil"),
      ],
    );
  }

  Widget cartListView(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(30),
      shrinkWrap: true,
      itemCount: controller.fethced_transaction.length,
      itemBuilder: (_, index) {
        var food = controller.fethced_transaction[index];

        return Dismissible(
          onDismissed: (direction) {
            if (direction == DismissDirection.startToEnd) {
              controller.removeCartItemAtSpecificIndex(index);
            }
          },
          key: Key(food.name),
          background: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 25,
                ),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const FaIcon(FontAwesomeIcons.trash),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: controller.isLightTheme
                  ? Colors.white
                  : DarkThemeColor.primaryLight,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(width: 20),
                Image.asset(food.image, scale: 10),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "${food.price}",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  children: [
                    Text(
                      "\Rp. ${controller.calculatePricePerEachItem(food)}",
                      style: h2Style.copyWith(color: LightThemeColor.accent),
                    )
                  ],
                )
              ],
            ),
          ).fadeAnimation(index * 0.6),
        );
      },
      separatorBuilder: (_, __) => const Padding(padding: EdgeInsets.all(10)),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: _appBar(context),
      body: EmptyWidget(
        title: "Empty Transaction",
        condition: controller.fethced_transaction.isNotEmpty,
        child: SingleChildScrollView(
          child: SizedBox(
            height: height * 0.5,
            child: GetBuilder(
              builder: (FoodController controller) => cartListView(context),
            ),
          ),
        ),
      ),
    );
  }
}
