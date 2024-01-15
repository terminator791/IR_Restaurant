import 'package:flutter/material.dart';
import 'package:IR_RESTAURANT/src/view/screen/home_screen.dart';
import './shipping_screen.dart'; // Import the shipping screen class
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../../controller/food_controller.dart';

final ShippingController shippingController = Get.put(ShippingController());

class CartScreen extends StatelessWidget {
  String? selectedProvince;
  String? selectedKabupaten;
  String? selectedKecamatan;
  String? selectedDesaKelurahan;

  CartScreen() {
    getForm();
    shippingController.initSharedPreferences();
  }

  void getForm() {
    selectedKabupaten = shippingController.kabupatenNama.value;
    selectedKecamatan = shippingController.kecamatanNama.value;
    selectedDesaKelurahan = shippingController.desaNama.value;
  }

  @override
  Widget build(BuildContext context) {
    selectedKabupaten = shippingController.kabupatenNama.value;
    selectedKecamatan = shippingController.kecamatanNama.value;
    selectedDesaKelurahan = shippingController.desaNama.value;
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            // Navigate to the home screen or any other screen you desire
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      HomeScreen()), // Replace HomeScreen with the desired screen
            );
          },
          child: Icon(Icons.home),
        ),
        title: Text('Cart'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (selectedKabupaten == null ||
                selectedKecamatan == null ||
                selectedDesaKelurahan == null)
              ElevatedButton(
                onPressed: () {
                  // Navigate to the Shipping_screen for adding address
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Shipping_screen()),
                  );
                },
                child: Text(
                  'Add Address',
                  style: TextStyle(fontSize: 18),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alamat Terpilih:',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text('Kabupaten/Kota: $selectedKabupaten'),
                  Text('Kecamatan: $selectedKecamatan'),
                  Text('Kecamatan: $selectedDesaKelurahan'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate back to the Shipping_screen for updating the address
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Shipping_screen()),
                      );
                    },
                    child: Text(
                      'Update Address',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
