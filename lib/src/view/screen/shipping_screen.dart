import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './shipping_screen_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class DesaKelurahan {
  final String id;
  final String districtId;
  final String name;

  DesaKelurahan({
    required this.id,
    required this.districtId,
    required this.name,
  });
}

class Kecamatan {
  final String id;
  final String regencyId;
  final String name;

  Kecamatan({
    required this.id,
    required this.regencyId,
    required this.name,
  });
}

class KabupatenKota {
  final String id;
  final String provinceId;
  final String name;

  KabupatenKota({
    required this.id,
    required this.provinceId,
    required this.name,
  });
}

class Province {
  final String id;
  final String name;

  Province({
    required this.id,
    required this.name,
  });
}

class ShippingController extends GetxController {
  late SharedPreferences prefs;

  var kabupatenNama = "".obs;
  var kecamatanNama = "".obs;
  var desaNama = "".obs;

  String kabupaten = "";
  String kecamatan = "";
  String desa = "";

  ShippingController() {
    initSharedPreferences();
  }

  void setKabupatenNama(String value) {
    kabupatenNama.value = value;
    saveDataToSharedPreferences();
    print(kabupatenNama.value);
  }

  void setKecamatanNama(String value) {
    kecamatanNama.value = value;
    saveDataToSharedPreferences();
  }

  void setDesaNama(String value) {
    desaNama.value = value;
    saveDataToSharedPreferences();
  }

  Future<void> initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    kabupatenNama.value = prefs.getString('kabupaten_nama') ?? "";
    kecamatanNama.value = prefs.getString('kecamatan_nama') ?? "";
    desaNama.value = prefs.getString('desa_nama') ?? "";
  }

  Future<void> saveDataToSharedPreferences() async {
    prefs.setString('kabupaten_nama', kabupatenNama.value);
    prefs.setString('kecamatan_nama', kecamatanNama.value);
    prefs.setString('desa_nama', desaNama.value);
  }

  void getkabupaten() {
    print(kabupatenNama.value);
  }

  SharedPreferences getPrefs() {
    return prefs;
  }
}

final ShippingController shippingController = Get.put(ShippingController());

class Shipping_screen extends StatefulWidget {
  @override
  _Shipping_screen createState() => _Shipping_screen();
}

class _Shipping_screen extends State<Shipping_screen> {
  String provinsi_nama = ""; // Initialize with a default value
  String kabupaten_nama = "";
  String kecamatan_nama = "";
  String desa_nama = "";
  List<Province> provinces = [];
  List<KabupatenKota> filteredKabupatenKota = [];
  List<Kecamatan> filteredKecamatan = [];
  List<DesaKelurahan> filteredDesaKelurahan = [];

  String? selectedProvince;
  String? selectedKabupaten;
  String? selectedKecamatan;
  String? selectedDesaKelurahan;

  String? selectedDesaKelurahan2;

  late SharedPreferences prefs;
  _Shipping_screen() {
    shippingController.initSharedPreferences();
  }

  Future<void> fetchKabupatenKota(String provinceId) async {
    final response = await http.get(
      Uri.parse(
          'https://terminator791.github.io/api-wilayah-indonesia/api/regencies/$provinceId.json'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        filteredKabupatenKota = data
            .map((item) => KabupatenKota(
                  id: item['id'],
                  provinceId: item['province_id'],
                  name: item['name'],
                ))
            .toList();
      });
    } else {
      throw Exception('Failed to load kabupaten/kota');
    }
  }

  Future<void> fetchKecamatan(String regencyId) async {
    final response = await http.get(
      Uri.parse(
          'https://terminator791.github.io/api-wilayah-indonesia/api/districts/$regencyId.json'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        filteredKecamatan = data
            .map((item) => Kecamatan(
                  id: item['id'],
                  regencyId: item['regency_id'],
                  name: item['name'],
                ))
            .toList();
      });
    } else {
      throw Exception('Failed to load kecamatan');
    }
  }

  Future<void> fetchDesaKelurahan(String districtId) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://terminator791.github.io/api-wilayah-indonesia/api/villages/$districtId.json',
        ),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          filteredDesaKelurahan = data
              .map((item) => DesaKelurahan(
                    id: item['id'],
                    districtId: item['district_id'],
                    name: item['name'],
                  ))
              .toList();
        });
      } else {
        throw Exception('Failed to load desa/kelurahan');
      }
    } catch (error) {
      print('Error fetching desa/kelurahan: $error');
    }
  }

  @override
  void initState() {
    shippingController.initSharedPreferences();
    super.initState();
    fetchProvinces();
  }

  Future<void> fetchProvinces() async {
    final response = await http.get(
      Uri.parse(
          'https://terminator791.github.io/api-wilayah-indonesia/api/provinces.json'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        provinces = data
            .map((item) => Province(id: item['id'], name: item['name']))
            .toList();
      });
    } else {
      throw Exception('Failed to load provinces');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            // Navigate to the home screen or any other screen you desire
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      CartScreen()), // Replace HomeScreen with the desired screen
            );
          },
          child: Icon(Icons.arrow_back),
        ),
        title: Text('SHIPPING ADDRESS'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih Provinsi:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedProvince,
              onChanged: (String? newValue) {
                setState(() {
                  selectedProvince = newValue;
                  fetchKabupatenKota(selectedProvince!);
                  selectedKabupaten = null;
                  filteredKecamatan = [];
                  selectedDesaKelurahan = null;
                  filteredDesaKelurahan = [];
                  provinsi_nama = selectedProvince != null
                      ? provinces
                          .where((province) => province.id == selectedProvince)
                          .first
                          .name
                      : "-";
                  prefs.setString('provinsi_nama', provinsi_nama);
                });
              },
              items: provinces.map<DropdownMenuItem<String>>(
                (Province province) {
                  return DropdownMenuItem<String>(
                    value: province.id,
                    child: Text(province.name),
                  );
                },
              ).toList(),
            ),
            SizedBox(height: 20),
            Text(
              'Kabupaten/Kota Terpilih:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedKabupaten,
              onChanged: (String? newValue) {
                setState(() {
                  selectedKabupaten = newValue;
                  fetchKecamatan(selectedKabupaten!);
                  selectedKecamatan = null;
                  filteredDesaKelurahan = [];
                  kabupaten_nama = selectedKabupaten != null
                      ? filteredKabupatenKota
                          .where((d) => d.id == selectedKabupaten)
                          .first
                          .name
                      : "-";
                  prefs.setString('kabupaten_nama', kabupaten_nama) ?? "-";
                });
              },
              items: filteredKabupatenKota.map<DropdownMenuItem<String>>(
                (KabupatenKota kabupatenKota) {
                  return DropdownMenuItem<String>(
                    value: kabupatenKota.id,
                    child: Text(kabupatenKota.name),
                  );
                },
              ).toList(),
            ),
            SizedBox(height: 20),
            Text(
              'Kecamatan Terpilih:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedKecamatan,
              onChanged: (String? newValue) {
                setState(() {
                  selectedKecamatan = newValue;
                  fetchDesaKelurahan(selectedKecamatan!);
                  selectedDesaKelurahan = null;
                  kecamatan_nama = selectedKecamatan != null
                      ? filteredKecamatan
                          .where((d) => d.id == selectedKecamatan)
                          .first
                          .name
                      : "-";
                  prefs.setString('kecamatan_nama', kecamatan_nama) ?? "-";
                });
              },
              items: filteredKecamatan.map<DropdownMenuItem<String>>(
                (Kecamatan kecamatan) {
                  return DropdownMenuItem<String>(
                    value: kecamatan.id,
                    child: Text(kecamatan.name),
                  );
                },
              ).toList(),
            ),
            Text(
              'Kecamatan Terpilih: $kecamatan_nama',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Desa/Kelurahan Terpilih:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedDesaKelurahan,
              onChanged: (String? newValue) {
                setState(() {
                  selectedDesaKelurahan = newValue;

                  if (selectedDesaKelurahan != null) {
                    DesaKelurahan selectedDesa = filteredDesaKelurahan
                        .firstWhere((d) => d.id == selectedDesaKelurahan,
                            orElse: () => DesaKelurahan(
                                id: '', districtId: '', name: '-'));
                    desa_nama = selectedDesa.name;
                  } else {
                    desa_nama = '-';
                  }
                });
              },
              items: filteredDesaKelurahan.map<DropdownMenuItem<String>>(
                (DesaKelurahan desaKelurahan) {
                  return DropdownMenuItem<String>(
                    value: desaKelurahan.id,
                    child: Text(desaKelurahan.name),
                  );
                },
              ).toList(),
            ),
            SizedBox(height: 20),
            Text(
              'Desa/Kelurahan Terpilih: $desa_nama',
              style: TextStyle(fontSize: 16),
            ),
            ElevatedButton(
              onPressed: () async {
                print(kabupaten_nama);
                shippingController.setKabupatenNama(kabupaten_nama);
                shippingController.setKecamatanNama(kecamatan_nama);
                shippingController.setDesaNama(desa_nama);
                shippingController.getkabupaten();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartScreen(),
                  ),
                );
              },
              child: Text(
                'Save',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
