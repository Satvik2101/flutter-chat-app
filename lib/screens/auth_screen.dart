import 'dart:async';
import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:android_intent/flag.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import '../screens/chat_screen.dart';
import '../widgets/auth/auth_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  late Timer timer;
  bool isLoading = false;

  Future<void> _showEmailVerificationDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Please verify email.'),
          content:
              const Text('Please check your email to verify your account.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Open in email app'),
              onPressed: () {
                if (Platform.isAndroid) {
                  AndroidIntent intent = const AndroidIntent(
                    action: 'android.intent.action.MAIN',
                    category: 'android.intent.category.APP_EMAIL',
                    flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
                  );
                  intent.launch().catchError((e) => print(e));
                } else if (Platform.isIOS) {
                  launch('message://').catchError((e) => print(e));
                }
              },
            )
          ],
        );
      },
    );
  }

  Future<void> _submitAuthForm(String email, String password, String username,
      bool isLogin, BuildContext ctx) async {
    UserCredential userCredential;

    try {
      if (isLogin) {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null && !user.emailVerified) {
        setState(() {
          isLoading = true;
        });
        await user.sendEmailVerification();
        await _showEmailVerificationDialog(context);
        timer = Timer.periodic(const Duration(seconds: 2), (timer) {
          checkEmailVerified();
        });
      } else {
        Navigator.of(context).pushReplacementNamed(ChatScreen.routeName);
      }
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'An error occured'),
          backgroundColor: Theme.of(ctx).errorColor,
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> checkEmailVerified() async {
    User user = _auth.currentUser!;
    await user.reload();
    if (user.emailVerified) {
      Navigator.of(context).pushReplacementNamed(ChatScreen.routeName);
      timer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            )
          : AuthForm(_submitAuthForm),
    );
  }
}
