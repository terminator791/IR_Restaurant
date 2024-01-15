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
import '../../model/food.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:another_flushbar/flushbar_helper.dart';
import 'package:another_flushbar/flushbar_route.dart';

final FoodController controller = Get.put(FoodController());

class CartScreen extends StatelessWidget {
  const CartScreen({
    Key? key,
  }) : super(key: key);

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      title: Text(
        "Cart screen",
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

  void _checkout(BuildContext context) {
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Confirm Checkout"),
              content: isLoading
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Lottie.asset(
                          'assets/loadings/loading.json', // Animasi loading
                          width: 100,
                          height: 100,
                        ),
                        Text("Processing Payment..."),
                      ],
                    )
                  : Text("Are you sure you want to proceed with the checkout?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true;
                          });

                          // Simulate a delay for the payment process (replace with actual logic)
                          await Future.delayed(Duration(seconds: 5));

                          // Simulate a successful payment (replace with actual logic)
                          bool paymentSuccess = true;

                          setState(() {
                            isLoading = false;
                          });

                          // Show a Snackbar with custom content
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: paymentSuccess
                                  ? buildSuccessSnackbar()
                                  : Text("Pembayaran gagal"),
                              duration: Duration(seconds: 3),
                              backgroundColor:
                                  paymentSuccess ? Colors.green : Colors.red,
                            ),
                          );

                          if (paymentSuccess) {
                            // Reset the cart to an empty state
                            controller.removeCartFoodFromPrefs_all();

                            controller.clearCart();
                            controller.calculateTotalPrice();

                            // Reset total and subtotal prices in the controller
                            controller.resetTotalPrice();
                            controller.resetSubtotalPrice();
                          }

                          Navigator.of(context).pop(); // Close the dialog
                        },
                  child: Text("Checkout"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _bottomAppBar(double height, double width, BuildContext context) {
    if (controller.cartFood.isNotEmpty) {
      return BottomAppBar(
        child: SizedBox(
          height: height * 0.37,
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Subtotal",
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Obx(() {
                            return Text(
                              "\Rp. ${controller.subtotalPrice.value}",
                              style: Theme.of(context).textTheme.displayMedium,
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Taxes",
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            "\5%",
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(thickness: 4.0, height: 30.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total",
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                          Obx(() {
                            return Text(
                              controller.totalPrice.value == 5.0
                                  ? "\Rp. 0.0"
                                  : "\Rp. ${controller.totalPrice}",
                              style: h2Style.copyWith(
                                color: LightThemeColor.accent,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * 0.1),
                        child: ElevatedButton(
                          onPressed: () {
                            _checkout(context);
                          },
                          child: const Text("Checkout"),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return const SizedBox(); // Hide bottom app bar when the cart is empty
    }
  }

  Widget cartListView(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(30),
      shrinkWrap: true,
      itemCount: controller.cartFood.length,
      itemBuilder: (_, index) {
        var food = controller.cartFood[index];

        return Dismissible(
          onDismissed: (direction) {
            if (direction == DismissDirection.startToEnd) {
              controller.removeFromCartAndPrefs(index);
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
                    CounterButton(
                      onIncrementSelected: () => controller.increaseItem(food),
                      onDecrementSelected: () => controller.decreaseItem(food),
                      size: const Size(24, 24),
                      padding: 0,
                      label: Text(
                        food.quantity.toString(),
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ),
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
      bottomNavigationBar: _bottomAppBar(height, width, context),
      appBar: _appBar(context),
      body: EmptyWidget(
        title: "Empty cart",
        condition: controller.cartFood.isNotEmpty,
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
