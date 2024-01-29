import 'package:ayomasak_2/screens/getstarted.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'screens/login.dart';
import 'screens/loginregister.dart';
import 'screens/navbar.dart';
import 'screens/register.dart';
import 'styles/color.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var auth = FirebaseAuth.instance;
  var isLogin = false;

  checkIfLogin() async {
    auth.authStateChanges().listen((User? user) {
      if (user != null && mounted) {
        setState(() {
          isLogin = true;
        });
      }
    });
  }

  @override
  void initState() {
    checkIfLogin();
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
          scaffoldBackgroundColor: greyBackground,
          colorScheme: ColorScheme.fromSeed(seedColor: greenPrimary),
          useMaterial3: true,
          fontFamily: "Inter"),
      home: isLogin ? const Navbar() : const GetStarted(),
      routes: {
        '/loginregister': (context) => const LoginRegister(),
        '/register': (context) => const Register(),
        '/login': (context) => const Login(),
        '/navbar': (context) => const Navbar()
      },
    );
  }
}
