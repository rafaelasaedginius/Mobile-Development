import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/homepage.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/my_recipe.dart';
import 'screens/recipe_detail.dart';
import 'screens/recipe_form.dart';
import 'screens/profile_screen.dart';
import 'screens/favorite_screen.dart';
import 'services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.jostTextTheme(),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: 'login',
      routes: {
        'home': (context) => HomePage(),
        'register': (context) => RegisterScreen(),
        'login': (context) => LoginScreen(),
        'my_recipe': (context) => MyRecipeScreen(),
        'recipe_form': (context) => RecipeFormScreen(),
        'recipe_detail': (context) => RecipeDetailScreen(),
        'profile': (context) => ProfileScreen(),
        'favorite': (context) => FavoriteScreen(),
      },
    );
  }
}