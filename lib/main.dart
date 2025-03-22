import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:work_manager/appColor.dart';
import 'package:work_manager/main_screen.dart';
import 'package:work_manager/models/boxes.dart';
import 'package:work_manager/models/profile.dart';
import 'package:work_manager/models/shift.dart';
import 'package:work_manager/screens/profile_screen.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(ProfileAdapter());
  Hive.registerAdapter(ShiftAdapter());
  profileBox = await Hive.openBox<Profile>("profiles");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Work Manager',
      theme: ThemeData(
        textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
        primaryColor: appColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: appColor,
          brightness: Brightness.light,
        ),

        useMaterial3: true,
      ),
      home:
          profileBox.values.isEmpty
              ? ProfileScreen(profileName: "", title: "Ajouter nouveau profil")
              : MainScreen(currentIndex: 1),
    );
  }
}
