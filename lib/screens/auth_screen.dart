import 'dart:async';
import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:android_intent/flag.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../widgets/auth/auth_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  Timer timer = Timer(Duration.zero, () {});
  bool isLoading = false;

  Future<void> _showEmailVerificationDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Please verify email.'),
          content: const Text(
              'Please check your email to verify your account.(It may take a few minutes to arrive)'),
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

  Future<void> _submitAuthForm(
    String email,
    String password,
    String username,
    File? image,
    bool isLogin,
    BuildContext ctx,
  ) async {
    UserCredential userCredential;
    setState(() {
      isLoading = true;
    });
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

        final ref = FirebaseStorage.instance
            .ref()
            .child('user-images')
            .child(userCredential.user!.uid + '.jpg');

        await ref.putFile(image!);
        final url = await ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(
          {
            'username': username,
            'email': email,
            'image_url': url,
          },
        );
      }

      User? user = FirebaseAuth.instance.currentUser;

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        await _showEmailVerificationDialog(context);
        timer = Timer.periodic(const Duration(seconds: 2), (timer) {
          checkEmailVerified(email, password);
        });
      }
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
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

  Future<void> checkEmailVerified(String email, String password) async {
    User user = _auth.currentUser!;
    await user.reload();
    if (user.emailVerified) {
      FirebaseAuth.instance.signOut();
      FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      timer.cancel();
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthForm(_submitAuthForm, isLoading),
    );
  }
}
