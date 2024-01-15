import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:IR_RESTAURANT/core/app_data.dart';
import 'package:IR_RESTAURANT/core/app_theme.dart';
import 'package:IR_RESTAURANT/src/model/food.dart';
import 'package:IR_RESTAURANT/core/app_extension.dart';
import 'package:IR_RESTAURANT/src/model/food_category.dart';
import 'dart:convert'; // Add this line
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';
import '../../src/view/screen/shipping_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:another_flushbar/flushbar_helper.dart';
import 'package:another_flushbar/flushbar_route.dart';

class FoodController extends GetxController {
  int foodCounter = 1;
  RxInt currentBottomNavItemIndex = 0.obs;
  RxList<Food> cartFood = <Food>[].obs;
  RxList<Food> transaction = <Food>[].obs;
  RxList<Food> fethced_transaction = <Food>[].obs;
  RxList<Food> favoriteFood = <Food>[].obs;
  RxList<FoodCategory> categories = AppData.categories.obs;
  RxList<Food> filteredFoods = AppData.foodItems.obs;
  RxDouble totalPrice = 0.0.obs;
  RxDouble subtotalPrice = 0.0.obs;
  Rx<ThemeData> theme = AppTheme.lightTheme.obs;
  bool isLightTheme = true;
  RxInt cartFoodLength = 0.obs;
  late SharedPreferences prefs;
  bool favorite = false;

  FoodController() {
    initSharedPreferences();
  }

  // Function to initialize shared preferences
  Future<void> initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    foodCounter = prefs.getInt('foodCounter') ?? 1;
    isLightTheme =
        prefs.getBool('theme') ?? true; // Default to true if not found
    theme.value = isLightTheme ? AppTheme.lightTheme : AppTheme.darkTheme;
    loadFavoriteFoodFromPrefs();
  }

  void removeFromCartAndPrefs2(int index) {
    print(cartFood[index]);
    // Remove the food item from the cart
    Food removedFood = cartFood[index];
    cartFood.removeAt(index);

    // Update the total price
    calculateTotalPrice();

    // Save the updated cart to shared preferences
    saveCartFoodToPrefs();
    update();
    print(cartFood);
  }

  void removeCartItemAtSpecificIndex2(int index) {
    // Remove the food item from the cart
    Food removedFood = cartFood[index];
    cartFood.removeAt(index);

    // Update the total price
    calculateTotalPrice();

    // Save the updated cart to shared preferences
    saveCartFoodToPrefs();

    update();
  }

  void removeCartFromPrefs(Food food) {
    List<Food> updatedCartFood = List.from(cartFood);
    updatedCartFood.removeWhere((element) => element == food);

    // Update the favoriteFood list and save it to SharedPreferences
    cartFood.assignAll(updatedCartFood);
    saveCartFoodToPrefs();
  }

  void switchBetweenBottomNavigationItems(int currentIndex) {
    currentBottomNavItemIndex.value = currentIndex;
  }

  int getCartFoodLength() {
    return cartFood.length;
  }

  void readData_from_foods() {
    DatabaseReference databaseReference =
        FirebaseDatabase.instance.reference().child('foods');

    databaseReference.onValue.listen((event) {
      DataSnapshot dataSnapshot = event.snapshot;
      Map<dynamic, dynamic>? values =
          dataSnapshot.value as Map<dynamic, dynamic>?;

      if (values != null) {
        // Mengambil nilai dari food1 (sushi1)
        Map<dynamic, dynamic>? sushi1Data = values['food1'];

        if (sushi1Data != null) {
          // Menampilkan nilai dari sushi1
          print('Name: ${sushi1Data['name']}');
          print('Description: ${sushi1Data['description']}');
        }
      }
    });
  }

  void readDataFromCart() {
    DatabaseReference databaseReference =
        FirebaseDatabase.instance.reference().child('cart');

    databaseReference.onValue.listen((event) {
      DataSnapshot dataSnapshot = event.snapshot;
      Map<dynamic, dynamic>? values =
          dataSnapshot.value as Map<dynamic, dynamic>?;

      if (values != null) {
        // Iterate through each item in the cart

        values.forEach((key, cartItem) {
          // Check if both 'name' and 'description' are not null
          if (cartItem['name'] != null && cartItem['description'] != null) {
            // Access the properties of each item
            print(key);
            print('Name: ${cartItem['name']}');
            print('Description: ${cartItem['description']}');
          }
        });
      }
    });
  }

  void fetch_data_transactions() {
    DatabaseReference databaseReference =
        FirebaseDatabase.instance.reference().child('transactions');

    databaseReference.onValue.listen((event) {
      DataSnapshot dataSnapshot = event.snapshot;
      Map<dynamic, dynamic>? values =
          dataSnapshot.value as Map<dynamic, dynamic>?;

      if (values != null) {
        // Clear the list before populating
        values.forEach((cartkey, cartItem) {
          if (cartItem['name'] != null && cartItem['description'] != null) {
            cartkey = Food(
              cartItem['image'],
              cartItem['name'],
              cartItem['price'],
              cartItem['quantity'],
              cartItem['isFavorite'],
              cartItem['description'],
              cartItem['score'],
              FoodType.sushi,
              cartItem['vter'],
            );
            fethced_transaction.add(cartkey);
          }
        });
        fethced_transaction.assignAll;
      }
    });
  }

  void checkfethced_transaction() {
    if (fethced_transaction.isEmpty) {
      print('Cartsssssss is empty');
    } else {
      print('Cartssssssssss has ${fethced_transaction.length} item(s):');
      for (var food in fethced_transaction) {
        print('Name: ${food.name}, score: ${food.type}');
      }
    }
  }

  void increaseItem(Food food) {
    food.quantity++;
    update();
    calculateTotalPrice();
  }

  void clearCart() {
    cartFood.forEach((food) {
      addToTransaction(food);
    });
    removeCartFoodFromPrefs_all();
    cartFood.clear();
    update();
  }

  void decreaseItem(Food food) {
    food.quantity = food.quantity-- < 1 ? 0 : food.quantity--;
    calculateTotalPrice();
    update();
    if (food.quantity < 1) {
      cartFood.removeWhere((element) => element == food);
    }
  }

  String calculatePricePerEachItem(Food food) {
    double price = 0;
    price = food.quantity * food.price;
    return price.toString();
  }

  void init_cart() {
    Food food = cartFood.last;
    addToCart(food);
  }

  void resetTotalPrice() {
    totalPrice.value = 0.0;
  }

  void resetSubtotalPrice() {
    subtotalPrice.value = 0.0;
    if (cartFood.isNotEmpty) {
      List<Food> food = List.from(cartFood);
    }
  }

  calculateTotalPrice() {
    totalPrice.value = 0;
    for (var element in cartFood) {
      totalPrice.value += (0.05 * element.quantity * element.price) +
          element.quantity * element.price;
      subtotalPrice.value = element.quantity * element.price;
    }
  }

  void checkCartFood() {
    if (cartFood.isEmpty) {
      print('Cart is empty');
    } else {
      print('Cart has ${cartFood.length} item(s):');
      for (var food in cartFood) {
        print('Name: ${food.name}, Quantity: ${food.quantity}');
      }
    }
  }

  // This should be outside the function or class
  Future<void> resetFoodCounter() async {
    foodCounter = 1;
    // Store the reset value of foodCounter in shared preferences
    await prefs.setInt('foodCounter', foodCounter);
  }

  void saveCartFoodToPrefs() {
    List<Map<String, dynamic>> cartFoodList =
        cartFood.map((food) => food.toJson()).toList();
    String cartFoodJson = jsonEncode(cartFoodList);
    prefs.setString('cartFood', cartFoodJson);
  }

  void loadCartFoodFromPrefs() {
    String? cartFoodJson = prefs.getString('cartFood');

    if (cartFoodJson != null) {
      List<dynamic> cartFoodList = jsonDecode(cartFoodJson);
      cartFood.assignAll(
        cartFoodList.map((foodJson) => Food.fromJson(foodJson)).toList(),
      );
    }
  }

  void removeCartFoodFromPrefs(Food food) {
    List<Food> updatedCartFood = List.from(cartFood);
    updatedCartFood.removeWhere((element) => element == food);

    cartFood.assignAll(updatedCartFood);
    saveFavoriteFoodToPrefs();
  }

  void addToCart(Food food) async {
    if (food.quantity > 0) {
      cartFood.add(food);
      cartFood.assignAll(cartFood.distinctBy((item) => item));
      calculateTotalPrice();
    }
  }

  void addToTransaction(Food food) {
    if (food.quantity > 0) {
      transaction.add(food);
      transaction.assignAll;
      calculateTotalPrice();
      saveTransactionToFirebase(food); // Menambahkan parameter food
    }
  }

  void saveTransactionToFirebase(Food food) async {
    DatabaseReference databaseReference =
        FirebaseDatabase.instance.reference().child('transactions');

    try {
      // Adjust as needed
      String foodKey = 'food${foodCounter++}'; // Adjust as needed

      // Store the updated value of foodCounter in shared preferences
      prefs.setInt('foodCounter', foodCounter);
      // Menambah data ke Firebase Realtime Database
      await databaseReference.child(foodKey).set({
        'name': food.name,
        'description': food.description,
        'image': food.image,
        'price': food.price,
        'quantity': food.quantity,
        'isFavorite': food.isFavorite,
        'score': food.score,
        'type': food.type.toString().split('.').last, // Convert enum to string
        'vter': food.voter,
      });

      print('Transaction saved to Firebase successfully');
    } catch (error) {
      print('Error saving transaction to Firebase: $error');
    }
  }

  void checkTransaction() {
    if (transaction.isEmpty) {
      print('Transaction list is empty');
    } else {
      print('Transaction list has ${transaction.length} item(s):');
      for (var food in transaction) {
        print('Name: ${food.name}, Quantity: ${food.quantity}');
      }
    }
  }

  filterItemByCategory(FoodCategory category) {
    for (var element in AppData.categories) {
      element.isSelected = false;
    }
    category.isSelected = true;

    if (category.type == FoodType.all) {
      filteredFoods.assignAll(AppData.foodItems.obs);
    } else {
      filteredFoods.assignAll(AppData.foodItems.where((item) {
        return item.type == category.type;
      }).toList());
    }
    update();

    filteredFoods.refresh();
  }

  void removeFavoriteFoodFromPrefs_all() {
    prefs.remove('favoriteFood');
  }

  void removeCartFoodFromPrefs_all() {
    prefs.remove('cartFood');
    update();
    saveCartFoodToPrefs();
    update();
  }

  void filterFoodsBySearch(String query) {
    if (query.isEmpty) {
      filteredFoods.assignAll(AppData.foodItems);
    } else {
      filteredFoods.assignAll(AppData.foodItems
          .where(
              (food) => food.name.toLowerCase().contains(query.toLowerCase()))
          .toList());
    }
    update();
  }

  void saveFavoriteFoodToPrefs() {
    List<Map<String, dynamic>> favoriteFoodList =
        favoriteFood.map((food) => food.toJson()).toList();
    String favoriteFoodJson = jsonEncode(favoriteFoodList);
    prefs.setString('favoriteFood', favoriteFoodJson);
    prefs.setBool('favorit', favorite);
  }

  void loadFavoriteFoodFromPrefs() {
    String? favoriteFoodJson = prefs.getString('favoriteFood');
    favorite = prefs.getBool('favorite') ?? false;
    if (favoriteFoodJson != null) {
      List<dynamic> favoriteFoodList = jsonDecode(favoriteFoodJson);
      favoriteFood.assignAll(
          favoriteFoodList.map((foodJson) => Food.fromJson(foodJson)).toList());
    }
  }

  void removeFavoriteFoodFromPrefs(Food food) {
    List<Food> updatedFavoriteFood = List.from(favoriteFood);
    updatedFavoriteFood.removeWhere((element) => element == food);

    // Update the favoriteFood list and save it to SharedPreferences
    favoriteFood.assignAll(updatedFavoriteFood);
    saveFavoriteFoodToPrefs();
  }

  void isFavoriteFood(BuildContext context, Food food) {
    food.isFavorite = !food.isFavorite;
    update();

    if (food.isFavorite) {
      favorite = true;
      favoriteFood.add(food);
      saveFavoriteFoodToPrefs();
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        title: "Success",
        titleSize: 15,
        icon: Icon(
          Icons.favorite,
          size: 28.0,
          color: Colors.redAccent,
        ),
        duration: Duration(seconds: 2),
        margin: EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        backgroundColor: Colors.green,
        messageSize: 15,
        message: "Added to Favorite",
      )..show(context);
    }

    if (!food.isFavorite) {
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        title: "Removed",
        titleSize: 15,
        icon: Icon(
          Icons.remove_circle,
          size: 28.0,
          color: Colors.blue,
        ),
        duration: Duration(seconds: 2),
        margin: EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        backgroundColor: Colors.redAccent,
        messageSize: 15,
        message: "Removed from Favorite",
      )..show(context);
      favorite = false;
      favoriteFood.removeWhere((element) => element == food);
      removeFavoriteFoodFromPrefs(food);
    }
  }

  void removeFromCartAndPrefs(int index) {
    // Remove the food item from the cart
    cartFood.removeAt(index);
    calculateTotalPrice();
    update();
  }

  removeCartItemAtSpecificIndex(int index) {
    cartFood.removeAt(index);
    calculateTotalPrice();
    removeCartFoodFromPrefs_all();
    update();
  }

  void changeTheme() {
    if (theme.value == AppTheme.darkTheme) {
      theme.value = AppTheme.lightTheme;
      isLightTheme = true;
    } else {
      theme.value = AppTheme.darkTheme;
      isLightTheme = false;
    }

    // Save the theme value to SharedPreferences
    prefs.setBool('theme', isLightTheme);

    // Notify listeners to update the UI
    update();
  }
}
