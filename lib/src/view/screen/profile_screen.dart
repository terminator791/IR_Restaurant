import 'package:flutter/material.dart';
import 'package:IR_RESTAURANT/core/app_asset.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:IR_RESTAURANT/src/view/screen/shipping_screen.dart';
import 'package:IR_RESTAURANT/src/view/widget/food_list_view.dart';
import '../../../Screens/welcome/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Screens/Login/login_screen.dart';
import '../../controller/food_controller.dart';
import './shipping_screen_card.dart';
import '../screen/home_screen.dart';

class PreferencesHelper {
  Future<bool> getStaySignedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String selectedProfileImage =
        prefs.getString('profileImage') ?? "profile1.png";
    bool staySignedIn = prefs.getBool('staySignedIn') ?? false;
    return staySignedIn;
  }
}

class FirebaseAuthHelper {
  static FirebaseAuth _auth = FirebaseAuth.instance;

  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  static bool isUserLoggedIn() {
    User? user = getCurrentUser();
    return user != null;
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late SharedPreferences prefs;
  bool staySignedIn = false;
  String selectedProfileImage =
      "profile1.png"; // Default selected profile image

  final List<String> profileImages = [
    "profile1.png",
    "profile2.png",
    "profile3.png",
    // Add more profile images as needed
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      staySignedIn = prefs.getBool('staySignedIn') ?? false;
      selectedProfileImage = prefs.getString('profileImage') ?? "profile1.png";
    });
  }

  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      _savePreferences(false);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const WelcomeScreen()));
    } catch (e) {
      print("Error during logout: $e");
    }
  }

  void _savePreferences(bool value) {
    prefs.setBool('staySignedIn', value);
  }

  void _changeProfilePicture(String profileImage) {
    setState(() {
      selectedProfileImage = profileImage;
      prefs.setString('profileImage', selectedProfileImage);
    });
  }

  List<Widget> buildProfileImageGrid() {
    return profileImages.map((image) {
      return GestureDetector(
        onTap: () => _changeProfilePicture(image),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: AssetImage("assets/profile/$image"),
            radius: 30,
            backgroundColor: selectedProfileImage == image
                ? Colors.blue // Highlight the selected profile picture
                : Colors.transparent,
          ),
        ),
      );
    }).toList();
  }

  List<Widget> buildAppBarActions() {
    if (FirebaseAuthHelper.isUserLoggedIn()) {
      return [
        GestureDetector(
          onTap: () {
            // Implement any action when the main profile picture is tapped.
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CircleAvatar(
              backgroundImage:
                  AssetImage("assets/profile/$selectedProfileImage"),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: () => _logout(context),
        ),
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            // Implement any action when the settings icon is tapped.
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CartScreen(),
              ),
            );
          },
        ),
      ];
    } else {
      return [
        IconButton(
          icon: Icon(Icons.login),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => LoginScreen(),
              ),
            );
          },
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String email = user?.email ?? "Guest";
    String displayName = user?.displayName ?? "Guest";

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ),
            );
          },
          child: Icon(Icons.home),
        ),
        title: const Text('Profile'),
        actions: buildAppBarActions(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundImage:
                        AssetImage("assets/profile/$selectedProfileImage"),
                    radius: 80,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Hello $displayName!",
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.email),
                      const SizedBox(width: 10),
                      Text(
                        "$email",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: buildProfileImageGrid(),
            ),
            if (FirebaseAuthHelper.isUserLoggedIn())
              Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Stay Signed In"),
                      Switch(
                        value: staySignedIn,
                        onChanged: (value) {
                          setState(() {
                            staySignedIn = value;
                            _savePreferences(value);
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
