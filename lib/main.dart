import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swift_scanner/provider/theme_provider.dart';

import 'screens/splash_screen.dart';
import 'screens/user_state.dart';

void main() async {
  // await Firebase.initializeApp();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeProvider themeChangeProvider = ThemeProvider();

  final Future<FirebaseApp> _firebaseInitialization = Firebase.initializeApp();

  void getCurrentTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.themePreferences.getTheme();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentTheme();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          return themeChangeProvider;
        })
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeData, child) {
          return MaterialApp(
            title: 'Swift Scanner',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              appBarTheme: AppBarTheme(
                color: Color(0xFF248EA9),
              ),
              primaryColor: Color(0xFF248EA9),
              colorScheme: ColorScheme.fromSwatch()
                  .copyWith(secondary: Color(0xFF7579E7)),
            ),
            home: const SplashScreen(),
            routes: {
              UserState.routeName: (ctx) => const UserState(),
              // LandingScreen.routeName: (ctx) => const LandingScreen(),
              // BottomBarScreen.routeName: (ctx) => const BottomBarScreen(),
              // LoginScreen.routeName: (ctx) => const LoginScreen(),
              // SignUpScreen.routeName: (ctx) => const SignUpScreen(),
              // ForgotPasswordScreen.routeName: (ctx) => const ForgotPasswordScreen(),
              // SearchScreen.routeName: (ctx) => const SearchScreen(),
            },
          );
        },
      ),
    );
  }
}
