import 'dart:io';

import 'package:flutter/material.dart';

import '../pickers/user_image_picker.dart';

class AuthForm extends StatefulWidget {
  const AuthForm(this.submitFn, this.isLoading, {Key? key}) : super(key: key);

  final void Function(
    String email,
    String password,
    String username,
    File? image,
    bool isLogin,
    BuildContext ctx,
  ) submitFn;
  final bool isLoading;
  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String _userEmail = '';
  String _userName = '';
  String _userPassword = '';
  bool _isLogin = true;
  File? _userImageFile;

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  void _trySubmit() {
    final curFormState = _formKey.currentState;
    if (curFormState == null) return;

    final isValid = curFormState.validate();
    FocusScope.of(context).unfocus();

    if (!_isLogin && _userImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).errorColor,
          content: const Text('Please select an image'),
        ),
      );
      return;
    }

    if (isValid) {
      curFormState.save();
      widget.submitFn(
        _userEmail.trim(),
        _userPassword,
        _userName.trim(),
        _userImageFile,
        _isLogin,
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: AnimatedSize(
                vsync: this,
                duration: const Duration(milliseconds: 300),
                curve: Curves.linear,
                child: Column(
                  //key: ValueKey(_isLogin),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      reverseDuration: const Duration(milliseconds: 100),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) =>
                              FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: animation.drive(
                            Tween(
                              begin: const Offset(0, -0.5),
                              end: const Offset(0, 0),
                            ),
                          ),
                          child: Center(child: child),
                        ),
                      ),
                      child: _isLogin
                          ? const SizedBox(
                              height: 0,
                            )
                          : Center(child: UserImagePicker(_pickedImage)),
                    ),
                    //Email address input
                    TextFormField(
                      key: const ValueKey('email'),
                      validator: (enteredEmail) {
                        if (enteredEmail == null || enteredEmail.isEmpty) {
                          return 'Email cannot be empty!';
                        }
                        if (!enteredEmail.contains('@')) {
                          return 'Invalid email!';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                      ),
                      onSaved: (value) {
                        _userEmail = value ?? '';
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    //Username input
                    if (!_isLogin)
                      TextFormField(
                        key: const ValueKey('username'),
                        validator: (enteredUsername) {
                          if (enteredUsername == null ||
                              enteredUsername.isEmpty) {
                            return 'Username cannot be empty';
                          }
                          if (enteredUsername.length < 4) {
                            return 'Username must be at least 4 characters long';
                          }
                          return null;
                        },
                        decoration:
                            const InputDecoration(labelText: 'Username'),
                        onSaved: (value) {
                          _userName = value ?? '';
                        },
                        textInputAction: TextInputAction.next,
                      ),
                    //Password Input
                    TextFormField(
                      key: const ValueKey('password'),
                      validator: (enteredPassword) {
                        if (enteredPassword == null ||
                            enteredPassword.isEmpty) {
                          return 'Password cannot be empty';
                        }
                        if (enteredPassword.length < 7) {
                          return 'Password must be at least 7 characters long';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Password',
                      ),
                      obscureText: true,
                      onSaved: (value) {
                        _userPassword = value ?? '';
                      },
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 12),
                    if (!widget.isLoading)
                      ElevatedButton(
                        child: Text(_isLogin ? 'Login' : 'Sign Up'),
                        onPressed: _trySubmit,
                      ),
                    if (!widget.isLoading)
                      TextButton(
                        child: Text(
                          _isLogin
                              ? 'Create new account'
                              : 'Login to an existing account',
                        ),
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                        style: TextButton.styleFrom(
                          primary: Theme.of(context).primaryColor,
                        ),
                      ),
                    if (widget.isLoading) const CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
