import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:ui' show PointerDeviceKind;
import 'package:IR_RESTAURANT/src/view/screen/home_screen.dart';
import 'package:IR_RESTAURANT/src/controller/food_controller.dart';
import 'package:IR_RESTAURANT/Screens/welcome/welcome_screen.dart';
import 'package:IR_RESTAURANT/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import "./src/view/screen/profile_screen.dart";
import './src/controller/food_controller.dart';

final FoodController controller = Get.put(FoodController());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Get.putAsync(() async => FoodController());
  PreferencesHelper preferencesHelper = PreferencesHelper();
  bool staySignedInValue = await preferencesHelper.getStaySignedIn();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp(
      initialScreen:
          staySignedInValue == true ? HomeScreen() : const WelcomeScreen()));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({Key? key, required this.initialScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      controller.fetch_data_transactions();
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
          },
        ),
        theme: controller.theme.value,
        home: initialScreen,
      );
    });
  }
}
