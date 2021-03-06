import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import './screens/auth_screen.dart';
import './screens/chat_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (ctx, appSnapshot) => MaterialApp(
        
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          backgroundColor: Colors.red[100],
          accentColor: Colors.purpleAccent[700],
          accentColorBrightness: Brightness.dark,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              primary: Colors.purple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        routes: {
          ChatScreen.routeName: (ctx) => const ChatScreen(),
        },
        home: appSnapshot.connectionState == ConnectionState.waiting
            ? const Scaffold(
            
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : StreamBuilder(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (ctx, AsyncSnapshot<User?> userSnapshot) {
                  if (userSnapshot.hasData &&
                      !userSnapshot.hasError &&
                      (userSnapshot.data?.emailVerified ?? false))
                    return const ChatScreen();
                  else
                    return const AuthScreen();
                },
              ),
      ),
    );
  }
}
