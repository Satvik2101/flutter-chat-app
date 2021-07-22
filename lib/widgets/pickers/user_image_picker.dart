import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker(this.pickedImageFunction, {Key? key}) : super(key: key);

  final void Function(File) pickedImageFunction;

  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImage;
  void _pickImage() async {
    final picker = ImagePicker();
    // pickedImage = await picker.getImage(
    //   source: ImageSource.gallery,
    //   imageQuality: 50,
    //   maxWidth: 150,
    // );
    final pickedImage = await picker.pickImage(source: ImageSource.camera);
    if (pickedImage == null) return;
    final pickedImageFile = File(pickedImage.path);
    setState(() {
      _pickedImage = pickedImageFile;
    });
    widget.pickedImageFunction(pickedImageFile);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          backgroundImage:
              _pickedImage == null ? null : FileImage(_pickedImage!),
        ),
        TextButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.image),
          label: const Text('Add image'),
        ),
      ],
    );
  }
}
